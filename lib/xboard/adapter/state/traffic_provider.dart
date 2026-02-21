import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/domain/models/traffic_record.dart';
import 'package:fl_clash/xboard/infrastructure/api/v2board_error_localizer.dart';
import 'package:fl_clash/xboard/infrastructure/api/v2board_response.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';

part 'generated/traffic_provider.g.dart';

/// Traffic logs state
class TrafficLogsState {
  final List<TrafficRecord> records;
  final bool isLoading;
  final String? errorMessage;
  final int total;

  const TrafficLogsState({
    this.records = const [],
    this.isLoading = false,
    this.errorMessage,
    this.total = 0,
  });

  TrafficLogsState copyWith({
    List<TrafficRecord>? records,
    bool? isLoading,
    String? errorMessage,
    int? total,
  }) {
    return TrafficLogsState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      total: total ?? this.total,
    );
  }
}

/// Traffic logs provider
@riverpod
class TrafficLogs extends _$TrafficLogs {
  @override
  TrafficLogsState build() {
    return const TrafficLogsState();
  }

  /// Fetch traffic logs from API
  Future<void> fetchTrafficLogs({
    int offset = 0,
    int limit = 30,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final api = await ref.read(xboardSdkProvider.future);
      final response = await api.getTrafficLogs(offset: offset, limit: limit);

      final v2Response = V2BoardResponse.fromJson(response);

      if (v2Response.data == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No traffic data available',
        );
        return;
      }

      // Parse response - handle both paginated Map and direct List formats
      final rawData = v2Response.data;
      List<dynamic> recordsList;
      int total;

      if (rawData is List) {
        recordsList = rawData;
        total = rawData.length;
      } else if (rawData is Map<String, dynamic>) {
        recordsList = rawData['data'] as List<dynamic>? ?? [];
        total = rawData['total'] as int? ?? 0;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Unexpected traffic data format',
        );
        return;
      }

      final records = recordsList.map((json) {
        final record = json as Map<String, dynamic>;
        return TrafficRecord(
          recordAt: record['record_at'] as int,
          u: record['u'] as int,
          d: record['d'] as int,
          serverRate: record['server_rate'].toString(),
        );
      }).toList();

      state = state.copyWith(
        records: records,
        total: total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: V2BoardErrorLocalizer.localize(ErrorSanitizer.sanitize(e.toString())),
      );
    }
  }

  /// Aggregate traffic records by date
  List<AggregatedTraffic> aggregateByDate() {
    final grouped = <String, Map<String, dynamic>>{};

    for (final record in state.records) {
      final date = DateTime.fromMillisecondsSinceEpoch(record.recordAt * 1000);
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = {
          'date': dateKey,
          'timestamp': (date.millisecondsSinceEpoch / 1000).floor(),
          'rateGroups': <double, TrafficRateGroup>{},
          'totalU': 0,
          'totalD': 0,
        };
      }

      final dayData = grouped[dateKey]!;
      final rateGroups = dayData['rateGroups'] as Map<double, TrafficRateGroup>;
      final rate = record.rateValue;

      if (!rateGroups.containsKey(rate)) {
        rateGroups[rate] = TrafficRateGroup(u: 0, d: 0, rate: rate);
      }

      rateGroups[rate] = TrafficRateGroup(
        u: rateGroups[rate]!.u + record.u,
        d: rateGroups[rate]!.d + record.d,
        rate: rate,
      );

      dayData['totalU'] = (dayData['totalU'] as int) + record.u;
      dayData['totalD'] = (dayData['totalD'] as int) + record.d;
    }

    // Convert to list and sort by date (newest first)
    final aggregated = grouped.entries.map((entry) {
      final dayData = entry.value;
      final rateGroups = (dayData['rateGroups'] as Map<double, TrafficRateGroup>)
          .values
          .toList()
        ..sort((a, b) => a.rate.compareTo(b.rate));

      return AggregatedTraffic(
        date: dayData['date'] as String,
        timestamp: dayData['timestamp'] as int,
        rateGroups: rateGroups,
        totalU: dayData['totalU'] as int,
        totalD: dayData['totalD'] as int,
        total: (dayData['totalU'] as int) + (dayData['totalD'] as int),
      );
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return aggregated;
  }
}
