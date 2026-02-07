part of '../xboard_database.dart';

@DataClassName('XBoardOrderRow')
class XBoardOrders extends Table {
  @override
  String get tableName => 'xboard_orders';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get tradeNo => text().unique()();
  TextColumn get email => text()(); // 关联用户
  IntColumn get planId => integer()();
  TextColumn get period => text()();
  RealColumn get totalAmount => real()();
  IntColumn get statusCode => integer()(); // OrderStatus code
  TextColumn get planName => text().nullable()();
  TextColumn get planContent => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get paidAt => dateTime().nullable()();
  RealColumn get handlingAmount =>
      real().withDefault(const Constant(0))();
  RealColumn get balanceAmount =>
      real().withDefault(const Constant(0))();
  RealColumn get refundAmount =>
      real().withDefault(const Constant(0))();
  RealColumn get discountAmount =>
      real().withDefault(const Constant(0))();
  RealColumn get surplusAmount =>
      real().withDefault(const Constant(0))();
  IntColumn get paymentId => integer().nullable()();
  TextColumn get paymentName => text().nullable()();
  IntColumn get couponId => integer().nullable()();
  IntColumn get commissionStatusCode => integer().nullable()();
  RealColumn get commissionBalance =>
      real().withDefault(const Constant(0))();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
