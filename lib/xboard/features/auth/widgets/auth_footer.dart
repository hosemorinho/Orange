import 'package:flutter/material.dart';
import 'package:fl_clash/common/common.dart';

/// Footer matching frontend's PageFooter component.
///
/// CSS: w-full px-6 py-4 bg-white/50 backdrop-blur-sm border-t
/// Content: "2026 AppName. All rights reserved."
class AuthFooter extends StatelessWidget {
  const AuthFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Text(
        '\u00A9 ${DateTime.now().year} $appName.',
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
