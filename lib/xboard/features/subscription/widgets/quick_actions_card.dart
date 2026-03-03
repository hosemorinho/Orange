import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/features/shared/shared.dart';

/// Quick Actions card with compact horizontal tile layout
class QuickActionsCard extends ConsumerWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop =
        Platform.isLinux || Platform.isWindows || Platform.isMacOS;

    return XBDashboardCard(
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      borderColor: Colors.transparent,
      showBorder: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: _CompactActionTile(
                  icon: Icons.shopping_bag_outlined,
                  title: appLocalizations.xboardPurchaseSubscription,
                  tintColor: colorScheme.primary,
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
                  tintColor: colorScheme.primary,
                  onTap: () => context.push('/orders'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CompactActionTile(
                  icon: Icons.support_agent_outlined,
                  title: appLocalizations.xboardSupportTickets,
                  tintColor: colorScheme.primary,
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
                  tintColor: colorScheme.primary,
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
  final Color tintColor;
  final VoidCallback onTap;

  const _CompactActionTile({
    required this.icon,
    required this.title,
    required this.tintColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 20, color: tintColor),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
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
