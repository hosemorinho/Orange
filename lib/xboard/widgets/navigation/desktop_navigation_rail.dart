import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Desktop side navigation rail.
class DesktopNavigationRail extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const DesktopNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 88,
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        border: Border(
          right: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Expanded(child: _buildNavigationItems(context, colorScheme)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context, ColorScheme colorScheme) {
    final appLocalizations = AppLocalizations.of(context);

    return NavigationRail(
      backgroundColor: Colors.transparent,
      selectedIndex: selectedIndex,
      extended: false,
      labelType: NavigationRailLabelType.all,
      leading: null,
      useIndicator: true,
      indicatorColor: colorScheme.primary.withValues(alpha: 0.14),
      selectedIconTheme: IconThemeData(color: colorScheme.primary, size: 24),
      selectedLabelTextStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
      ),
      unselectedIconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 22,
      ),
      unselectedLabelTextStyle: TextStyle(
        fontSize: 11,
        color: colorScheme.onSurfaceVariant,
      ),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text(appLocalizations.xboardHome),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.shopping_bag_outlined),
          selectedIcon: const Icon(Icons.shopping_bag),
          label: Text(appLocalizations.xboardPlans),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.support_agent_outlined),
          selectedIcon: const Icon(Icons.support_agent),
          label: Text(appLocalizations.xboardTickets),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.people_outline),
          selectedIcon: const Icon(Icons.people),
          label: Text(appLocalizations.xboardInvite),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: Text(appLocalizations.xboardSettings),
        ),
      ],
      onDestinationSelected: onDestinationSelected,
    );
  }
}
