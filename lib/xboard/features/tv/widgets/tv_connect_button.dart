import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/core/bridges/subscription_bridge.dart'
    show FunctionTag;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Large circular VPN connect button for TV.
class TvConnectButton extends ConsumerStatefulWidget {
  const TvConnectButton({super.key});

  @override
  ConsumerState<TvConnectButton> createState() => _TvConnectButtonState();
}

class _TvConnectButtonState extends ConsumerState<TvConnectButton>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconAnimation;
  late AnimationController _pulseController;
  bool _isStart = false;
  bool _isFocused = false;
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
      isStartProvider,
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

  void _handleSwitchStart() {
    setState(() => _isStart = !_isStart);
    _updateController();
    debouncer.call(
      FunctionTag.updateStatus,
      () => appController
          .updateStatus(
            _isStart,
            trigger: 'xboard.tv_connect_button',
          )
          .whenComplete(() {
            final actualState = ref.read(isStartProvider);
            if (mounted && actualState != _isStart) {
              setState(() => _isStart = actualState);
              _updateController();
            }
          }),
      duration: commonDuration,
    );
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
    final hasProfile = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    if (!hasProfile) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final subscription = ref.watch(subscriptionInfoProvider);

    final bgColor = _isStart ? colorScheme.tertiary : colorScheme.primary;
    final fgColor = _isStart ? colorScheme.onTertiary : colorScheme.onPrimary;

    // Progress ring data
    double progress = 0;
    if (subscription != null && subscription.transferLimit > 0) {
      progress = (subscription.usagePercentage / 100).clamp(0.0, 1.0);
    }

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
            final scale =
                _isFocused ? 1.05 : (_isStart ? 1.0 + _pulseController.value * 0.02 : 1.0);
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
                progress: progress,
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
  final double progress;
  final Color ringColor;
  final Color progressColor;
  final bool isFocused;
  final Color focusBorderColor;

  _ProgressRingPainter({
    required this.progress,
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

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        progressPaint,
      );
    }

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
      progress != old.progress ||
      isFocused != old.isFocused ||
      ringColor != old.ringColor;
}
