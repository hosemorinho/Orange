import 'dart:math';
import 'package:flutter/material.dart';

class ArcGauge extends StatefulWidget {
  final double progress;
  final Color activeColor;
  final Color backgroundColor;
  final Duration duration;

  const ArcGauge({
    super.key,
    required this.progress,
    required this.activeColor,
    this.backgroundColor = const Color(0x26000000),
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<ArcGauge> createState() => _ArcGaugeState();
}

class _ArcGaugeState extends State<ArcGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _oldProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _oldProgress = 0.0;
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ArcGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _oldProgress = oldWidget.progress * _animationController.value;
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ArcGaugePainter(
            progress: _oldProgress +
                (widget.progress - _oldProgress) *
                    Curves.easeOutCubic
                        .transform(_animationController.value),
            activeColor: widget.activeColor,
            backgroundColor: widget.backgroundColor,
          ),
        );
      },
    );
  }
}

class _ArcGaugePainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color backgroundColor;

  _ArcGaugePainter({
    required this.progress,
    required this.activeColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = min(size.width / 2, size.height * 0.8) - 8;
    const strokeWidth = 12.0;
    const startAngle = pi + pi * 0.15; // slightly past 180 for visual balance
    const sweepAngle = pi * 0.7; // 126 degree arc on each side = 252 total

    // Background arc
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = backgroundColor;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * 2,
      false,
      bgPaint,
    );

    // Active arc with gradient
    if (progress > 0) {
      final activeSweep = sweepAngle * 2 * progress.clamp(0.0, 1.0);

      final gradientPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + activeSweep,
          colors: [
            activeColor,
            activeColor.withValues(alpha: 0.7),
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: radius),
        );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweep,
        false,
        gradientPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
