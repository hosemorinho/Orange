import 'dart:io';
import 'package:fl_clash/common/num.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/subscription/providers/xboard_subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/models/models.dart' as fl_models;
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:go_router/go_router.dart';
import '../services/subscription_status_service.dart';
import 'package:fl_clash/l10n/l10n.dart';
class SubscriptionUsageCard extends ConsumerWidget {
  final DomainSubscription? subscriptionInfo;
  final DomainUser? userInfo;
  final fl_models.SubscriptionInfo? profileSubscriptionInfo;
  const SubscriptionUsageCard({
    super.key,
    this.subscriptionInfo,
    this.userInfo,
    this.profileSubscriptionInfo,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userState = ref.watch(xboardUserProvider);
    SubscriptionStatusResult? subscriptionStatus;
    if (userState.isAuthenticated && subscriptionInfo != null) {
      subscriptionStatus = subscriptionStatusService.checkSubscriptionStatus(
        userState: userState,
        profileSubscriptionInfo: profileSubscriptionInfo,
      );
    }
    if (profileSubscriptionInfo == null && userInfo == null && subscriptionInfo == null) {
      return _buildEmptyCard(theme, context);
    }
    if (subscriptionStatus != null && 
        (subscriptionStatus.type == SubscriptionStatusType.expired || 
         subscriptionStatus.type == SubscriptionStatusType.exhausted ||
         subscriptionStatus.type == SubscriptionStatusType.noSubscription)) {
      return _buildStatusCard(subscriptionStatus, theme, context);
    }
    return _buildUsageCard(theme, context);
  }
  Widget _buildEmptyCard(ThemeData theme, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_outlined,
              size: 32,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).xboardNoSubscriptionInfo,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context).xboardLoginToViewSubscription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  Widget _buildStatusCard(SubscriptionStatusResult statusResult, ThemeData theme, BuildContext context) {
    IconData statusIcon;
    Color statusColor;
    String statusText;
    String statusDetail;
    switch (statusResult.type) {
      case SubscriptionStatusType.noSubscription:
        statusIcon = Icons.card_giftcard_outlined;
        statusColor = theme.colorScheme.primary;
        statusText = AppLocalizations.of(context).xboardNoAvailableSubscription;
        statusDetail = AppLocalizations.of(context).xboardPurchaseSubscriptionToUse;
        break;
      case SubscriptionStatusType.expired:
        statusIcon = Icons.schedule_outlined;
        statusColor = theme.colorScheme.error;
        statusText = AppLocalizations.of(context).xboardSubscriptionExpired;
        statusDetail = statusResult.getDetailMessage(context) ?? AppLocalizations.of(context).xboardRenewToContinue;
        break;
      case SubscriptionStatusType.exhausted:
        statusIcon = Icons.data_usage_outlined;
        statusColor = theme.colorScheme.secondary;
        statusText = AppLocalizations.of(context).xboardTrafficExhausted;
        statusDetail = statusResult.getDetailMessage(context) ?? AppLocalizations.of(context).xboardBuyMoreTrafficOrUpgrade;
        break;
      default:
        statusIcon = Icons.info_outlined;
        statusColor = theme.colorScheme.primary;
        statusText = statusResult.getMessage(context);
        statusDetail = statusResult.getDetailMessage(context) ?? '';
    }
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusDetail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final userState = ref.watch(xboardUserProvider);
                  return IconButton(
                    onPressed: userState.isLoading ? null : () async {
                      await ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();
                    },
                    icon: userState.isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: statusColor,
                          ),
                        )
                      : Icon(
                          Icons.refresh,
                          color: statusColor,
                          size: 20,
                        ),
                    tooltip: AppLocalizations.of(context).xboardRefreshSubscriptionInfo,
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(20, 20),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                },
              ),
            ],
          ),
          if (statusResult.expiredAt != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${AppLocalizations.of(context).xboardExpiryTime}: ${_formatDateTime(statusResult.expiredAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // 续费按钮
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, child) {
              return SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await _handleRenewAction(context, ref);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: statusColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.shopping_bag, size: 18),
                  label: Text(_getRenewButtonText(statusResult.type, context)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  String _getRenewButtonText(SubscriptionStatusType type, BuildContext context) {
    switch (type) {
      case SubscriptionStatusType.noSubscription:
        return AppLocalizations.of(context).xboardPurchasePlan;
      case SubscriptionStatusType.expired:
        return AppLocalizations.of(context).xboardRenewPlan;
      case SubscriptionStatusType.exhausted:
        return AppLocalizations.of(context).xboardPurchaseTraffic;
      default:
        return AppLocalizations.of(context).xboardPurchasePlan;
    }
  }
  
  Future<void> _handleRenewAction(BuildContext context, WidgetRef ref) async {
    final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
    
    // 尝试获取用户当前订阅的套餐ID
    final userState = ref.read(xboardUserProvider);
    final currentPlanId = userState.subscriptionInfo?.planId;
    
    if (currentPlanId != null) {
      // 确保套餐列表已加载
      var plans = ref.read(xboardSubscriptionProvider);
      if (plans.isEmpty) {
        await ref.read(xboardSubscriptionProvider.notifier).loadPlans();
        plans = ref.read(xboardSubscriptionProvider);
      }
      
      DomainPlan? currentPlan;
      try {
        currentPlan = plans.firstWhere((plan) => plan.id == currentPlanId);
      } catch (e) {
        currentPlan = null;
      }
      
      if (currentPlan != null) {
        if (isDesktop) {
          context.go('/plans');
        } else {
          context.push('/plans/purchase', extra: currentPlan);
        }
        return;
      }
    }
    
    // 没找到套餐：跳转到套餐列表页面
    if (isDesktop) {
      context.go('/plans');
    } else {
      context.push('/plans');
    }
  }
  Widget _buildUsageCard(ThemeData theme, BuildContext context) {
    final progress = _getProgressValue();
    final usedTraffic = _getUsedTraffic();
    final totalTraffic = _getTotalTraffic();
    final remainingDays = _calculateRemainingDays();
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.of(context).xboardUsed,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Consumer(
                builder: (context, ref, child) {
                  final userState = ref.watch(xboardUserProvider);
                  return IconButton(
                    onPressed: userState.isLoading ? null : () async {
                      await ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();
                    },
                    icon: userState.isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.refresh,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                    tooltip: AppLocalizations.of(context).xboardRefreshSubscriptionInfo,
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(20, 20),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Compact progress bar with percentage
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(progress, theme),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(progress, theme),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildStatItem(
                  icon: Icons.cloud_download,
                  label: AppLocalizations.of(context).xboardUsedTraffic,
                  value: _formatBytes(usedTraffic),
                  subtitle: '/ ${_formatBytes(totalTraffic)}',
                  theme: theme,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.schedule,
                  label: AppLocalizations.of(context).xboardValidityPeriod,
                  value: remainingDays == null
                    ? AppLocalizations.of(context).xboardUnlimitedTime
                    : '$remainingDays',
                  subtitle: remainingDays == null
                    ? ''
                    : AppLocalizations.of(context).xboardDays,
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextSpan(
                text: subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  String _formatBytes(double bytes) {
    if (bytes < 0) return '0 B';
    final trafficShow = bytes.toInt().traffic;
    return '${trafficShow.value} ${trafficShow.unit}';
  }
  int? _calculateRemainingDays() {
    DateTime? expiredAt;
    if (profileSubscriptionInfo?.expire != null && profileSubscriptionInfo!.expire != 0) {
      expiredAt = DateTime.fromMillisecondsSinceEpoch(profileSubscriptionInfo!.expire * 1000);
    } else if (subscriptionInfo?.expiredAt != null) {
      expiredAt = subscriptionInfo!.expiredAt;
    }
    // 如果 expiredAt 为 null，返回 null 表示不限时
    if (expiredAt == null) return null;
    final now = DateTime.now();
    final difference = expiredAt.difference(now);
    return difference.inDays.clamp(0, double.infinity).toInt();
  }
  double _getProgressValue() {
    if (profileSubscriptionInfo != null && profileSubscriptionInfo!.total > 0) {
      final used = profileSubscriptionInfo!.upload + profileSubscriptionInfo!.download;
      return (used / profileSubscriptionInfo!.total).clamp(0.0, 1.0);
    }
    return 0.0;
  }
  double _getUsedTraffic() {
    if (profileSubscriptionInfo != null) {
      return (profileSubscriptionInfo!.upload + profileSubscriptionInfo!.download).toDouble();
    }
    return 0;
  }
  double _getTotalTraffic() {
    if (profileSubscriptionInfo != null && profileSubscriptionInfo!.total > 0) {
      return profileSubscriptionInfo!.total.toDouble();
    }
    return userInfo?.transferLimit?.toDouble() ?? 0;
  }
  Color _getProgressColor(double progress, ThemeData theme) {
    if (progress >= 0.9) {
      return theme.colorScheme.error;
    } else if (progress >= 0.7) {
      return theme.colorScheme.error.withValues(alpha: 0.7);
    } else {
      return theme.colorScheme.primary;
    }
  }
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}