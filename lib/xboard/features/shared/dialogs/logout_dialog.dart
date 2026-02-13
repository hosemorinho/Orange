import 'package:flutter/material.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/providers/providers.dart';

/// Shows a logout confirmation dialog using FlClash's native globalState.showMessage.
///
/// Usage:
/// ```dart
/// await showLogoutDialog(context, ref);
/// ```
Future<void> showLogoutDialog(BuildContext context, WidgetRef ref) async {
  final result = await globalState.showMessage(
    context: context,
    message: TextSpan(text: appLocalizations.logoutConfirmMsg),
    title: appLocalizations.confirmLogout,
    confirmText: appLocalizations.logout,
    cancelText: appLocalizations.cancel,
  );

  if (result == true) {
    await _performLogout(context, ref);
  }
}

Future<void> _performLogout(BuildContext context, WidgetRef ref) async {
  try {
    // Stop proxy before clearing auth
    if (ref.read(isStartProvider)) {
      await appController.updateStatus(
        false,
        trigger: 'xboard.logout_dialog',
      );
    }
    await ref.read(xboardUserProvider.notifier).logout();
    if (context.mounted) {
      XBoardNotification.showSuccess(appLocalizations.loggedOutSuccess);
    }
  } catch (e) {
    if (context.mounted) {
      XBoardNotification.showError(appLocalizations.logoutFailed(ErrorSanitizer.sanitize(e.toString())));
    }
  }
}
