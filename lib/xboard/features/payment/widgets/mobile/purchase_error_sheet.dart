/// 购买错误底部弹窗
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/features/payment/models/error_recovery.dart';

/// 购买错误底部弹窗
class PurchaseErrorSheet extends StatelessWidget {
  final ErrorRecovery recovery;
  final VoidCallback? onRetry;
  final VoidCallback? onViewOrder;
  final VoidCallback? onContactSupport;

  const PurchaseErrorSheet({
    super.key,
    required this.recovery,
    this.onRetry,
    this.onViewOrder,
    this.onContactSupport,
  });

  /// 显示错误弹窗
  static Future<void> show(
    BuildContext context, {
    required ErrorRecovery recovery,
    VoidCallback? onRetry,
    VoidCallback? onViewOrder,
    VoidCallback? onContactSupport,
  }) async {
    HapticFeedback.heavyImpact();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PurchaseErrorSheet(
        recovery: recovery,
        onRetry: onRetry,
        onViewOrder: onViewOrder,
        onContactSupport: onContactSupport,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  recovery.icon,
                  size: 32,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                recovery.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              _buildActionButtons(context, l10n, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final buttons = <Widget>[];

    if (recovery.canRetry && onRetry != null) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
            ),
            child: Text(
              recovery.actionLabel ?? l10n.xboardRetry,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      );
    } else if (onViewOrder != null) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onViewOrder!();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
            ),
            child: Text(
              recovery.actionLabel ?? l10n.xboardViewOrders,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      );
    } else {
      buttons.add(
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
            ),
            child: Text(
              l10n.xboardConfirm,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      );
    }

    if (recovery.secondaryActionLabel != null && onViewOrder != null) {
      if (recovery.canRetry && onViewOrder != null) {
        buttons.insert(
          0,
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onViewOrder!();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
              ),
              child: Text(
                recovery.secondaryActionLabel ?? l10n.xboardViewOrders,
              ),
            ),
          ),
        );
      }
    }

    if (onContactSupport != null) {
      buttons.add(const SizedBox(height: 12));
      buttons.add(
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onContactSupport!();
          },
          child: Text(
            l10n.xboardCustomerService,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(children: buttons);
  }
}