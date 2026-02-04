import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/traffic_record.freezed.dart';
part 'generated/traffic_record.g.dart';

/// Domain layer: Traffic record model
///
/// Represents a single traffic usage record with server rate information
@freezed
abstract class TrafficRecord with _$TrafficRecord {
  const factory TrafficRecord({
    /// Record timestamp (Unix timestamp in seconds)
    required int recordAt,

    /// Upload bytes
    required int u,

    /// Download bytes
    required int d,

    /// Server rate multiplier (e.g., "1.0", "1.5", "2.0")
    required String serverRate,
  }) = _TrafficRecord;
  const TrafficRecord._();

  factory TrafficRecord.fromJson(Map<String, dynamic> json) =>
    _$TrafficRecordFromJson(json);

  /// Total traffic (upload + download)
  int get total => u + d;

  /// Parse server rate as double
  double get rateValue => double.tryParse(serverRate) ?? 1.0;

  /// Format bytes to GB with 2 decimal places
  static String formatBytesToGB(int bytes) {
    final gb = bytes / (1024 * 1024 * 1024);
    if (gb < 0.01) return '< 0.01';
    return gb.toStringAsFixed(2);
  }

  /// Format total traffic to GB
  String get totalGB => formatBytesToGB(total);

  /// Format upload to GB
  String get uploadGB => formatBytesToGB(u);

  /// Format download to GB
  String get downloadGB => formatBytesToGB(d);
}

/// Aggregated traffic data by date
@freezed
abstract class AggregatedTraffic with _$AggregatedTraffic {
  const factory AggregatedTraffic({
    /// Date string (YYYY-MM-DD)
    required String date,

    /// Timestamp for the day
    required int timestamp,

    /// Traffic records grouped by rate
    required List<TrafficRateGroup> rateGroups,

    /// Total upload bytes for the day
    required int totalU,

    /// Total download bytes for the day
    required int totalD,

    /// Total traffic for the day
    required int total,
  }) = _AggregatedTraffic;
  const AggregatedTraffic._();

  factory AggregatedTraffic.fromJson(Map<String, dynamic> json) =>
    _$AggregatedTrafficFromJson(json);

  /// Format total to GB
  String get totalGB => TrafficRecord.formatBytesToGB(total);
}

/// Traffic grouped by rate
@freezed
abstract class TrafficRateGroup with _$TrafficRateGroup {
  const factory TrafficRateGroup({
    /// Upload bytes
    required int u,

    /// Download bytes
    required int d,

    /// Rate multiplier
    required double rate,
  }) = _TrafficRateGroup;
  const TrafficRateGroup._();

  factory TrafficRateGroup.fromJson(Map<String, dynamic> json) =>
    _$TrafficRateGroupFromJson(json);

  /// Total traffic for this rate group
  int get total => u + d;

  /// Format total to GB
  String get totalGB => TrafficRecord.formatBytesToGB(total);

  /// Format upload to GB
  String get uploadGB => TrafficRecord.formatBytesToGB(u);

  /// Format download to GB
  String get downloadGB => TrafficRecord.formatBytesToGB(d);
}
