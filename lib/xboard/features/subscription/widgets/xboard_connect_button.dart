import 'package:fl_clash/common/common.dart';
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

    return Theme(
      data: Theme.of(context).copyWith(
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          sizeConstraints: const BoxConstraints(
            minWidth: 56,
            maxWidth: 200,
          ),
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller.view,
        builder: (_, child) {
          final textWidth = globalState.measure
                  .computeTextSize(
                    Text(
                      utils.getTimeDifference(
                        DateTime.now(),
                      ),
                      style: context.textTheme.titleMedium?.toSoftBold,
                    ),
                  )
                  .width +
              16;
          return FloatingActionButton.extended(
            clipBehavior: Clip.antiAlias,
            materialTapTargetSize: MaterialTapTargetSize.padded,
            heroTag: "xboard_connect_button",
            onPressed: () {
              handleSwitchStart();
            },
            icon: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: _animation,
            ),
            label: SizedBox(
              width: textWidth * _animation.value,
              child: child!,
            ),
          );
        },
        child: Consumer(
          builder: (_, ref, __) {
            final runTime = ref.watch(runTimeProvider);
            final text = utils.getTimeText(runTime);
            final colorScheme = Theme.of(context).colorScheme;
            final foregroundColor = isStart ? colorScheme.onTertiary : colorScheme.onPrimary;
            return Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: Theme.of(context).textTheme.titleMedium?.toSoftBold.copyWith(
                color: foregroundColor,
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _buildInlineButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 使用 Material 3 的语义化颜色
    // 运行时：使用 tertiaryContainer（通常是绿色系容器）
    // 停止时：使用 primaryContainer（主题色容器）
    final backgroundColor = isStart ? colorScheme.tertiaryContainer : colorScheme.primaryContainer;
    final foregroundColor = isStart ? colorScheme.onTertiaryContainer : colorScheme.onPrimaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _controller.view,
        builder: (_, child) {
          return Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  handleSwitchStart();
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        progress: _animation,
                        size: 28,
                        color: foregroundColor,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isStart
                              ? AppLocalizations.of(context).xboardStopProxy
                              : AppLocalizations.of(context).xboardStartProxy,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: foregroundColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isStart) ...[
                            const SizedBox(height: 3),
                            Consumer(
                              builder: (_, ref, __) {
                                final runTime = ref.watch(runTimeProvider);
                                final text = utils.getTimeText(runTime);
                                return Text(
                                  AppLocalizations.of(context).xboardRunningTime(text),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: foregroundColor.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 