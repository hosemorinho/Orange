import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/shared/dialogs/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final tun = ref.watch(
      patchClashConfigProvider.select((state) => state.tun.enable),
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: FocusTraversalGroup(
            child: ListView(
              padding: const EdgeInsets.all(32),
              children: [
                // User info card
                if (userInfo != null) ...[
                  _UserInfoCard(
                    email: userInfo.email,
                    planName: subscription?.planName,
                    balance: userInfo.balanceInYuan,
                  ),
                  const SizedBox(height: 24),
                ],

                // Settings header
                Text(
                  appLocalizations.xboardSettings,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Theme
                _TvSettingRow(
                  icon: Icons.brightness_6,
                  title: appLocalizations.switchTheme,
                  autofocus: true,
                  trailing: const _ThemeLabel(),
                  onPressed: () => showThemeDialog(context, ref),
                ),
                const SizedBox(height: 8),

                // TUN mode
                _TvSettingRow(
                  icon: Icons.security,
                  title: 'TUN',
                  trailing: _TunToggle(tun: tun),
                  onPressed: () {
                    ref
                        .read(patchClashConfigProvider.notifier)
                        .update((state) => state.copyWith.tun(enable: !tun));
                  },
                ),
                const SizedBox(height: 8),

                // Proxy mode
                _TvSettingRow(
                  icon: Icons.route,
                  title: appLocalizations.outboundMode,
                  trailing: Text(
                    mode == Mode.rule
                        ? appLocalizations.rule
                        : appLocalizations.global,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    final newMode = mode == Mode.rule ? Mode.global : Mode.rule;
                    appController.changeMode(newMode);
                  },
                ),
                const SizedBox(height: 32),

                // Logout button
                const _TvLogoutButton(),
              ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
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
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          planName!,
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '\u00a5${balance.toStringAsFixed(2)}',
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
      height: 72,
      child: TvFocusCard(
        autofocus: autofocus,
        onPressed: onPressed,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 28, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing!,
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
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TunToggle extends StatelessWidget {
  final bool tun;

  const _TunToggle({required this.tun});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: tun
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        tun ? 'ON' : 'OFF',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: tun
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TvLogoutButton extends ConsumerStatefulWidget {
  const _TvLogoutButton();

  @override
  ConsumerState<_TvLogoutButton> createState() => _TvLogoutButtonState();
}

class _TvLogoutButtonState extends ConsumerState<_TvLogoutButton> {
  bool _isFocused = false;
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.select ||
            event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
      showLogoutDialog(context, ref);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appLocalizations = AppLocalizations.of(context);

    return Focus(
      focusNode: _focusNode,
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () => showLogoutDialog(context, ref),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 64,
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
            border: _isFocused
                ? Border.all(color: colorScheme.error, width: 3)
                : null,
          ),
          child: Center(
            child: Text(
              appLocalizations.logout,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
