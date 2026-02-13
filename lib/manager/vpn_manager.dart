import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
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

class _VpnContainerState extends ConsumerState<VpnManager> {
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
