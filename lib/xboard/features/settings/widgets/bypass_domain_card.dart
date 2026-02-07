import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/providers.dart';
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
        onTap: () async {
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
    );
  }
}

