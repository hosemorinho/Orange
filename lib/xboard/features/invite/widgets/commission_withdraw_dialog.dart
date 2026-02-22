import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/features/invite/providers/invite_provider.dart';

/// Dialog for withdrawing commission
class CommissionWithdrawDialog extends ConsumerStatefulWidget {
  final double availableCommission;

  const CommissionWithdrawDialog({
    super.key,
    required this.availableCommission,
  });

  @override
  ConsumerState<CommissionWithdrawDialog> createState() =>
      _CommissionWithdrawDialogState();
}

class _CommissionWithdrawDialogState
    extends ConsumerState<CommissionWithdrawDialog> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  String? _selectedMethod;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _handleWithdraw() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMethod == null) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(
        withdrawCommissionProvider(
          _selectedMethod!,
          _accountController.text,
        ).future,
      );
      if (!mounted) return;

      // Refresh invite stats from UI scope for immediate feedback.
      ref.invalidate(inviteDataProviderProvider);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.withdrawSubmitted),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appLocalizations.withdrawFailed(
                ErrorSanitizer.sanitize(e.toString()),
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final configAsync = ref.watch(commissionConfigProvider);

    return AlertDialog(
      title: Text(appLocalizations.withdrawCommission),
      content: configAsync.when(
        data: (config) {
          final isWithdraw = config['is_withdraw'] as int? ?? 0;
          final withdrawClose = config['withdraw_close'] as int? ?? 0;
          final methods =
              (config['withdraw_methods'] as List<dynamic>?)?.cast<String>() ??
              [];

          if (isWithdraw == 0 || withdrawClose == 1) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.block,
                  size: 48,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  appLocalizations.withdrawClosed,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }

          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLocalizations.withdrawableAmount(
                    widget.availableCommission.toStringAsFixed(2),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedMethod,
                  decoration: InputDecoration(
                    labelText: appLocalizations.withdrawMethod,
                    border: const OutlineInputBorder(),
                  ),
                  hint: Text(appLocalizations.selectWithdrawMethod),
                  items: methods.map((method) {
                    return DropdownMenuItem(value: method, child: Text(method));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedMethod = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.selectWithdrawMethod;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _accountController,
                  decoration: InputDecoration(
                    labelText: appLocalizations.withdrawAccount,
                    hintText: appLocalizations.enterWithdrawAccount,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.enterWithdrawAccount;
                    }
                    return null;
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              ErrorSanitizer.sanitize(error.toString()),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(appLocalizations.xboardCancel),
        ),
        if (configAsync.hasValue &&
            (configAsync.value?['is_withdraw'] as int? ?? 0) != 0 &&
            (configAsync.value?['withdraw_close'] as int? ?? 0) != 1)
          FilledButton(
            onPressed: _isSubmitting ? null : _handleWithdraw,
            child: _isSubmitting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Text(appLocalizations.confirmWithdraw),
          ),
      ],
    );
  }
}
