// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../traffic_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrafficRecord _$TrafficRecordFromJson(Map<String, dynamic> json) =>
    _TrafficRecord(
      recordAt: (json['recordAt'] as num).toInt(),
      u: (json['u'] as num).toInt(),
      d: (json['d'] as num).toInt(),
      serverRate: json['serverRate'] as String,
    );

Map<String, dynamic> _$TrafficRecordToJson(_TrafficRecord instance) =>
    <String, dynamic>{
      'recordAt': instance.recordAt,
      'u': instance.u,
      'd': instance.d,
      'serverRate': instance.serverRate,
    };

_AggregatedTraffic _$AggregatedTrafficFromJson(Map<String, dynamic> json) =>
    _AggregatedTraffic(
      date: json['date'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      rateGroups: (json['rateGroups'] as List<dynamic>)
          .map((e) => TrafficRateGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalU: (json['totalU'] as num).toInt(),
      totalD: (json['totalD'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$AggregatedTrafficToJson(_AggregatedTraffic instance) =>
    <String, dynamic>{
      'date': instance.date,
      'timestamp': instance.timestamp,
      'rateGroups': instance.rateGroups,
      'totalU': instance.totalU,
      'totalD': instance.totalD,
      'total': instance.total,
    };

_TrafficRateGroup _$TrafficRateGroupFromJson(Map<String, dynamic> json) =>
    _TrafficRateGroup(
      u: (json['u'] as num).toInt(),
      d: (json['d'] as num).toInt(),
      rate: (json['rate'] as num).toDouble(),
    );

Map<String, dynamic> _$TrafficRateGroupToJson(_TrafficRateGroup instance) =>
    <String, dynamic>{'u': instance.u, 'd': instance.d, 'rate': instance.rate};
