// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../traffic_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrafficRecord {

/// Record timestamp (Unix timestamp in seconds)
 int get recordAt;/// Upload bytes
 int get u;/// Download bytes
 int get d;/// Server rate multiplier (e.g., "1.0", "1.5", "2.0")
 String get serverRate;
/// Create a copy of TrafficRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrafficRecordCopyWith<TrafficRecord> get copyWith => _$TrafficRecordCopyWithImpl<TrafficRecord>(this as TrafficRecord, _$identity);

  /// Serializes this TrafficRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrafficRecord&&(identical(other.recordAt, recordAt) || other.recordAt == recordAt)&&(identical(other.u, u) || other.u == u)&&(identical(other.d, d) || other.d == d)&&(identical(other.serverRate, serverRate) || other.serverRate == serverRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recordAt,u,d,serverRate);

@override
String toString() {
  return 'TrafficRecord(recordAt: $recordAt, u: $u, d: $d, serverRate: $serverRate)';
}


}

/// @nodoc
abstract mixin class $TrafficRecordCopyWith<$Res>  {
  factory $TrafficRecordCopyWith(TrafficRecord value, $Res Function(TrafficRecord) _then) = _$TrafficRecordCopyWithImpl;
@useResult
$Res call({
 int recordAt, int u, int d, String serverRate
});




}
/// @nodoc
class _$TrafficRecordCopyWithImpl<$Res>
    implements $TrafficRecordCopyWith<$Res> {
  _$TrafficRecordCopyWithImpl(this._self, this._then);

  final TrafficRecord _self;
  final $Res Function(TrafficRecord) _then;

/// Create a copy of TrafficRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recordAt = null,Object? u = null,Object? d = null,Object? serverRate = null,}) {
  return _then(_self.copyWith(
recordAt: null == recordAt ? _self.recordAt : recordAt // ignore: cast_nullable_to_non_nullable
as int,u: null == u ? _self.u : u // ignore: cast_nullable_to_non_nullable
as int,d: null == d ? _self.d : d // ignore: cast_nullable_to_non_nullable
as int,serverRate: null == serverRate ? _self.serverRate : serverRate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TrafficRecord].
extension TrafficRecordPatterns on TrafficRecord {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrafficRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrafficRecord() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrafficRecord value)  $default,){
final _that = this;
switch (_that) {
case _TrafficRecord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrafficRecord value)?  $default,){
final _that = this;
switch (_that) {
case _TrafficRecord() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int recordAt,  int u,  int d,  String serverRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrafficRecord() when $default != null:
return $default(_that.recordAt,_that.u,_that.d,_that.serverRate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int recordAt,  int u,  int d,  String serverRate)  $default,) {final _that = this;
switch (_that) {
case _TrafficRecord():
return $default(_that.recordAt,_that.u,_that.d,_that.serverRate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int recordAt,  int u,  int d,  String serverRate)?  $default,) {final _that = this;
switch (_that) {
case _TrafficRecord() when $default != null:
return $default(_that.recordAt,_that.u,_that.d,_that.serverRate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrafficRecord extends TrafficRecord {
  const _TrafficRecord({required this.recordAt, required this.u, required this.d, required this.serverRate}): super._();
  factory _TrafficRecord.fromJson(Map<String, dynamic> json) => _$TrafficRecordFromJson(json);

/// Record timestamp (Unix timestamp in seconds)
@override final  int recordAt;
/// Upload bytes
@override final  int u;
/// Download bytes
@override final  int d;
/// Server rate multiplier (e.g., "1.0", "1.5", "2.0")
@override final  String serverRate;

/// Create a copy of TrafficRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrafficRecordCopyWith<_TrafficRecord> get copyWith => __$TrafficRecordCopyWithImpl<_TrafficRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrafficRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrafficRecord&&(identical(other.recordAt, recordAt) || other.recordAt == recordAt)&&(identical(other.u, u) || other.u == u)&&(identical(other.d, d) || other.d == d)&&(identical(other.serverRate, serverRate) || other.serverRate == serverRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recordAt,u,d,serverRate);

@override
String toString() {
  return 'TrafficRecord(recordAt: $recordAt, u: $u, d: $d, serverRate: $serverRate)';
}


}

/// @nodoc
abstract mixin class _$TrafficRecordCopyWith<$Res> implements $TrafficRecordCopyWith<$Res> {
  factory _$TrafficRecordCopyWith(_TrafficRecord value, $Res Function(_TrafficRecord) _then) = __$TrafficRecordCopyWithImpl;
@override @useResult
$Res call({
 int recordAt, int u, int d, String serverRate
});




}
/// @nodoc
class __$TrafficRecordCopyWithImpl<$Res>
    implements _$TrafficRecordCopyWith<$Res> {
  __$TrafficRecordCopyWithImpl(this._self, this._then);

  final _TrafficRecord _self;
  final $Res Function(_TrafficRecord) _then;

/// Create a copy of TrafficRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recordAt = null,Object? u = null,Object? d = null,Object? serverRate = null,}) {
  return _then(_TrafficRecord(
recordAt: null == recordAt ? _self.recordAt : recordAt // ignore: cast_nullable_to_non_nullable
as int,u: null == u ? _self.u : u // ignore: cast_nullable_to_non_nullable
as int,d: null == d ? _self.d : d // ignore: cast_nullable_to_non_nullable
as int,serverRate: null == serverRate ? _self.serverRate : serverRate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AggregatedTraffic {

/// Date string (YYYY-MM-DD)
 String get date;/// Timestamp for the day
 int get timestamp;/// Traffic records grouped by rate
 List<TrafficRateGroup> get rateGroups;/// Total upload bytes for the day
 int get totalU;/// Total download bytes for the day
 int get totalD;/// Total traffic for the day
 int get total;
/// Create a copy of AggregatedTraffic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AggregatedTrafficCopyWith<AggregatedTraffic> get copyWith => _$AggregatedTrafficCopyWithImpl<AggregatedTraffic>(this as AggregatedTraffic, _$identity);

  /// Serializes this AggregatedTraffic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AggregatedTraffic&&(identical(other.date, date) || other.date == date)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other.rateGroups, rateGroups)&&(identical(other.totalU, totalU) || other.totalU == totalU)&&(identical(other.totalD, totalD) || other.totalD == totalD)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,timestamp,const DeepCollectionEquality().hash(rateGroups),totalU,totalD,total);

@override
String toString() {
  return 'AggregatedTraffic(date: $date, timestamp: $timestamp, rateGroups: $rateGroups, totalU: $totalU, totalD: $totalD, total: $total)';
}


}

/// @nodoc
abstract mixin class $AggregatedTrafficCopyWith<$Res>  {
  factory $AggregatedTrafficCopyWith(AggregatedTraffic value, $Res Function(AggregatedTraffic) _then) = _$AggregatedTrafficCopyWithImpl;
@useResult
$Res call({
 String date, int timestamp, List<TrafficRateGroup> rateGroups, int totalU, int totalD, int total
});




}
/// @nodoc
class _$AggregatedTrafficCopyWithImpl<$Res>
    implements $AggregatedTrafficCopyWith<$Res> {
  _$AggregatedTrafficCopyWithImpl(this._self, this._then);

  final AggregatedTraffic _self;
  final $Res Function(AggregatedTraffic) _then;

/// Create a copy of AggregatedTraffic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? timestamp = null,Object? rateGroups = null,Object? totalU = null,Object? totalD = null,Object? total = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,rateGroups: null == rateGroups ? _self.rateGroups : rateGroups // ignore: cast_nullable_to_non_nullable
as List<TrafficRateGroup>,totalU: null == totalU ? _self.totalU : totalU // ignore: cast_nullable_to_non_nullable
as int,totalD: null == totalD ? _self.totalD : totalD // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AggregatedTraffic].
extension AggregatedTrafficPatterns on AggregatedTraffic {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AggregatedTraffic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AggregatedTraffic() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AggregatedTraffic value)  $default,){
final _that = this;
switch (_that) {
case _AggregatedTraffic():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AggregatedTraffic value)?  $default,){
final _that = this;
switch (_that) {
case _AggregatedTraffic() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  int timestamp,  List<TrafficRateGroup> rateGroups,  int totalU,  int totalD,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AggregatedTraffic() when $default != null:
return $default(_that.date,_that.timestamp,_that.rateGroups,_that.totalU,_that.totalD,_that.total);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  int timestamp,  List<TrafficRateGroup> rateGroups,  int totalU,  int totalD,  int total)  $default,) {final _that = this;
switch (_that) {
case _AggregatedTraffic():
return $default(_that.date,_that.timestamp,_that.rateGroups,_that.totalU,_that.totalD,_that.total);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  int timestamp,  List<TrafficRateGroup> rateGroups,  int totalU,  int totalD,  int total)?  $default,) {final _that = this;
switch (_that) {
case _AggregatedTraffic() when $default != null:
return $default(_that.date,_that.timestamp,_that.rateGroups,_that.totalU,_that.totalD,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AggregatedTraffic extends AggregatedTraffic {
  const _AggregatedTraffic({required this.date, required this.timestamp, required final  List<TrafficRateGroup> rateGroups, required this.totalU, required this.totalD, required this.total}): _rateGroups = rateGroups,super._();
  factory _AggregatedTraffic.fromJson(Map<String, dynamic> json) => _$AggregatedTrafficFromJson(json);

/// Date string (YYYY-MM-DD)
@override final  String date;
/// Timestamp for the day
@override final  int timestamp;
/// Traffic records grouped by rate
 final  List<TrafficRateGroup> _rateGroups;
/// Traffic records grouped by rate
@override List<TrafficRateGroup> get rateGroups {
  if (_rateGroups is EqualUnmodifiableListView) return _rateGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rateGroups);
}

/// Total upload bytes for the day
@override final  int totalU;
/// Total download bytes for the day
@override final  int totalD;
/// Total traffic for the day
@override final  int total;

/// Create a copy of AggregatedTraffic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AggregatedTrafficCopyWith<_AggregatedTraffic> get copyWith => __$AggregatedTrafficCopyWithImpl<_AggregatedTraffic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AggregatedTrafficToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AggregatedTraffic&&(identical(other.date, date) || other.date == date)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other._rateGroups, _rateGroups)&&(identical(other.totalU, totalU) || other.totalU == totalU)&&(identical(other.totalD, totalD) || other.totalD == totalD)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,timestamp,const DeepCollectionEquality().hash(_rateGroups),totalU,totalD,total);

@override
String toString() {
  return 'AggregatedTraffic(date: $date, timestamp: $timestamp, rateGroups: $rateGroups, totalU: $totalU, totalD: $totalD, total: $total)';
}


}

/// @nodoc
abstract mixin class _$AggregatedTrafficCopyWith<$Res> implements $AggregatedTrafficCopyWith<$Res> {
  factory _$AggregatedTrafficCopyWith(_AggregatedTraffic value, $Res Function(_AggregatedTraffic) _then) = __$AggregatedTrafficCopyWithImpl;
@override @useResult
$Res call({
 String date, int timestamp, List<TrafficRateGroup> rateGroups, int totalU, int totalD, int total
});




}
/// @nodoc
class __$AggregatedTrafficCopyWithImpl<$Res>
    implements _$AggregatedTrafficCopyWith<$Res> {
  __$AggregatedTrafficCopyWithImpl(this._self, this._then);

  final _AggregatedTraffic _self;
  final $Res Function(_AggregatedTraffic) _then;

/// Create a copy of AggregatedTraffic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? timestamp = null,Object? rateGroups = null,Object? totalU = null,Object? totalD = null,Object? total = null,}) {
  return _then(_AggregatedTraffic(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,rateGroups: null == rateGroups ? _self._rateGroups : rateGroups // ignore: cast_nullable_to_non_nullable
as List<TrafficRateGroup>,totalU: null == totalU ? _self.totalU : totalU // ignore: cast_nullable_to_non_nullable
as int,totalD: null == totalD ? _self.totalD : totalD // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TrafficRateGroup {

/// Upload bytes
 int get u;/// Download bytes
 int get d;/// Rate multiplier
 double get rate;
/// Create a copy of TrafficRateGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrafficRateGroupCopyWith<TrafficRateGroup> get copyWith => _$TrafficRateGroupCopyWithImpl<TrafficRateGroup>(this as TrafficRateGroup, _$identity);

  /// Serializes this TrafficRateGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrafficRateGroup&&(identical(other.u, u) || other.u == u)&&(identical(other.d, d) || other.d == d)&&(identical(other.rate, rate) || other.rate == rate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,u,d,rate);

@override
String toString() {
  return 'TrafficRateGroup(u: $u, d: $d, rate: $rate)';
}


}

/// @nodoc
abstract mixin class $TrafficRateGroupCopyWith<$Res>  {
  factory $TrafficRateGroupCopyWith(TrafficRateGroup value, $Res Function(TrafficRateGroup) _then) = _$TrafficRateGroupCopyWithImpl;
@useResult
$Res call({
 int u, int d, double rate
});




}
/// @nodoc
class _$TrafficRateGroupCopyWithImpl<$Res>
    implements $TrafficRateGroupCopyWith<$Res> {
  _$TrafficRateGroupCopyWithImpl(this._self, this._then);

  final TrafficRateGroup _self;
  final $Res Function(TrafficRateGroup) _then;

/// Create a copy of TrafficRateGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? u = null,Object? d = null,Object? rate = null,}) {
  return _then(_self.copyWith(
u: null == u ? _self.u : u // ignore: cast_nullable_to_non_nullable
as int,d: null == d ? _self.d : d // ignore: cast_nullable_to_non_nullable
as int,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TrafficRateGroup].
extension TrafficRateGroupPatterns on TrafficRateGroup {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrafficRateGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrafficRateGroup() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrafficRateGroup value)  $default,){
final _that = this;
switch (_that) {
case _TrafficRateGroup():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrafficRateGroup value)?  $default,){
final _that = this;
switch (_that) {
case _TrafficRateGroup() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int u,  int d,  double rate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrafficRateGroup() when $default != null:
return $default(_that.u,_that.d,_that.rate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int u,  int d,  double rate)  $default,) {final _that = this;
switch (_that) {
case _TrafficRateGroup():
return $default(_that.u,_that.d,_that.rate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int u,  int d,  double rate)?  $default,) {final _that = this;
switch (_that) {
case _TrafficRateGroup() when $default != null:
return $default(_that.u,_that.d,_that.rate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrafficRateGroup extends TrafficRateGroup {
  const _TrafficRateGroup({required this.u, required this.d, required this.rate}): super._();
  factory _TrafficRateGroup.fromJson(Map<String, dynamic> json) => _$TrafficRateGroupFromJson(json);

/// Upload bytes
@override final  int u;
/// Download bytes
@override final  int d;
/// Rate multiplier
@override final  double rate;

/// Create a copy of TrafficRateGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrafficRateGroupCopyWith<_TrafficRateGroup> get copyWith => __$TrafficRateGroupCopyWithImpl<_TrafficRateGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrafficRateGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrafficRateGroup&&(identical(other.u, u) || other.u == u)&&(identical(other.d, d) || other.d == d)&&(identical(other.rate, rate) || other.rate == rate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,u,d,rate);

@override
String toString() {
  return 'TrafficRateGroup(u: $u, d: $d, rate: $rate)';
}


}

/// @nodoc
abstract mixin class _$TrafficRateGroupCopyWith<$Res> implements $TrafficRateGroupCopyWith<$Res> {
  factory _$TrafficRateGroupCopyWith(_TrafficRateGroup value, $Res Function(_TrafficRateGroup) _then) = __$TrafficRateGroupCopyWithImpl;
@override @useResult
$Res call({
 int u, int d, double rate
});




}
/// @nodoc
class __$TrafficRateGroupCopyWithImpl<$Res>
    implements _$TrafficRateGroupCopyWith<$Res> {
  __$TrafficRateGroupCopyWithImpl(this._self, this._then);

  final _TrafficRateGroup _self;
  final $Res Function(_TrafficRateGroup) _then;

/// Create a copy of TrafficRateGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? u = null,Object? d = null,Object? rate = null,}) {
  return _then(_TrafficRateGroup(
u: null == u ? _self.u : u // ignore: cast_nullable_to_non_nullable
as int,d: null == d ? _self.d : d // ignore: cast_nullable_to_non_nullable
as int,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
