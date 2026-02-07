import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import '../xboard_database.dart';

/// XBoardPlanRow 与 DomainPlan 之间的转换扩展
extension XBoardPlanRowToDomain on XBoardPlanRow {
  /// 转换为领域模型
  DomainPlan toDomain() {
    return DomainPlan(
      id: id,
      name: name,
      groupId: groupId,
      transferQuota: transferQuota,
      description: description,
      tags: _parseTags(tags),
      speedLimit: speedLimit,
      deviceLimit: deviceLimit,
      isVisible: isVisible,
      renewable: renewable,
      sort: sort,
      onetimePrice: onetimePrice,
      monthlyPrice: monthlyPrice,
      quarterlyPrice: quarterlyPrice,
      halfYearlyPrice: halfYearlyPrice,
      yearlyPrice: yearlyPrice,
      twoYearPrice: twoYearPrice,
      threeYearPrice: threeYearPrice,
      resetPrice: resetPrice,
      createdAt: createdAt,
      updatedAt: updatedAt,
      metadata: _parseMetadata(metadata),
    );
  }

  List<String> _parseTags(String tagsJson) {
    try {
      return List<String>.from(jsonDecode(tagsJson));
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> _parseMetadata(String metadataJson) {
    try {
      return Map<String, dynamic>.from(jsonDecode(metadataJson));
    } catch (_) {
      return {};
    }
  }
}

/// DomainPlan 转换为数据库 Companion
extension DomainPlanToCompanion on DomainPlan {
  /// 转换为数据库插入/更新对象
  XBoardPlansCompanion toCompanion({DateTime? cachedAt}) {
    return XBoardPlansCompanion(
      id: Value(id),
      name: Value(name),
      groupId: Value(groupId),
      transferQuota: Value(transferQuota),
      description: Value(description),
      tags: Value(jsonEncode(tags)),
      speedLimit: Value(speedLimit),
      deviceLimit: Value(deviceLimit),
      isVisible: Value(isVisible),
      renewable: Value(renewable),
      sort: Value(sort),
      onetimePrice: Value(onetimePrice),
      monthlyPrice: Value(monthlyPrice),
      quarterlyPrice: Value(quarterlyPrice),
      halfYearlyPrice: Value(halfYearlyPrice),
      yearlyPrice: Value(yearlyPrice),
      twoYearPrice: Value(twoYearPrice),
      threeYearPrice: Value(threeYearPrice),
      resetPrice: Value(resetPrice),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      metadata: Value(jsonEncode(metadata)),
      cachedAt: Value(cachedAt ?? DateTime.now()),
    );
  }
}
