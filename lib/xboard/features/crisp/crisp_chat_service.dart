import 'dart:io';

import 'package:crisp_chat/crisp_chat.dart';
import 'package:fl_clash/xboard/features/crisp/crisp_config.dart';
import 'package:fl_clash/xboard/domain/models/user.dart';
import 'package:fl_clash/xboard/domain/models/plan.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Crisp live chat service.
///
/// Uses the native Crisp SDK on mobile (Android/iOS) and falls back to
/// opening the Crisp web chat via url_launcher on desktop platforms.
class CrispChatService {
  CrispChatService._();

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  /// Whether the current platform supports the native Crisp SDK.
  static bool get _isNativePlatform => Platform.isAndroid || Platform.isIOS;

  /// Open the Crisp chat window, pushing user/plan data into the session.
  ///
  /// On desktop platforms the web chat URL is launched in the default browser.
  static Future<void> openChat({
    required DomainUser user,
    DomainPlan? plan,
  }) async {
    if (effectiveCrispWebsiteId.isEmpty) return;

    if (_isNativePlatform) {
      await _openNativeChat(user: user, plan: plan);
    } else {
      await _openWebChat();
    }
  }

  /// Reset the Crisp session (call on logout).
  static Future<void> resetSession() async {
    if (effectiveCrispWebsiteId.isEmpty) return;
    if (!_isNativePlatform) return;

    await FlutterCrispChat.resetCrispChatSession();
  }

  // ---------------------------------------------------------------------------
  // Native (Android / iOS)
  // ---------------------------------------------------------------------------

  static Future<void> _openNativeChat({
    required DomainUser user,
    DomainPlan? plan,
  }) async {
    // Build user object
    final crispUser = User(
      email: user.email,
      avatar: user.avatarUrl.isNotEmpty ? user.avatarUrl : null,
    );

    final config = CrispConfig(
      websiteID: effectiveCrispWebsiteId,
      user: crispUser,
    );

    // Push session data
    FlutterCrispChat.setSessionString(
      key: 'UUID',
      value: user.uuid,
    );

    if (plan != null) {
      FlutterCrispChat.setSessionString(
        key: 'Plan',
        value: plan.name,
      );
    }

    if (user.expiredAt != null) {
      FlutterCrispChat.setSessionString(
        key: 'ExpireTime',
        value: _dateFormat.format(user.expiredAt!),
      );
    }

    FlutterCrispChat.setSessionString(
      key: 'Traffic',
      value: user.totalTraffic,
    );

    FlutterCrispChat.setSessionString(
      key: 'TrafficUsed',
      value: user.usedTraffic,
    );

    FlutterCrispChat.setSessionString(
      key: 'Balance',
      value: user.balanceInYuan.toString(),
    );

    FlutterCrispChat.setSessionString(
      key: 'Commission',
      value: user.commissionBalanceInYuan.toString(),
    );

    if (user.createdAt != null) {
      FlutterCrispChat.setSessionString(
        key: 'RegistrationTime',
        value: _dateFormat.format(user.createdAt!),
      );
    }

    await FlutterCrispChat.openCrispChat(config: config);
  }

  // ---------------------------------------------------------------------------
  // Desktop fallback (url_launcher)
  // ---------------------------------------------------------------------------

  static Future<void> _openWebChat() async {
    final uri = Uri.parse(
      'https://go.crisp.chat/chat/embed/?website_id=$effectiveCrispWebsiteId',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
