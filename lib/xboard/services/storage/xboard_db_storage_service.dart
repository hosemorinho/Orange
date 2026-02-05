/// XBoard 数据库存储服务
///
/// 使用 Drift 数据库替代 SharedPreferences 的存储服务
library;

import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/database/database.dart';

/// XBoard 数据库存储服务
///
/// 负责存储和读取XBoard相关数据，使用 Drift 数据库
class XBoardDbStorageService {
  final UserRepository _userRepo;
  final SubscriptionRepository _subscriptionRepo;
  final AuthRepository _authRepo;
  final NoticeRepository _noticeRepo;

  XBoardDbStorageService({
    required UserRepository userRepo,
    required SubscriptionRepository subscriptionRepo,
    required AuthRepository authRepo,
    required NoticeRepository noticeRepo,
  })  : _userRepo = userRepo,
        _subscriptionRepo = subscriptionRepo,
        _authRepo = authRepo,
        _noticeRepo = noticeRepo;

  // ===== 用户信息 =====

  /// 保存用户信息
  Future<Result<bool>> saveDomainUser(DomainUser user) async {
    try {
      await _userRepo.saveUser(user);
      return Result.success(true);
    } catch (e, stackTrace) {
      return Result.failure(XBoardStorageException(
        message: '保存用户信息失败',
        operation: 'write',
        key: 'user',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// 获取当前用户
  Future<Result<DomainUser?>> getDomainUser() async {
    try {
      final user = await _userRepo.getCurrentUser();
      return Result.success(user);
    } catch (e, stackTrace) {
      return Result.failure(XBoardStorageException(
        message: '读取用户信息失败',
        operation: 'read',
        key: 'user',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// 获取用户邮箱
  Future<Result<String?>> getUserEmail() async {
    try {
      final user = await _userRepo.getCurrentUser();
      return Result.success(user?.email);
    } catch (e, stackTrace) {
      return Result.failure(XBoardStorageException(
        message: '读取用户邮箱失败',
        operation: 'read',
        key: 'user_email',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// 监听用户变化
  Stream<DomainUser?> watchDomainUser() {
    return _userRepo.watchCurrentUser();
  }

  // ===== 订阅信息 =====

  /// 保存订阅信息
  Future<Result<bool>> saveDomainSubscription(DomainSubscription subscription) async {
    try {
      await _subscriptionRepo.saveSubscription(subscription);
      return Result.success(true);
    } catch (e, stackTrace) {
      return Result.failure(XBoardStorageException(
        message: '保存订阅信息失败',
        operation: 'write',
        key: 'subscription',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// 获取当前订阅
  Future<Result<DomainSubscription?>> getDomainSubscription() async {
    try {
      final subscription = await _subscriptionRepo.getCurrentSubscription();
      return Result.success(subscription);
    } catch (e, stackTrace) {
      return Result.failure(XBoardStorageException(
        message: '读取订阅信息失败',
        operation: 'read',
        key: 'subscription',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// 监听订阅变化
  Stream<DomainSubscription?> watchDomainSubscription() {
    return _subscriptionRepo.watchCurrentSubscription();
  }

  // ===== 认证令牌 =====

  /// 保存认证令牌
  Future<Result<bool>> saveAuthToken(String email, String token) async {
    try {
      await _authRepo.saveToken(email, token);
      return Result.success(true);
    } catch (e, stackTrace) {
      return Result.failure(XBoardStorageException(
        message: '保存认证令牌失败',
        operation: 'write',
        key: 'auth_token',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// 获取当前认证令牌
  Future<Result<String?>> getAuthToken() async {
    try {
      final token = await _authRepo.getCurrentToken();
      return Result.success(token);
    } catch (e, stackTrace) {
      return Result.failure(XBoardStorageException(
        message: '读取认证令牌失败',
        operation: 'read',
        key: 'auth_token',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// 检查是否有认证令牌
  Future<bool> hasAuthToken() async {
    return _authRepo.hasToken();
  }

  // ===== 公告已读状态 =====

  /// 判断公告是否需要显示
  Future<bool> shouldShowNoticeDialog(int noticeId) async {
    return _noticeRepo.shouldShowNotice(noticeId);
  }

  /// 标记公告已读
  Future<Result<bool>> saveNoticeDialogReadTime(int noticeId) async {
    try {
      await _noticeRepo.markAsRead(noticeId);
      return Result.success(true);
    } catch (e, stackTrace) {
      return Result.failure(XBoardStorageException(
        message: '保存公告已读状态失败',
        operation: 'write',
        key: 'notice_read_$noticeId',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  // ===== 认证数据清理 =====

  /// 清空认证数据
  Future<Result<bool>> clearAuthData() async {
    try {
      await _userRepo.clearAll();
      await _subscriptionRepo.clearAll();
      await _authRepo.clearAll();
      return Result.success(true);
    } catch (e, stackTrace) {
      return Result.failure(XBoardStorageException(
        message: '清空认证数据失败',
        operation: 'delete',
        key: 'auth_data',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
