/// 离线读模型 Provider（简化版）
///
/// 提供离线最小可用的数据快照：
/// - 用户信息（邮箱、套餐、到期时间）
/// - 订阅摘要（流量、设备数）
///
/// UI 层优先读取离线数据，网络成功后更新。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/services/storage/xboard_storage_service.dart';
import 'package:fl_clash/xboard/services/storage/xboard_storage_provider.dart';

final _logger = FileLogger('offline_model_provider.dart');

/// 离线读模型状态
class OfflineModelState {
  final DomainUser? user;
  final DomainSubscription? subscription;
  final bool isOffline;
  final DateTime? lastSyncAt;

  const OfflineModelState({
    this.user,
    this.subscription,
    this.isOffline = false,
    this.lastSyncAt,
  });

  /// 是否有任何数据
  bool get hasAnyData => user != null || subscription != null;

  /// 是否有订阅数据
  bool get hasSubscription => subscription != null;

  /// 是否有用户数据
  bool get hasUser => user != null;

  OfflineModelState copyWith({
    DomainUser? user,
    DomainSubscription? subscription,
    bool? isOffline,
    DateTime? lastSyncAt,
  }) {
    return OfflineModelState(
      user: user ?? this.user,
      subscription: subscription ?? this.subscription,
      isOffline: isOffline ?? this.isOffline,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  @override
  String toString() =>
      'OfflineModelState(user: ${user?.email}, subscription: ${subscription?.planId}, isOffline: $isOffline)';
}

/// 离线读模型 Provider
///
/// 使用方式：
/// ```dart
/// final offlineState = ref.watch(offlineModelProvider);
/// if (offlineState.isOffline) {
///   // 显示离线标识
/// }
/// ```
final offlineModelProvider = Provider<OfflineModelState>(
  (ref) => ref.watch(offlineModelNotifierProvider),
);

/// 离线读模型 Notifier
class OfflineModelNotifier extends Notifier<OfflineModelState> {
  late final XBoardStorageService _storageService;

  @override
  OfflineModelState build() {
    _storageService = ref.watch(storageServiceProvider);
    Future.microtask(initialize);
    return const OfflineModelState();
  }

  /// 初始化：从存储加载离线数据
  Future<void> initialize() async {
    _logger.info('加载离线读模型...');

    // 并行加载用户和订阅数据
    final results = await Future.wait([
      _storageService.getDomainUser(),
      _storageService.getDomainSubscription(),
    ]);

    final userResult = results[0] as Result<DomainUser?>;
    final subscriptionResult = results[1] as Result<DomainSubscription?>;

    DomainUser? user;
    DomainSubscription? subscription;

    userResult.when(
      success: (data) => user = data,
      failure: (error) => _logger.debug('加载离线用户数据失败: $error'),
    );

    subscriptionResult.when(
      success: (data) => subscription = data,
      failure: (error) => _logger.debug('加载离线订阅数据失败: $error'),
    );

    if (user != null || subscription != null) {
      state = state.copyWith(
        user: user,
        subscription: subscription,
        lastSyncAt: DateTime.now(),
      );
      _logger.info('离线读模型加载完成: $state');
    }
  }

  /// 更新用户数据（网络请求成功后调用）
  void updateUser(DomainUser user) {
    state = state.copyWith(user: user, lastSyncAt: DateTime.now());
    _storageService.saveDomainUser(user);
    _logger.debug('离线用户数据已更新');
  }

  /// 更新订阅数据（网络请求成功后调用）
  void updateSubscription(DomainSubscription subscription) {
    state = state.copyWith(
      subscription: subscription,
      lastSyncAt: DateTime.now(),
    );
    _storageService.saveDomainSubscription(subscription);
    _logger.debug('离线订阅数据已更新');
  }

  /// 标记为离线模式
  void markOffline() {
    state = state.copyWith(isOffline: true);
    _logger.info('进入离线模式');
  }

  /// 标记为在线模式
  void markOnline() {
    state = state.copyWith(isOffline: false);
    _logger.info('进入在线模式');
  }

  /// 清除所有离线数据
  Future<void> clear() async {
    state = const OfflineModelState();
    await _storageService.clearDomainUser();
    await _storageService.clearDomainSubscription();
    _logger.info('离线数据已清除');
  }
}

/// 离线读模型 Notifier Provider
final offlineModelNotifierProvider =
    NotifierProvider<OfflineModelNotifier, OfflineModelState>(
      OfflineModelNotifier.new,
    );
