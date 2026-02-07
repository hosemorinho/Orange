// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../invite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DomainInviteCode _$DomainInviteCodeFromJson(Map<String, dynamic> json) =>
    _DomainInviteCode(
      code: json['code'] as String,
      status: (json['status'] as num?)?.toInt() ?? 1,
      commissionRate: (json['commissionRate'] as num).toDouble(),
      commissionBalanceInCents:
          (json['commissionBalanceInCents'] as num?)?.toInt() ?? 0,
      registeredUsers: (json['registeredUsers'] as num?)?.toInt() ?? 0,
      pageViews: (json['pageViews'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DomainInviteCodeToJson(_DomainInviteCode instance) =>
    <String, dynamic>{
      'code': instance.code,
      'status': instance.status,
      'commissionRate': instance.commissionRate,
      'commissionBalanceInCents': instance.commissionBalanceInCents,
      'registeredUsers': instance.registeredUsers,
      'pageViews': instance.pageViews,
      'createdAt': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
    };

_DomainInviteStats _$DomainInviteStatsFromJson(Map<String, dynamic> json) =>
    _DomainInviteStats(
      registeredUsers: (json['registeredUsers'] as num?)?.toInt() ?? 0,
      settledCommissionInCents:
          (json['settledCommissionInCents'] as num?)?.toInt() ?? 0,
      pendingCommissionInCents:
          (json['pendingCommissionInCents'] as num?)?.toInt() ?? 0,
      commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0,
      availableCommissionInCents:
          (json['availableCommissionInCents'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DomainInviteStatsToJson(_DomainInviteStats instance) =>
    <String, dynamic>{
      'registeredUsers': instance.registeredUsers,
      'settledCommissionInCents': instance.settledCommissionInCents,
      'pendingCommissionInCents': instance.pendingCommissionInCents,
      'commissionRate': instance.commissionRate,
      'availableCommissionInCents': instance.availableCommissionInCents,
    };
