import 'package:fl_clash/leaf/providers/leaf_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Leaf connect button — replaces XBoardConnectButton and StartButton.
///
/// Uses leaf providers instead of Clash appController/isStartProvider.
class LeafConnectButton extends ConsumerStatefulWidget {
  final bool isFloating;

  const LeafConnectButton({
    super.key,
    this.isFloating = false,
  });

  @override
  ConsumerState<LeafConnectButton> createState() => _LeafConnectButtonState();
}

class _LeafConnectButtonState extends ConsumerState<LeafConnectButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isStart = false;
  bool _isSwitching = false;

  @override
  void initState() {
    super.initState();
    _isStart = ref.read(isLeafRunningProvider);
    _controller = AnimationController(
      vsync: this,
      value: _isStart ? 1 : 0,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    ref.listenManual(
      isLeafRunningProvider,
      (prev, next) {
        if (next != _isStart) {
          _isStart = next;
          _updateController();
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

  Future<void> _handleSwitchStart() async {
    if (_isSwitching) return;
    _isSwitching = true;
    try {
      _isStart = !_isStart;
      _updateController();
      if (_isStart) {
        await startLeaf(ref);
      } else {
        await stopLeaf(ref);
      }
    } finally {
      _isSwitching = false;
    }
  }

  void _updateController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isStart && mounted) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final nodes = ref.watch(leafNodesProvider);
    if (nodes.isEmpty) return const SizedBox.shrink();

    if (widget.isFloating) {
      return _buildFloatingButton(context);
    } else {
      return _buildInlineButton(context);
    }
  }

  Widget _buildFloatingButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor =
        _isStart ? colorScheme.tertiary : colorScheme.primary;
    final foregroundColor =
        _isStart ? colorScheme.onTertiary : colorScheme.onPrimary;

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
            onTap: _handleSwitchStart,
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
    final backgroundColor =
        _isStart ? colorScheme.tertiary : colorScheme.primary;
    final foregroundColor =
        _isStart ? colorScheme.onTertiary : colorScheme.onPrimary;

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
            onTap: _handleSwitchStart,
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
