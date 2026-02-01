import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/domain/models/traffic_record.dart';

/// Traffic list widget - displays daily traffic usage in expandable cards
class TrafficList extends ConsumerStatefulWidget {
  final List<AggregatedTraffic> data;
  final bool loading;

  const TrafficList({
    super.key,
    required this.data,
    this.loading = false,
  });

  @override
  ConsumerState<TrafficList> createState() => _TrafficListState();
}

class _TrafficListState extends ConsumerState<TrafficList> {
  int? _expandedIndex;

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

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.data.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final day = widget.data[index];
        final isExpanded = _expandedIndex == index;

        return _buildTrafficCard(
          day,
          index,
          isExpanded,
          l10n,
          colorScheme,
        );
      },
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
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

  Widget _buildTrafficCard(
    AggregatedTraffic day,
    int index,
    bool isExpanded,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Summary - Always visible
          InkWell(
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            _formatDate(day.timestamp, l10n),
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${day.totalGB} GB',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Details - Expandable
          if (isExpanded) ...[
            Divider(
              height: 1,
              color: colorScheme.outlineVariant,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full date
                  Text(
                    _formatFullDate(day.timestamp, l10n),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Rate groups
                  ...day.rateGroups.map((group) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _getRateColor(group.rate, colorScheme)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  '${group.rate}x',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _getRateColor(group.rate, colorScheme),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '(${l10n.upload}: ${group.uploadGB} GB / ${l10n.download}: ${group.downloadGB} GB)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _getRateColor(group.rate, colorScheme)
                                          .withValues(alpha: 0.8),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${group.totalGB} GB',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _getRateColor(group.rate, colorScheme),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Total summary
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.xboardTrafficTotal,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${day.totalGB} GB',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get color for different rate multipliers
  Color _getRateColor(double rate, ColorScheme colorScheme) {
    // Match frontend colors: 1x=Blue, 1.5x=Green, 2x=Orange, 3x=Red, 0.5x=Purple
    if (rate == 1.0) {
      return Colors.blue.shade600; // Blue for 1x
    } else if (rate == 1.5) {
      return Colors.green.shade600; // Green for 1.5x
    } else if (rate == 2.0) {
      return Colors.orange.shade600; // Orange for 2x
    } else if (rate == 3.0) {
      return Colors.red.shade600; // Red for 3x
    } else if (rate == 0.5) {
      return Colors.purple.shade600; // Purple for 0.5x
    } else {
      return colorScheme.onSurfaceVariant; // Default
    }
  }

  /// Format date to "Today", "Yesterday", or "MM/DD"
  String _formatDate(int timestamp, AppLocalizations l10n) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return l10n.xboardToday;
    } else if (dateOnly == yesterday) {
      return l10n.xboardYesterday;
    } else {
      return DateFormat('MM/dd').format(date);
    }
  }

  /// Format full date
  String _formatFullDate(int timestamp, AppLocalizations l10n) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat.yMMMMEEEEd().format(date);
  }
}
