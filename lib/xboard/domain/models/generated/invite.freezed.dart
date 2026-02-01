// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../invite.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DomainInviteCode _$DomainInviteCodeFromJson(Map<String, dynamic> json) {
  return _DomainInviteCode.fromJson(json);
}

/// @nodoc
mixin _$DomainInviteCode {
  /// Invite code string
  String get code => throw _privateConstructorUsedError;

  /// Code status (0=inactive, 1=active)
  int get status => throw _privateConstructorUsedError;

  /// Commission rate for this code (0-100)
  double get commissionRate => throw _privateConstructorUsedError;

  /// Commission balance earned from this code (cents)
  int get commissionBalanceInCents => throw _privateConstructorUsedError;

  /// Number of registered users
  int get registeredUsers => throw _privateConstructorUsedError;

  /// Page views count
  int get pageViews => throw _privateConstructorUsedError;

  /// Creation timestamp
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Metadata
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this DomainInviteCode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DomainInviteCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DomainInviteCodeCopyWith<DomainInviteCode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DomainInviteCodeCopyWith<$Res> {
  factory $DomainInviteCodeCopyWith(
          DomainInviteCode value, $Res Function(DomainInviteCode) then) =
      _$DomainInviteCodeCopyWithImpl<$Res, DomainInviteCode>;
  @useResult
  $Res call(
      {String code,
      int status,
      double commissionRate,
      int commissionBalanceInCents,
      int registeredUsers,
      int pageViews,
      DateTime createdAt,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$DomainInviteCodeCopyWithImpl<$Res, $Val extends DomainInviteCode>
    implements $DomainInviteCodeCopyWith<$Res> {
  _$DomainInviteCodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DomainInviteCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? status = null,
    Object? commissionRate = null,
    Object? commissionBalanceInCents = null,
    Object? registeredUsers = null,
    Object? pageViews = null,
    Object? createdAt = null,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      commissionRate: null == commissionRate
          ? _value.commissionRate
          : commissionRate // ignore: cast_nullable_to_non_nullable
              as double,
      commissionBalanceInCents: null == commissionBalanceInCents
          ? _value.commissionBalanceInCents
          : commissionBalanceInCents // ignore: cast_nullable_to_non_nullable
              as int,
      registeredUsers: null == registeredUsers
          ? _value.registeredUsers
          : registeredUsers // ignore: cast_nullable_to_non_nullable
              as int,
      pageViews: null == pageViews
          ? _value.pageViews
          : pageViews // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DomainInviteCodeImplCopyWith<$Res>
    implements $DomainInviteCodeCopyWith<$Res> {
  factory _$$DomainInviteCodeImplCopyWith(_$DomainInviteCodeImpl value,
          $Res Function(_$DomainInviteCodeImpl) then) =
      __$$DomainInviteCodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code,
      int status,
      double commissionRate,
      int commissionBalanceInCents,
      int registeredUsers,
      int pageViews,
      DateTime createdAt,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$DomainInviteCodeImplCopyWithImpl<$Res>
    extends _$DomainInviteCodeCopyWithImpl<$Res, _$DomainInviteCodeImpl>
    implements _$$DomainInviteCodeImplCopyWith<$Res> {
  __$$DomainInviteCodeImplCopyWithImpl(_$DomainInviteCodeImpl _value,
      $Res Function(_$DomainInviteCodeImpl) _then)
      : super(_value, _then);

  /// Create a copy of DomainInviteCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? status = null,
    Object? commissionRate = null,
    Object? commissionBalanceInCents = null,
    Object? registeredUsers = null,
    Object? pageViews = null,
    Object? createdAt = null,
    Object? metadata = null,
  }) {
    return _then(_$DomainInviteCodeImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      commissionRate: null == commissionRate
          ? _value.commissionRate
          : commissionRate // ignore: cast_nullable_to_non_nullable
              as double,
      commissionBalanceInCents: null == commissionBalanceInCents
          ? _value.commissionBalanceInCents
          : commissionBalanceInCents // ignore: cast_nullable_to_non_nullable
              as int,
      registeredUsers: null == registeredUsers
          ? _value.registeredUsers
          : registeredUsers // ignore: cast_nullable_to_non_nullable
              as int,
      pageViews: null == pageViews
          ? _value.pageViews
          : pageViews // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DomainInviteCodeImpl extends _DomainInviteCode {
  const _$DomainInviteCodeImpl(
      {required this.code,
      this.status = 1,
      required this.commissionRate,
      this.commissionBalanceInCents = 0,
      this.registeredUsers = 0,
      this.pageViews = 0,
      required this.createdAt,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata,
        super._();

  factory _$DomainInviteCodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$DomainInviteCodeImplFromJson(json);

  /// Invite code string
  @override
  final String code;

  /// Code status (0=inactive, 1=active)
  @override
  @JsonKey()
  final int status;

  /// Commission rate for this code (0-100)
  @override
  final double commissionRate;

  /// Commission balance earned from this code (cents)
  @override
  @JsonKey()
  final int commissionBalanceInCents;

  /// Number of registered users
  @override
  @JsonKey()
  final int registeredUsers;

  /// Page views count
  @override
  @JsonKey()
  final int pageViews;

  /// Creation timestamp
  @override
  final DateTime createdAt;

  /// Metadata
  final Map<String, dynamic> _metadata;

  /// Metadata
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'DomainInviteCode(code: $code, status: $status, commissionRate: $commissionRate, commissionBalanceInCents: $commissionBalanceInCents, registeredUsers: $registeredUsers, pageViews: $pageViews, createdAt: $createdAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DomainInviteCodeImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.commissionRate, commissionRate) ||
                other.commissionRate == commissionRate) &&
            (identical(
                    other.commissionBalanceInCents, commissionBalanceInCents) ||
                other.commissionBalanceInCents == commissionBalanceInCents) &&
            (identical(other.registeredUsers, registeredUsers) ||
                other.registeredUsers == registeredUsers) &&
            (identical(other.pageViews, pageViews) ||
                other.pageViews == pageViews) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      code,
      status,
      commissionRate,
      commissionBalanceInCents,
      registeredUsers,
      pageViews,
      createdAt,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of DomainInviteCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DomainInviteCodeImplCopyWith<_$DomainInviteCodeImpl> get copyWith =>
      __$$DomainInviteCodeImplCopyWithImpl<_$DomainInviteCodeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DomainInviteCodeImplToJson(
      this,
    );
  }
}

abstract class _DomainInviteCode extends DomainInviteCode {
  const factory _DomainInviteCode(
      {required final String code,
      final int status,
      required final double commissionRate,
      final int commissionBalanceInCents,
      final int registeredUsers,
      final int pageViews,
      required final DateTime createdAt,
      final Map<String, dynamic> metadata}) = _$DomainInviteCodeImpl;
  const _DomainInviteCode._() : super._();

  factory _DomainInviteCode.fromJson(Map<String, dynamic> json) =
      _$DomainInviteCodeImpl.fromJson;

  /// Invite code string
  @override
  String get code;

  /// Code status (0=inactive, 1=active)
  @override
  int get status;

  /// Commission rate for this code (0-100)
  @override
  double get commissionRate;

  /// Commission balance earned from this code (cents)
  @override
  int get commissionBalanceInCents;

  /// Number of registered users
  @override
  int get registeredUsers;

  /// Page views count
  @override
  int get pageViews;

  /// Creation timestamp
  @override
  DateTime get createdAt;

  /// Metadata
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of DomainInviteCode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DomainInviteCodeImplCopyWith<_$DomainInviteCodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DomainInviteStats _$DomainInviteStatsFromJson(Map<String, dynamic> json) {
  return _DomainInviteStats.fromJson(json);
}

/// @nodoc
mixin _$DomainInviteStats {
  /// Total registered users via all invite codes
  int get registeredUsers => throw _privateConstructorUsedError;

  /// Settled commission in cents
  int get settledCommissionInCents => throw _privateConstructorUsedError;

  /// Pending commission in cents
  int get pendingCommissionInCents => throw _privateConstructorUsedError;

  /// System commission rate (0-100)
  double get commissionRate => throw _privateConstructorUsedError;

  /// Available commission for withdrawal in cents
  int get availableCommissionInCents => throw _privateConstructorUsedError;

  /// Serializes this DomainInviteStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DomainInviteStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DomainInviteStatsCopyWith<DomainInviteStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DomainInviteStatsCopyWith<$Res> {
  factory $DomainInviteStatsCopyWith(
          DomainInviteStats value, $Res Function(DomainInviteStats) then) =
      _$DomainInviteStatsCopyWithImpl<$Res, DomainInviteStats>;
  @useResult
  $Res call(
      {int registeredUsers,
      int settledCommissionInCents,
      int pendingCommissionInCents,
      double commissionRate,
      int availableCommissionInCents});
}

/// @nodoc
class _$DomainInviteStatsCopyWithImpl<$Res, $Val extends DomainInviteStats>
    implements $DomainInviteStatsCopyWith<$Res> {
  _$DomainInviteStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DomainInviteStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? registeredUsers = null,
    Object? settledCommissionInCents = null,
    Object? pendingCommissionInCents = null,
    Object? commissionRate = null,
    Object? availableCommissionInCents = null,
  }) {
    return _then(_value.copyWith(
      registeredUsers: null == registeredUsers
          ? _value.registeredUsers
          : registeredUsers // ignore: cast_nullable_to_non_nullable
              as int,
      settledCommissionInCents: null == settledCommissionInCents
          ? _value.settledCommissionInCents
          : settledCommissionInCents // ignore: cast_nullable_to_non_nullable
              as int,
      pendingCommissionInCents: null == pendingCommissionInCents
          ? _value.pendingCommissionInCents
          : pendingCommissionInCents // ignore: cast_nullable_to_non_nullable
              as int,
      commissionRate: null == commissionRate
          ? _value.commissionRate
          : commissionRate // ignore: cast_nullable_to_non_nullable
              as double,
      availableCommissionInCents: null == availableCommissionInCents
          ? _value.availableCommissionInCents
          : availableCommissionInCents // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DomainInviteStatsImplCopyWith<$Res>
    implements $DomainInviteStatsCopyWith<$Res> {
  factory _$$DomainInviteStatsImplCopyWith(_$DomainInviteStatsImpl value,
          $Res Function(_$DomainInviteStatsImpl) then) =
      __$$DomainInviteStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int registeredUsers,
      int settledCommissionInCents,
      int pendingCommissionInCents,
      double commissionRate,
      int availableCommissionInCents});
}

/// @nodoc
class __$$DomainInviteStatsImplCopyWithImpl<$Res>
    extends _$DomainInviteStatsCopyWithImpl<$Res, _$DomainInviteStatsImpl>
    implements _$$DomainInviteStatsImplCopyWith<$Res> {
  __$$DomainInviteStatsImplCopyWithImpl(_$DomainInviteStatsImpl _value,
      $Res Function(_$DomainInviteStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DomainInviteStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? registeredUsers = null,
    Object? settledCommissionInCents = null,
    Object? pendingCommissionInCents = null,
    Object? commissionRate = null,
    Object? availableCommissionInCents = null,
  }) {
    return _then(_$DomainInviteStatsImpl(
      registeredUsers: null == registeredUsers
          ? _value.registeredUsers
          : registeredUsers // ignore: cast_nullable_to_non_nullable
              as int,
      settledCommissionInCents: null == settledCommissionInCents
          ? _value.settledCommissionInCents
          : settledCommissionInCents // ignore: cast_nullable_to_non_nullable
              as int,
      pendingCommissionInCents: null == pendingCommissionInCents
          ? _value.pendingCommissionInCents
          : pendingCommissionInCents // ignore: cast_nullable_to_non_nullable
              as int,
      commissionRate: null == commissionRate
          ? _value.commissionRate
          : commissionRate // ignore: cast_nullable_to_non_nullable
              as double,
      availableCommissionInCents: null == availableCommissionInCents
          ? _value.availableCommissionInCents
          : availableCommissionInCents // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DomainInviteStatsImpl extends _DomainInviteStats {
  const _$DomainInviteStatsImpl(
      {this.registeredUsers = 0,
      this.settledCommissionInCents = 0,
      this.pendingCommissionInCents = 0,
      this.commissionRate = 0,
      this.availableCommissionInCents = 0})
      : super._();

  factory _$DomainInviteStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DomainInviteStatsImplFromJson(json);

  /// Total registered users via all invite codes
  @override
  @JsonKey()
  final int registeredUsers;

  /// Settled commission in cents
  @override
  @JsonKey()
  final int settledCommissionInCents;

  /// Pending commission in cents
  @override
  @JsonKey()
  final int pendingCommissionInCents;

  /// System commission rate (0-100)
  @override
  @JsonKey()
  final double commissionRate;

  /// Available commission for withdrawal in cents
  @override
  @JsonKey()
  final int availableCommissionInCents;

  @override
  String toString() {
    return 'DomainInviteStats(registeredUsers: $registeredUsers, settledCommissionInCents: $settledCommissionInCents, pendingCommissionInCents: $pendingCommissionInCents, commissionRate: $commissionRate, availableCommissionInCents: $availableCommissionInCents)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DomainInviteStatsImpl &&
            (identical(other.registeredUsers, registeredUsers) ||
                other.registeredUsers == registeredUsers) &&
            (identical(
                    other.settledCommissionInCents, settledCommissionInCents) ||
                other.settledCommissionInCents == settledCommissionInCents) &&
            (identical(
                    other.pendingCommissionInCents, pendingCommissionInCents) ||
                other.pendingCommissionInCents == pendingCommissionInCents) &&
            (identical(other.commissionRate, commissionRate) ||
                other.commissionRate == commissionRate) &&
            (identical(other.availableCommissionInCents,
                    availableCommissionInCents) ||
                other.availableCommissionInCents ==
                    availableCommissionInCents));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      registeredUsers,
      settledCommissionInCents,
      pendingCommissionInCents,
      commissionRate,
      availableCommissionInCents);

  /// Create a copy of DomainInviteStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DomainInviteStatsImplCopyWith<_$DomainInviteStatsImpl> get copyWith =>
      __$$DomainInviteStatsImplCopyWithImpl<_$DomainInviteStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DomainInviteStatsImplToJson(
      this,
    );
  }
}

abstract class _DomainInviteStats extends DomainInviteStats {
  const factory _DomainInviteStats(
      {final int registeredUsers,
      final int settledCommissionInCents,
      final int pendingCommissionInCents,
      final double commissionRate,
      final int availableCommissionInCents}) = _$DomainInviteStatsImpl;
  const _DomainInviteStats._() : super._();

  factory _DomainInviteStats.fromJson(Map<String, dynamic> json) =
      _$DomainInviteStatsImpl.fromJson;

  /// Total registered users via all invite codes
  @override
  int get registeredUsers;

  /// Settled commission in cents
  @override
  int get settledCommissionInCents;

  /// Pending commission in cents
  @override
  int get pendingCommissionInCents;

  /// System commission rate (0-100)
  @override
  double get commissionRate;

  /// Available commission for withdrawal in cents
  @override
  int get availableCommissionInCents;

  /// Create a copy of DomainInviteStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DomainInviteStatsImplCopyWith<_$DomainInviteStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
