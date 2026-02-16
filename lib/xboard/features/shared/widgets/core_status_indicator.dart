import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:fl_clash/xboard/core/bridges/core_status_bridge.dart'
    show CoreStatus;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 核心状态指示器组件
/// 显示 Clash 核心的连接状态（connecting/connected/disconnected）
/// 点击可以重启核心
class CoreStatusIndicator extends ConsumerWidget {
  const CoreStatusIndicator({super.key});

  Future<void> _handleConnection(BuildContext context, WidgetRef ref) async {
    final coreStatus = ref.read(coreStatusProvider);
    if (coreStatus == CoreStatus.connecting) {
      return;
    }
    final tip = coreStatus == CoreStatus.connected
        ? appLocalizations.forceRestartCoreTip
        : appLocalizations.restartCoreTip;
    final res = await globalState.showMessage(message: TextSpan(text: tip));
    if (res != true) {
      return;
    }
    appController.restartCore();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coreStatus = ref.watch(coreStatusProvider);

    return Tooltip(
      message: appLocalizations.coreStatus,
      child: FadeScaleBox(
        alignment: Alignment.centerRight,
        child: coreStatus == CoreStatus.connected
            ? IconButton.filled(
                visualDensity: VisualDensity.compact,
                iconSize: 20,
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: switch (Theme.brightnessOf(context)) {
                    Brightness.light => context.colorScheme.onSurfaceVariant,
                    Brightness.dark => context.colorScheme.onPrimaryFixedVariant,
                  },
                ),
                onPressed: () => _handleConnection(context, ref),
                icon: const Icon(Icons.check, fontWeight: FontWeight.w900),
              )
            : FilledButton.icon(
                key: ValueKey(coreStatus),
                onPressed: () => _handleConnection(context, ref),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  backgroundColor: switch (coreStatus) {
                    CoreStatus.connecting => null,
                    CoreStatus.connected => Colors.greenAccent,
                    CoreStatus.disconnected => context.colorScheme.error,
                  },
                  foregroundColor: switch (coreStatus) {
                    CoreStatus.connecting => null,
                    CoreStatus.connected => switch (Theme.brightnessOf(context)) {
                      Brightness.light => context.colorScheme.onSurfaceVariant,
                      Brightness.dark => null,
                    },
                    CoreStatus.disconnected => context.colorScheme.onError,
                  },
                ),
                icon: SizedBox(
                  height: globalState.measure.bodyMediumHeight,
                  width: globalState.measure.bodyMediumHeight,
                  child: switch (coreStatus) {
                    CoreStatus.connecting => Padding(
                        padding: const EdgeInsets.all(2),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: context.colorScheme.onPrimary,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    CoreStatus.connected => const Icon(
                        Icons.check_sharp,
                        fontWeight: FontWeight.w900,
                      ),
                    CoreStatus.disconnected => const Icon(
                        Icons.restart_alt_sharp,
                        fontWeight: FontWeight.w900,
                      ),
                  },
                ),
                label: Text(switch (coreStatus) {
                  CoreStatus.connecting => appLocalizations.connecting,
                  CoreStatus.connected => appLocalizations.connected,
                  CoreStatus.disconnected => appLocalizations.disconnected,
                }),
              ),
      ),
    );
  }
}
