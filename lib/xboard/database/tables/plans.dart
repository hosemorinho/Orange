part of '../xboard_database.dart';

@DataClassName('XBoardPlanRow')
class XBoardPlans extends Table {
  @override
  String get tableName => 'xboard_plans';

  IntColumn get id => integer()(); // 使用原始 planId 作为主键
  TextColumn get name => text()();
  IntColumn get groupId => integer()();
  IntColumn get transferQuota => integer()();
  TextColumn get description => text().nullable()();
  TextColumn get tags =>
      text().withDefault(const Constant('[]'))(); // JSON array
  IntColumn get speedLimit => integer().nullable()();
  IntColumn get deviceLimit => integer().nullable()();
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();
  BoolColumn get renewable => boolean().withDefault(const Constant(true))();
  IntColumn get sort => integer().nullable()();
  RealColumn get onetimePrice => real().nullable()();
  RealColumn get monthlyPrice => real().nullable()();
  RealColumn get quarterlyPrice => real().nullable()();
  RealColumn get halfYearlyPrice => real().nullable()();
  RealColumn get yearlyPrice => real().nullable()();
  RealColumn get twoYearPrice => real().nullable()();
  RealColumn get threeYearPrice => real().nullable()();
  RealColumn get resetPrice => real().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
