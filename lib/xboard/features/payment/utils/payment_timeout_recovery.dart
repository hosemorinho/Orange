/// 支付超时恢复工具
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/core/core.dart';

final _logger = FileLogger('payment_timeout_recovery.dart');

/// 支付超时恢复工具
class PaymentTimeoutRecovery {
  PaymentTimeoutRecovery._();

  /// 显示支付超时恢复对话框
  static Future<void> showRecoveryDialog(
    BuildContext context, {
    required String tradeNo,
    VoidCallback? onRetry,
    VoidCallback? onViewOrder,
  }) async {
    final l10n = AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.xboardTimeoutErrorTitle),
        content: Text(l10n.xboardTimeoutErrorDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.xboardCancel),
          ),
          if (onViewOrder != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                onViewOrder();
              },
              child: Text(l10n.xboardViewOrders),
            ),
        ],
      ),
    );
  }

  /// 显示支付结果确认对话框
  static Future<bool> showPaymentResultConfirm(
    BuildContext context, {
    required String tradeNo,
  }) async {
    final l10n = AppLocalizations.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.xboardPaymentConfirmTitle),
        content: Text(l10n.xboardPaymentConfirmDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.xboardPaymentFailed),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.xboardPaymentSuccess),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

