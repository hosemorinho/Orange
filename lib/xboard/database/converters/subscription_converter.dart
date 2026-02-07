import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import '../xboard_database.dart';

/// XBoardSubscriptionRow 与 DomainSubscription 之间的转换扩展
extension XBoardSubscriptionRowToDomain on XBoardSubscriptionRow {
  /// 转换为领域模型
  DomainSubscription toDomain() {
    return DomainSubscription(
      subscribeUrl: subscribeUrl,
      email: email,
      uuid: uuid,
      planId: planId,
      planName: planName,
      token: token,
      transferLimit: transferLimit,
      uploadedBytes: uploadedBytes,
      downloadedBytes: downloadedBytes,
      speedLimit: speedLimit,
      deviceLimit: deviceLimit,
      expiredAt: expiredAt,
      nextResetAt: nextResetAt,
      metadata: _parseMetadata(metadata),
    );
  }

  Map<String, dynamic> _parseMetadata(String metadataJson) {
    try {
      return Map<String, dynamic>.from(jsonDecode(metadataJson));
    } catch (_) {
      return {};
    }
  }
}

/// DomainSubscription 转换为数据库 Companion
extension DomainSubscriptionToCompanion on DomainSubscription {
  /// 转换为数据库插入/更新对象
  XBoardSubscriptionsCompanion toCompanion({DateTime? lastSyncedAt}) {
    return XBoardSubscriptionsCompanion(
      email: Value(email),
      subscribeUrl: Value(subscribeUrl),
      uuid: Value(uuid),
      planId: Value(planId),
      planName: Value(planName),
      token: Value(token),
      transferLimit: Value(transferLimit),
      uploadedBytes: Value(uploadedBytes),
      downloadedBytes: Value(downloadedBytes),
      speedLimit: Value(speedLimit),
      deviceLimit: Value(deviceLimit),
      expiredAt: Value(expiredAt),
      nextResetAt: Value(nextResetAt),
      metadata: Value(jsonEncode(metadata)),
      lastSyncedAt: Value(lastSyncedAt ?? DateTime.now()),
    );
  }
}
