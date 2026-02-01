import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/domain/models/traffic_record.dart';
import 'dart:math' as math;

/// Simple traffic chart widget using CustomPainter
class TrafficChartSimple extends ConsumerStatefulWidget {
  final List<AggregatedTraffic> data;
  final bool loading;

  const TrafficChartSimple({
    super.key,
    required this.data,
    this.loading = false,
  });

  @override
  ConsumerState<TrafficChartSimple> createState() => _TrafficChartSimpleState();
}

class _TrafficChartSimpleState extends ConsumerState<TrafficChartSimple> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = appLocalizations;

    if (widget.loading) {
      return _buildLoadingState(colorScheme);
    }

    if (widget.data.isEmpty) {
      return _buildEmptyState(l10n, colorScheme);
    }

    // Take last 7 days (or less if not enough data)
    final chartData = widget.data.take(7).toList().reversed.toList();

    // Find max value for Y axis
    final maxValue = chartData.isEmpty
        ? 1
        : chartData.map((d) => d.total).reduce(math.max);

    // Get all unique rates for legend
    final allRates = <double>{};
    for (final day in chartData) {
      for (final group in day.rateGroups) {
        allRates.add(group.rate);
      }
    }
    final sortedRates = allRates.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Legend
        _buildLegend(sortedRates, colorScheme, l10n),
        const SizedBox(height: 16),

        // Chart
        SizedBox(
          height: 250,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (details) {
                  final barWidth = constraints.maxWidth / chartData.length;
                  final index = (details.localPosition.dx / barWidth).floor();
                  if (index >= 0 && index < chartData.length) {
                    setState(() {
                      _hoveredIndex = index;
                    });
                  }
                },
                onTapCancel: () {
                  setState(() {
                    _hoveredIndex = null;
                  });
                },
                child: CustomPaint(
                  painter: _TrafficChartPainter(
                    data: chartData,
                    maxValue: maxValue,
                    colorScheme: colorScheme,
                    hoveredIndex: _hoveredIndex,
                  ),
                  size: Size(constraints.maxWidth, 250),
                ),
              );
            },
          ),
        ),

        // Tooltip
        if (_hoveredIndex != null && _hoveredIndex! < chartData.length)
          _buildTooltip(chartData[_hoveredIndex!], colorScheme, l10n),
      ],
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ColorScheme colorScheme) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.xboardTrafficNoData,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(
    List<double> rates,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: rates.map((rate) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getRateColor(rate),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${rate}x',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTooltip(
    AggregatedTraffic day,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatFullDate(day.timestamp),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.xboardTrafficTotal,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${day.totalGB} GB',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          ...day.rateGroups.map((group) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getRateColor(group.rate),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${group.rate}x:',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${group.totalGB} GB',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getRateColor(double rate) {
    if (rate == 1.0) {
      return Colors.blue.shade600;
    } else if (rate == 1.5) {
      return Colors.green.shade600;
    } else if (rate == 2.0) {
      return Colors.orange.shade600;
    } else if (rate == 3.0) {
      return Colors.red.shade600;
    } else if (rate == 0.5) {
      return Colors.purple.shade600;
    } else {
      return Colors.grey.shade600;
    }
  }

  String _formatFullDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat.MMMd().format(date);
  }
}

/// Custom painter for traffic chart
class _TrafficChartPainter extends CustomPainter {
  final List<AggregatedTraffic> data;
  final int maxValue;
  final ColorScheme colorScheme;
  final int? hoveredIndex;

  _TrafficChartPainter({
    required this.data,
    required this.maxValue,
    required this.colorScheme,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = EdgeInsets.only(left: 50, right: 20, top: 20, bottom: 40);
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;

    // Draw Y axis grid lines and labels
    _drawYAxis(canvas, size, padding, chartHeight);

    // Draw bars
    _drawBars(canvas, size, padding, chartWidth, chartHeight);

    // Draw X axis labels
    _drawXAxisLabels(canvas, size, padding, chartWidth);
  }

  void _drawYAxis(Canvas canvas, Size size, EdgeInsets padding, double chartHeight) {
    const yTicks = 5;
    final paint = Paint()
      ..color = colorScheme.outlineVariant
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i <= yTicks; i++) {
      final value = (maxValue / yTicks) * (yTicks - i);
      final y = padding.top + (chartHeight / yTicks) * i;

      // Grid line
      canvas.drawLine(
        Offset(padding.left, y),
        Offset(size.width - padding.right, y),
        paint..color = colorScheme.outlineVariant.withValues(alpha: 0.3),
      );

      // Y axis label
      final gb = value / (1024 * 1024 * 1024);
      final label = gb < 0.01 ? '0' : gb.toStringAsFixed(1);
      textPainter.text = TextSpan(
        text: '$label GB',
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(padding.left - textPainter.width - 8, y - textPainter.height / 2),
      );
    }
  }

  void _drawBars(
    Canvas canvas,
    Size size,
    EdgeInsets padding,
    double chartWidth,
    double chartHeight,
  ) {
    final barWidth = chartWidth / data.length;
    final barSpacing = barWidth * 0.2;
    final actualBarWidth = barWidth - barSpacing;

    for (int i = 0; i < data.length; i++) {
      final day = data[i];
      final x = padding.left + (i * barWidth) + (barSpacing / 2);

      // Draw stacked bars for each rate group
      double currentY = padding.top + chartHeight;

      for (final group in day.rateGroups) {
        final barHeight = (group.total / maxValue) * chartHeight;
        final rect = Rect.fromLTWH(
          x,
          currentY - barHeight,
          actualBarWidth,
          barHeight,
        );

        final paint = Paint()
          ..color = _getRateColor(group.rate)
              .withValues(alpha: hoveredIndex == i ? 1.0 : 0.7)
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          paint,
        );

        currentY -= barHeight;
      }
    }
  }

  void _drawXAxisLabels(
    Canvas canvas,
    Size size,
    EdgeInsets padding,
    double chartWidth,
  ) {
    final barWidth = chartWidth / data.length;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < data.length; i++) {
      final day = data[i];
      final x = padding.left + (i * barWidth) + (barWidth / 2);

      final date = DateTime.fromMillisecondsSinceEpoch(day.timestamp * 1000);
      final label = DateFormat('M/d').format(date);

      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - padding.bottom + 10),
      );
    }
  }

  Color _getRateColor(double rate) {
    if (rate == 1.0) {
      return Colors.blue.shade600;
    } else if (rate == 1.5) {
      return Colors.green.shade600;
    } else if (rate == 2.0) {
      return Colors.orange.shade600;
    } else if (rate == 3.0) {
      return Colors.red.shade600;
    } else if (rate == 0.5) {
      return Colors.purple.shade600;
    } else {
      return Colors.grey.shade600;
    }
  }

  @override
  bool shouldRepaint(_TrafficChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.hoveredIndex != hoveredIndex;
  }
}
