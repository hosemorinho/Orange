import 'package:flutter/material.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/features/shared/shared.dart';

/// Statistics section for invite page
///
/// Displays stats as compact text rows inside a dashboard card
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

        // Stats card with compact rows
        XBDashboardCard(
          child: Column(
            children: [
              _CompactStatRow(
                icon: Icons.people_outline,
                label: appLocalizations.xboardRegisteredUsers,
                value: stats.registeredUsers.toString(),
              ),
              const Divider(height: 1),
              _CompactStatRow(
                icon: Icons.check_circle_outline,
                label: appLocalizations.xboardSettledCommission,
                value: '¥${stats.settledCommission.toStringAsFixed(2)}',
              ),
              const Divider(height: 1),
              _CompactStatRow(
                icon: Icons.schedule,
                label: appLocalizations.xboardPendingCommission,
                value: '¥${stats.pendingCommission.toStringAsFixed(2)}',
              ),
              const Divider(height: 1),
              _CompactStatRow(
                icon: Icons.trending_up,
                label: hasCustomRate
                    ? appLocalizations.xboardCustomCommissionRate
                    : appLocalizations.xboardSystemCommissionRate,
                value: '${effectiveRate.toStringAsFixed(0)}%',
              ),
              const Divider(height: 1),
              _CompactStatRow(
                icon: Icons.account_balance_wallet_outlined,
                label: appLocalizations.xboardAvailableCommission,
                value: '¥${stats.availableCommission.toStringAsFixed(2)}',
                bold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactStatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool bold;

  const _CompactStatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: bold ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
