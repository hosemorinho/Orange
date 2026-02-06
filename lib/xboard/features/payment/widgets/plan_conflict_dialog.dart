import 'package:flutter/material.dart';
import 'package:fl_clash/l10n/l10n.dart';

/// Dialog warning users when purchasing a different plan while an active
/// subscription exists. Mirrors React web app NewOrderCheckout behavior.
class PlanConflictDialog extends StatelessWidget {
  const PlanConflictDialog._();

  /// Shows the plan conflict dialog.
  /// Returns `true` if user wants to continue, `false` to go back.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PlanConflictDialog._(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: Colors.amber.shade700,
        size: 48,
      ),
      title: Text(l10n.xboardPlanConflictTitle),
      content: Text(
        l10n.xboardPlanConflictMessage,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.xboardGoBack),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.xboardContinuePurchase),
        ),
      ],
    );
  }
}
