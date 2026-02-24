import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 进度环形绘制器
///
/// 用于 VPN Hero Card 的流量进度环显示
class ProgressRingPainter extends CustomPainter {
  final Color color;
  final bool isActive;
  final double pulseProgress;
  final double progress;
  final double ringRadius;

  const ProgressRingPainter({
    required this.color,
    required this.isActive,
    required this.pulseProgress,
    required this.progress,
    required this.ringRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 3.5;
    const startAngle = -math.pi / 2; // 12 o'clock

    // Background ring (full circle, low opacity)
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.15);
    canvas.drawCircle(center, ringRadius, bgPaint);

    // Foreground arc (progress-based)
    final safeProgress = progress.isNaN || progress.isInfinite
        ? 0.0
        : progress.clamp(0.0, 1.0);
    if (safeProgress > 0) {
      final sweepAngle = 2 * math.pi * safeProgress;
      final scale = isActive ? 1.0 + 0.03 * pulseProgress : 1.0;
      final effectiveRadius = ringRadius * scale;

      final gradientPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader =
            SweepGradient(
              startAngle: startAngle,
              endAngle: startAngle + sweepAngle,
              colors: [color, color.withValues(alpha: 0.7)],
            ).createShader(
              Rect.fromCircle(center: center, radius: effectiveRadius),
            );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: effectiveRadius),
        startAngle,
        sweepAngle,
        false,
        gradientPaint,
      );
    } else if (isActive) {
      // When active but no progress data, show a pulsing full ring
      final scale = 1.0 + 0.03 * pulseProgress;
      final opacity = 0.3 + 0.4 * pulseProgress;
      final pulsePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: opacity);
      canvas.drawCircle(center, ringRadius * scale, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.isActive != isActive ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}
