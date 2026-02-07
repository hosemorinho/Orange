import 'package:flutter/material.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/features/shared/shared.dart';

/// Header matching frontend's PageHeader component.
///
/// CSS: w-full px-6 py-4 bg-white/50 backdrop-blur-sm border-b border-slate-200
/// Layout: Logo + AppName (left) | ThemeToggle + LanguageSwitcher (right)
class AuthHeader extends StatelessWidget {
  final Widget? trailing;

  const AuthHeader({super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        // bg-white/50 dark:bg-slate-900/50
        color: colorScheme.surface.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            // border-slate-200 dark:border-slate-700
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo: 32x32 primary square with lightning bolt icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.flash_on_rounded,
              size: 20,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 8),
          // App name: text-xl font-bold
          Text(
            appName,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Right side: LanguageSelector + optional trailing
          const LanguageSelector(),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}
