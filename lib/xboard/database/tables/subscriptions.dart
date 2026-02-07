part of '../xboard_database.dart';

@DataClassName('XBoardSubscriptionRow')
class XBoardSubscriptions extends Table {
  @override
  String get tableName => 'xboard_subscriptions';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text()(); // 关联用户
  TextColumn get subscribeUrl => text()();
  TextColumn get uuid => text()();
  IntColumn get planId => integer()();
  TextColumn get planName => text().nullable()();
  TextColumn get token => text().nullable()();
  IntColumn get transferLimit => integer().withDefault(const Constant(0))();
  IntColumn get uploadedBytes => integer().withDefault(const Constant(0))();
  IntColumn get downloadedBytes => integer().withDefault(const Constant(0))();
  IntColumn get speedLimit => integer().nullable()();
  IntColumn get deviceLimit => integer().nullable()();
  DateTimeColumn get expiredAt => dateTime().nullable()();
  DateTimeColumn get nextResetAt => dateTime().nullable()();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
