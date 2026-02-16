import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/leaf/providers/leaf_providers.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VpnManager extends ConsumerStatefulWidget {
  final Widget child;

  const VpnManager({super.key, required this.child});

  @override
  ConsumerState<VpnManager> createState() => _VpnContainerState();
}

class _VpnContainerState extends ConsumerState<VpnManager> with ServiceListener {
  @override
  void initState() {
    super.initState();
    if (system.isAndroid) {
      ref.listenManual(vpnStateProvider, (prev, next) {
        if (prev != next) {
          _showRestartTip();
        }
      });
    }
    if (system.isDesktop) {
      ref.listenManual(desktopTunStateProvider, (prev, next) {
        if (prev != next) {
          _showRestartTip();
        }
      });
    }
    if (system.isIOS) {
      service?.addListener(this);
    }
  }

  @override
  void dispose() {
    if (system.isIOS) {
      service?.removeListener(this);
    }
    super.dispose();
  }

  @override
  void onVpnStatusChanged({
    required String status,
    required bool connected,
  }) {
    if (!system.isIOS) return;
    commonPrint.log(
      'iOS VPN status: $status, connected=$connected',
      logLevel: LogLevel.info,
    );
    if (connected && (status == 'connected' || status == 'reasserting')) {
      globalState.startTime ??= DateTime.now();
      ref.read(isLeafRunningProvider.notifier).set(true);
      appController.updateRunTime();
      return;
    }
    if (connected) {
      return;
    }
    globalState.startTime = null;
    ref.read(isLeafRunningProvider.notifier).set(false);
    appController.updateRunTime();
    ref.read(trafficsProvider.notifier).clear();
    ref.read(totalTrafficProvider.notifier).value = Traffic();
  }

  void _showRestartTip() {
    throttler.call(
      FunctionTag.vpnTip,
      () {
        if (!ref.read(isStartProvider)) return;
        if (system.isAndroid) {
          final state = ref.read(vpnStateProvider);
          if (state == globalState.lastVpnState) return;
        }
        globalState.showNotifier(
          appLocalizations.vpnConfigChangeDetected,
          actionState: MessageActionState(
            actionText: appLocalizations.restart,
            action: () async {
              await globalState.handleStop();
              await appController.updateStatus(
                true,
                trigger: 'vpn_manager.restart_tip',
              );
            },
          ),
        );
      },
      duration: const Duration(seconds: 6),
      fire: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
