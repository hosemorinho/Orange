import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_clash/xboard/services/services.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'tun_introduction_dialog.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/features/shared/utils/node_resolver.dart';

// 初始化文件级日志器
final _logger = FileLogger('xboard_outbound_mode.dart');
class XBoardOutboundMode extends StatelessWidget {
  const XBoardOutboundMode({super.key});
  void _handleModeChange(WidgetRef ref, Mode modeOption) {
    _logger.debug('[XBoardOutboundMode] 切换模式到: $modeOption');

    // 在模式切换前，同步节点选择
    final currentMode = ref.read(patchClashConfigProvider.select((state) => state.mode));
    if (currentMode != modeOption) {
      _syncNodeSelectionOnModeChange(ref, from: currentMode, to: modeOption);
    }

    globalState.appController.changeMode(modeOption);

    if (modeOption == Mode.global) {
      _logger.debug('[XBoardOutboundMode] 切换到全局模式，检查节点选择');
      Future.delayed(const Duration(milliseconds: 100), () {
        _ensureValidProxyForGlobalMode(ref);
      });
    }
  }
  Future<void> _handleTunToggle(BuildContext context, WidgetRef ref, bool selected) async {
    if (selected) {
      final storageService = ref.read(storageServiceProvider);
      final hasShownResult = await storageService.hasTunFirstUseShown();
      final hasShown = hasShownResult.dataOrNull ?? false;
      if (!hasShown) {
        if (context.mounted) {
          final shouldEnable = await TunIntroductionDialog.show(context);
          if (shouldEnable == true) {
            await storageService.markTunFirstUseShown();
            ref.read(patchClashConfigProvider.notifier).updateState(
                  (state) => state.copyWith.tun(enable: true),
                );
          }
        }
      } else {
        ref.read(patchClashConfigProvider.notifier).updateState(
              (state) => state.copyWith.tun(enable: true),
            );
      }
    } else {
      ref.read(patchClashConfigProvider.notifier).updateState(
            (state) => state.copyWith.tun(enable: false),
          );
    }
  }
  void _syncNodeSelectionOnModeChange(
    WidgetRef ref, {
    required Mode from,
    required Mode to,
  }) {
    final groups = ref.read(groupsProvider);
    final selectedMap = ref.read(selectedMapProvider);

    if (groups.isEmpty) return;

    // 规则模式 → 全局模式：同步当前规则节点到 GLOBAL 组
    if (from == Mode.rule && to == Mode.global) {
      _logger.debug('[XBoardOutboundMode] 从规则模式切换到全局模式，同步节点');

      // 使用 node_resolver 解析当前规则模式的活动节点
      final resolved = resolveCurrentNode(
        groups: groups,
        selectedMap: selectedMap,
        mode: Mode.rule,
      );

      if (resolved.proxy != null &&
          resolved.proxy!.name.toUpperCase() != 'DIRECT' &&
          resolved.proxy!.name.toUpperCase() != 'REJECT') {
        _logger.debug('[XBoardOutboundMode] 同步节点 ${resolved.proxy!.name} 到 GLOBAL 组');
        globalState.appController.updateCurrentSelectedMap(
          GroupName.GLOBAL.name,
          resolved.proxy!.name,
        );
      }
    }

    // 全局模式 → 规则模式：同步 GLOBAL 节点到主要代理组
    else if (from == Mode.global && to == Mode.rule) {
      _logger.debug('[XBoardOutboundMode] 从全局模式切换到规则模式，同步节点');

      final globalGroup = groups.firstWhere(
        (g) => g.name == GroupName.GLOBAL.name,
        orElse: () => groups.first,
      );

      final globalSelected = selectedMap[globalGroup.name];
      if (globalSelected != null &&
          globalSelected.isNotEmpty &&
          globalSelected.toUpperCase() != 'DIRECT' &&
          globalSelected.toUpperCase() != 'REJECT') {
        // 找到第一个可选择的规则组（非 GLOBAL、非隐藏）
        final ruleGroup = groups.firstWhere(
          (g) =>
              g.name != GroupName.GLOBAL.name &&
              g.hidden != true &&
              g.type == GroupType.Selector,
          orElse: () => globalGroup,
        );

        if (ruleGroup.name != globalGroup.name) {
          // 检查该节点是否在目标组中存在
          final nodeExists = ruleGroup.all.any((p) => p.name == globalSelected);
          if (nodeExists) {
            _logger
                .debug('[XBoardOutboundMode] 同步节点 $globalSelected 到 ${ruleGroup.name} 组');
            globalState.appController.updateCurrentSelectedMap(
              ruleGroup.name,
              globalSelected,
            );
          }
        }
      }
    }
  }

  void _ensureValidProxyForGlobalMode(WidgetRef ref) {
    _logger.debug('[XBoardOutboundMode] 检查全局模式下的节点选择');
    final groups = ref.read(groupsProvider);
    if (groups.isEmpty) {
      _logger.debug('[XBoardOutboundMode] 没有可用的代理组');
      return;
    }
    final globalGroup = groups.firstWhere(
      (group) => group.name == GroupName.GLOBAL.name,
      orElse: () => groups.first,
    );
    _logger.debug('[XBoardOutboundMode] 找到全局组: ${globalGroup.name}, 节点数: ${globalGroup.all.length}');
    if (globalGroup.all.isEmpty) {
      _logger.debug('[XBoardOutboundMode] 全局组没有可用节点');
      return;
    }

    // 检查当前是否已有选择
    final selectedMap = ref.read(selectedMapProvider);
    final currentSelected = selectedMap[globalGroup.name];

    // 如果已有选择且该节点仍然存在，则保持不变
    if (currentSelected != null && currentSelected.isNotEmpty) {
      final selectedProxy = globalGroup.all.firstWhere(
        (proxy) => proxy.name == currentSelected,
        orElse: () => globalGroup.all.first,
      );
      if (selectedProxy.name == currentSelected &&
          selectedProxy.name.toUpperCase() != 'DIRECT' &&
          selectedProxy.name.toUpperCase() != 'REJECT') {
        _logger.debug('[XBoardOutboundMode] 保持已选择的节点: $currentSelected');
        return;
      }
    }

    // 如果没有选择或选择无效，则自动选择第一个有效节点
    _logger.debug('[XBoardOutboundMode] 当前无有效选择，自动选择节点');
    Proxy? validProxy;
    for (final proxy in globalGroup.all) {
      if (proxy.name.toUpperCase() != 'DIRECT' &&
          proxy.name.toLowerCase() != 'direct' &&
          proxy.name.toUpperCase() != 'REJECT') {
        validProxy = proxy;
        _logger.debug('[XBoardOutboundMode] 选择有效代理节点: ${proxy.name}');
        break;
      }
    }
    if (validProxy != null) {
      _logger.debug('[XBoardOutboundMode] 设置选中代理: ${validProxy.name}');
      globalState.appController.updateCurrentSelectedMap(
        globalGroup.name,
        validProxy.name,
      );
      _logger.debug('[XBoardOutboundMode] 代理节点设置完成');
    } else {
      _logger.debug('[XBoardOutboundMode] 没有找到有效的代理节点');
    }
  }
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer(
      builder: (context, ref, child) {
        final mode = ref.watch(patchClashConfigProvider.select((state) => state.mode));
        final tunEnabled = ref.watch(patchClashConfigProvider.select((state) => state.tun.enable));
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tune,
                    color: colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context).xboardProxyMode,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<Mode>(
                  segments: [
                    ButtonSegment(
                      value: Mode.rule,
                      label: Text(Intl.message(Mode.rule.name)),
                      icon: const Icon(Icons.alt_route, size: 16),
                    ),
                    ButtonSegment(
                      value: Mode.global,
                      label: Text(Intl.message(Mode.global.name)),
                      icon: const Icon(Icons.public, size: 16),
                    ),
                  ],
                  selected: {mode == Mode.direct ? Mode.rule : mode},
                  onSelectionChanged: (selected) {
                    _handleModeChange(ref, selected.first);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.vpn_lock,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TUN',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Switch(
                    value: tunEnabled,
                    onChanged: (value) {
                      _handleTunToggle(context, ref, value);
                    },
                    activeColor: colorScheme.tertiary,
                    activeTrackColor: colorScheme.tertiaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _getModeDescription(mode, tunEnabled, context),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  String _getModeDescription(Mode mode, bool tunEnabled, BuildContext context) {
    final tunStatus = tunEnabled ? ' | ${AppLocalizations.of(context).xboardTunEnabled}' : '';
    switch (mode) {
      case Mode.rule:
        return '${AppLocalizations.of(context).xboardProxyModeRuleDescription}$tunStatus';
      case Mode.global:
        return '${AppLocalizations.of(context).xboardProxyModeGlobalDescription}$tunStatus';
      case Mode.direct:
        return '${AppLocalizations.of(context).xboardProxyModeDirectDescription}$tunStatus';
    }
  }
}
