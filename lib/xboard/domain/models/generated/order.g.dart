// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DomainOrderImpl _$$DomainOrderImplFromJson(Map<String, dynamic> json) =>
    _$DomainOrderImpl(
      tradeNo: json['tradeNo'] as String,
      planId: (json['planId'] as num).toInt(),
      period: json['period'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      planName: json['planName'] as String?,
      planContent: json['planContent'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      handlingAmount: (json['handlingAmount'] as num?)?.toDouble() ?? 0,
      balanceAmount: (json['balanceAmount'] as num?)?.toDouble() ?? 0,
      refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      surplusAmount: (json['surplusAmount'] as num?)?.toDouble() ?? 0,
      paymentId: (json['paymentId'] as num?)?.toInt(),
      paymentName: json['paymentName'] as String?,
      couponId: (json['couponId'] as num?)?.toInt(),
      commissionStatus: $enumDecodeNullable(
          _$OrderCommissionStatusEnumMap, json['commissionStatus']),
      commissionBalance: (json['commissionBalance'] as num?)?.toDouble() ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$DomainOrderImplToJson(_$DomainOrderImpl instance) =>
    <String, dynamic>{
      'tradeNo': instance.tradeNo,
      'planId': instance.planId,
      'period': instance.period,
      'totalAmount': instance.totalAmount,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'planName': instance.planName,
      'planContent': instance.planContent,
      'createdAt': instance.createdAt.toIso8601String(),
      'paidAt': instance.paidAt?.toIso8601String(),
      'handlingAmount': instance.handlingAmount,
      'balanceAmount': instance.balanceAmount,
      'refundAmount': instance.refundAmount,
      'discountAmount': instance.discountAmount,
      'surplusAmount': instance.surplusAmount,
      'paymentId': instance.paymentId,
      'paymentName': instance.paymentName,
      'couponId': instance.couponId,
      'commissionStatus':
          _$OrderCommissionStatusEnumMap[instance.commissionStatus],
      'commissionBalance': instance.commissionBalance,
      'metadata': instance.metadata,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.processing: 'processing',
  OrderStatus.canceled: 'canceled',
  OrderStatus.completed: 'completed',
  OrderStatus.discounted: 'discounted',
};

const _$OrderCommissionStatusEnumMap = {
  OrderCommissionStatus.pending: 'pending',
  OrderCommissionStatus.processing: 'processing',
  OrderCommissionStatus.completed: 'completed',
  OrderCommissionStatus.none: 'none',
};
