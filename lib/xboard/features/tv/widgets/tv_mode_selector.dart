import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tv_focus_card.dart';

/// D-pad friendly Rule/Global mode switcher for TV.
class TvModeSelector extends ConsumerWidget {
  const TvModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode =
        ref.watch(patchClashConfigProvider.select((state) => state.mode));
    final appLocalizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ModeButton(
          label: appLocalizations.rule,
          isSelected: mode == Mode.rule,
          onPressed: () => appController.changeMode(Mode.rule),
          colorScheme: colorScheme,
          textTheme: textTheme,
        ),
        const SizedBox(width: 12),
        _ModeButton(
          label: appLocalizations.global,
          isSelected: mode == Mode.global,
          onPressed: () => appController.changeMode(Mode.global),
          colorScheme: colorScheme,
          textTheme: textTheme,
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 48,
      child: TvFocusCard(
        isSelected: isSelected,
        onPressed: onPressed,
        borderRadius: BorderRadius.circular(24),
        padding: EdgeInsets.zero,
        child: Center(
          child: Text(
            label,
            style: textTheme.titleSmall?.copyWith(
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
