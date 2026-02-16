import 'package:fl_clash/controller.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoreManager extends ConsumerStatefulWidget {
  final Widget child;

  const CoreManager({super.key, required this.child});

  @override
  ConsumerState<CoreManager> createState() => _CoreContainerState();
}

class _CoreContainerState extends ConsumerState<CoreManager> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      currentSetupStateProvider.select((state) => state?.profileId),
      (prev, next) {
        if (prev != next) {
          appController.fullSetup();
        }
      },
    );
    ref.listenManual(updateParamsProvider, (prev, next) {
      if (prev != next) {
        appController.updateConfigDebounce();
      }
    });
    // Leaf does not support log streaming from the core.
    // The openLogs setting is kept for UI state but doesn't trigger core logs.
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }
}
