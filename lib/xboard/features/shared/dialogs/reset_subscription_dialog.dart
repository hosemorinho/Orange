import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/state.dart';

/// Shows a reset subscription confirmation dialog using FlClash's native globalState.showMessage.
///
/// Usage:
/// ```dart
/// await showResetSubscriptionDialog(context, ref);
/// ```
Future<void> showResetSubscriptionDialog(BuildContext context, WidgetRef ref) async {
  final result = await globalState.showMessage(
    context: context,
    message: TextSpan(text: appLocalizations.xboardResetConfirmDesc),
    title: appLocalizations.xboardResetConfirmTitle,
    confirmText: appLocalizations.xboardConfirm,
    cancelText: appLocalizations.cancel,
  );

  if (result == true) {
    if (!context.mounted) return;
    await _handleReset(context, ref);
  }
}

Future<void> _handleReset(BuildContext context, WidgetRef ref) async {
  try {
    final api = await ref.read(xboardSdkProvider.future);
    await api.resetSecurity();

    // Refresh user info to get new subscription URL
    await ref.read(xboardUserProvider.notifier).refreshUserInfo();

    if (context.mounted) {
      XBoardNotification.showSuccess(
        appLocalizations.xboardResetSubscriptionSuccess,
      );
    }
  } catch (e) {
    if (context.mounted) {
      XBoardNotification.showError(
        '${appLocalizations.xboardResetSubscriptionError}: ${ErrorSanitizer.sanitize(e.toString())}',
      );
    }
  }
}
