import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/bypass_domain_card.dart';
import '../widgets/lan_sharing_widgets.dart';

class XBoardSettingsPage extends ConsumerWidget {
  const XBoardSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.xboardSettings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: appLocalizations.xboardNetworkSettings),
          const SizedBox(height: 8),
          const BypassDomainCard(),
          const SizedBox(height: 24),
          _SectionHeader(title: appLocalizations.xboardLanSharing),
          const SizedBox(height: 8),
          const AllowLanCard(),
          const SizedBox(height: 8),
          const LanPortCard(),
          const SizedBox(height: 8),
          const LanInfoCard(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
