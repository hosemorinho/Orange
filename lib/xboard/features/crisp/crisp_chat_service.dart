import 'dart:io';

import 'package:crisp_chat/crisp_chat.dart';
import 'package:fl_clash/common/num.dart';
import 'package:fl_clash/models/profile.dart';
import 'package:fl_clash/xboard/features/crisp/crisp_config.dart';
import 'package:fl_clash/xboard/domain/models/subscription.dart';
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
  /// [profileSubInfo] is the subscription info from Clash profile headers
  /// (upload/download/total/expire). This is the same source the homepage uses.
  /// [subscription] is the V2Board subscription data (fallback).
  ///
  /// On desktop platforms the web chat URL is launched in the default browser.
  static Future<void> openChat({
    required DomainUser user,
    DomainPlan? plan,
    SubscriptionInfo? profileSubInfo,
    DomainSubscription? subscription,
  }) async {
    if (effectiveCrispWebsiteId.isEmpty) return;

    if (_isNativePlatform) {
      await _openNativeChat(
        user: user,
        plan: plan,
        profileSubInfo: profileSubInfo,
        subscription: subscription,
      );
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
    SubscriptionInfo? profileSubInfo,
    DomainSubscription? subscription,
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

    // --- Traffic: use profile sub info (same source as homepage) ---
    final traffic = _resolveTraffic(profileSubInfo, subscription, user);
    FlutterCrispChat.setSessionString(
      key: 'Traffic',
      value: traffic.total,
    );
    FlutterCrispChat.setSessionString(
      key: 'TrafficUsed',
      value: traffic.used,
    );

    // --- Expiration: use profile sub info → subscription → user ---
    final expiredAt = _resolveExpiredAt(profileSubInfo, subscription, user);
    if (expiredAt != null) {
      final remaining = expiredAt.difference(DateTime.now()).inDays;
      final days = remaining >= 0 ? remaining : 0;
      FlutterCrispChat.setSessionString(
        key: 'ExpireTime',
        value: '${_dateFormat.format(expiredAt)} ($days天)',
      );
    }

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

  /// Resolve traffic values using the same priority as the homepage:
  /// 1. Profile SubscriptionInfo (Clash subscription URL headers)
  /// 2. DomainSubscription (V2Board subscription API)
  /// 3. DomainUser (V2Board user API)
  static _TrafficInfo _resolveTraffic(
    SubscriptionInfo? profileSubInfo,
    DomainSubscription? subscription,
    DomainUser user,
  ) {
    // Source 1: profile subscription headers (same as homepage vpn_hero_card)
    if (profileSubInfo != null &&
        (profileSubInfo.upload > 0 ||
            profileSubInfo.download > 0 ||
            profileSubInfo.total > 0)) {
      final used = profileSubInfo.upload + profileSubInfo.download;
      final total = profileSubInfo.total;
      return _TrafficInfo(
        used: _formatBytes(used),
        total: total > 0 ? _formatBytes(total) : '∞',
      );
    }

    // Source 2: DomainSubscription (V2Board subscription API)
    if (subscription != null &&
        (subscription.uploadedBytes > 0 ||
            subscription.downloadedBytes > 0 ||
            subscription.transferLimit > 0)) {
      return _TrafficInfo(
        used: subscription.formattedUsedTraffic,
        total: subscription.formattedTotalTraffic,
      );
    }

    // Source 3: DomainUser (V2Board user API)
    return _TrafficInfo(
      used: user.usedTraffic,
      total: user.totalTraffic,
    );
  }

  /// Resolve expiration date using the same priority as the homepage:
  /// 1. Profile SubscriptionInfo expire (unix timestamp)
  /// 2. DomainSubscription.expiredAt
  /// 3. DomainUser.expiredAt
  static DateTime? _resolveExpiredAt(
    SubscriptionInfo? profileSubInfo,
    DomainSubscription? subscription,
    DomainUser user,
  ) {
    if (profileSubInfo != null &&
        profileSubInfo.expire != 0) {
      return DateTime.fromMillisecondsSinceEpoch(
          profileSubInfo.expire * 1000);
    }
    if (subscription?.expiredAt != null) {
      return subscription!.expiredAt;
    }
    return user.expiredAt;
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    final trafficShow = bytes.traffic;
    return '${trafficShow.value} ${trafficShow.unit}';
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

class _TrafficInfo {
  final String used;
  final String total;
  const _TrafficInfo({required this.used, required this.total});
}
