import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_clash/xboard/services/services.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'tun_introduction_dialog.dart';
import 'package:fl_clash/l10n/l10n.dart';

// 初始化文件级日志器
final _logger = FileLogger('xboard_outbound_mode.dart');
class XBoardOutboundMode extends StatelessWidget {
  const XBoardOutboundMode({super.key});
  Future<void> _handleModeChange(WidgetRef ref, Mode modeOption) async {
    _logger.debug('[XBoardOutboundMode] 切换模式到: $modeOption');

    // FlClash 核心的 changeMode 已经处理了所有切换逻辑：
    // - 全局模式: 更新 currentGroupName 为 GLOBAL + 确保节点选择
    // - 规则模式: 更新 currentGroupName 为第一个可见的非 GLOBAL 组
    await appController.changeMode(modeOption);
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
            ref.read(patchClashConfigProvider.notifier).update(
                  (state) => state.copyWith.tun(enable: true),
                );
          }
        }
      } else {
        ref.read(patchClashConfigProvider.notifier).update(
              (state) => state.copyWith.tun(enable: true),
            );
      }
    } else {
      ref.read(patchClashConfigProvider.notifier).update(
            (state) => state.copyWith.tun(enable: false),
          );
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
