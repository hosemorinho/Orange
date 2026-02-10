import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/leaf/providers/leaf_providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Leaf version of the logout dialog.
///
/// Stops leaf before clearing auth, instead of calling appController.updateStatus.
Future<void> showLeafLogoutDialog(BuildContext context, WidgetRef ref) async {
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
    // Stop leaf proxy before clearing auth
    if (ref.read(isLeafRunningProvider)) {
      await stopLeaf(ref);
    }
    await ref.read(xboardUserProvider.notifier).logout();
    if (context.mounted) {
      XBoardNotification.showSuccess(appLocalizations.loggedOutSuccess);
    }
  } catch (e) {
    if (context.mounted) {
      XBoardNotification.showError(
          appLocalizations.logoutFailed(ErrorSanitizer.sanitize(e.toString())));
    }
  }
}
