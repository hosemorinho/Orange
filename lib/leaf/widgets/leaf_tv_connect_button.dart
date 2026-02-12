import 'dart:math';

import 'package:fl_clash/controller.dart';
import 'package:fl_clash/leaf/providers/leaf_providers.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Large circular VPN connect button for TV — leaf version.
///
/// Uses appController.updateStatus() for full lifecycle management.
class LeafTvConnectButton extends ConsumerStatefulWidget {
  const LeafTvConnectButton({super.key});

  @override
  ConsumerState<LeafTvConnectButton> createState() =>
      _LeafTvConnectButtonState();
}

class _LeafTvConnectButtonState extends ConsumerState<LeafTvConnectButton>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconAnimation;
  late AnimationController _pulseController;
  bool _isStart = false;
  bool _isFocused = false;
  bool _isSwitching = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isStart = ref.read(isStartProvider);

    _iconController = AnimationController(
      vsync: this,
      value: _isStart ? 1 : 0,
      duration: const Duration(milliseconds: 200),
    );
    _iconAnimation = CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeOutBack,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (_isStart) _pulseController.repeat(reverse: true);

    ref.listenManual(
      runTimeProvider.select((state) => state != null),
      (prev, next) {
        if (next != _isStart) {
          setState(() => _isStart = next);
          _updateController();
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    _pulseController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSwitchStart() async {
    if (_isSwitching) return;
    _isSwitching = true;
    final targetState = !_isStart;
    setState(() => _isStart = targetState);
    _updateController();
    appController.updateStatus(targetState).whenComplete(() {
      _isSwitching = false;
    });
  }

  void _updateController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isStart) {
        _iconController.forward();
        _pulseController.repeat(reverse: true);
      } else {
        _iconController.reverse();
        _pulseController.stop();
        _pulseController.reset();
      }
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.select ||
            event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
      _handleSwitchStart();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final nodes = ref.watch(leafNodesProvider);
    if (nodes.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = _isStart ? colorScheme.tertiary : colorScheme.primary;
    final fgColor = _isStart ? colorScheme.onTertiary : colorScheme.onPrimary;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: _handleSwitchStart,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = _isFocused
                ? 1.05
                : (_isStart
                    ? 1.0 + _pulseController.value * 0.02
                    : 1.0);
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: _ProgressRingPainter(
                ringColor: bgColor.withValues(alpha: 0.3),
                progressColor: bgColor,
                isFocused: _isFocused,
                focusBorderColor: colorScheme.onSurface,
              ),
              child: Center(
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: _iconAnimation,
                      size: 72,
                      color: fgColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final Color ringColor;
  final Color progressColor;
  final bool isFocused;
  final Color focusBorderColor;

  _ProgressRingPainter({
    required this.ringColor,
    required this.progressColor,
    required this.isFocused,
    required this.focusBorderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background ring
    final bgPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Focus border
    if (isFocused) {
      final focusPaint = Paint()
        ..color = focusBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawCircle(center, radius + 8, focusPaint);
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) =>
      isFocused != old.isFocused || ringColor != old.ringColor;
}
