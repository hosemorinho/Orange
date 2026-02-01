// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../traffic_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrafficRecord _$TrafficRecordFromJson(Map<String, dynamic> json) {
  return _TrafficRecord.fromJson(json);
}

/// @nodoc
mixin _$TrafficRecord {
  /// Record timestamp (Unix timestamp in seconds)
  int get recordAt => throw _privateConstructorUsedError;

  /// Upload bytes
  int get u => throw _privateConstructorUsedError;

  /// Download bytes
  int get d => throw _privateConstructorUsedError;

  /// Server rate multiplier (e.g., "1.0", "1.5", "2.0")
  String get serverRate => throw _privateConstructorUsedError;

  /// Serializes this TrafficRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrafficRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrafficRecordCopyWith<TrafficRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrafficRecordCopyWith<$Res> {
  factory $TrafficRecordCopyWith(
          TrafficRecord value, $Res Function(TrafficRecord) then) =
      _$TrafficRecordCopyWithImpl<$Res, TrafficRecord>;
  @useResult
  $Res call({int recordAt, int u, int d, String serverRate});
}

/// @nodoc
class _$TrafficRecordCopyWithImpl<$Res, $Val extends TrafficRecord>
    implements $TrafficRecordCopyWith<$Res> {
  _$TrafficRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrafficRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recordAt = null,
    Object? u = null,
    Object? d = null,
    Object? serverRate = null,
  }) {
    return _then(_value.copyWith(
      recordAt: null == recordAt
          ? _value.recordAt
          : recordAt // ignore: cast_nullable_to_non_nullable
              as int,
      u: null == u
          ? _value.u
          : u // ignore: cast_nullable_to_non_nullable
              as int,
      d: null == d
          ? _value.d
          : d // ignore: cast_nullable_to_non_nullable
              as int,
      serverRate: null == serverRate
          ? _value.serverRate
          : serverRate // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrafficRecordImplCopyWith<$Res>
    implements $TrafficRecordCopyWith<$Res> {
  factory _$$TrafficRecordImplCopyWith(
          _$TrafficRecordImpl value, $Res Function(_$TrafficRecordImpl) then) =
      __$$TrafficRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int recordAt, int u, int d, String serverRate});
}

/// @nodoc
class __$$TrafficRecordImplCopyWithImpl<$Res>
    extends _$TrafficRecordCopyWithImpl<$Res, _$TrafficRecordImpl>
    implements _$$TrafficRecordImplCopyWith<$Res> {
  __$$TrafficRecordImplCopyWithImpl(
      _$TrafficRecordImpl _value, $Res Function(_$TrafficRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrafficRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recordAt = null,
    Object? u = null,
    Object? d = null,
    Object? serverRate = null,
  }) {
    return _then(_$TrafficRecordImpl(
      recordAt: null == recordAt
          ? _value.recordAt
          : recordAt // ignore: cast_nullable_to_non_nullable
              as int,
      u: null == u
          ? _value.u
          : u // ignore: cast_nullable_to_non_nullable
              as int,
      d: null == d
          ? _value.d
          : d // ignore: cast_nullable_to_non_nullable
              as int,
      serverRate: null == serverRate
          ? _value.serverRate
          : serverRate // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrafficRecordImpl extends _TrafficRecord {
  const _$TrafficRecordImpl(
      {required this.recordAt,
      required this.u,
      required this.d,
      required this.serverRate})
      : super._();

  factory _$TrafficRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrafficRecordImplFromJson(json);

  /// Record timestamp (Unix timestamp in seconds)
  @override
  final int recordAt;

  /// Upload bytes
  @override
  final int u;

  /// Download bytes
  @override
  final int d;

  /// Server rate multiplier (e.g., "1.0", "1.5", "2.0")
  @override
  final String serverRate;

  @override
  String toString() {
    return 'TrafficRecord(recordAt: $recordAt, u: $u, d: $d, serverRate: $serverRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrafficRecordImpl &&
            (identical(other.recordAt, recordAt) ||
                other.recordAt == recordAt) &&
            (identical(other.u, u) || other.u == u) &&
            (identical(other.d, d) || other.d == d) &&
            (identical(other.serverRate, serverRate) ||
                other.serverRate == serverRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, recordAt, u, d, serverRate);

  /// Create a copy of TrafficRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrafficRecordImplCopyWith<_$TrafficRecordImpl> get copyWith =>
      __$$TrafficRecordImplCopyWithImpl<_$TrafficRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrafficRecordImplToJson(
      this,
    );
  }
}

abstract class _TrafficRecord extends TrafficRecord {
  const factory _TrafficRecord(
      {required final int recordAt,
      required final int u,
      required final int d,
      required final String serverRate}) = _$TrafficRecordImpl;
  const _TrafficRecord._() : super._();

  factory _TrafficRecord.fromJson(Map<String, dynamic> json) =
      _$TrafficRecordImpl.fromJson;

  /// Record timestamp (Unix timestamp in seconds)
  @override
  int get recordAt;

  /// Upload bytes
  @override
  int get u;

  /// Download bytes
  @override
  int get d;

  /// Server rate multiplier (e.g., "1.0", "1.5", "2.0")
  @override
  String get serverRate;

  /// Create a copy of TrafficRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrafficRecordImplCopyWith<_$TrafficRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AggregatedTraffic _$AggregatedTrafficFromJson(Map<String, dynamic> json) {
  return _AggregatedTraffic.fromJson(json);
}

/// @nodoc
mixin _$AggregatedTraffic {
  /// Date string (YYYY-MM-DD)
  String get date => throw _privateConstructorUsedError;

  /// Timestamp for the day
  int get timestamp => throw _privateConstructorUsedError;

  /// Traffic records grouped by rate
  List<TrafficRateGroup> get rateGroups => throw _privateConstructorUsedError;

  /// Total upload bytes for the day
  int get totalU => throw _privateConstructorUsedError;

  /// Total download bytes for the day
  int get totalD => throw _privateConstructorUsedError;

  /// Total traffic for the day
  int get total => throw _privateConstructorUsedError;

  /// Serializes this AggregatedTraffic to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AggregatedTraffic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AggregatedTrafficCopyWith<AggregatedTraffic> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AggregatedTrafficCopyWith<$Res> {
  factory $AggregatedTrafficCopyWith(
          AggregatedTraffic value, $Res Function(AggregatedTraffic) then) =
      _$AggregatedTrafficCopyWithImpl<$Res, AggregatedTraffic>;
  @useResult
  $Res call(
      {String date,
      int timestamp,
      List<TrafficRateGroup> rateGroups,
      int totalU,
      int totalD,
      int total});
}

/// @nodoc
class _$AggregatedTrafficCopyWithImpl<$Res, $Val extends AggregatedTraffic>
    implements $AggregatedTrafficCopyWith<$Res> {
  _$AggregatedTrafficCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AggregatedTraffic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? timestamp = null,
    Object? rateGroups = null,
    Object? totalU = null,
    Object? totalD = null,
    Object? total = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      rateGroups: null == rateGroups
          ? _value.rateGroups
          : rateGroups // ignore: cast_nullable_to_non_nullable
              as List<TrafficRateGroup>,
      totalU: null == totalU
          ? _value.totalU
          : totalU // ignore: cast_nullable_to_non_nullable
              as int,
      totalD: null == totalD
          ? _value.totalD
          : totalD // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AggregatedTrafficImplCopyWith<$Res>
    implements $AggregatedTrafficCopyWith<$Res> {
  factory _$$AggregatedTrafficImplCopyWith(_$AggregatedTrafficImpl value,
          $Res Function(_$AggregatedTrafficImpl) then) =
      __$$AggregatedTrafficImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String date,
      int timestamp,
      List<TrafficRateGroup> rateGroups,
      int totalU,
      int totalD,
      int total});
}

/// @nodoc
class __$$AggregatedTrafficImplCopyWithImpl<$Res>
    extends _$AggregatedTrafficCopyWithImpl<$Res, _$AggregatedTrafficImpl>
    implements _$$AggregatedTrafficImplCopyWith<$Res> {
  __$$AggregatedTrafficImplCopyWithImpl(_$AggregatedTrafficImpl _value,
      $Res Function(_$AggregatedTrafficImpl) _then)
      : super(_value, _then);

  /// Create a copy of AggregatedTraffic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? timestamp = null,
    Object? rateGroups = null,
    Object? totalU = null,
    Object? totalD = null,
    Object? total = null,
  }) {
    return _then(_$AggregatedTrafficImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int,
      rateGroups: null == rateGroups
          ? _value._rateGroups
          : rateGroups // ignore: cast_nullable_to_non_nullable
              as List<TrafficRateGroup>,
      totalU: null == totalU
          ? _value.totalU
          : totalU // ignore: cast_nullable_to_non_nullable
              as int,
      totalD: null == totalD
          ? _value.totalD
          : totalD // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AggregatedTrafficImpl extends _AggregatedTraffic {
  const _$AggregatedTrafficImpl(
      {required this.date,
      required this.timestamp,
      required final List<TrafficRateGroup> rateGroups,
      required this.totalU,
      required this.totalD,
      required this.total})
      : _rateGroups = rateGroups,
        super._();

  factory _$AggregatedTrafficImpl.fromJson(Map<String, dynamic> json) =>
      _$$AggregatedTrafficImplFromJson(json);

  /// Date string (YYYY-MM-DD)
  @override
  final String date;

  /// Timestamp for the day
  @override
  final int timestamp;

  /// Traffic records grouped by rate
  final List<TrafficRateGroup> _rateGroups;

  /// Traffic records grouped by rate
  @override
  List<TrafficRateGroup> get rateGroups {
    if (_rateGroups is EqualUnmodifiableListView) return _rateGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rateGroups);
  }

  /// Total upload bytes for the day
  @override
  final int totalU;

  /// Total download bytes for the day
  @override
  final int totalD;

  /// Total traffic for the day
  @override
  final int total;

  @override
  String toString() {
    return 'AggregatedTraffic(date: $date, timestamp: $timestamp, rateGroups: $rateGroups, totalU: $totalU, totalD: $totalD, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AggregatedTrafficImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality()
                .equals(other._rateGroups, _rateGroups) &&
            (identical(other.totalU, totalU) || other.totalU == totalU) &&
            (identical(other.totalD, totalD) || other.totalD == totalD) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, timestamp,
      const DeepCollectionEquality().hash(_rateGroups), totalU, totalD, total);

  /// Create a copy of AggregatedTraffic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AggregatedTrafficImplCopyWith<_$AggregatedTrafficImpl> get copyWith =>
      __$$AggregatedTrafficImplCopyWithImpl<_$AggregatedTrafficImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AggregatedTrafficImplToJson(
      this,
    );
  }
}

abstract class _AggregatedTraffic extends AggregatedTraffic {
  const factory _AggregatedTraffic(
      {required final String date,
      required final int timestamp,
      required final List<TrafficRateGroup> rateGroups,
      required final int totalU,
      required final int totalD,
      required final int total}) = _$AggregatedTrafficImpl;
  const _AggregatedTraffic._() : super._();

  factory _AggregatedTraffic.fromJson(Map<String, dynamic> json) =
      _$AggregatedTrafficImpl.fromJson;

  /// Date string (YYYY-MM-DD)
  @override
  String get date;

  /// Timestamp for the day
  @override
  int get timestamp;

  /// Traffic records grouped by rate
  @override
  List<TrafficRateGroup> get rateGroups;

  /// Total upload bytes for the day
  @override
  int get totalU;

  /// Total download bytes for the day
  @override
  int get totalD;

  /// Total traffic for the day
  @override
  int get total;

  /// Create a copy of AggregatedTraffic
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AggregatedTrafficImplCopyWith<_$AggregatedTrafficImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrafficRateGroup _$TrafficRateGroupFromJson(Map<String, dynamic> json) {
  return _TrafficRateGroup.fromJson(json);
}

/// @nodoc
mixin _$TrafficRateGroup {
  /// Upload bytes
  int get u => throw _privateConstructorUsedError;

  /// Download bytes
  int get d => throw _privateConstructorUsedError;

  /// Rate multiplier
  double get rate => throw _privateConstructorUsedError;

  /// Serializes this TrafficRateGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrafficRateGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrafficRateGroupCopyWith<TrafficRateGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrafficRateGroupCopyWith<$Res> {
  factory $TrafficRateGroupCopyWith(
          TrafficRateGroup value, $Res Function(TrafficRateGroup) then) =
      _$TrafficRateGroupCopyWithImpl<$Res, TrafficRateGroup>;
  @useResult
  $Res call({int u, int d, double rate});
}

/// @nodoc
class _$TrafficRateGroupCopyWithImpl<$Res, $Val extends TrafficRateGroup>
    implements $TrafficRateGroupCopyWith<$Res> {
  _$TrafficRateGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrafficRateGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? u = null,
    Object? d = null,
    Object? rate = null,
  }) {
    return _then(_value.copyWith(
      u: null == u
          ? _value.u
          : u // ignore: cast_nullable_to_non_nullable
              as int,
      d: null == d
          ? _value.d
          : d // ignore: cast_nullable_to_non_nullable
              as int,
      rate: null == rate
          ? _value.rate
          : rate // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrafficRateGroupImplCopyWith<$Res>
    implements $TrafficRateGroupCopyWith<$Res> {
  factory _$$TrafficRateGroupImplCopyWith(_$TrafficRateGroupImpl value,
          $Res Function(_$TrafficRateGroupImpl) then) =
      __$$TrafficRateGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int u, int d, double rate});
}

/// @nodoc
class __$$TrafficRateGroupImplCopyWithImpl<$Res>
    extends _$TrafficRateGroupCopyWithImpl<$Res, _$TrafficRateGroupImpl>
    implements _$$TrafficRateGroupImplCopyWith<$Res> {
  __$$TrafficRateGroupImplCopyWithImpl(_$TrafficRateGroupImpl _value,
      $Res Function(_$TrafficRateGroupImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrafficRateGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? u = null,
    Object? d = null,
    Object? rate = null,
  }) {
    return _then(_$TrafficRateGroupImpl(
      u: null == u
          ? _value.u
          : u // ignore: cast_nullable_to_non_nullable
              as int,
      d: null == d
          ? _value.d
          : d // ignore: cast_nullable_to_non_nullable
              as int,
      rate: null == rate
          ? _value.rate
          : rate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrafficRateGroupImpl extends _TrafficRateGroup {
  const _$TrafficRateGroupImpl(
      {required this.u, required this.d, required this.rate})
      : super._();

  factory _$TrafficRateGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrafficRateGroupImplFromJson(json);

  /// Upload bytes
  @override
  final int u;

  /// Download bytes
  @override
  final int d;

  /// Rate multiplier
  @override
  final double rate;

  @override
  String toString() {
    return 'TrafficRateGroup(u: $u, d: $d, rate: $rate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrafficRateGroupImpl &&
            (identical(other.u, u) || other.u == u) &&
            (identical(other.d, d) || other.d == d) &&
            (identical(other.rate, rate) || other.rate == rate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, u, d, rate);

  /// Create a copy of TrafficRateGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrafficRateGroupImplCopyWith<_$TrafficRateGroupImpl> get copyWith =>
      __$$TrafficRateGroupImplCopyWithImpl<_$TrafficRateGroupImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrafficRateGroupImplToJson(
      this,
    );
  }
}

abstract class _TrafficRateGroup extends TrafficRateGroup {
  const factory _TrafficRateGroup(
      {required final int u,
      required final int d,
      required final double rate}) = _$TrafficRateGroupImpl;
  const _TrafficRateGroup._() : super._();

  factory _TrafficRateGroup.fromJson(Map<String, dynamic> json) =
      _$TrafficRateGroupImpl.fromJson;

  /// Upload bytes
  @override
  int get u;

  /// Download bytes
  @override
  int get d;

  /// Rate multiplier
  @override
  double get rate;

  /// Create a copy of TrafficRateGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrafficRateGroupImplCopyWith<_$TrafficRateGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
