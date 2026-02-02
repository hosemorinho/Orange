import 'dart:io';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final userAuthState = ref.watch(xboardUserProvider);
    final subscription = ref.watch(subscriptionInfoProvider);
    final user = ref.watch(userInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.xboardSubscriptionDetails),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          IconButton(
            icon: userAuthState.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onSurface,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: userAuthState.isLoading
                ? null
                : () => ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo(),
          ),
        ],
      ),
      body: subscription == null
          ? _buildNoSubscription(theme)
          : RefreshIndicator(
              onRefresh: () => ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildPlanInfoCard(theme, subscription, user),
                  const SizedBox(height: 16),
                  _buildTrafficCard(theme, subscription),
                  const SizedBox(height: 16),
                  _buildTimeInfoCard(theme, subscription),
                ],
              ),
            ),
    );
  }

  Widget _buildNoSubscription(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.xboardNoSubscriptionInfo,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.xboardPurchasePlanPrompt,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
              if (isDesktop) {
                context.go('/plans');
              } else {
                context.push('/plans');
              }
            },
            icon: const Icon(Icons.shopping_bag_outlined),
            label: Text(l10n.xboardBrowsePlansButton),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanInfoCard(ThemeData theme, DomainSubscription sub, DomainUser? user) {
    final l10n = AppLocalizations.of(context)!;
    final statusInfo = _getStatusInfo(sub, theme);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
            theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
          ],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.workspace_premium,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.planName ?? l10n.xboardPlanWithId(sub.planId),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusInfo.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusInfo.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: statusInfo.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (sub.speedLimit != null || sub.deviceLimit != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (sub.speedLimit != null) ...[
                  _buildInfoChip(theme, Icons.speed, '${sub.speedLimit} Mbps'),
                  const SizedBox(width: 8),
                ],
                if (sub.deviceLimit != null)
                  _buildInfoChip(theme, Icons.devices, l10n.xboardDeviceLimitCount(sub.deviceLimit!)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(ThemeData theme, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficCard(ThemeData theme, DomainSubscription sub) {
    final l10n = AppLocalizations.of(context)!;
    final progress = sub.transferLimit > 0
        ? (sub.totalUsedBytes / sub.transferLimit).clamp(0.0, 1.0)
        : 0.0;
    final progressColor = _getProgressColor(progress, theme);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.data_usage, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.xboardTrafficUsage,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${sub.usagePercentage.toStringAsFixed(1)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTrafficItem(
                  theme,
                  l10n.xboardUsed,
                  sub.formattedUsedTraffic,
                  Icons.cloud_upload_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
              ),
              Expanded(
                child: _buildTrafficItem(
                  theme,
                  l10n.xboardRemaining,
                  sub.formattedRemainingTraffic,
                  Icons.cloud_download_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
              ),
              Expanded(
                child: _buildTrafficItem(
                  theme,
                  l10n.xboardTotal,
                  sub.formattedTotalTraffic,
                  Icons.cloud_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        l10n.xboardUploadTrafficLabel(sub.formattedUploadedTraffic),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.arrow_downward, size: 14, color: theme.colorScheme.secondary),
                      const SizedBox(width: 4),
                      Text(
                        l10n.xboardDownloadTrafficLabel(sub.formattedDownloadedTraffic),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficItem(ThemeData theme, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfoCard(ThemeData theme, DomainSubscription sub) {
    final l10n = AppLocalizations.of(context)!;
    final daysRemaining = sub.daysRemaining;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.xboardTimeInfo,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimeRow(
            theme,
            l10n.xboardExpiryTime,
            sub.expiredAt != null ? _formatDateTime(sub.expiredAt!) : l10n.xboardNeverExpire,
          ),
          if (daysRemaining != null) ...[
            const SizedBox(height: 8),
            _buildTimeRow(
              theme,
              l10n.xboardRemainingDaysLabel,
              l10n.xboardRemainingDaysCount(daysRemaining),
              valueColor: daysRemaining <= 0
                  ? theme.colorScheme.error
                  : daysRemaining <= 7
                      ? theme.colorScheme.error.withValues(alpha: 0.7)
                      : null,
            ),
          ],
          if (sub.nextResetAt != null) ...[
            const SizedBox(height: 8),
            _buildTimeRow(
              theme,
              l10n.xboardResetTraffic,
              _formatDateTime(sub.nextResetAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeRow(ThemeData theme, String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  ({String label, Color color}) _getStatusInfo(DomainSubscription sub, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;
    if (sub.isExpired) {
      return (label: l10n.xboardExpired, color: colorScheme.error);
    }
    if (sub.isTrafficExhausted) {
      return (label: l10n.xboardTrafficExhausted, color: colorScheme.error.withValues(alpha: 0.7));
    }
    if (sub.isExpiringSoon) {
      return (label: l10n.xboardExpiringSoon, color: colorScheme.error.withValues(alpha: 0.7));
    }
    return (label: l10n.xboardActive, color: colorScheme.tertiary);
  }

  Color _getProgressColor(double progress, ThemeData theme) {
    if (progress >= 0.9) return theme.colorScheme.error;
    if (progress >= 0.7) return theme.colorScheme.error.withValues(alpha: 0.7);
    return theme.colorScheme.primary;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
