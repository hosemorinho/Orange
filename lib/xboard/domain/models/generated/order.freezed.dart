// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DomainOrder _$DomainOrderFromJson(Map<String, dynamic> json) {
  return _DomainOrder.fromJson(json);
}

/// @nodoc
mixin _$DomainOrder {
  /// 订单号（交易号）
  String get tradeNo => throw _privateConstructorUsedError;

  /// 套餐 ID
  int get planId => throw _privateConstructorUsedError;

  /// 周期类型
  String get period => throw _privateConstructorUsedError;

  /// 订单金额（元）
  double get totalAmount => throw _privateConstructorUsedError;

  /// 订单状态
  OrderStatus get status => throw _privateConstructorUsedError;

  /// 套餐名称（可选）
  String? get planName => throw _privateConstructorUsedError;

  /// 套餐内容（HTML，可选）
  String? get planContent => throw _privateConstructorUsedError;

  /// 创建时间
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// 支付时间
  DateTime? get paidAt => throw _privateConstructorUsedError;

  /// 手续费（元）
  double get handlingAmount => throw _privateConstructorUsedError;

  /// 余额支付金额（元）
  double get balanceAmount => throw _privateConstructorUsedError;

  /// 退款金额（元）
  double get refundAmount => throw _privateConstructorUsedError;

  /// 折扣金额（元）
  double get discountAmount => throw _privateConstructorUsedError;

  /// 剩余金额（元）
  double get surplusAmount => throw _privateConstructorUsedError;

  /// 支付方式 ID
  int? get paymentId => throw _privateConstructorUsedError;

  /// 支付方式名称
  String? get paymentName => throw _privateConstructorUsedError;

  /// 优惠券 ID
  int? get couponId => throw _privateConstructorUsedError;

  /// 佣金状态
  OrderCommissionStatus? get commissionStatus =>
      throw _privateConstructorUsedError;

  /// 佣金余额（元）
  double get commissionBalance => throw _privateConstructorUsedError;

  /// 元数据
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this DomainOrder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DomainOrder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DomainOrderCopyWith<DomainOrder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DomainOrderCopyWith<$Res> {
  factory $DomainOrderCopyWith(
          DomainOrder value, $Res Function(DomainOrder) then) =
      _$DomainOrderCopyWithImpl<$Res, DomainOrder>;
  @useResult
  $Res call(
      {String tradeNo,
      int planId,
      String period,
      double totalAmount,
      OrderStatus status,
      String? planName,
      String? planContent,
      DateTime createdAt,
      DateTime? paidAt,
      double handlingAmount,
      double balanceAmount,
      double refundAmount,
      double discountAmount,
      double surplusAmount,
      int? paymentId,
      String? paymentName,
      int? couponId,
      OrderCommissionStatus? commissionStatus,
      double commissionBalance,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$DomainOrderCopyWithImpl<$Res, $Val extends DomainOrder>
    implements $DomainOrderCopyWith<$Res> {
  _$DomainOrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DomainOrder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tradeNo = null,
    Object? planId = null,
    Object? period = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? planName = freezed,
    Object? planContent = freezed,
    Object? createdAt = null,
    Object? paidAt = freezed,
    Object? handlingAmount = null,
    Object? balanceAmount = null,
    Object? refundAmount = null,
    Object? discountAmount = null,
    Object? surplusAmount = null,
    Object? paymentId = freezed,
    Object? paymentName = freezed,
    Object? couponId = freezed,
    Object? commissionStatus = freezed,
    Object? commissionBalance = null,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      tradeNo: null == tradeNo
          ? _value.tradeNo
          : tradeNo // ignore: cast_nullable_to_non_nullable
              as String,
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as int,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      planName: freezed == planName
          ? _value.planName
          : planName // ignore: cast_nullable_to_non_nullable
              as String?,
      planContent: freezed == planContent
          ? _value.planContent
          : planContent // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      paidAt: freezed == paidAt
          ? _value.paidAt
          : paidAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      handlingAmount: null == handlingAmount
          ? _value.handlingAmount
          : handlingAmount // ignore: cast_nullable_to_non_nullable
              as double,
      balanceAmount: null == balanceAmount
          ? _value.balanceAmount
          : balanceAmount // ignore: cast_nullable_to_non_nullable
              as double,
      refundAmount: null == refundAmount
          ? _value.refundAmount
          : refundAmount // ignore: cast_nullable_to_non_nullable
              as double,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      surplusAmount: null == surplusAmount
          ? _value.surplusAmount
          : surplusAmount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentId: freezed == paymentId
          ? _value.paymentId
          : paymentId // ignore: cast_nullable_to_non_nullable
              as int?,
      paymentName: freezed == paymentName
          ? _value.paymentName
          : paymentName // ignore: cast_nullable_to_non_nullable
              as String?,
      couponId: freezed == couponId
          ? _value.couponId
          : couponId // ignore: cast_nullable_to_non_nullable
              as int?,
      commissionStatus: freezed == commissionStatus
          ? _value.commissionStatus
          : commissionStatus // ignore: cast_nullable_to_non_nullable
              as OrderCommissionStatus?,
      commissionBalance: null == commissionBalance
          ? _value.commissionBalance
          : commissionBalance // ignore: cast_nullable_to_non_nullable
              as double,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DomainOrderImplCopyWith<$Res>
    implements $DomainOrderCopyWith<$Res> {
  factory _$$DomainOrderImplCopyWith(
          _$DomainOrderImpl value, $Res Function(_$DomainOrderImpl) then) =
      __$$DomainOrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String tradeNo,
      int planId,
      String period,
      double totalAmount,
      OrderStatus status,
      String? planName,
      String? planContent,
      DateTime createdAt,
      DateTime? paidAt,
      double handlingAmount,
      double balanceAmount,
      double refundAmount,
      double discountAmount,
      double surplusAmount,
      int? paymentId,
      String? paymentName,
      int? couponId,
      OrderCommissionStatus? commissionStatus,
      double commissionBalance,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$DomainOrderImplCopyWithImpl<$Res>
    extends _$DomainOrderCopyWithImpl<$Res, _$DomainOrderImpl>
    implements _$$DomainOrderImplCopyWith<$Res> {
  __$$DomainOrderImplCopyWithImpl(
      _$DomainOrderImpl _value, $Res Function(_$DomainOrderImpl) _then)
      : super(_value, _then);

  /// Create a copy of DomainOrder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tradeNo = null,
    Object? planId = null,
    Object? period = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? planName = freezed,
    Object? planContent = freezed,
    Object? createdAt = null,
    Object? paidAt = freezed,
    Object? handlingAmount = null,
    Object? balanceAmount = null,
    Object? refundAmount = null,
    Object? discountAmount = null,
    Object? surplusAmount = null,
    Object? paymentId = freezed,
    Object? paymentName = freezed,
    Object? couponId = freezed,
    Object? commissionStatus = freezed,
    Object? commissionBalance = null,
    Object? metadata = null,
  }) {
    return _then(_$DomainOrderImpl(
      tradeNo: null == tradeNo
          ? _value.tradeNo
          : tradeNo // ignore: cast_nullable_to_non_nullable
              as String,
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as int,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      planName: freezed == planName
          ? _value.planName
          : planName // ignore: cast_nullable_to_non_nullable
              as String?,
      planContent: freezed == planContent
          ? _value.planContent
          : planContent // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      paidAt: freezed == paidAt
          ? _value.paidAt
          : paidAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      handlingAmount: null == handlingAmount
          ? _value.handlingAmount
          : handlingAmount // ignore: cast_nullable_to_non_nullable
              as double,
      balanceAmount: null == balanceAmount
          ? _value.balanceAmount
          : balanceAmount // ignore: cast_nullable_to_non_nullable
              as double,
      refundAmount: null == refundAmount
          ? _value.refundAmount
          : refundAmount // ignore: cast_nullable_to_non_nullable
              as double,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      surplusAmount: null == surplusAmount
          ? _value.surplusAmount
          : surplusAmount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentId: freezed == paymentId
          ? _value.paymentId
          : paymentId // ignore: cast_nullable_to_non_nullable
              as int?,
      paymentName: freezed == paymentName
          ? _value.paymentName
          : paymentName // ignore: cast_nullable_to_non_nullable
              as String?,
      couponId: freezed == couponId
          ? _value.couponId
          : couponId // ignore: cast_nullable_to_non_nullable
              as int?,
      commissionStatus: freezed == commissionStatus
          ? _value.commissionStatus
          : commissionStatus // ignore: cast_nullable_to_non_nullable
              as OrderCommissionStatus?,
      commissionBalance: null == commissionBalance
          ? _value.commissionBalance
          : commissionBalance // ignore: cast_nullable_to_non_nullable
              as double,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DomainOrderImpl extends _DomainOrder {
  const _$DomainOrderImpl(
      {required this.tradeNo,
      required this.planId,
      required this.period,
      required this.totalAmount,
      required this.status,
      this.planName,
      this.planContent,
      required this.createdAt,
      this.paidAt,
      this.handlingAmount = 0,
      this.balanceAmount = 0,
      this.refundAmount = 0,
      this.discountAmount = 0,
      this.surplusAmount = 0,
      this.paymentId,
      this.paymentName,
      this.couponId,
      this.commissionStatus,
      this.commissionBalance = 0,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata,
        super._();

  factory _$DomainOrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$DomainOrderImplFromJson(json);

  /// 订单号（交易号）
  @override
  final String tradeNo;

  /// 套餐 ID
  @override
  final int planId;

  /// 周期类型
  @override
  final String period;

  /// 订单金额（元）
  @override
  final double totalAmount;

  /// 订单状态
  @override
  final OrderStatus status;

  /// 套餐名称（可选）
  @override
  final String? planName;

  /// 套餐内容（HTML，可选）
  @override
  final String? planContent;

  /// 创建时间
  @override
  final DateTime createdAt;

  /// 支付时间
  @override
  final DateTime? paidAt;

  /// 手续费（元）
  @override
  @JsonKey()
  final double handlingAmount;

  /// 余额支付金额（元）
  @override
  @JsonKey()
  final double balanceAmount;

  /// 退款金额（元）
  @override
  @JsonKey()
  final double refundAmount;

  /// 折扣金额（元）
  @override
  @JsonKey()
  final double discountAmount;

  /// 剩余金额（元）
  @override
  @JsonKey()
  final double surplusAmount;

  /// 支付方式 ID
  @override
  final int? paymentId;

  /// 支付方式名称
  @override
  final String? paymentName;

  /// 优惠券 ID
  @override
  final int? couponId;

  /// 佣金状态
  @override
  final OrderCommissionStatus? commissionStatus;

  /// 佣金余额（元）
  @override
  @JsonKey()
  final double commissionBalance;

  /// 元数据
  final Map<String, dynamic> _metadata;

  /// 元数据
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'DomainOrder(tradeNo: $tradeNo, planId: $planId, period: $period, totalAmount: $totalAmount, status: $status, planName: $planName, planContent: $planContent, createdAt: $createdAt, paidAt: $paidAt, handlingAmount: $handlingAmount, balanceAmount: $balanceAmount, refundAmount: $refundAmount, discountAmount: $discountAmount, surplusAmount: $surplusAmount, paymentId: $paymentId, paymentName: $paymentName, couponId: $couponId, commissionStatus: $commissionStatus, commissionBalance: $commissionBalance, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DomainOrderImpl &&
            (identical(other.tradeNo, tradeNo) || other.tradeNo == tradeNo) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.planName, planName) ||
                other.planName == planName) &&
            (identical(other.planContent, planContent) ||
                other.planContent == planContent) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt) &&
            (identical(other.handlingAmount, handlingAmount) ||
                other.handlingAmount == handlingAmount) &&
            (identical(other.balanceAmount, balanceAmount) ||
                other.balanceAmount == balanceAmount) &&
            (identical(other.refundAmount, refundAmount) ||
                other.refundAmount == refundAmount) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.surplusAmount, surplusAmount) ||
                other.surplusAmount == surplusAmount) &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.paymentName, paymentName) ||
                other.paymentName == paymentName) &&
            (identical(other.couponId, couponId) ||
                other.couponId == couponId) &&
            (identical(other.commissionStatus, commissionStatus) ||
                other.commissionStatus == commissionStatus) &&
            (identical(other.commissionBalance, commissionBalance) ||
                other.commissionBalance == commissionBalance) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        tradeNo,
        planId,
        period,
        totalAmount,
        status,
        planName,
        planContent,
        createdAt,
        paidAt,
        handlingAmount,
        balanceAmount,
        refundAmount,
        discountAmount,
        surplusAmount,
        paymentId,
        paymentName,
        couponId,
        commissionStatus,
        commissionBalance,
        const DeepCollectionEquality().hash(_metadata)
      ]);

  /// Create a copy of DomainOrder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DomainOrderImplCopyWith<_$DomainOrderImpl> get copyWith =>
      __$$DomainOrderImplCopyWithImpl<_$DomainOrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DomainOrderImplToJson(
      this,
    );
  }
}

abstract class _DomainOrder extends DomainOrder {
  const factory _DomainOrder(
      {required final String tradeNo,
      required final int planId,
      required final String period,
      required final double totalAmount,
      required final OrderStatus status,
      final String? planName,
      final String? planContent,
      required final DateTime createdAt,
      final DateTime? paidAt,
      final double handlingAmount,
      final double balanceAmount,
      final double refundAmount,
      final double discountAmount,
      final double surplusAmount,
      final int? paymentId,
      final String? paymentName,
      final int? couponId,
      final OrderCommissionStatus? commissionStatus,
      final double commissionBalance,
      final Map<String, dynamic> metadata}) = _$DomainOrderImpl;
  const _DomainOrder._() : super._();

  factory _DomainOrder.fromJson(Map<String, dynamic> json) =
      _$DomainOrderImpl.fromJson;

  /// 订单号（交易号）
  @override
  String get tradeNo;

  /// 套餐 ID
  @override
  int get planId;

  /// 周期类型
  @override
  String get period;

  /// 订单金额（元）
  @override
  double get totalAmount;

  /// 订单状态
  @override
  OrderStatus get status;

  /// 套餐名称（可选）
  @override
  String? get planName;

  /// 套餐内容（HTML，可选）
  @override
  String? get planContent;

  /// 创建时间
  @override
  DateTime get createdAt;

  /// 支付时间
  @override
  DateTime? get paidAt;

  /// 手续费（元）
  @override
  double get handlingAmount;

  /// 余额支付金额（元）
  @override
  double get balanceAmount;

  /// 退款金额（元）
  @override
  double get refundAmount;

  /// 折扣金额（元）
  @override
  double get discountAmount;

  /// 剩余金额（元）
  @override
  double get surplusAmount;

  /// 支付方式 ID
  @override
  int? get paymentId;

  /// 支付方式名称
  @override
  String? get paymentName;

  /// 优惠券 ID
  @override
  int? get couponId;

  /// 佣金状态
  @override
  OrderCommissionStatus? get commissionStatus;

  /// 佣金余额（元）
  @override
  double get commissionBalance;

  /// 元数据
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of DomainOrder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DomainOrderImplCopyWith<_$DomainOrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
