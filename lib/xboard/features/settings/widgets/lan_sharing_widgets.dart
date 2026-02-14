import 'dart:io';

import 'package:fl_clash/common/utils.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllowLanCard extends ConsumerWidget {
  const AllowLanCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final allowLan = ref.watch(
      patchClashConfigProvider.select((state) => state.allowLan),
    );

    return SwitchListTile(
      secondary: Icon(Icons.wifi, color: theme.colorScheme.primary),
      title: Text(appLocalizations.xboardAllowLan),
      subtitle: Text(appLocalizations.xboardLanSharingDesc),
      value: allowLan,
      contentPadding: EdgeInsets.zero,
      onChanged: (value) {
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith(allowLan: value));
      },
    );
  }
}

class LanPortCard extends ConsumerWidget {
  const LanPortCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final mixedPort = ref.watch(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.settings_ethernet, color: theme.colorScheme.primary),
      title: Text(appLocalizations.xboardProxyPort),
      subtitle: Text('$mixedPort'),
      trailing: const Icon(Icons.edit),
      onTap: () => _showPortDialog(context, ref, mixedPort),
    );
  }

  void _showPortDialog(BuildContext context, WidgetRef ref, int currentPort) {
    final controller = TextEditingController(text: '$currentPort');
    final appLocalizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(appLocalizations.xboardProxyPort),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '1024-65535',
              border: const OutlineInputBorder(),
              labelText: appLocalizations.port,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(appLocalizations.cancel),
            ),
            FilledButton(
              onPressed: () {
                final port = int.tryParse(controller.text);
                if (port == null || port < 1024 || port > 65535) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        appLocalizations.portTip(appLocalizations.port),
                      ),
                    ),
                  );
                  return;
                }
                ref
                    .read(patchClashConfigProvider.notifier)
                    .update((state) => state.copyWith(mixedPort: port));
                Navigator.pop(context);
              },
              child: Text(appLocalizations.confirm),
            ),
          ],
        );
      },
    );
  }
}

class LanInfoCard extends ConsumerStatefulWidget {
  const LanInfoCard({super.key});

  @override
  ConsumerState<LanInfoCard> createState() => _LanInfoCardState();
}

class _LanInfoCardState extends ConsumerState<LanInfoCard> {
  String? _localIp;

  @override
  void initState() {
    super.initState();
    _loadIp();
  }

  Future<void> _loadIp() async {
    final ip = await utils.getLocalIpAddress();
    if (mounted) {
      setState(() => _localIp = ip);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final allowLan = ref.watch(
      patchClashConfigProvider.select((state) => state.allowLan),
    );
    final mixedPort = ref.watch(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );

    if (!allowLan) return const SizedBox.shrink();

    final ip = _localIp ?? '...';
    final httpProxy = 'http://$ip:$mixedPort';
    final socksProxy = 'socks5://$ip:$mixedPort';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                appLocalizations.xboardProxyInfo,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProxyInfoRow(label: 'HTTP/HTTPS', value: httpProxy),
          const SizedBox(height: 6),
          _ProxyInfoRow(label: 'SOCKS5', value: socksProxy),
          const Divider(height: 24),
          Text(
            appLocalizations.xboardProxyCommands,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          _CommandBlock(
            platform: 'Unix (Bash/Zsh)',
            command:
                'export HTTP_PROXY=$httpProxy\nexport HTTPS_PROXY=$httpProxy\nexport ALL_PROXY=$socksProxy',
          ),
          const SizedBox(height: 8),
          _CommandBlock(
            platform: 'Windows (PowerShell)',
            command:
                '\$env:HTTP_PROXY="$httpProxy"\n\$env:HTTPS_PROXY="$httpProxy"\n\$env:ALL_PROXY="$socksProxy"',
          ),
          const SizedBox(height: 8),
          _CommandBlock(
            platform: 'Windows (CMD)',
            command:
                'set HTTP_PROXY=$httpProxy\nset HTTPS_PROXY=$httpProxy\nset ALL_PROXY=$socksProxy',
          ),
          if (Platform.isMacOS) ...[
            const SizedBox(height: 8),
            _CommandBlock(
              platform: 'macOS System Proxy',
              command:
                  'networksetup -setwebproxy "Wi-Fi" $ip $mixedPort\nnetworksetup -setsecurewebproxy "Wi-Fi" $ip $mixedPort\nnetworksetup -setsocksfirewallproxy "Wi-Fi" $ip $mixedPort',
            ),
          ],
        ],
      ),
    );
  }
}

class _ProxyInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProxyInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 16),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(appLocalizations.xboardCopied),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          visualDensity: VisualDensity.compact,
          tooltip: appLocalizations.copy,
        ),
      ],
    );
  }
}

class _CommandBlock extends StatelessWidget {
  final String platform;
  final String command;

  const _CommandBlock({required this.platform, required this.command});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  platform,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 14),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: command));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(appLocalizations.xboardCopied),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  visualDensity: VisualDensity.compact,
                  tooltip: appLocalizations.copy,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text(
              command,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 11,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
