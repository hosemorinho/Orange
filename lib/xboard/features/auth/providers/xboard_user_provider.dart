import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/features/auth/auth.dart';
import 'package:fl_clash/xboard/services/services.dart';
import 'package:fl_clash/xboard/features/profile/providers/profile_import_provider.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/infrastructure/api/api.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/adapter/state/user_state.dart';
import 'package:fl_clash/xboard/adapter/state/subscription_state.dart';

// 初始化文件级日志器
final _logger = FileLogger('xboard_user_provider.dart');

// 使用领域模型
final userInfoProvider = StateProvider<DomainUser?>((ref) => null);
final subscriptionInfoProvider = StateProvider<DomainSubscription?>((ref) => null);
final userUIStateProvider = StateProvider<UIState>((ref) => const UIState());
class XBoardUserAuthNotifier extends Notifier<UserAuthState> {
  late final XBoardStorageService _storageService;

  @override
  UserAuthState build() {
    _storageService = ref.read(storageServiceProvider);
    return const UserAuthState();
  }
  Future<bool> quickAuth() async {
    try {
      _logger.info('快速认证检查：检查登录状态...');
      final hasToken = await V2BoardTokenStorage.hasToken()
          .timeout(const Duration(seconds: 5), onTimeout: () {
        _logger.info('快速认证超时，假设无token');
        return false;
      });

      if (hasToken) {
        String? email;
        DomainUser? userInfo;
        DomainSubscription? subscriptionInfo;
        try {
          final emailResult = await _storageService.getUserEmail()
              .timeout(const Duration(seconds: 2));
          email = emailResult.dataOrNull;

          final userInfoResult = await _storageService.getDomainUser()
              .timeout(const Duration(seconds: 2));
          userInfo = userInfoResult.dataOrNull;

          final subscriptionInfoResult = await _storageService.getDomainSubscription()
              .timeout(const Duration(seconds: 2));
          subscriptionInfo = subscriptionInfoResult.dataOrNull;
        } catch (e) {
          _logger.info('获取缓存数据失败，但继续进行认证: $e');
        }

        state = state.copyWith(
          isAuthenticated: true,
          isInitialized: true,
          email: email,
        );

        if (userInfo != null) {
          ref.read(userInfoProvider.notifier).state = userInfo;
        }
        if (subscriptionInfo != null) {
          ref.read(subscriptionInfoProvider.notifier).state = subscriptionInfo;
        }

        _logger.info('快速认证成功：已有token，直接进入主界面. isInitialized: ${state.isInitialized}');
        _backgroundTokenValidation();

        // 启动时自动导入订阅
        if (subscriptionInfo?.subscribeUrl?.isNotEmpty == true) {
          _logger.info('启动时自动导入订阅: ${subscriptionInfo!.subscribeUrl}');
          ref.read(profileImportProvider.notifier).importSubscription(subscriptionInfo.subscribeUrl);
        }

        return true;
      } else {
        _logger.info('快速认证：无本地token，显示登录页面. isInitialized: ${state.isInitialized}');
        state = state.copyWith(isInitialized: true);
        return false;
      }
    } catch (e) {
      _logger.info('快速认证失败: $e');
      state = state.copyWith(isInitialized: true);
      _logger.info('快速认证失败: $e. isInitialized: ${state.isInitialized}');
      return false;
    } finally {
      if (!state.isInitialized) {
        _logger.info('强制设置初始化状态为true. isInitialized: ${state.isInitialized}');
        state = state.copyWith(isInitialized: true);
      }
    }
  }
  void _backgroundTokenValidation() {
    Future.delayed(const Duration(milliseconds: 1000), () async {
      try {
        _logger.info('后台验证token有效性...');
        // 使用 getUserInfo 验证 token
        try {
          await ref.read(getUserInfoProvider.future);
          _logger.info('Token验证成功，静默更新用户数据');
          _silentUpdateUserData();
        } catch (e) {
          _logger.info('Token验证失败，显示登录过期提示: $e');
          _showTokenExpiredDialog();
        }
      } catch (e) {
        _logger.info('后台token验证异常: $e');
      }
    });
  }
  Future<void> _silentUpdateUserData() async {
    try {
      // 获取订阅信息
      ref.invalidate(getSubscriptionProvider);
      final subscriptionData = await ref.read(getSubscriptionProvider.future);

      // 获取用户信息
      try {
        ref.invalidate(getUserInfoProvider);
        final userInfoData = await ref.read(getUserInfoProvider.future);

        await _storageService.saveDomainUser(userInfoData);
        ref.read(userInfoProvider.notifier).state = userInfoData;
      } catch (e) {
        _logger.info('静默更新用户信息失败: $e');
      }

      await _storageService.saveDomainSubscription(subscriptionData);
      ref.read(subscriptionInfoProvider.notifier).state = subscriptionData;

      if (subscriptionData.subscribeUrl.isNotEmpty) {
        _logger.info('[后台验证] 开始自动导入订阅配置: ${subscriptionData.subscribeUrl}');
        ref.read(profileImportProvider.notifier).importSubscription(subscriptionData.subscribeUrl);
      } else {
        _logger.info('[后台验证] 订阅URL为空，跳过配置导入');
      }

      _logger.info('静默更新用户数据完成');
    } catch (e) {
      _logger.info('静默更新用户数据失败: $e');
    }
  }
  void _showTokenExpiredDialog() {
    state = state.copyWith(
      errorMessage: 'TOKEN_EXPIRED', // 特殊标记，UI层检测到后显示对话框
    );
  }
  void clearTokenExpiredError() {
    if (state.errorMessage == 'TOKEN_EXPIRED') {
      state = state.copyWith(errorMessage: null);
    }
  }
  Future<void> handleTokenExpired() async {
    _logger.info('处理token过期，清除认证状态');
    try {
      final api = await ref.read(xboardSdkProvider.future);
      await api.clearToken();
    } catch (e) {
      _logger.info('清除token失败: $e');
      await V2BoardTokenStorage.clearAuth();
    }
    await _storageService.clearAuthData();
    state = const UserAuthState(isInitialized: true);
  }
  Future<bool> autoAuth() async {
    return await quickAuth();
  }
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      _logger.info('开始登录: $email');

      final api = await ref.read(xboardSdkProvider.future);
      final json = await api.login(email, password);
      final data = json['data'] as Map<String, dynamic>? ?? {};
      final token = data['token'] as String?;

      if (token == null || token.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '登录失败',
        );
        return false;
      }

      await api.saveAndSetToken(token);

      _logger.info('登录成功，立即获取用户信息');
      await _storageService.saveUserEmail(email);

      // 获取用户信息和订阅信息
      try {
        _logger.info('开始获取用户信息...');
        ref.invalidate(getUserInfoProvider);
        final userInfo = await ref.read(getUserInfoProvider.future);

        _logger.info('用户信息API调用完成');
        ref.read(userInfoProvider.notifier).state = userInfo;
        await _storageService.saveDomainUser(userInfo);
        _logger.info('用户信息已保存: ${userInfo.email}');

        _logger.info('开始获取订阅信息...');
        ref.invalidate(getSubscriptionProvider);
        final subscriptionInfo = await ref.read(getSubscriptionProvider.future);

        _logger.info('订阅信息API调用完成');
        ref.read(subscriptionInfoProvider.notifier).state = subscriptionInfo;
        await _storageService.saveDomainSubscription(subscriptionInfo);
        _logger.info('订阅信息已保存，subscribeUrl: ${subscriptionInfo.subscribeUrl}');

        // 登录成功后自动导入订阅配置
        if (subscriptionInfo.subscribeUrl.isNotEmpty) {
          _logger.info('[登录成功] 开始自动导入订阅配置: ${subscriptionInfo.subscribeUrl}');
          ref.read(profileImportProvider.notifier).importSubscription(subscriptionInfo.subscribeUrl);
        } else {
          _logger.info('[登录成功] 订阅URL为空，跳过配置导入');
        }
      } catch (e, stackTrace) {
        _logger.info('获取用户/订阅信息失败，但继续登录: $e');
        _logger.info('错误堆栈: $stackTrace');
      }

        _logger.info('准备更新状态...');
        final newState = state.copyWith(
          isAuthenticated: true,
          isInitialized: true,
          email: email,
          isLoading: false,
        );
        state = newState;
        _logger.info('===== 认证状态已更新! =====');
        _logger.info('isAuthenticated: ${state.isAuthenticated}');
        _logger.info('isInitialized: ${state.isInitialized}');
        _logger.info('email: ${state.email}');
        _logger.info('===========================');

        return true;
    } catch (e) {
      _logger.info('登录出错: $e');
      String errorMessage = '登录失败';
      if (e is V2BoardApiException) {
        errorMessage = e.message;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      return false;
    }
  }
  Future<bool> register(String email, String password, String? inviteCode, String emailCode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      _logger.info('开始注册: $email');

      final api = await ref.read(xboardSdkProvider.future);
      final json = await api.register(
        email,
        password,
        inviteCode: inviteCode,
        emailCode: emailCode,
      );

      // V2Board register returns token on success
      final data = json['data'] as Map<String, dynamic>? ?? {};
      final token = data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await api.saveAndSetToken(token);
      }

      _logger.info('注册成功');
      await _storageService.saveUserEmail(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      _logger.info('注册出错: $e');
      String errorMessage = '注册失败';
      if (e is V2BoardApiException) {
        errorMessage = e.message;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      return false;
    }
  }
  Future<bool> sendVerificationCode(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      _logger.info('发送验证码到: $email');
      final api = await ref.read(xboardSdkProvider.future);
      await api.sendEmailVerify(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      _logger.info('发送验证码出错: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
  Future<bool> resetPassword(String email, String password, String emailCode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      _logger.info('重置密码: $email');

      final api = await ref.read(xboardSdkProvider.future);
      await api.forget(email, emailCode, password);

      _logger.info('密码重置成功');
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      _logger.info('重置密码出错: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
  Future<void> refreshSubscriptionInfoAfterPayment() async {
    if (!state.isAuthenticated) {
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      _logger.info('刷新订阅信息...');

      DomainUser? userInfo;
      DomainSubscription? subscriptionData;

      try {
        ref.invalidate(getUserInfoProvider);
        userInfo = await ref.read(getUserInfoProvider.future);
        if (userInfo != null) {
          await _storageService.saveDomainUser(userInfo!);
        }
        ref.read(userInfoProvider.notifier).state = userInfo;
      } catch (e) {
        _logger.info('获取用户详细信息失败: $e');
      }

      try {
        ref.invalidate(getSubscriptionProvider);
        subscriptionData = await ref.read(getSubscriptionProvider.future);
        if (subscriptionData != null) {
          await _storageService.saveDomainSubscription(subscriptionData!);
        }
        ref.read(subscriptionInfoProvider.notifier).state = subscriptionData;
      } catch (e) {
        _logger.info('获取订阅信息失败: $e');
      }

      state = state.copyWith(
        userInfo: userInfo,
        subscriptionInfo: subscriptionData,
        isLoading: false,
      );
      _logger.info('订阅信息已刷新');

      if (subscriptionData?.subscribeUrl.isNotEmpty == true) {
        _logger.info('[支付成功] 开始重新导入订阅配置: ${subscriptionData!.subscribeUrl}');
        _logger.info('[支付成功] 使用强制刷新模式，跳过重复检测');
        ref.read(profileImportProvider.notifier).importSubscription(
          subscriptionData.subscribeUrl,
          forceRefresh: true,
        );
      } else {
        _logger.info('[支付成功] 订阅链接为空，跳过重新导入');
      }
    } catch (e) {
      _logger.info('刷新订阅信息出错: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshSubscriptionInfo() async {
    if (!state.isAuthenticated) {
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      _logger.info('刷新订阅信息...');

      DomainUser? userInfo;
      DomainSubscription? subscriptionData;

      try {
        ref.invalidate(getUserInfoProvider);
        userInfo = await ref.read(getUserInfoProvider.future);
        if (userInfo != null) {
          await _storageService.saveDomainUser(userInfo!);
        }
        ref.read(userInfoProvider.notifier).state = userInfo;
      } catch (e) {
        _logger.info('获取用户详细信息失败: $e');
      }

      try {
        ref.invalidate(getSubscriptionProvider);
        subscriptionData = await ref.read(getSubscriptionProvider.future);
        if (subscriptionData != null) {
          await _storageService.saveDomainSubscription(subscriptionData!);
        }
        ref.read(subscriptionInfoProvider.notifier).state = subscriptionData;
      } catch (e) {
        _logger.info('获取订阅信息失败: $e');
      }

      state = state.copyWith(
        userInfo: userInfo,
        subscriptionInfo: subscriptionData,
        isLoading: false,
      );
      _logger.info('订阅信息已刷新');

      // 触发订阅导入流程
      if (subscriptionData?.subscribeUrl.isNotEmpty == true) {
        _logger.info('[手动刷新] 开始导入订阅配置: ${subscriptionData!.subscribeUrl}');
        _logger.info('[手动刷新] 使用强制刷新模式，跳过重复检测');
        ref.read(profileImportProvider.notifier).importSubscription(
          subscriptionData.subscribeUrl,
          forceRefresh: true,
        );
      } else {
        _logger.info('[手动刷新] 订阅链接为空，跳过导入');
      }
    } catch (e) {
      _logger.info('刷新订阅信息出错: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  Future<void> refreshUserInfo() async {
    if (!state.isAuthenticated) {
      return;
    }
    try {
      _logger.info('刷新用户详细信息...');

      ref.invalidate(getUserInfoProvider);
      final userInfoData = await ref.read(getUserInfoProvider.future);

      await _storageService.saveDomainUser(userInfoData);
      ref.read(userInfoProvider.notifier).state = userInfoData;
      state = state.copyWith(userInfo: userInfoData);
      _logger.info('用户详细信息已刷新');
    } catch (e) {
      _logger.info('刷新用户详细信息出错: $e');
    }
  }
  Future<void> logout() async {
    _logger.info('用户登出');

    try {
      final api = await ref.read(xboardSdkProvider.future);
      await api.logout();
      await api.clearToken();
    } catch (e) {
      _logger.info('登出API调用失败: $e');
      await V2BoardTokenStorage.clearAuth();
    }
    await _storageService.clearAuthData();

    state = const UserAuthState(
      isInitialized: true, // 登出后保持初始化状态，只重置认证信息
    );
  }
  /// 强制设置 isInitialized = true
  /// 用于初始化流程完全失败时的兜底，确保路由不会卡在 /loading
  void forceInitialized() {
    if (!state.isInitialized) {
      _logger.info('强制设置 isInitialized = true（兜底）');
      state = state.copyWith(isInitialized: true);
    }
  }

  String? get currentAuthToken => null; // Token管理已委托给API Service
  bool get isAuthenticated => state.isAuthenticated;
  String? get currentEmail => state.email;
}
final xboardUserAuthProvider = NotifierProvider<XBoardUserAuthNotifier, UserAuthState>(
  XBoardUserAuthNotifier.new,
);
final xboardUserProvider = xboardUserAuthProvider;
extension UserInfoHelpers on WidgetRef {
  DomainUser? get userInfo => read(userInfoProvider);
  DomainSubscription? get subscriptionInfo => read(subscriptionInfoProvider);
  UserAuthState get userAuthState => read(xboardUserAuthProvider);
  bool get isAuthenticated => read(xboardUserAuthProvider).isAuthenticated;
}
