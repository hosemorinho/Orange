part of '../xboard_database.dart';

@DataClassName('XBoardUserRow')
class XBoardUsers extends Table {
  @override
  String get tableName => 'xboard_users';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text().unique()();
  TextColumn get uuid => text()();
  TextColumn get avatarUrl => text().withDefault(const Constant(''))();
  IntColumn get planId => integer().nullable()();
  IntColumn get transferLimit => integer().withDefault(const Constant(0))();
  IntColumn get uploadedBytes => integer().withDefault(const Constant(0))();
  IntColumn get downloadedBytes => integer().withDefault(const Constant(0))();
  IntColumn get balanceInCents => integer().withDefault(const Constant(0))();
  IntColumn get commissionBalanceInCents =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get expiredAt => dateTime().nullable()();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get banned => boolean().withDefault(const Constant(false))();
  BoolColumn get remindExpire =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get remindTraffic =>
      boolean().withDefault(const Constant(true))();
  RealColumn get discount => real().nullable()();
  RealColumn get commissionRate => real().nullable()();
  TextColumn get telegramId => text().nullable()();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
