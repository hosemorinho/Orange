import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/shared/dialogs/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/tv_design_tokens.dart';
import '../widgets/tv_focus_card.dart';

/// TV settings page with large, D-pad friendly controls.
class TvSettingsPage extends ConsumerWidget {
  const TvSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appLocalizations = AppLocalizations.of(context);
    final userInfo = ref.watch(userInfoProvider);
    final subscription = ref.watch(subscriptionInfoProvider);
    final mode = ref.watch(
      patchClashConfigProvider.select((state) => state.mode),
    );

    return Scaffold(
      body: DecoratedBox(
        decoration: TvDesignTokens.background(colorScheme),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Padding(
                padding: TvDesignTokens.pagePadding,
                child: Container(
                  decoration: TvDesignTokens.panel(
                    colorScheme,
                    emphasized: true,
                  ),
                  child: FocusTraversalGroup(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.settings_rounded,
                              size: 24,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              appLocalizations.xboardSettings,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        if (userInfo != null) ...[
                          _UserInfoCard(
                            email: userInfo.email,
                            planName: subscription?.planName,
                            balance: userInfo.balanceInYuan,
                          ),
                          const SizedBox(height: 18),
                        ],

                        _TvSettingRow(
                          icon: Icons.brightness_6_rounded,
                          title: appLocalizations.switchTheme,
                          autofocus: true,
                          trailing: const _ThemeLabel(),
                          onPressed: () => showThemeDialog(context, ref),
                        ),
                        const SizedBox(height: 10),

                        _TvSettingRow(
                          icon: Icons.route_rounded,
                          title: appLocalizations.outboundMode,
                          trailing: Text(
                            mode == Mode.rule
                                ? appLocalizations.rule
                                : appLocalizations.global,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () {
                            final newMode = mode == Mode.rule
                                ? Mode.global
                                : Mode.rule;
                            appController.changeMode(newMode);
                          },
                        ),
                        const SizedBox(height: 24),

                        const _TvLogoutButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  final String email;
  final String? planName;
  final double balance;

  const _UserInfoCard({
    required this.email,
    required this.planName,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                email.isNotEmpty ? email[0].toUpperCase() : '?',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (planName != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          planName!,
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '${AppLocalizations.of(context).xboardAccountBalance}: ¥${balance.toStringAsFixed(2)}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TvSettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool autofocus;
  final Widget? trailing;
  final VoidCallback? onPressed;

  const _TvSettingRow({
    required this.icon,
    required this.title,
    this.autofocus = false,
    this.trailing,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 76,
      child: TvFocusCard(
        autofocus: autofocus,
        onPressed: onPressed,
        borderRadius: BorderRadius.circular(TvDesignTokens.controlRadius),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null) ...[trailing!],
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeLabel extends ConsumerWidget {
  const _ThemeLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      themeSettingProvider.select((state) => state.themeMode),
    );
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    String label;
    switch (themeMode) {
      case ThemeMode.light:
        label = appLocalizations.light;
      case ThemeMode.dark:
        label = appLocalizations.dark;
      case ThemeMode.system:
        label = appLocalizations.auto;
    }

    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TvLogoutButton extends ConsumerWidget {
  const _TvLogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final appLocalizations = AppLocalizations.of(context);

    return SizedBox(
      height: 74,
      child: TvFocusCard(
        onPressed: () => showLogoutDialog(context, ref),
        borderRadius: BorderRadius.circular(TvDesignTokens.controlRadius),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 22, color: colorScheme.error),
            const SizedBox(width: 10),
            Text(
              appLocalizations.logout,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
