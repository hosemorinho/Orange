import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import '../xboard_database.dart';

/// XBoardUserRow 与 DomainUser 之间的转换扩展
extension XBoardUserRowToDomain on XBoardUserRow {
  /// 转换为领域模型
  DomainUser toDomain() {
    return DomainUser(
      email: email,
      uuid: uuid,
      avatarUrl: avatarUrl,
      planId: planId,
      transferLimit: transferLimit,
      uploadedBytes: uploadedBytes,
      downloadedBytes: downloadedBytes,
      balanceInCents: balanceInCents,
      commissionBalanceInCents: commissionBalanceInCents,
      expiredAt: expiredAt,
      lastLoginAt: lastLoginAt,
      createdAt: createdAt,
      banned: banned,
      remindExpire: remindExpire,
      remindTraffic: remindTraffic,
      discount: discount,
      commissionRate: commissionRate,
      telegramId: telegramId,
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

/// DomainUser 转换为数据库 Companion
extension DomainUserToCompanion on DomainUser {
  /// 转换为数据库插入/更新对象
  XBoardUsersCompanion toCompanion({DateTime? lastSyncedAt}) {
    return XBoardUsersCompanion(
      email: Value(email),
      uuid: Value(uuid),
      avatarUrl: Value(avatarUrl),
      planId: Value(planId),
      transferLimit: Value(transferLimit),
      uploadedBytes: Value(uploadedBytes),
      downloadedBytes: Value(downloadedBytes),
      balanceInCents: Value(balanceInCents),
      commissionBalanceInCents: Value(commissionBalanceInCents),
      expiredAt: Value(expiredAt),
      lastLoginAt: Value(lastLoginAt),
      createdAt: Value(createdAt),
      banned: Value(banned),
      remindExpire: Value(remindExpire),
      remindTraffic: Value(remindTraffic),
      discount: Value(discount),
      commissionRate: Value(commissionRate),
      telegramId: Value(telegramId),
      metadata: Value(jsonEncode(metadata)),
      lastSyncedAt: Value(lastSyncedAt ?? DateTime.now()),
    );
  }
}
