import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';

class ResetSubscriptionDialog extends ConsumerStatefulWidget {
  const ResetSubscriptionDialog({super.key});

  @override
  ConsumerState<ResetSubscriptionDialog> createState() =>
      _ResetSubscriptionDialogState();
}

class _ResetSubscriptionDialogState
    extends ConsumerState<ResetSubscriptionDialog> {
  bool _isLoading = false;

  Future<void> _handleReset() async {
    setState(() => _isLoading = true);

    try {
      final api = await ref.read(xboardSdkProvider.future);
      await api.resetSecurity();

      // Refresh user info to get new subscription URL
      await ref.read(xboardUserProvider.notifier).refreshUserInfo();

      if (mounted) {
        Navigator.of(context).pop();
        XBoardNotification.showSuccess(
          appLocalizations.xboardResetSubscriptionSuccess,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        XBoardNotification.showError(
          '${appLocalizations.xboardResetSubscriptionError}: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(appLocalizations.xboardResetConfirmTitle),
      content: Text(appLocalizations.xboardResetConfirmDesc),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleReset,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onError,
                  ),
                )
              : Text(appLocalizations.xboardConfirm),
        ),
      ],
    );
  }
}
