import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/proxies/proxies.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/features/latency/services/auto_latency_service.dart';
import 'package:fl_clash/xboard/features/latency/widgets/latency_indicator.dart';
import 'package:fl_clash/l10n/l10n.dart';
class NodeSelectorBar extends ConsumerStatefulWidget {
  const NodeSelectorBar({super.key});
  @override
  ConsumerState<NodeSelectorBar> createState() => _NodeSelectorBarState();
}
class _NodeSelectorBarState extends ConsumerState<NodeSelectorBar> {
  String? _lastProxyName;
  bool _isFirstBuild = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      autoLatencyService.initialize(ref);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          autoLatencyService.testCurrentNode();
        }
      });
    });
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider);
    final selectedMap = ref.watch(selectedMapProvider);
    final mode = ref.watch(patchClashConfigProvider.select((state) => state.mode));
    ref.listen(runTimeProvider, (previous, next) {
      final wasConnected = previous != null;
      final isConnected = next != null;
      if (wasConnected != isConnected) {
        autoLatencyService.onConnectionStatusChanged(isConnected);
      }
    });
    ref.listen(selectedMapProvider, (previous, next) {
      if (previous != null && next != previous) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            autoLatencyService.onNodeChanged();
          }
        });
      }
    });
    if (groups.isEmpty) {
      return _buildEmptyState(context);
    }
    Group? currentGroup;
    Proxy? currentProxy;
    if (mode == Mode.global) {
      currentGroup = groups.firstWhere(
        (group) => group.name == GroupName.GLOBAL.name,
        orElse: () => groups.first,
      );
    } else if (mode == Mode.rule) {
      for (final group in groups) {
        if (group.hidden == true) continue;
        if (group.name == GroupName.GLOBAL.name) continue;
        final selectedProxyName = selectedMap[group.name];
        if (selectedProxyName != null && selectedProxyName.isNotEmpty) {
          final referencedGroup = groups.firstWhere(
            (g) => g.name == selectedProxyName,
            orElse: () => group, // 如果没找到引用的组，就使用当前组
          );
          if (referencedGroup.name == selectedProxyName && referencedGroup.type == GroupType.URLTest) {
            currentGroup = referencedGroup;
            break;
          } else {
            currentGroup = group;
            break;
          }
        }
      }
      if (currentGroup == null) {
        currentGroup = groups.firstWhere(
          (group) => group.hidden != true && group.name != GroupName.GLOBAL.name,
          orElse: () => groups.first,
        );
        if (currentGroup.now != null && currentGroup.now!.isNotEmpty) {
          final nowValue = currentGroup.now!;
          final referencedGroup = groups.firstWhere(
            (g) => g.name == nowValue,
            orElse: () => currentGroup!,
          );
          if (referencedGroup.name == nowValue && referencedGroup.type == GroupType.URLTest) {
            currentGroup = referencedGroup;
          }
        }
      }
    }
    if (currentGroup == null || currentGroup.all.isEmpty) {
      return _buildEmptyState(context);
    }
    final selectedProxyName = selectedMap[currentGroup.name] ?? "";
    String realNodeName;
    if (currentGroup.type == GroupType.URLTest) {
      realNodeName = currentGroup.now ?? "";
    } else {
      realNodeName = currentGroup.getCurrentSelectedName(selectedProxyName);
    }
    if (realNodeName.isNotEmpty) {
      currentProxy = currentGroup.all.firstWhere(
        (proxy) => proxy.name == realNodeName,
        orElse: () => currentGroup!.all.first,
      );
    } else {
      currentProxy = currentGroup.all.first;
    }
    _checkNodeChange(currentProxy);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _buildProxyDisplay(context, currentGroup, currentProxy),
    );
  }
  Widget _buildProxyDisplay(BuildContext context, Group group, Proxy proxy) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CommonScaffold(
                  title: AppLocalizations.of(context).xboardProxy,
                  body: const ProxiesView(),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xff0369A1).withValues(alpha: 0.15),
                        const Color(0xff0EA5E9).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.dns_outlined,
                    color: const Color(0xff0369A1),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        proxy.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildProxyLatency(proxy),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommonScaffold(
                          title: AppLocalizations.of(context).xboardProxy,
                          body: const ProxiesView(),
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xff0369A1),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(64, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(context).xboardSwitch,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildProxyLatency(Proxy proxy) {
    final delayState = ref.watch(getDelayProvider(
      proxyName: proxy.name,
      testUrl: ref.read(appSettingProvider).testUrl,
    ));
    return LatencyIndicator(
      delayValue: delayState,
      onTap: () => _handleManualTest(proxy),
      showIcon: true,
    );
  }
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.error.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                color: theme.colorScheme.onErrorContainer,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context).xboardNoAvailableNodes,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppLocalizations.of(context).xboardClickToSetupNodes,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommonScaffold(
                      title: AppLocalizations.of(context).xboardProxy,
                      body: const ProxiesView(),
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff0369A1),
                foregroundColor: Colors.white,
                minimumSize: const Size(64, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context).xboardSetup,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _checkNodeChange(Proxy currentProxy) {
    if (_isFirstBuild) {
      _lastProxyName = currentProxy.name;
      _isFirstBuild = false;
      return;
    }
    if (_lastProxyName != currentProxy.name) {
      _lastProxyName = currentProxy.name;
      autoLatencyService.onNodeChanged();
    }
  }
  void _handleManualTest(Proxy proxy) {
    autoLatencyService.testProxy(proxy, forceTest: true);
  }
}