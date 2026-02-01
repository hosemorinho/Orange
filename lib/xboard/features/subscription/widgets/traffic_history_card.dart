import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/features/shared/widgets/xb_dashboard_card.dart';
import 'package:fl_clash/xboard/adapter/state/traffic_provider.dart';
import 'package:fl_clash/xboard/features/subscription/widgets/traffic_list.dart';
import 'package:fl_clash/xboard/features/subscription/widgets/traffic_chart_simple.dart';

/// Traffic History Card Widget
///
/// Displays traffic usage history with collapsible design
/// Mobile: List view by default, toggle to chart
/// Desktop: Chart view by default, collapsible
class TrafficHistoryCard extends ConsumerStatefulWidget {
  final bool initiallyExpanded;

  const TrafficHistoryCard({
    super.key,
    this.initiallyExpanded = false,
  });

  @override
  ConsumerState<TrafficHistoryCard> createState() => _TrafficHistoryCardState();
}

class _TrafficHistoryCardState extends ConsumerState<TrafficHistoryCard> {
  late bool _isExpanded;
  bool _showChart = false;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    // Desktop defaults to chart view
    _showChart = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      // Fetch traffic data on first load
      Future.microtask(() {
        ref.read(trafficLogsProvider.notifier).fetchTrafficLogs(limit: 30);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = appLocalizations;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final trafficState = ref.watch(trafficLogsProvider);
    final aggregatedData = trafficState.records.isNotEmpty
        ? ref.read(trafficLogsProvider.notifier).aggregateByDate()
        : <dynamic>[];

    return XBDashboardCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header with toggle button (always visible)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: XBSectionTitle(
                      title: l10n.xboardTrafficHistory,
                      icon: Icons.analytics_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Summary badge showing total records
                  if (aggregatedData.isNotEmpty && !trafficState.isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${aggregatedData.length} ${l10n.days}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Expand/collapse icon
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Collapsible content
          if (_isExpanded)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // View toggle buttons (Chart / List)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SegmentedButton<bool>(
                          segments: [
                            ButtonSegment<bool>(
                              value: false,
                              label: Text(
                                l10n.xboardViewList,
                                style: const TextStyle(fontSize: 12),
                              ),
                              icon: const Icon(Icons.list, size: 16),
                            ),
                            ButtonSegment<bool>(
                              value: true,
                              label: Text(
                                l10n.xboardViewChart,
                                style: const TextStyle(fontSize: 12),
                              ),
                              icon: const Icon(Icons.show_chart, size: 16),
                            ),
                          ],
                          selected: {_showChart},
                          onSelectionChanged: (Set<bool> selected) {
                            setState(() {
                              _showChart = selected.first;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Content (Chart or List)
                    if (_showChart)
                      TrafficChartSimple(
                        data: aggregatedData,
                        loading: trafficState.isLoading,
                      )
                    else
                      TrafficList(
                        data: aggregatedData,
                        loading: trafficState.isLoading,
                      ),

                    // Error message
                    if (trafficState.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          trafficState.errorMessage!,
                          style: TextStyle(
                            color: colorScheme.error,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
