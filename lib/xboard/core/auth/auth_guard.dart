/// 全局认证守卫
///
/// 统一处理令牌过期、401 响应等认证失败场景。
/// 各页面和 Provider 通过 `authGuardProvider` 监听认证状态。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/core/core.dart';

final _logger = FileLogger('auth_guard.dart');

/// 认证守卫状态
enum AuthGuardStatus { authenticated, expired, loggedOut }

/// 认证守卫状态容器
class AuthGuardState {
  final AuthGuardStatus status;

  const AuthGuardState(this.status);

  static const authenticated = AuthGuardState(AuthGuardStatus.authenticated);
  static const expired = AuthGuardState(AuthGuardStatus.expired);
  static const loggedOut = AuthGuardState(AuthGuardStatus.loggedOut);
}

/// 认证守卫 Provider
///
/// 用法：
/// ```dart
/// final state = ref.watch(authGuardProvider);
/// if (state.status == AuthGuardStatus.expired) {
///   // 显示登录过期提示
/// }
/// ```
class AuthGuardNotifier extends Notifier<AuthGuardState> {
  @override
  AuthGuardState build() => AuthGuardState.authenticated;

  void markExpired() => state = AuthGuardState.expired;

  void markLoggedOut() => state = AuthGuardState.loggedOut;

  void markAuthenticated() => state = AuthGuardState.authenticated;
}

final authGuardProvider = NotifierProvider<AuthGuardNotifier, AuthGuardState>(
  AuthGuardNotifier.new,
);

/// 认证守卫服务
class AuthGuard {
  /// 标记令牌已过期
  static void markExpired(Ref ref) {
    _logger.warning('认证令牌已过期');
    ref.read(authGuardProvider.notifier).markExpired();
  }

  /// 标记已登出
  static void markLoggedOut(Ref ref) {
    _logger.info('用户已登出');
    ref.read(authGuardProvider.notifier).markLoggedOut();
  }

  /// 标记已认证（登录成功后调用）
  static void markAuthenticated(Ref ref) {
    _logger.info('用户已认证');
    ref.read(authGuardProvider.notifier).markAuthenticated();
  }

  /// 检查响应是否为 401/403 认证失败
  static bool isAuthFailure(int? statusCode) {
    return statusCode == 401 || statusCode == 403;
  }
}
