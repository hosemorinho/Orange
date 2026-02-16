import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/config.dart';

/// Shows a theme selection dialog using FlClash's native UI patterns.
///
/// Usage:
/// ```dart
/// final result = await showThemeDialog(context, ref);
/// ```
Future<void> showThemeDialog(BuildContext context, WidgetRef ref) async {
  final currentThemeMode = ref.read(themeSettingProvider.select((state) => state.themeMode));

  final result = await showDialog<ThemeMode>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(appLocalizations.selectTheme),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            final IconData icon;
            final String label;
            switch (mode) {
              case ThemeMode.system:
                icon = Icons.auto_mode;
                label = appLocalizations.auto;
                break;
              case ThemeMode.light:
                icon = Icons.light_mode;
                label = appLocalizations.light;
                break;
              case ThemeMode.dark:
                icon = Icons.dark_mode;
                label = appLocalizations.dark;
                break;
            }

            return RadioListTile<ThemeMode>(
              value: mode,
              groupValue: currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  Navigator.of(context).pop(value);
                }
              },
              title: Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 12),
                  Text(label),
                ],
              ),
            );
          }).toList(),
        ),
      );
    },
  );

  if (result != null && result != currentThemeMode) {
    ref.read(themeSettingProvider.notifier).update(
      (state) => state.copyWith(themeMode: result),
    );
  }
}
