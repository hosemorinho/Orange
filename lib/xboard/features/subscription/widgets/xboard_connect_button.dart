import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/l10n/l10n.dart';
class XBoardConnectButton extends ConsumerStatefulWidget {
  final bool isFloating; // 是否为浮动按钮模式
  const XBoardConnectButton({
    super.key,
    this.isFloating = false,
  });
  @override
  ConsumerState<XBoardConnectButton> createState() => _XBoardConnectButtonState();
}
class _XBoardConnectButtonState extends ConsumerState<XBoardConnectButton>
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
        appController.updateStatus(isStart);
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
    if (widget.isFloating) {
      return _buildFloatingButton(context);
    } else {
      return _buildInlineButton(context);
    }
  }
  Widget _buildFloatingButton(BuildContext context) {
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
  Widget _buildInlineButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 使用更强烈的主题色区分运行状态
    // 运行时：使用 tertiary（通常是绿色/成功色）
    // 停止时：使用 primary（主题色）
    final backgroundColor = isStart ? colorScheme.tertiary : colorScheme.primary;
    final foregroundColor = isStart ? colorScheme.onTertiary : colorScheme.onPrimary;

    return Center(
      child: Container(
        width: 96,
        height: 96,
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
                size: 48,
                color: foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 