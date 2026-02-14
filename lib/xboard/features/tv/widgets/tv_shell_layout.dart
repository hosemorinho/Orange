import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Top tab bar + content layout for TV.
class TvShellLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const TvShellLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
          Divider(
            height: 1,
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          Expanded(child: navigationShell),
        ],
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
      height: 64,
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FocusTraversalGroup(
        child: Row(
          children: [
            for (int i = 0; i < tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
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

class _TabButton extends StatefulWidget {
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
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _isFocused = false;

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.select ||
            event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
      widget.onPressed();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    Border? border;

    if (widget.isSelected) {
      bgColor = widget.colorScheme.primaryContainer;
      fgColor = widget.colorScheme.onPrimaryContainer;
    } else {
      bgColor = Colors.transparent;
      fgColor = widget.colorScheme.onSurfaceVariant;
    }

    if (_isFocused) {
      border = Border.all(color: widget.colorScheme.primary, width: 3);
    }

    return Focus(
      autofocus: widget.isSelected,
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 180,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: border,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 20, color: fgColor),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: widget.textTheme.titleSmall?.copyWith(
                  color: fgColor,
                  fontWeight: widget.isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
