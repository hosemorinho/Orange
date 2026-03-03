import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'tv_design_tokens.dart';
import 'tv_focus_card.dart';

/// Top tab bar + content layout for TV.
class TvShellLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const TvShellLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: TvDesignTokens.background(colorScheme),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Column(
              children: [
                _TvTopTabBar(
                  currentIndex: navigationShell.currentIndex,
                  onIndexChanged: (index) {
                    navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    );
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      FocusScope.of(context).nextFocus();
                    });
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    decoration: TvDesignTokens.panel(colorScheme),
                    clipBehavior: Clip.antiAlias,
                    child: navigationShell,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TvTopTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const _TvTopTabBar({
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appLocalizations = AppLocalizations.of(context);

    final tabs = [
      (icon: Icons.home, label: appLocalizations.xboardHome),
      (icon: Icons.settings, label: appLocalizations.xboardSettings),
    ];

    return Container(
      height: 76,
      decoration: TvDesignTokens.panel(colorScheme, emphasized: true),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: FocusTraversalGroup(
        child: Row(
          children: [
            for (int i = 0; i < tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              _TabButton(
                icon: tabs[i].icon,
                label: tabs[i].label,
                isSelected: currentIndex == i,
                onPressed: () => onIndexChanged(i),
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ],
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return SizedBox(
      width: 192,
      child: TvFocusCard(
        autofocus: isSelected,
        isSelected: isSelected,
        onPressed: onPressed,
        borderRadius: BorderRadius.circular(TvDesignTokens.controlRadius),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: fgColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: textTheme.titleSmall?.copyWith(
                color: fgColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
