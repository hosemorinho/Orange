part of '../xboard_database.dart';

@DataClassName('XBoardNoticeReadRow')
class XBoardNoticeReads extends Table {
  @override
  String get tableName => 'xboard_notice_reads';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get noticeId => integer()();
  DateTimeColumn get readAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [{noticeId}];
}
