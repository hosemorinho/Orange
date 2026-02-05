part of '../xboard_database.dart';

@DataClassName('XBoardDomainRow')
class XBoardDomains extends Table {
  @override
  String get tableName => 'xboard_domains';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get url => text().unique()();
  IntColumn get latencyMs => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  BoolColumn get isAvailable =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastCheckedAt => dateTime().nullable()();
}
