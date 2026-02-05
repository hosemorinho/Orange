import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/features/shared/shared.dart';

/// Quick Actions card with compact horizontal tile layout
class QuickActionsCard extends ConsumerWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = AppLocalizations.of(context);
    final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;

    return XBDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          XBSectionTitle(
            title: appLocalizations.xboardQuickActions,
            icon: Icons.flash_on,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CompactActionTile(
                  icon: Icons.shopping_bag_outlined,
                  title: appLocalizations.xboardPurchaseSubscription,
                  onTap: () {
                    if (isDesktop) {
                      context.go('/plans');
                    } else {
                      context.push('/plans');
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CompactActionTile(
                  icon: Icons.receipt_long_outlined,
                  title: appLocalizations.xboardMyOrders,
                  onTap: () => context.push('/orders'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CompactActionTile(
                  icon: Icons.support_agent_outlined,
                  title: appLocalizations.xboardSupportTickets,
                  onTap: () {
                    if (isDesktop) {
                      context.go('/support');
                    } else {
                      context.push('/support');
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CompactActionTile(
                  icon: Icons.person_add_outlined,
                  title: appLocalizations.xboardInviteFriends,
                  onTap: () => context.go('/invite'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _CompactActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
