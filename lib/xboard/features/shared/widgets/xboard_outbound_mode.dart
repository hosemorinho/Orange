import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_clash/xboard/services/services.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/core/bridges/subscription_bridge.dart'
    show Mode;
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

  Future<void> _handleTunToggle(
      BuildContext context, WidgetRef ref, bool selected) async {
    if (!system.isDesktop) {
      return;
    }
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
    final l10n = AppLocalizations.of(context);

    return Consumer(
      builder: (context, ref, child) {
        final mode = ref.watch(
            patchClashConfigProvider.select((state) => state.mode));
        final tunEnabled = ref.watch(patchClashConfigProvider
            .select((state) => state.tun.enable));
        final showTun = system.isDesktop;
        return LayoutBuilder(
          builder: (context, constraints) {
            // 根据可用宽度调整布局
            final isNarrow = constraints.maxWidth < 280;
            final buttonWidth = isNarrow
                ? null
                : double.infinity;
            final horizontalPadding = isNarrow ? 8.0 : 14.0;

            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 14.0,
              ),
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
                      Expanded(
                        child: Text(
                          l10n.xboardProxyMode,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isNarrow ? 10 : 12),
                  SizedBox(
                    width: buttonWidth,
                    child: _buildModeSelector(context, mode, isNarrow, ref),
                  ),
                  SizedBox(height: isNarrow ? 10 : 12),
                  if (showTun) ...[
                    _buildTunRow(context, tunEnabled, isNarrow, ref),
                    const SizedBox(height: 6),
                  ],
                  Flexible(
                    child: Text(
                      _getModeDescription(mode, showTun ? tunEnabled : false, l10n),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.65),
                            fontSize: 12,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModeSelector(BuildContext context, Mode mode, bool isNarrow, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final thumbColor = switch (mode) {
      Mode.rule => colorScheme.secondaryContainer,
      Mode.global => colorScheme.primaryContainer,
      Mode.direct => colorScheme.secondaryContainer,
    };

    return CommonTabBar<Mode>(
      children: {
        Mode.rule: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.alt_route, size: 14),
              const SizedBox(width: 4),
              Text(
                Intl.message(Mode.rule.name),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Mode.global: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.public, size: 14),
              const SizedBox(width: 4),
              Text(
                Intl.message(Mode.global.name),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      },
      groupValue: mode == Mode.direct ? Mode.rule : mode,
      onValueChanged: (value) {
        if (value != null) _handleModeChange(ref, value);
      },
      thumbColor: thumbColor,
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
    );
  }

  Widget _buildTunRow(BuildContext context, bool tunEnabled, bool isNarrow, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          Icons.vpn_lock,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'TUN',
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          // 约束 Switch 宽度，防止在小屏幕下挤压
          width: isNarrow ? 52 : null,
          child: Switch(
            value: tunEnabled,
            onChanged: (value) {
              _handleTunToggle(context, ref, value);
            },
            activeThumbColor: colorScheme.tertiary,
            activeTrackColor: colorScheme.tertiaryContainer,
          ),
        ),
      ],
    );
  }

  String _getModeDescription(
      Mode mode, bool tunEnabled, AppLocalizations l10n) {
    final tunStatus =
        tunEnabled ? ' | ${l10n.xboardTunEnabled}' : '';
    switch (mode) {
      case Mode.rule:
        return '${l10n.xboardProxyModeRuleDescription}$tunStatus';
      case Mode.global:
        return '${l10n.xboardProxyModeGlobalDescription}$tunStatus';
      case Mode.direct:
        return '${l10n.xboardProxyModeDirectDescription}$tunStatus';
    }
  }
}
