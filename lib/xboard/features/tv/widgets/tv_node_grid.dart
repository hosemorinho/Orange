import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/common.dart' as proxies_common;
import 'package:fl_clash/widgets/text.dart';
import 'package:fl_clash/xboard/features/latency/widgets/latency_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tv_design_tokens.dart';
import 'tv_focus_card.dart';

/// D-pad navigable node grid for TV.
class TvNodeGrid extends ConsumerStatefulWidget {
  const TvNodeGrid({super.key});

  @override
  ConsumerState<TvNodeGrid> createState() => _TvNodeGridState();
}

class _TvNodeGridState extends ConsumerState<TvNodeGrid> {
  bool _isRefreshing = false;

  Future<void> _refreshNodes() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final currentProfile = ref.read(currentProfileProvider);
      if (currentProfile != null) {
        await appController.updateProfile(currentProfile);
        if (mounted) {
          globalState.showNotifier(
            AppLocalizations.of(context).xboardNodesUpdated,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        globalState.showNotifier(AppLocalizations.of(context).checkNetwork);
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  int _resolveCrossAxisCount(double width) {
    if (width >= 1400) return 4;
    if (width >= 900) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider);
    final selectedMap = ref.watch(selectedMapProvider);
    final mode = ref.watch(
      patchClashConfigProvider.select((state) => state.mode),
    );
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final nodes = _flattenNodes(groups, selectedMap, mode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.34,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.dns_rounded, size: 22, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  appLocalizations.xboardSwitchNode,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${nodes.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: nodes.isEmpty
              ? _buildEmptyState(context, appLocalizations, theme, colorScheme)
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = _resolveCrossAxisCount(
                      constraints.maxWidth,
                    );
                    return FocusTraversalGroup(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 2.9,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
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
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations appLocalizations,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(20),
        decoration: TvDesignTokens.panel(colorScheme),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              appLocalizations.xboardNoAvailableNodes,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              appLocalizations.checkNetwork,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 240,
              child: TvFocusCard(
                autofocus: true,
                onPressed: _isRefreshing ? null : _refreshNodes,
                borderRadius: BorderRadius.circular(
                  TvDesignTokens.controlRadius,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isRefreshing
                          ? appLocalizations.xboardInitializing
                          : appLocalizations.xboardUpdateNodes,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_FlatNode> _flattenNodes(
    List<Group> groups,
    Map<String, String> selectedMap,
    Mode mode,
  ) {
    final List<_FlatNode> nodes = [];
    final groupNames = groups.map((g) => g.name).toSet();
    Group? targetGroup;

    // Keep TV behavior aligned with Android:
    // - global mode: only GLOBAL group's nodes
    // - rule mode: only first visible non-GLOBAL selector group's nodes
    for (final group in groups) {
      if (group.type != GroupType.Selector) continue;
      if (group.hidden == true) continue;
      if (mode == Mode.global) {
        if (group.name != GroupName.GLOBAL.name) continue;
      } else {
        if (group.name == GroupName.GLOBAL.name) continue;
      }
      targetGroup = group;
      break;
    }

    if (targetGroup == null) {
      return nodes;
    }

    for (final proxy in targetGroup.all) {
      if (groupNames.contains(proxy.name)) continue;
      final proxyNameUpper = proxy.name.toUpperCase();
      if (proxyNameUpper == 'DIRECT' || proxyNameUpper == 'REJECT') continue;

      final selected = selectedMap[targetGroup.name] == proxy.name;
      nodes.add(
        _FlatNode(
          proxy: proxy,
          groupName: targetGroup.name,
          isSelected: selected,
        ),
      );
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

class _TvNodeCard extends ConsumerStatefulWidget {
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
  ConsumerState<_TvNodeCard> createState() => _TvNodeCardState();
}

class _TvNodeCardState extends ConsumerState<_TvNodeCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TvFocusCard(
      isSelected: widget.isSelected,
      onPressed: widget.onTap,
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      borderRadius: BorderRadius.circular(TvDesignTokens.controlRadius),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.dns_rounded,
              size: 18,
              color: widget.isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EmojiText(
                  widget.proxy.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: widget.isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: widget.isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.45,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.proxy.type,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildLatency(),
        ],
      ),
    );
  }

  Widget _buildLatency() {
    final testUrl = ref.read(appSettingProvider).testUrl;
    final provider = getDelayProvider(
      proxyName: widget.proxy.name,
      testUrl: testUrl,
    );
    final delayState = (_isFocused || widget.isSelected)
        ? ref.watch(provider)
        : ref.read(provider);

    return LatencyIndicator(
      delayValue: delayState,
      onTap: () => proxies_common.proxyDelayTest(widget.proxy, testUrl),
      isCompact: true,
    );
  }
}
