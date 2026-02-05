import 'package:fl_clash/xboard/domain/domain.dart';
import '../xboard_database.dart';
import '../converters/converters.dart';

/// 订单数据仓库
class OrderRepository {
  final XBoardDatabase _db;

  OrderRepository(this._db);

  /// 获取所有订单
  Future<List<DomainOrder>> getAllOrders() async {
    final rows = await _db.xBoardOrdersDao.getAllOrders();
    return rows.map((row) => row.toDomain()).toList();
  }

  /// 获取用户的订单
  Future<List<DomainOrder>> getOrdersByEmail(String email) async {
    final rows = await _db.xBoardOrdersDao.getOrdersByEmail(email);
    return rows.map((row) => row.toDomain()).toList();
  }

  /// 获取待支付订单
  Future<List<DomainOrder>> getPendingOrders(String email) async {
    final rows = await _db.xBoardOrdersDao.getPendingOrders(email);
    return rows.map((row) => row.toDomain()).toList();
  }

  /// 根据交易号获取订单
  Future<DomainOrder?> getOrderByTradeNo(String tradeNo) async {
    final row = await _db.xBoardOrdersDao.getOrderByTradeNo(tradeNo);
    return row?.toDomain();
  }

  /// 保存订单
  Future<void> saveOrder(DomainOrder order, String email) async {
    await _db.xBoardOrdersDao.upsertOrder(order.toCompanion(email: email));
  }

  /// 批量保存订单
  Future<void> saveOrders(List<DomainOrder> orders, String email) async {
    final companions = orders.map((o) => o.toCompanion(email: email)).toList();
    await _db.xBoardOrdersDao.upsertOrders(companions);
  }

  /// 删除订单
  Future<void> deleteOrder(String tradeNo) async {
    await _db.xBoardOrdersDao.deleteOrder(tradeNo);
  }

  /// 清空用户的所有订单
  Future<void> clearByEmail(String email) async {
    await _db.xBoardOrdersDao.clearByEmail(email);
  }

  /// 清空所有订单
  Future<void> clearAll() async {
    await _db.xBoardOrdersDao.clearAll();
  }
}
