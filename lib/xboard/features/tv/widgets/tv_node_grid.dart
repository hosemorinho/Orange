import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/xboard/features/latency/widgets/latency_indicator.dart';
import 'package:fl_clash/views/proxies/common.dart' as proxies_common;
import 'package:fl_clash/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tv_focus_card.dart';

/// D-pad navigable node grid for TV.
class TvNodeGrid extends ConsumerWidget {
  const TvNodeGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);
    final selectedMap = ref.watch(selectedMapProvider);
    final mode =
        ref.watch(patchClashConfigProvider.select((state) => state.mode));
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final nodes = _flattenNodes(groups, selectedMap, mode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.dns, size: 24, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                appLocalizations.xboardSwitchNode,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${nodes.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Grid
        Expanded(
          child: nodes.isEmpty
              ? Center(
                  child: Text(
                    appLocalizations.noData,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : FocusTraversalGroup(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 3.0,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: nodes.length,
                    itemBuilder: (context, index) {
                      final node = nodes[index];
                      return _TvNodeCard(
                        proxy: node.proxy,
                        groupName: node.groupName,
                        isSelected: node.isSelected,
                        onTap: () {
                          appController.updateCurrentSelectedMap(
                            node.groupName,
                            node.proxy.name,
                          );
                          appController.changeProxyDebounce(
                            node.groupName,
                            node.proxy.name,
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  List<_FlatNode> _flattenNodes(
    List<Group> groups,
    Map<String, String> selectedMap,
    Mode mode,
  ) {
    final Set<String> seen = {};
    final List<_FlatNode> nodes = [];
    final groupNames = groups.map((g) => g.name).toSet();

    for (final group in groups) {
      if (group.type != GroupType.Selector) continue;
      if (mode == Mode.global) {
        if (group.name != GroupName.GLOBAL.name) continue;
      } else {
        if (group.name == GroupName.GLOBAL.name) continue;
      }
      if (group.hidden == true) continue;

      for (final proxy in group.all) {
        if (groupNames.contains(proxy.name)) continue;
        if (seen.contains(proxy.name)) continue;
        final proxyNameUpper = proxy.name.toUpperCase();
        if (proxyNameUpper == 'DIRECT' || proxyNameUpper == 'REJECT') continue;
        seen.add(proxy.name);

        final selected = selectedMap[group.name] == proxy.name;
        nodes.add(_FlatNode(
          proxy: proxy,
          groupName: group.name,
          isSelected: selected,
        ));
      }
    }
    return nodes;
  }
}

class _FlatNode {
  final Proxy proxy;
  final String groupName;
  final bool isSelected;

  const _FlatNode({
    required this.proxy,
    required this.groupName,
    required this.isSelected,
  });
}

class _TvNodeCard extends ConsumerWidget {
  final Proxy proxy;
  final String groupName;
  final bool isSelected;
  final VoidCallback onTap;

  const _TvNodeCard({
    required this.proxy,
    required this.groupName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TvFocusCard(
      isSelected: isSelected,
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.dns,
            size: 20,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EmojiText(
                  proxy.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  proxy.type,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _buildLatency(ref),
        ],
      ),
    );
  }

  Widget _buildLatency(WidgetRef ref) {
    final delayState = ref.watch(getDelayProvider(
      proxyName: proxy.name,
      testUrl: ref.read(appSettingProvider).testUrl,
    ));
    return LatencyIndicator(
      delayValue: delayState,
      onTap: () => proxies_common.proxyDelayTest(
        proxy,
        ref.read(appSettingProvider).testUrl,
      ),
      isCompact: true,
    );
  }
}
