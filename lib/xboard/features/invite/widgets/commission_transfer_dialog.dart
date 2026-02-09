import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/features/invite/providers/invite_provider.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';

/// Dialog for transferring commission to wallet balance
class CommissionTransferDialog extends ConsumerStatefulWidget {
  final double availableCommission;

  const CommissionTransferDialog({
    super.key,
    required this.availableCommission,
  });

  @override
  ConsumerState<CommissionTransferDialog> createState() =>
      _CommissionTransferDialogState();
}

class _CommissionTransferDialogState
    extends ConsumerState<CommissionTransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isTransferring = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);

    setState(() => _isTransferring = true);

    try {
      await ref.read(transferCommissionProvider(amount).future);

      // Refresh user info to update balance
      ref.read(xboardUserProvider.notifier).refreshUserInfo();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appLocalizations.transferSuccessMsg(amount.toStringAsFixed(2)),
            ),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations.transferFailed(ErrorSanitizer.sanitize(e.toString()))),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTransferring = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxAmount = widget.availableCommission;

    return AlertDialog(
      title: Text(appLocalizations.transferToWallet),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalizations.maxTransferable(maxAmount.toStringAsFixed(2)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: appLocalizations.transferAmount,
                hintText: appLocalizations.enterTransferAmount,
                prefixText: '¥ ',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations.enterTransferAmountError;
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return appLocalizations.invalidTransferAmount;
                }
                if (amount > maxAmount) {
                  return appLocalizations
                      .transferAmountExceeded(maxAmount.toStringAsFixed(2));
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Text(
              appLocalizations.transferNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isTransferring ? null : () => Navigator.of(context).pop(),
          child: Text(appLocalizations.xboardCancel),
        ),
        FilledButton(
          onPressed: _isTransferring ? null : _handleTransfer,
          child: _isTransferring
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Text(appLocalizations.confirmTransfer),
        ),
      ],
    );
  }
}
