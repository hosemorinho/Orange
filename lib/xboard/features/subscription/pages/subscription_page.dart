import 'dart:io';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final userAuthState = ref.watch(xboardUserProvider);
    final subscription = ref.watch(subscriptionInfoProvider);
    final user = ref.watch(userInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('订阅详情'),
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
                  const SizedBox(height: 16),
                  _buildSubscriptionUrlCard(theme, subscription),
                ],
              ),
            ),
    );
  }

  Widget _buildNoSubscription(ThemeData theme) {
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
            '暂无订阅信息',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请先购买套餐',
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
            label: const Text('浏览套餐'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanInfoCard(ThemeData theme, DomainSubscription sub, DomainUser? user) {
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
                      sub.planName ?? '套餐 #${sub.planId}',
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
                  _buildInfoChip(theme, Icons.devices, '${sub.deviceLimit} 设备'),
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
                '流量使用',
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
                  '已用',
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
                  '剩余',
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
                  '总计',
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
                        '上传: ${sub.formattedUploadedTraffic}',
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
                        '下载: ${sub.formattedDownloadedTraffic}',
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
                '时间信息',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimeRow(
            theme,
            '到期时间',
            sub.expiredAt != null ? _formatDateTime(sub.expiredAt!) : '永不过期',
          ),
          if (daysRemaining != null) ...[
            const SizedBox(height: 8),
            _buildTimeRow(
              theme,
              '剩余天数',
              '$daysRemaining 天',
              valueColor: daysRemaining <= 7
                  ? Colors.orange.shade600
                  : daysRemaining <= 0
                      ? Colors.red.shade600
                      : null,
            ),
          ],
          if (sub.nextResetAt != null) ...[
            const SizedBox(height: 8),
            _buildTimeRow(
              theme,
              '流量重置',
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

  Widget _buildSubscriptionUrlCard(ThemeData theme, DomainSubscription sub) {
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
              Icon(Icons.link, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '订阅链接',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              sub.subscribeUrl,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _copySubscriptionUrl(sub.subscribeUrl),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('复制链接'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _importSubscription(sub.subscribeUrl),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('一键导入'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '请妥善保管您的订阅链接，不要分享给他人',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copySubscriptionUrl(String url) {
    Clipboard.setData(ClipboardData(text: url));
    XBoardNotification.showSuccess('订阅链接已复制到剪贴板');
  }

  void _importSubscription(String url) {
    Clipboard.setData(ClipboardData(text: url));
    XBoardNotification.showSuccess('订阅链接已复制，请在首页导入');
  }

  ({String label, Color color}) _getStatusInfo(DomainSubscription sub, ThemeData theme) {
    if (sub.isExpired) {
      return (label: '已过期', color: Colors.red.shade600);
    }
    if (sub.isTrafficExhausted) {
      return (label: '流量耗尽', color: Colors.orange.shade600);
    }
    if (sub.isExpiringSoon) {
      return (label: '即将到期', color: Colors.orange.shade600);
    }
    return (label: '生效中', color: Colors.green.shade600);
  }

  Color _getProgressColor(double progress, ThemeData theme) {
    if (progress >= 0.9) return Colors.red.shade400;
    if (progress >= 0.7) return Colors.orange.shade400;
    return theme.colorScheme.primary;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
