/// 全局认证守卫
///
/// 统一处理令牌过期、401 响应等认证失败场景。
/// 各页面和 Provider 通过 `authGuardProvider` 监听认证状态。
library;

import 'package:flutter/foundation.dart';
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
final authGuardProvider = Provider<AuthGuardState>((ref) {
  return const AuthGuardState(AuthGuardStatus.authenticated);
});

/// 认证守卫服务
class AuthGuard {
  /// 标记令牌已过期
  static void markExpired(Ref ref) {
    _logger.warning('认证令牌已过期');
    // 由于 Provider 是只读的，这里需要通过其他方式更新状态
    // 实际使用中可以通过事件总线或状态管理器来处理
  }

  /// 标记已登出
  static void markLoggedOut(Ref ref) {
    _logger.info('用户已登出');
    // TODO: 更新状态
  }

  /// 标记已认证（登录成功后调用）
  static void markAuthenticated(Ref ref) {
    _logger.info('用户已认证');
    // TODO: 更新状态
  }

  /// 检查响应是否为 401/403 认证失败
  static bool isAuthFailure(int? statusCode) {
    return statusCode == 401 || statusCode == 403;
  }
}
