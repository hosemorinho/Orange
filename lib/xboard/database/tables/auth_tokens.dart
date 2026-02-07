part of '../xboard_database.dart';

@DataClassName('XBoardAuthTokenRow')
class XBoardAuthTokens extends Table {
  @override
  String get tableName => 'xboard_auth_tokens';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text().unique()();
  TextColumn get token => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
}
