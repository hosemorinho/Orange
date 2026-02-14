import 'package:flutter/material.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/features/auth/auth.dart';
import 'package:fl_clash/xboard/domain/domain.dart';

enum SubscriptionStatusType {
  valid,
  noSubscription,
  expired,
  expiringSoon,
  lowTraffic,
  exhausted,
  notLoggedIn,
  parseFailed,
}

class SubscriptionStatusResult {
  final SubscriptionStatusType type;
  final String Function(BuildContext) messageBuilder;
  final String? Function(BuildContext)? detailMessageBuilder;
  final DateTime? expiredAt;
  final int? remainingDays;
  final bool needsDialog;

  const SubscriptionStatusResult({
    required this.type,
    required this.messageBuilder,
    this.detailMessageBuilder,
    this.expiredAt,
    this.remainingDays,
    this.needsDialog = false,
  });

  String getMessage(BuildContext context) => messageBuilder(context);

  String? getDetailMessage(BuildContext context) =>
      detailMessageBuilder?.call(context);

  bool get shouldShowDialog => needsDialog;
}

class SubscriptionStatusService {
  static const SubscriptionStatusService _instance =
      SubscriptionStatusService._internal();

  factory SubscriptionStatusService() => _instance;

  const SubscriptionStatusService._internal();

  SubscriptionStatusResult checkSubscriptionStatus({
    required UserAuthState userState,
    DomainSubscription? subscriptionInfo,
  }) {
    if (!userState.isAuthenticated) {
      return SubscriptionStatusResult(
        type: SubscriptionStatusType.notLoggedIn,
        messageBuilder: (context) =>
            AppLocalizations.of(context).subscriptionNotLoggedIn,
        detailMessageBuilder: (context) =>
            AppLocalizations.of(context).subscriptionNotLoggedInDetail,
        needsDialog: false,
      );
    }

    // 从 userState 获取 planId（包括 subscriptionInfo 和 userInfo 中的 planId）
    final planId = _getEffectivePlanId(userState);
    if (planId == null) {
      return SubscriptionStatusResult(
        type: SubscriptionStatusType.noSubscription,
        messageBuilder: (context) =>
            AppLocalizations.of(context).subscriptionNoSubscription,
        detailMessageBuilder: (context) =>
            AppLocalizations.of(context).subscriptionNoSubscriptionDetail,
        needsDialog: true,
      );
    }

    // 使用 DomainSubscription 对象检查订阅状态
    if (subscriptionInfo == null) {
      // API 获取失败，假设为有效状态，允许用户使用已有的本地订阅配置
      // 不显示弹窗（needsDialog: false），只显示基本信息
      return SubscriptionStatusResult(
        type: SubscriptionStatusType.valid,
        messageBuilder: (context) =>
            AppLocalizations.of(context).subscriptionValid,
        detailMessageBuilder: null,  // 不显示详情，避免误导用户
        needsDialog: false,  // 关键：不弹窗，避免中断用户使用
      );
    }

    final expiredAt = subscriptionInfo.expiredAt;
    if (expiredAt != null) {
      final now = DateTime.now();
      final isExpired = subscriptionInfo.isExpired;
      final remainingDays = subscriptionInfo.daysRemaining;

      if (isExpired) {
        return SubscriptionStatusResult(
          type: SubscriptionStatusType.expired,
          messageBuilder: (context) =>
              AppLocalizations.of(context).subscriptionExpired,
          detailMessageBuilder: (context) => AppLocalizations.of(
            context,
          ).subscriptionExpiredDetail(_formatDate(expiredAt)),
          expiredAt: expiredAt,
          remainingDays: remainingDays,
          needsDialog: true,
        );
      }

      if (remainingDays == 0) {
        return SubscriptionStatusResult(
          type: SubscriptionStatusType.expired,
          messageBuilder: (context) =>
              AppLocalizations.of(context).subscriptionExpiresToday,
          detailMessageBuilder: (context) =>
              AppLocalizations.of(context).subscriptionExpiresTodayDetail,
          expiredAt: expiredAt,
          remainingDays: remainingDays,
          needsDialog: true,
        );
      }

      if (remainingDays <= 3) {
        return SubscriptionStatusResult(
          type: SubscriptionStatusType.expiringSoon,
          messageBuilder: (context) =>
              AppLocalizations.of(context).subscriptionExpiringInDays,
          detailMessageBuilder: (context) => AppLocalizations.of(
            context,
          ).subscriptionExpiringInDaysDetail(remainingDays),
          expiredAt: expiredAt,
          remainingDays: remainingDays,
          needsDialog: false,
        );
      }
    }

    final trafficStatus = _checkTrafficStatus(subscriptionInfo);
    if (trafficStatus != null) {
      return trafficStatus;
    }

    final remainingDays = subscriptionInfo.daysRemaining;
    return SubscriptionStatusResult(
      type: SubscriptionStatusType.valid,
      messageBuilder: (context) =>
          AppLocalizations.of(context).subscriptionValid,
      detailMessageBuilder: remainingDays != null
          ? (context) => AppLocalizations.of(
              context,
            ).subscriptionValidDetail(remainingDays)
          : null,
      expiredAt: expiredAt,
      remainingDays: remainingDays,
      needsDialog: false,
    );
  }

  int? _getEffectivePlanId(UserAuthState userState) {
    final candidatePlanIds = <int?>[
      userState.subscriptionInfo?.planId,
      userState.userInfo?.planId,
    ];

    for (final candidatePlanId in candidatePlanIds) {
      if (candidatePlanId != null && candidatePlanId > 0) {
        return candidatePlanId;
      }
    }

    return null;
  }

  SubscriptionStatusResult? _checkTrafficStatus(
    DomainSubscription? subscriptionInfo,
  ) {
    if (subscriptionInfo == null || subscriptionInfo.transferLimit <= 0) {
      return null;
    }

    final usageRatio = subscriptionInfo.usagePercentage / 100;

    if (usageRatio >= 1.0 || subscriptionInfo.isTrafficExhausted) {
      return SubscriptionStatusResult(
        type: SubscriptionStatusType.exhausted,
        messageBuilder: (context) =>
            AppLocalizations.of(context).subscriptionTrafficExhausted,
        detailMessageBuilder: (context) =>
            AppLocalizations.of(context).subscriptionTrafficExhaustedDetail,
        needsDialog: true,
      );
    }

    if (usageRatio >= 0.95) {
      return SubscriptionStatusResult(
        type: SubscriptionStatusType.lowTraffic,
        messageBuilder: (context) =>
            AppLocalizations.of(context).xboardRemindTraffic,
        detailMessageBuilder: (context) =>
            AppLocalizations.of(context).xboardRenewToContinue,
        needsDialog: true,
      );
    }

    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool shouldShowStartupDialog(SubscriptionStatusResult result) {
    switch (result.type) {
      case SubscriptionStatusType.expired:
        return true;
      case SubscriptionStatusType.lowTraffic:
        return true;
      case SubscriptionStatusType.exhausted:
        return true;
      case SubscriptionStatusType.noSubscription:
        return true;
      case SubscriptionStatusType.parseFailed:
        // API 获取失败不应该弹窗，避免中断用户使用已有的本地订阅配置
        return false;
      case SubscriptionStatusType.expiringSoon:
        return false;
      case SubscriptionStatusType.valid:
        return false;
      case SubscriptionStatusType.notLoggedIn:
        return false;
    }
  }
}

final subscriptionStatusService = SubscriptionStatusService();
