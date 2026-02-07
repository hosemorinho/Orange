part of '../xboard_database.dart';

@DriftAccessor(tables: [XBoardOrders])
class XBoardOrdersDao extends DatabaseAccessor<XBoardDatabase>
    with _$XBoardOrdersDaoMixin {
  XBoardOrdersDao(super.attachedDatabase);

  /// 获取所有订单（按创建时间倒序）
  Future<List<XBoardOrderRow>> getAllOrders() {
    return (select(xBoardOrders)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// 获取用户的订单
  Future<List<XBoardOrderRow>> getOrdersByEmail(String email) {
    return (select(xBoardOrders)
          ..where((t) => t.email.equals(email))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// 获取待支付订单
  Future<List<XBoardOrderRow>> getPendingOrders(String email) {
    return (select(xBoardOrders)
          ..where((t) => t.email.equals(email) & t.statusCode.equals(0)))
        .get();
  }

  /// 根据交易号获取订单
  Future<XBoardOrderRow?> getOrderByTradeNo(String tradeNo) {
    return (select(xBoardOrders)..where((t) => t.tradeNo.equals(tradeNo)))
        .getSingleOrNull();
  }

  /// 保存或更新订单
  Future<int> upsertOrder(XBoardOrdersCompanion order) {
    return into(xBoardOrders).insertOnConflictUpdate(order);
  }

  /// 批量保存订单
  Future<void> upsertOrders(List<XBoardOrdersCompanion> orders) async {
    await batch((b) => b.insertAllOnConflictUpdate(xBoardOrders, orders));
  }

  /// 删除订单
  Future<int> deleteOrder(String tradeNo) {
    return (delete(xBoardOrders)..where((t) => t.tradeNo.equals(tradeNo))).go();
  }

  /// 清空用户的所有订单
  Future<int> clearByEmail(String email) {
    return (delete(xBoardOrders)..where((t) => t.email.equals(email))).go();
  }

  /// 清空所有订单
  Future<int> clearAll() {
    return delete(xBoardOrders).go();
  }
}
