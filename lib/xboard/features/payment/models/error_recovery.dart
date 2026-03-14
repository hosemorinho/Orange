/// 错误恢复策略模型
library;

import 'package:flutter/material.dart';

/// 错误操作类型
enum ErrorAction {
  /// 重试操作
  retry,

  /// 关闭/忽略
  dismiss,

  /// 联系客服
  contactSupport,

  /// 查看订单
  checkOrder,
}

/// 错误恢复策略
class ErrorRecovery {
  /// 错误消息（显示给用户）
  final String message;

  /// 恢复操作类型
  final ErrorAction action;

  /// 图标
  final IconData icon;

  /// 主操作按钮文字
  final String? actionLabel;

  /// 次要操作按钮文字
  final String? secondaryActionLabel;

  const ErrorRecovery({
    required this.message,
    required this.action,
    required this.icon,
    this.actionLabel,
    this.secondaryActionLabel,
  });

  /// 是否可以重试
  bool get canRetry => action == ErrorAction.retry;

  /// 网络错误恢复策略
  factory ErrorRecovery.networkError({String? customMessage}) {
    return ErrorRecovery(
      message: customMessage ?? '网络连接失败，请检查网络后重试',
      action: ErrorAction.retry,
      icon: Icons.wifi_off_outlined,
    );
  }

  /// 超时错误恢复策略
  factory ErrorRecovery.timeoutError() {
    return const ErrorRecovery(
      message: '请求超时，请稍后重试',
      action: ErrorAction.retry,
      icon: Icons.timer_outlined,
    );
  }

  /// 服务器错误恢复策略
  factory ErrorRecovery.serverError() {
    return const ErrorRecovery(
      message: '服务器暂时无法响应，请稍后重试',
      action: ErrorAction.retry,
      icon: Icons.cloud_off_outlined,
    );
  }

  /// 认证错误恢复策略
  factory ErrorRecovery.authError() {
    return const ErrorRecovery(
      message: '登录已过期，请重新登录',
      action: ErrorAction.dismiss,
      icon: Icons.logout_outlined,
    );
  }

  /// 优惠券错误恢复策略
  factory ErrorRecovery.couponError({String? message}) {
    return ErrorRecovery(
      message: message ?? '优惠券无效或已过期',
      action: ErrorAction.dismiss,
      icon: Icons.local_offer_outlined,
    );
  }

  /// 订单错误恢复策略
  factory ErrorRecovery.orderError({String? message}) {
    return ErrorRecovery(
      message: message ?? '订单处理失败',
      action: ErrorAction.checkOrder,
      icon: Icons.receipt_long_outlined,
    );
  }

  /// 通用错误恢复策略
  factory ErrorRecovery.genericError({String? message}) {
    return ErrorRecovery(
      message: message ?? '操作失败，请稍后重试',
      action: ErrorAction.retry,
      icon: Icons.error_outline,
    );
  }
}