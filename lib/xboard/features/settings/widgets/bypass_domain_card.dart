import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/config.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BypassDomainCard extends ConsumerWidget {
  const BypassDomainCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bypassDomain = ref.watch(
      networkSettingProvider.select((state) => state.bypassDomain),
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.block,
          color: theme.colorScheme.primary,
        ),
        title: Text(appLocalizations.xboardBypassDomain),
        subtitle: Text(
          bypassDomain.isEmpty
              ? appLocalizations.xboardBypassDomainDesc
              : appLocalizations.xboardBypassDomainCount(bypassDomain.length),
        ),
        trailing: const Icon(Icons.chevron_right),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const _BypassDomainPage(),
            ),
          );
        },
      ),
    );
  }
}

class _BypassDomainPage extends ConsumerWidget {
  const _BypassDomainPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = AppLocalizations.of(context);
    final bypassDomain = ref.watch(
      networkSettingProvider.select((state) => state.bypassDomain),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.xboardBypassDomain),
        actions: [
          IconButton(
            onPressed: () async {
              final res = await globalState.showMessage(
                title: appLocalizations.reset,
                message: TextSpan(
                  text: appLocalizations.resetTip,
                ),
              );
              if (res != true) return;
              ref.read(networkSettingProvider.notifier).updateState(
                    (state) => state.copyWith(
                      bypassDomain: defaultBypassDomain,
                    ),
                  );
            },
            tooltip: appLocalizations.reset,
            icon: const Icon(Icons.replay),
          ),
        ],
      ),
      body: ListInputPage(
        title: appLocalizations.xboardBypassDomain,
        items: bypassDomain,
        titleBuilder: (item) => Text(item),
        onChange: (items) {
          ref.read(networkSettingProvider.notifier).updateState(
                (state) => state.copyWith(
                  bypassDomain: List.from(items),
                ),
              );
        },
      ),
    );
  }
}
