part of '../xboard_database.dart';

@DriftAccessor(tables: [XBoardSubscriptions])
class XBoardSubscriptionsDao extends DatabaseAccessor<XBoardDatabase>
    with _$XBoardSubscriptionsDaoMixin {
  XBoardSubscriptionsDao(super.attachedDatabase);

  /// 获取当前订阅
  Future<XBoardSubscriptionRow?> getCurrentSubscription() async {
    final query = select(xBoardSubscriptions)
      ..orderBy([(t) => OrderingTerm.desc(t.lastSyncedAt)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  /// 根据邮箱获取订阅
  Future<XBoardSubscriptionRow?> getSubscriptionByEmail(String email) {
    return (select(xBoardSubscriptions)..where((t) => t.email.equals(email)))
        .getSingleOrNull();
  }

  /// 保存或更新订阅
  Future<int> upsertSubscription(XBoardSubscriptionsCompanion subscription) {
    return into(xBoardSubscriptions).insertOnConflictUpdate(subscription);
  }

  /// 删除订阅
  Future<int> deleteSubscription(String email) {
    return (delete(xBoardSubscriptions)..where((t) => t.email.equals(email)))
        .go();
  }

  /// 清空所有订阅
  Future<int> clearAll() {
    return delete(xBoardSubscriptions).go();
  }

  /// 监听当前订阅变化
  Stream<XBoardSubscriptionRow?> watchCurrentSubscription() {
    final query = select(xBoardSubscriptions)
      ..orderBy([(t) => OrderingTerm.desc(t.lastSyncedAt)])
      ..limit(1);
    return query.watchSingleOrNull();
  }
}
