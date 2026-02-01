import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/features/shared/shared.dart';

/// Quick Actions card matching frontend Dashboard.tsx design
///
/// Provides quick access to:
/// - Purchase plans
/// - View orders
/// - Support tickets
/// - Invite friends
class QuickActionsCard extends ConsumerWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return XBDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          XBSectionTitle(
            title: appLocalizations.xboardQuickActions,
            icon: Icons.flash_on,
          ),
          const SizedBox(height: 16),
          _QuickActionButton(
            icon: Icons.shopping_bag_outlined,
            iconColor: Theme.of(context).colorScheme.primary,
            iconBackground: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            title: appLocalizations.xboardPurchaseSubscription,
            subtitle: appLocalizations.xboardBrowsePlans,
            onTap: () {
              final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
              if (isDesktop) {
                context.go('/plans');
              } else {
                context.push('/plans');
              }
            },
          ),
          const SizedBox(height: 12),
          _QuickActionButton(
            icon: Icons.receipt_long_outlined,
            iconColor: Theme.of(context).colorScheme.primary,
            iconBackground: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            title: appLocalizations.xboardMyOrders,
            subtitle: appLocalizations.xboardViewOrders,
            onTap: () {
              final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
              if (isDesktop) {
                context.go('/orders');
              } else {
                context.push('/orders');
              }
            },
          ),
          const SizedBox(height: 12),
          _QuickActionButton(
            icon: Icons.support_agent_outlined,
            iconColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
            iconBackground: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
            title: appLocalizations.xboardSupportTickets,
            subtitle: appLocalizations.xboardGetSupport,
            trailing: const _TicketBadge(),
            onTap: () {
              final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
              if (isDesktop) {
                context.go('/tickets');
              } else {
                context.push('/tickets');
              }
            },
          ),
          const SizedBox(height: 12),
          _QuickActionButton(
            icon: Icons.person_add_outlined,
            iconColor: Theme.of(context).colorScheme.tertiary,
            iconBackground: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
            title: appLocalizations.xboardInviteFriends,
            subtitle: appLocalizations.xboardEarnCommission,
            onTap: () {
              final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
              if (isDesktop) {
                context.go('/invite');
              } else {
                context.push('/invite');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _QuickActionButton({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Trailing (badge or arrow)
              if (trailing != null) trailing!,
              // Arrow icon
              Icon(
                Icons.chevron_right,
                size: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ticket count badge (placeholder - to be connected with actual ticket provider)
class _TicketBadge extends ConsumerWidget {
  const _TicketBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Connect with actual ticket provider to show pending count
    const pendingCount = 0; // Placeholder

    if (pendingCount == 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$pendingCount',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
