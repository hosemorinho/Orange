import 'package:fl_clash/xboard/domain/domain.dart';
import '../xboard_database.dart';
import '../converters/converters.dart';

/// 订阅数据仓库
class SubscriptionRepository {
  final XBoardDatabase _db;

  SubscriptionRepository(this._db);

  /// 获取当前订阅
  Future<DomainSubscription?> getCurrentSubscription() async {
    final row = await _db.xBoardSubscriptionsDao.getCurrentSubscription();
    return row?.toDomain();
  }

  /// 根据邮箱获取订阅
  Future<DomainSubscription?> getSubscriptionByEmail(String email) async {
    final row = await _db.xBoardSubscriptionsDao.getSubscriptionByEmail(email);
    return row?.toDomain();
  }

  /// 保存订阅（插入或更新）
  Future<void> saveSubscription(DomainSubscription subscription) async {
    await _db.xBoardSubscriptionsDao.upsertSubscription(subscription.toCompanion());
  }

  /// 删除订阅
  Future<void> deleteSubscription(String email) async {
    await _db.xBoardSubscriptionsDao.deleteSubscription(email);
  }

  /// 清空所有订阅
  Future<void> clearAll() async {
    await _db.xBoardSubscriptionsDao.clearAll();
  }

  /// 监听当前订阅变化
  Stream<DomainSubscription?> watchCurrentSubscription() {
    return _db.xBoardSubscriptionsDao.watchCurrentSubscription().map((row) => row?.toDomain());
  }
}
