part of '../xboard_database.dart';

@DriftAccessor(tables: [XBoardNoticeReads])
class XBoardNoticeReadsDao extends DatabaseAccessor<XBoardDatabase>
    with _$XBoardNoticeReadsDaoMixin {
  XBoardNoticeReadsDao(super.attachedDatabase);

  /// 检查公告是否在指定时间内已读
  Future<bool> isNoticeReadWithin(int noticeId, Duration duration) async {
    final record = await (select(xBoardNoticeReads)
          ..where((t) => t.noticeId.equals(noticeId)))
        .getSingleOrNull();

    if (record == null) return false;
    return DateTime.now().difference(record.readAt) <= duration;
  }

  /// 标记公告已读
  Future<int> markAsRead(int noticeId) {
    return into(xBoardNoticeReads).insertOnConflictUpdate(
      XBoardNoticeReadsCompanion.insert(
        noticeId: noticeId,
        readAt: DateTime.now(),
      ),
    );
  }

  /// 清理过期的已读记录
  Future<int> cleanExpired(Duration maxAge) {
    final cutoff = DateTime.now().subtract(maxAge);
    return (delete(xBoardNoticeReads)
          ..where((t) => t.readAt.isSmallerThanValue(cutoff)))
        .go();
  }

  /// 清空所有已读记录
  Future<int> clearAll() {
    return delete(xBoardNoticeReads).go();
  }
}
