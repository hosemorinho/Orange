// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../invite.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainInviteCode {

/// Invite code string
 String get code;/// Code status (0=inactive, 1=active)
 int get status;/// Commission rate for this code (0-100)
 double get commissionRate;/// Commission balance earned from this code (cents)
 int get commissionBalanceInCents;/// Number of registered users
 int get registeredUsers;/// Page views count
 int get pageViews;/// Creation timestamp
 DateTime get createdAt;/// Metadata
 Map<String, dynamic> get metadata;
/// Create a copy of DomainInviteCode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainInviteCodeCopyWith<DomainInviteCode> get copyWith => _$DomainInviteCodeCopyWithImpl<DomainInviteCode>(this as DomainInviteCode, _$identity);

  /// Serializes this DomainInviteCode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainInviteCode&&(identical(other.code, code) || other.code == code)&&(identical(other.status, status) || other.status == status)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.commissionBalanceInCents, commissionBalanceInCents) || other.commissionBalanceInCents == commissionBalanceInCents)&&(identical(other.registeredUsers, registeredUsers) || other.registeredUsers == registeredUsers)&&(identical(other.pageViews, pageViews) || other.pageViews == pageViews)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,status,commissionRate,commissionBalanceInCents,registeredUsers,pageViews,createdAt,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'DomainInviteCode(code: $code, status: $status, commissionRate: $commissionRate, commissionBalanceInCents: $commissionBalanceInCents, registeredUsers: $registeredUsers, pageViews: $pageViews, createdAt: $createdAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DomainInviteCodeCopyWith<$Res>  {
  factory $DomainInviteCodeCopyWith(DomainInviteCode value, $Res Function(DomainInviteCode) _then) = _$DomainInviteCodeCopyWithImpl;
@useResult
$Res call({
 String code, int status, double commissionRate, int commissionBalanceInCents, int registeredUsers, int pageViews, DateTime createdAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$DomainInviteCodeCopyWithImpl<$Res>
    implements $DomainInviteCodeCopyWith<$Res> {
  _$DomainInviteCodeCopyWithImpl(this._self, this._then);

  final DomainInviteCode _self;
  final $Res Function(DomainInviteCode) _then;

/// Create a copy of DomainInviteCode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? status = null,Object? commissionRate = null,Object? commissionBalanceInCents = null,Object? registeredUsers = null,Object? pageViews = null,Object? createdAt = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,commissionBalanceInCents: null == commissionBalanceInCents ? _self.commissionBalanceInCents : commissionBalanceInCents // ignore: cast_nullable_to_non_nullable
as int,registeredUsers: null == registeredUsers ? _self.registeredUsers : registeredUsers // ignore: cast_nullable_to_non_nullable
as int,pageViews: null == pageViews ? _self.pageViews : pageViews // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainInviteCode].
extension DomainInviteCodePatterns on DomainInviteCode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainInviteCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainInviteCode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainInviteCode value)  $default,){
final _that = this;
switch (_that) {
case _DomainInviteCode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainInviteCode value)?  $default,){
final _that = this;
switch (_that) {
case _DomainInviteCode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  int status,  double commissionRate,  int commissionBalanceInCents,  int registeredUsers,  int pageViews,  DateTime createdAt,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainInviteCode() when $default != null:
return $default(_that.code,_that.status,_that.commissionRate,_that.commissionBalanceInCents,_that.registeredUsers,_that.pageViews,_that.createdAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  int status,  double commissionRate,  int commissionBalanceInCents,  int registeredUsers,  int pageViews,  DateTime createdAt,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _DomainInviteCode():
return $default(_that.code,_that.status,_that.commissionRate,_that.commissionBalanceInCents,_that.registeredUsers,_that.pageViews,_that.createdAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  int status,  double commissionRate,  int commissionBalanceInCents,  int registeredUsers,  int pageViews,  DateTime createdAt,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _DomainInviteCode() when $default != null:
return $default(_that.code,_that.status,_that.commissionRate,_that.commissionBalanceInCents,_that.registeredUsers,_that.pageViews,_that.createdAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainInviteCode extends DomainInviteCode {
  const _DomainInviteCode({required this.code, this.status = 1, required this.commissionRate, this.commissionBalanceInCents = 0, this.registeredUsers = 0, this.pageViews = 0, required this.createdAt, final  Map<String, dynamic> metadata = const {}}): _metadata = metadata,super._();
  factory _DomainInviteCode.fromJson(Map<String, dynamic> json) => _$DomainInviteCodeFromJson(json);

/// Invite code string
@override final  String code;
/// Code status (0=inactive, 1=active)
@override@JsonKey() final  int status;
/// Commission rate for this code (0-100)
@override final  double commissionRate;
/// Commission balance earned from this code (cents)
@override@JsonKey() final  int commissionBalanceInCents;
/// Number of registered users
@override@JsonKey() final  int registeredUsers;
/// Page views count
@override@JsonKey() final  int pageViews;
/// Creation timestamp
@override final  DateTime createdAt;
/// Metadata
 final  Map<String, dynamic> _metadata;
/// Metadata
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of DomainInviteCode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainInviteCodeCopyWith<_DomainInviteCode> get copyWith => __$DomainInviteCodeCopyWithImpl<_DomainInviteCode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainInviteCodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainInviteCode&&(identical(other.code, code) || other.code == code)&&(identical(other.status, status) || other.status == status)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.commissionBalanceInCents, commissionBalanceInCents) || other.commissionBalanceInCents == commissionBalanceInCents)&&(identical(other.registeredUsers, registeredUsers) || other.registeredUsers == registeredUsers)&&(identical(other.pageViews, pageViews) || other.pageViews == pageViews)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,status,commissionRate,commissionBalanceInCents,registeredUsers,pageViews,createdAt,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'DomainInviteCode(code: $code, status: $status, commissionRate: $commissionRate, commissionBalanceInCents: $commissionBalanceInCents, registeredUsers: $registeredUsers, pageViews: $pageViews, createdAt: $createdAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DomainInviteCodeCopyWith<$Res> implements $DomainInviteCodeCopyWith<$Res> {
  factory _$DomainInviteCodeCopyWith(_DomainInviteCode value, $Res Function(_DomainInviteCode) _then) = __$DomainInviteCodeCopyWithImpl;
@override @useResult
$Res call({
 String code, int status, double commissionRate, int commissionBalanceInCents, int registeredUsers, int pageViews, DateTime createdAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$DomainInviteCodeCopyWithImpl<$Res>
    implements _$DomainInviteCodeCopyWith<$Res> {
  __$DomainInviteCodeCopyWithImpl(this._self, this._then);

  final _DomainInviteCode _self;
  final $Res Function(_DomainInviteCode) _then;

/// Create a copy of DomainInviteCode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? status = null,Object? commissionRate = null,Object? commissionBalanceInCents = null,Object? registeredUsers = null,Object? pageViews = null,Object? createdAt = null,Object? metadata = null,}) {
  return _then(_DomainInviteCode(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,commissionBalanceInCents: null == commissionBalanceInCents ? _self.commissionBalanceInCents : commissionBalanceInCents // ignore: cast_nullable_to_non_nullable
as int,registeredUsers: null == registeredUsers ? _self.registeredUsers : registeredUsers // ignore: cast_nullable_to_non_nullable
as int,pageViews: null == pageViews ? _self.pageViews : pageViews // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$DomainInviteStats {

/// Total registered users via all invite codes
 int get registeredUsers;/// Settled commission in cents
 int get settledCommissionInCents;/// Pending commission in cents
 int get pendingCommissionInCents;/// System commission rate (0-100)
 double get commissionRate;/// Available commission for withdrawal in cents
 int get availableCommissionInCents;
/// Create a copy of DomainInviteStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainInviteStatsCopyWith<DomainInviteStats> get copyWith => _$DomainInviteStatsCopyWithImpl<DomainInviteStats>(this as DomainInviteStats, _$identity);

  /// Serializes this DomainInviteStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainInviteStats&&(identical(other.registeredUsers, registeredUsers) || other.registeredUsers == registeredUsers)&&(identical(other.settledCommissionInCents, settledCommissionInCents) || other.settledCommissionInCents == settledCommissionInCents)&&(identical(other.pendingCommissionInCents, pendingCommissionInCents) || other.pendingCommissionInCents == pendingCommissionInCents)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.availableCommissionInCents, availableCommissionInCents) || other.availableCommissionInCents == availableCommissionInCents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,registeredUsers,settledCommissionInCents,pendingCommissionInCents,commissionRate,availableCommissionInCents);

@override
String toString() {
  return 'DomainInviteStats(registeredUsers: $registeredUsers, settledCommissionInCents: $settledCommissionInCents, pendingCommissionInCents: $pendingCommissionInCents, commissionRate: $commissionRate, availableCommissionInCents: $availableCommissionInCents)';
}


}

/// @nodoc
abstract mixin class $DomainInviteStatsCopyWith<$Res>  {
  factory $DomainInviteStatsCopyWith(DomainInviteStats value, $Res Function(DomainInviteStats) _then) = _$DomainInviteStatsCopyWithImpl;
@useResult
$Res call({
 int registeredUsers, int settledCommissionInCents, int pendingCommissionInCents, double commissionRate, int availableCommissionInCents
});




}
/// @nodoc
class _$DomainInviteStatsCopyWithImpl<$Res>
    implements $DomainInviteStatsCopyWith<$Res> {
  _$DomainInviteStatsCopyWithImpl(this._self, this._then);

  final DomainInviteStats _self;
  final $Res Function(DomainInviteStats) _then;

/// Create a copy of DomainInviteStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? registeredUsers = null,Object? settledCommissionInCents = null,Object? pendingCommissionInCents = null,Object? commissionRate = null,Object? availableCommissionInCents = null,}) {
  return _then(_self.copyWith(
registeredUsers: null == registeredUsers ? _self.registeredUsers : registeredUsers // ignore: cast_nullable_to_non_nullable
as int,settledCommissionInCents: null == settledCommissionInCents ? _self.settledCommissionInCents : settledCommissionInCents // ignore: cast_nullable_to_non_nullable
as int,pendingCommissionInCents: null == pendingCommissionInCents ? _self.pendingCommissionInCents : pendingCommissionInCents // ignore: cast_nullable_to_non_nullable
as int,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,availableCommissionInCents: null == availableCommissionInCents ? _self.availableCommissionInCents : availableCommissionInCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainInviteStats].
extension DomainInviteStatsPatterns on DomainInviteStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainInviteStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainInviteStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainInviteStats value)  $default,){
final _that = this;
switch (_that) {
case _DomainInviteStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainInviteStats value)?  $default,){
final _that = this;
switch (_that) {
case _DomainInviteStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int registeredUsers,  int settledCommissionInCents,  int pendingCommissionInCents,  double commissionRate,  int availableCommissionInCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainInviteStats() when $default != null:
return $default(_that.registeredUsers,_that.settledCommissionInCents,_that.pendingCommissionInCents,_that.commissionRate,_that.availableCommissionInCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int registeredUsers,  int settledCommissionInCents,  int pendingCommissionInCents,  double commissionRate,  int availableCommissionInCents)  $default,) {final _that = this;
switch (_that) {
case _DomainInviteStats():
return $default(_that.registeredUsers,_that.settledCommissionInCents,_that.pendingCommissionInCents,_that.commissionRate,_that.availableCommissionInCents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int registeredUsers,  int settledCommissionInCents,  int pendingCommissionInCents,  double commissionRate,  int availableCommissionInCents)?  $default,) {final _that = this;
switch (_that) {
case _DomainInviteStats() when $default != null:
return $default(_that.registeredUsers,_that.settledCommissionInCents,_that.pendingCommissionInCents,_that.commissionRate,_that.availableCommissionInCents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainInviteStats extends DomainInviteStats {
  const _DomainInviteStats({this.registeredUsers = 0, this.settledCommissionInCents = 0, this.pendingCommissionInCents = 0, this.commissionRate = 0, this.availableCommissionInCents = 0}): super._();
  factory _DomainInviteStats.fromJson(Map<String, dynamic> json) => _$DomainInviteStatsFromJson(json);

/// Total registered users via all invite codes
@override@JsonKey() final  int registeredUsers;
/// Settled commission in cents
@override@JsonKey() final  int settledCommissionInCents;
/// Pending commission in cents
@override@JsonKey() final  int pendingCommissionInCents;
/// System commission rate (0-100)
@override@JsonKey() final  double commissionRate;
/// Available commission for withdrawal in cents
@override@JsonKey() final  int availableCommissionInCents;

/// Create a copy of DomainInviteStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainInviteStatsCopyWith<_DomainInviteStats> get copyWith => __$DomainInviteStatsCopyWithImpl<_DomainInviteStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainInviteStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainInviteStats&&(identical(other.registeredUsers, registeredUsers) || other.registeredUsers == registeredUsers)&&(identical(other.settledCommissionInCents, settledCommissionInCents) || other.settledCommissionInCents == settledCommissionInCents)&&(identical(other.pendingCommissionInCents, pendingCommissionInCents) || other.pendingCommissionInCents == pendingCommissionInCents)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.availableCommissionInCents, availableCommissionInCents) || other.availableCommissionInCents == availableCommissionInCents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,registeredUsers,settledCommissionInCents,pendingCommissionInCents,commissionRate,availableCommissionInCents);

@override
String toString() {
  return 'DomainInviteStats(registeredUsers: $registeredUsers, settledCommissionInCents: $settledCommissionInCents, pendingCommissionInCents: $pendingCommissionInCents, commissionRate: $commissionRate, availableCommissionInCents: $availableCommissionInCents)';
}


}

/// @nodoc
abstract mixin class _$DomainInviteStatsCopyWith<$Res> implements $DomainInviteStatsCopyWith<$Res> {
  factory _$DomainInviteStatsCopyWith(_DomainInviteStats value, $Res Function(_DomainInviteStats) _then) = __$DomainInviteStatsCopyWithImpl;
@override @useResult
$Res call({
 int registeredUsers, int settledCommissionInCents, int pendingCommissionInCents, double commissionRate, int availableCommissionInCents
});




}
/// @nodoc
class __$DomainInviteStatsCopyWithImpl<$Res>
    implements _$DomainInviteStatsCopyWith<$Res> {
  __$DomainInviteStatsCopyWithImpl(this._self, this._then);

  final _DomainInviteStats _self;
  final $Res Function(_DomainInviteStats) _then;

/// Create a copy of DomainInviteStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? registeredUsers = null,Object? settledCommissionInCents = null,Object? pendingCommissionInCents = null,Object? commissionRate = null,Object? availableCommissionInCents = null,}) {
  return _then(_DomainInviteStats(
registeredUsers: null == registeredUsers ? _self.registeredUsers : registeredUsers // ignore: cast_nullable_to_non_nullable
as int,settledCommissionInCents: null == settledCommissionInCents ? _self.settledCommissionInCents : settledCommissionInCents // ignore: cast_nullable_to_non_nullable
as int,pendingCommissionInCents: null == pendingCommissionInCents ? _self.pendingCommissionInCents : pendingCommissionInCents // ignore: cast_nullable_to_non_nullable
as int,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,availableCommissionInCents: null == availableCommissionInCents ? _self.availableCommissionInCents : availableCommissionInCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
