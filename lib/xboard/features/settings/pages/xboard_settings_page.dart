import 'dart:io';
import 'package:path/path.dart' hide windows;
import 'package:fl_clash/common/common.dart' show system, windows;
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/features/shared/widgets/xb_dashboard_card.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/shared/dialogs/dialogs.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_clash/xboard/features/shared/dialogs/theme_dialog.dart';
import 'package:fl_clash/views/hotkey.dart';
import 'package:fl_clash/views/config/advanced.dart';

import '../widgets/bypass_domain_card.dart';
import '../widgets/lan_sharing_widgets.dart';

class XBoardSettingsPage extends ConsumerWidget {
  const XBoardSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userInfo = ref.watch(userInfoProvider);
    final subscription = ref.watch(subscriptionInfoProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(appLocalizations.xboardSettings),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Section (Compact)
              if (userInfo != null) ...[
                XBDashboardCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Compact Avatar
                      Container(
                        width: 40,
                        height: 40,
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
                            userInfo.email[0].toUpperCase(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Email and plan
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              userInfo.email,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                if (subscription?.planName != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      subscription!.planName!,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  '¥${userInfo.balanceInYuan.toStringAsFixed(2)}',
                                  style: theme.textTheme.labelSmall?.copyWith(
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
                ),
                const SizedBox(height: 16),

                // Account Settings Section
                XBSectionTitle(
                  title: appLocalizations.xboardAccountSettings,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 8),
                XBDashboardCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      // Notifications subsection
                      _SubsectionHeader(
                        title: appLocalizations.xboardNotifications,
                        icon: Icons.notifications_outlined,
                      ),
                      _SettingTile(
                        icon: Icons.schedule_outlined,
                        title: appLocalizations.xboardRemindExpire,
                        trailing: _LoadingSwitch(
                          value: userInfo.remindExpire,
                          onChanged: (value) => _updateNotificationSetting(
                            ref,
                            context,
                            remindExpire: value,
                            remindTraffic: userInfo.remindTraffic,
                          ),
                        ),
                      ),
                      _SettingDivider(),
                      _SettingTile(
                        icon: Icons.data_usage_outlined,
                        title: appLocalizations.xboardRemindTraffic,
                        trailing: _LoadingSwitch(
                          value: userInfo.remindTraffic,
                          onChanged: (value) => _updateNotificationSetting(
                            ref,
                            context,
                            remindExpire: userInfo.remindExpire,
                            remindTraffic: value,
                          ),
                        ),
                      ),
                      _SettingDivider(),

                      // Security subsection
                      _SubsectionHeader(
                        title: appLocalizations.xboardSecurity,
                        icon: Icons.security_outlined,
                      ),
                      _SettingTile(
                        icon: Icons.lock_outline,
                        title: appLocalizations.xboardChangePassword,
                        subtitle: appLocalizations.password,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          showChangePasswordDialog(context, ref);
                        },
                      ),
                      _SettingDivider(),
                      _SettingTile(
                        icon: Icons.refresh_outlined,
                        title: appLocalizations.xboardResetSubscription,
                        subtitle: appLocalizations.xboardResetSubscriptionDesc,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          showResetSubscriptionDialog(context, ref);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Network Settings Section
              XBSectionTitle(
                title: appLocalizations.xboardNetworkSettings,
                icon: Icons.settings_ethernet_outlined,
              ),
              const SizedBox(height: 8),
              XBDashboardCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _NetworkSettingItem(
                        icon: Icons.block_outlined,
                        title: appLocalizations.xboardBypassDomain,
                        subtitle: appLocalizations.xboardBypassDomainDesc,
                        onTap: () async {
                          final bypassDomain = ref.read(
                            networkSettingProvider.select((state) => state.bypassDomain),
                          );
                          final result = await Navigator.of(context).push<List<String>>(
                            MaterialPageRoute(
                              builder: (context) => ListInputPage(
                                title: appLocalizations.xboardBypassDomain,
                                items: bypassDomain,
                                titleBuilder: (item) => Text(item),
                              ),
                            ),
                          );
                          if (result != null) {
                            ref.read(networkSettingProvider.notifier).update(
                                  (state) => state.copyWith(
                                    bypassDomain: List.from(result),
                                  ),
                                );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              XBDashboardCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const AllowLanCard(),
                    const Divider(height: 24),
                    const LanPortCard(),
                    const SizedBox(height: 16),
                    const LanInfoCard(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Appearance Section
              XBSectionTitle(
                title: appLocalizations.xboardAppearance,
                icon: Icons.palette_outlined,
              ),
              const SizedBox(height: 8),
              XBDashboardCard(
                padding: EdgeInsets.zero,
                child: _SettingTile(
                  icon: Icons.brightness_6,
                  title: appLocalizations.switchTheme,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showThemeDialog(context, ref);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Application Settings Section
              XBSectionTitle(
                title: appLocalizations.applicationSettings,
                icon: Icons.tune_outlined,
              ),
              const SizedBox(height: 8),
              XBDashboardCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // Advanced Configuration
                    _SettingTile(
                      icon: Icons.build_outlined,
                      title: appLocalizations.advancedConfig,
                      subtitle: appLocalizations.advancedConfigDesc,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AdvancedConfigView(),
                          ),
                        );
                      },
                    ),
                    // Hotkey Management (Desktop only)
                    if (system.isDesktop) ...[
                      _SettingDivider(),
                      _SettingTile(
                        icon: Icons.keyboard_outlined,
                        title: appLocalizations.hotkeyManagement,
                        subtitle: appLocalizations.hotkeyManagementDesc,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const HotKeyView(),
                            ),
                          );
                        },
                      ),
                    ],
                    // Loopback Unlock Tool (Windows only)
                    if (system.isWindows) ...[
                      _SettingDivider(),
                      _SettingTile(
                        icon: Icons.lock_open_outlined,
                        title: appLocalizations.loopback,
                        subtitle: appLocalizations.loopbackDesc,
                        trailing: const Icon(Icons.launch),
                        onTap: () {
                          windows?.runas(
                            '"${join(dirname(Platform.resolvedExecutable), "EnableLoopback.exe")}"',
                            '',
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Logout Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: () {
                      showLogoutDialog(context, ref);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.errorContainer,
                      foregroundColor: colorScheme.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(appLocalizations.logout),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat.yMMMd().format(date);
  }

  Future<void> _updateNotificationSetting(
    WidgetRef ref,
    BuildContext context, {
    required bool remindExpire,
    required bool remindTraffic,
  }) async {
    final appLocalizations = AppLocalizations.of(context);
    try {
      final api = await ref.read(xboardSdkProvider.future);
      await api.updateUser({
        'remind_expire': remindExpire ? 1 : 0,
        'remind_traffic': remindTraffic ? 1 : 0,
      });

      // Refresh user info to reflect changes
      await ref.read(xboardUserProvider.notifier).refreshUserInfo();

      XBoardNotification.showSuccess(
        appLocalizations.xboardNotificationUpdateSuccess,
      );
    } catch (e) {
      XBoardNotification.showError(
        '${appLocalizations.xboardNotificationUpdateError}: $e',
      );
    }
  }
}

// Subsection header within a card
class _SubsectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SubsectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Setting tile for individual settings
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

// Divider between settings
class _SettingDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 52),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
      ),
    );
  }
}

// Switch with loading overlay during async operations
class _LoadingSwitch extends StatefulWidget {
  final bool value;
  final Future<void> Function(bool) onChanged;

  const _LoadingSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  State<_LoadingSwitch> createState() => _LoadingSwitchState();
}

class _LoadingSwitchState extends State<_LoadingSwitch> {
  bool _isLoading = false;

  Future<void> _handleChanged(bool value) async {
    setState(() => _isLoading = true);
    try {
      await widget.onChanged(value);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: _isLoading ? 0.4 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Switch(
              value: widget.value,
              onChanged: _isLoading ? null : _handleChanged,
            ),
          ),
          if (_isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}

// Network setting item
class _NetworkSettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NetworkSettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

