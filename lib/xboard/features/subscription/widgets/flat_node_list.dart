import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/common.dart' as proxies_common;
import 'package:fl_clash/widgets/text.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/features/shared/utils/node_tag_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlatNodeListView extends ConsumerStatefulWidget {
  const FlatNodeListView({super.key});

  @override
  ConsumerState<FlatNodeListView> createState() => _FlatNodeListViewState();
}

class _FlatNodeListViewState extends ConsumerState<FlatNodeListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isRefreshing = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testAllNodesDelay();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _testAllNodesDelay() async {
    if (_isTesting) return;

    final groups = ref.read(groupsProvider);
    final selectedMap = ref.read(selectedMapProvider);
    final mode = ref.read(
      patchClashConfigProvider.select((state) => state.mode),
    );

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
          message: TextSpan(text: ErrorSanitizer.sanitize(e.toString())),
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
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width >= 900;

    final groups = ref.watch(groupsProvider);
    final selectedMap = ref.watch(selectedMapProvider);
    final mode = ref.watch(
      patchClashConfigProvider.select((state) => state.mode),
    );

    final nodes = _flattenNodes(groups, selectedMap, mode);
    final filtered = _searchQuery.isEmpty
        ? nodes
        : nodes.where((n) {
            final q = _searchQuery.toLowerCase();
            return n.proxy.name.toLowerCase().contains(q) ||
                n.proxy.type.toLowerCase().contains(q);
          }).toList();

    final content = SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: isDesktop ? 760 : screenSize.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: isDesktop
              ? BorderRadius.circular(28)
              : const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            if (!isDesktop) ...[
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 4),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      appLocalizations.xboardSwitchNode,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_isTesting || _isRefreshing)
                    SizedBox(
                      width: 34,
                      height: 34,
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  else ...[
                    IconButton(
                      icon: const Icon(Icons.speed_outlined),
                      tooltip: appLocalizations.xboardTestAllNodes,
                      onPressed: _testAllNodesDelay,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: appLocalizations.xboardUpdateNodes,
                      onPressed: _refreshSubscription,
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: appLocalizations.xboardSearchNode,
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.35),
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
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final node = filtered[index];
                        return _FlatNodeCard(
                          proxy: node.proxy,
                          isSelected: node.isSelected,
                          onTap: () => _selectNode(node),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: isDesktop ? Alignment.center : Alignment.bottomCenter,
        child: content,
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
        nodes.add(
          _FlatNode(proxy: proxy, groupName: group.name, isSelected: selected),
        );
      }
    }

    return nodes;
  }

  void _selectNode(_FlatNode node) {
    appController.updateCurrentSelectedMap(node.groupName, node.proxy.name);
    appController.changeProxyDebounce(node.groupName, node.proxy.name);
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
  final bool isSelected;
  final VoidCallback onTap;

  const _FlatNodeCard({
    required this.proxy,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tags = extractNodeTags(proxy.name);
    final flag = extractCountryFlag(proxy.name);
    final delayState = ref.watch(
      getDelayProvider(
        proxyName: proxy.name,
        testUrl: ref.read(appSettingProvider).testUrl,
      ),
    );

    final displayName = _displayName(proxy.name, flag);
    final protocol = proxy.type.toUpperCase();
    final detailTag = tags
        .where((tag) => tag.toLowerCase() != protocol.toLowerCase())
        .firstOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.5)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.28)
              : colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.14)
                        : colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.35,
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: flag != null
                      ? Text(
                          flag,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: 'Twemoji',
                          ),
                        )
                      : Icon(
                          Icons.public_outlined,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EmojiText(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _Badge(
                            label: protocol,
                            color: isSelected
                                ? colorScheme.primary.withValues(alpha: 0.18)
                                : colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.75),
                            textColor: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                          if (detailTag != null) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                detailTag,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => proxies_common.proxyDelayTest(
                        proxy,
                        ref.read(appSettingProvider).testUrl,
                      ),
                      child: Text(
                        _delayText(context, delayState),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _delayColor(delayState, colorScheme),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _displayName(String input, String? flag) {
    if (flag == null) return input.trim();
    return input.replaceFirst(flag, '').trim();
  }

  String _delayText(BuildContext context, int? delay) {
    if (delay == null) return '--';
    if (delay == 0) return '...';
    if (delay < 0) return AppLocalizations.of(context).xboardLatencyTimeout;
    return '$delay ms';
  }

  Color _delayColor(int? delay, ColorScheme colorScheme) {
    if (delay == null || delay == 0) {
      return colorScheme.onSurfaceVariant;
    }
    if (delay < 0) {
      return colorScheme.error;
    }
    return utils.getDelayColor(delay) ?? colorScheme.primary;
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
