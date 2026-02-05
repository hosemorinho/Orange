import '../xboard_database.dart';

/// 公告数据仓库
///
/// 管理公告已读状态
class DbNoticeRepository {
  final XBoardDatabase _db;

  /// 已读状态有效期（默认 24 小时）
  final Duration readValidDuration;

  DbNoticeRepository(this._db, {this.readValidDuration = const Duration(hours: 24)});

  /// 检查公告是否需要显示
  Future<bool> shouldShowNotice(int noticeId) async {
    final isRead = await _db.xBoardNoticeReadsDao.isNoticeReadWithin(noticeId, readValidDuration);
    return !isRead;
  }

  /// 标记公告已读
  Future<void> markAsRead(int noticeId) async {
    await _db.xBoardNoticeReadsDao.markAsRead(noticeId);
  }

  /// 清理过期的已读记录
  Future<void> cleanExpired() async {
    await _db.xBoardNoticeReadsDao.cleanExpired(readValidDuration);
  }

  /// 清空所有已读记录
  Future<void> clearAll() async {
    await _db.xBoardNoticeReadsDao.clearAll();
  }
}
