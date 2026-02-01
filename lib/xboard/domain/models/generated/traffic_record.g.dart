// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../traffic_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrafficRecordImpl _$$TrafficRecordImplFromJson(Map<String, dynamic> json) =>
    _$TrafficRecordImpl(
      recordAt: (json['recordAt'] as num).toInt(),
      u: (json['u'] as num).toInt(),
      d: (json['d'] as num).toInt(),
      serverRate: json['serverRate'] as String,
    );

Map<String, dynamic> _$$TrafficRecordImplToJson(_$TrafficRecordImpl instance) =>
    <String, dynamic>{
      'recordAt': instance.recordAt,
      'u': instance.u,
      'd': instance.d,
      'serverRate': instance.serverRate,
    };

_$AggregatedTrafficImpl _$$AggregatedTrafficImplFromJson(
        Map<String, dynamic> json) =>
    _$AggregatedTrafficImpl(
      date: json['date'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      rateGroups: (json['rateGroups'] as List<dynamic>)
          .map((e) => TrafficRateGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalU: (json['totalU'] as num).toInt(),
      totalD: (json['totalD'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$$AggregatedTrafficImplToJson(
        _$AggregatedTrafficImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'timestamp': instance.timestamp,
      'rateGroups': instance.rateGroups,
      'totalU': instance.totalU,
      'totalD': instance.totalD,
      'total': instance.total,
    };

_$TrafficRateGroupImpl _$$TrafficRateGroupImplFromJson(
        Map<String, dynamic> json) =>
    _$TrafficRateGroupImpl(
      u: (json['u'] as num).toInt(),
      d: (json['d'] as num).toInt(),
      rate: (json['rate'] as num).toDouble(),
    );

Map<String, dynamic> _$$TrafficRateGroupImplToJson(
        _$TrafficRateGroupImpl instance) =>
    <String, dynamic>{
      'u': instance.u,
      'd': instance.d,
      'rate': instance.rate,
    };
