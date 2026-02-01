import 'package:flutter/material.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/domain/domain.dart';

/// Statistics cards section for invite page
///
/// Displays 5 stat cards in responsive grid:
/// - Mobile: 1 column
/// - Tablet: 2 columns
/// - Desktop: 5 columns
class InviteStatsSection extends StatelessWidget {
  final DomainInviteStats stats;
  final double? customCommissionRate;

  const InviteStatsSection({
    super.key,
    required this.stats,
    this.customCommissionRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine which commission rate to display
    final effectiveRate = customCommissionRate ?? stats.commissionRate;
    final hasCustomRate = customCommissionRate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom rate banner (if applicable)
        if (hasCustomRate) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: '${appLocalizations.xboardCustomCommissionRate}: ',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: '${effectiveRate.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        TextSpan(
                          text: ' (${appLocalizations.xboardUserSpecificRate})',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Stats cards grid
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive columns
            int crossAxisCount = 1;
            if (constraints.maxWidth >= 1200) {
              crossAxisCount = 5; // Desktop: 5 columns
            } else if (constraints.maxWidth >= 600) {
              crossAxisCount = 2; // Tablet: 2 columns
            }

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: crossAxisCount == 5 ? 1.1 : 1.8,
              children: [
                _StatCard(
                  title: appLocalizations.xboardRegisteredUsers,
                  value: stats.registeredUsers.toString(),
                  icon: Icons.people_outline,
                  color: colorScheme.primary,
                ),
                _StatCard(
                  title: appLocalizations.xboardSettledCommission,
                  value: stats.settledCommission.toStringAsFixed(2),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                _StatCard(
                  title: appLocalizations.xboardPendingCommission,
                  value: stats.pendingCommission.toStringAsFixed(2),
                  icon: Icons.schedule,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: hasCustomRate
                      ? appLocalizations.xboardCustomCommissionRate
                      : appLocalizations.xboardSystemCommissionRate,
                  value: effectiveRate.toStringAsFixed(0),
                  unit: '%',
                  icon: Icons.trending_up,
                  color: colorScheme.primary,
                ),
                _StatCard(
                  title: appLocalizations.xboardAvailableCommission,
                  value: stats.availableCommission.toStringAsFixed(2),
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.green,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Individual stat card widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          // Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
