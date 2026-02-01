import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartButton extends ConsumerStatefulWidget {
  const StartButton({super.key});

  @override
  ConsumerState<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends ConsumerState<StartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isStart = false;

  @override
  void initState() {
    super.initState();
    isStart = globalState.appState.runTime != null;
    _controller = AnimationController(
      vsync: this,
      value: isStart ? 1 : 0,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    ref.listenManual(
      runTimeProvider.select((state) => state != null),
      (prev, next) {
        if (next != isStart) {
          isStart = next;
          updateController();
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  handleSwitchStart() {
    isStart = !isStart;
    updateController();
    debouncer.call(
      FunctionTag.updateStatus,
      () {
        globalState.appController.updateStatus(isStart);
      },
      duration: commonDuration,
    );
  }

  updateController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isStart) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(startButtonSelectorStateProvider);
    if (!state.isInit || !state.hasProfile) {
      return Container();
    }

    final colorScheme = Theme.of(context).colorScheme;
    // 使用 Material 3 的语义化颜色
    // 运行时：使用 tertiary（通常是绿色系）
    // 停止时：使用 primary（主题色）
    final backgroundColor = isStart ? colorScheme.tertiary : colorScheme.primary;
    final foregroundColor = isStart ? colorScheme.onTertiary : colorScheme.onPrimary;

    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: handleSwitchStart,
            customBorder: const CircleBorder(),
            child: Center(
              child: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: _animation,
                size: 36,
                color: foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
