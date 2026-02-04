import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/xboard/features/latency/services/auto_latency_service.dart';
import 'package:fl_clash/xboard/features/latency/widgets/latency_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/views/proxies/common.dart' as proxies_common;
import 'package:fl_clash/xboard/features/shared/utils/node_tag_parser.dart';

class FlatNodeListView extends ConsumerStatefulWidget {
  const FlatNodeListView({super.key});

  @override
  ConsumerState<FlatNodeListView> createState() => _FlatNodeListViewState();
}

class _FlatNodeListViewState extends ConsumerState<FlatNodeListView> {
  String _searchQuery = '';
  bool _isRefreshing = false;
  bool _isTesting = false;

  Future<void> _testAllNodesDelay() async {
    if (_isTesting) return;

    final groups = ref.read(groupsProvider);
    final selectedMap = ref.read(selectedMapProvider);
    final mode =
        ref.read(patchClashConfigProvider.select((state) => state.mode));

    final nodes = _flattenNodes(groups, selectedMap, mode);
    if (nodes.isEmpty) {
      globalState.showNotifier(
        AppLocalizations.of(context).xboardNoAvailableNodes,
      );
      return;
    }

    setState(() => _isTesting = true);

    try {
      final proxies = nodes.map((n) => n.proxy).toList();
      final testUrl = ref.read(appSettingProvider).testUrl;

      // 批量测速
      await proxies_common.delayTest(proxies, testUrl);
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }

  Future<void> _refreshSubscription() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      // 重新拉取订阅配置文件
      final currentProfile = ref.read(currentProfileProvider);
      if (currentProfile != null) {
        await appController.updateProfile(currentProfile);
      }

      if (mounted) {
        globalState.showNotifier(
          AppLocalizations.of(context).xboardNodesUpdated,
        );
      }
    } catch (e) {
      if (mounted) {
        globalState.showMessage(
          title: AppLocalizations.of(context).tip,
          message: TextSpan(text: e.toString()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final groups = ref.watch(groupsProvider);
    final selectedMap = ref.watch(selectedMapProvider);
    final mode = ref.watch(patchClashConfigProvider.select((state) => state.mode));

    final nodes = _flattenNodes(groups, selectedMap, mode);
    final filtered = _searchQuery.isEmpty
        ? nodes
        : nodes.where((n) {
            final q = _searchQuery.toLowerCase();
            return n.proxy.name.toLowerCase().contains(q) ||
                n.proxy.type.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.xboardSwitchNode),
        actions: [
          if (_isTesting || _isRefreshing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.speed),
              tooltip: appLocalizations.xboardTestAllNodes,
              onPressed: _testAllNodesDelay,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: appLocalizations.xboardUpdateNodes,
              onPressed: _refreshSubscription,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: appLocalizations.xboardSearchNode,
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      appLocalizations.noData,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final node = filtered[index];
                      return _FlatNodeCard(
                        proxy: node.proxy,
                        groupName: node.groupName,
                        isSelected: node.isSelected,
                        onTap: () => _selectNode(node),
                      );
                    },
                  ),
          ),
        ],
      ),
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
      // 全局模式下只显示 GLOBAL 组的节点
      // 规则模式下跳过 GLOBAL 组
      if (mode == Mode.global) {
        if (group.name != GroupName.GLOBAL.name) continue;
      } else {
        if (group.name == GroupName.GLOBAL.name) continue;
      }
      if (group.hidden == true) continue;

      for (final proxy in group.all) {
        if (groupNames.contains(proxy.name)) continue;
        if (seen.contains(proxy.name)) continue;
        // 过滤掉 DIRECT 和 REJECT 特殊节点（大小写不敏感）
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

  void _selectNode(_FlatNode node) {
    appController.updateCurrentSelectedMap(
      node.groupName,
      node.proxy.name,
    );
    Navigator.of(context).pop();
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

class _FlatNodeCard extends ConsumerWidget {
  final Proxy proxy;
  final String groupName;
  final bool isSelected;
  final VoidCallback onTap;

  const _FlatNodeCard({
    required this.proxy,
    required this.groupName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tags = extractNodeTags(proxy.name);

    return Card(
      elevation: 0,
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: colorScheme.primary.withValues(alpha: 0.3))
            : BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: Icon(
          Icons.dns,
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          proxy.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              proxy.type,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: tags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        trailing: _buildLatency(ref),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
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
      onTap: () => autoLatencyService.testProxy(proxy, forceTest: true),
      isCompact: true,
    );
  }
}
