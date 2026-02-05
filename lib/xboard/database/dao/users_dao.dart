part of '../xboard_database.dart';

@DriftAccessor(tables: [XBoardUsers])
class XBoardUsersDao extends DatabaseAccessor<XBoardDatabase>
    with _$XBoardUsersDaoMixin {
  XBoardUsersDao(super.attachedDatabase);

  /// 获取当前用户（最近同步的）
  Future<XBoardUserRow?> getCurrentUser() async {
    final query = select(xBoardUsers)
      ..orderBy([(t) => OrderingTerm.desc(t.lastSyncedAt)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  /// 根据邮箱获取用户
  Future<XBoardUserRow?> getUserByEmail(String email) {
    return (select(xBoardUsers)..where((t) => t.email.equals(email)))
        .getSingleOrNull();
  }

  /// 保存或更新用户
  Future<int> upsertUser(XBoardUsersCompanion user) {
    return into(xBoardUsers).insertOnConflictUpdate(user);
  }

  /// 删除用户
  Future<int> deleteUser(String email) {
    return (delete(xBoardUsers)..where((t) => t.email.equals(email))).go();
  }

  /// 清空所有用户
  Future<int> clearAll() {
    return delete(xBoardUsers).go();
  }

  /// 监听当前用户变化
  Stream<XBoardUserRow?> watchCurrentUser() {
    final query = select(xBoardUsers)
      ..orderBy([(t) => OrderingTerm.desc(t.lastSyncedAt)])
      ..limit(1);
    return query.watchSingleOrNull();
  }
}
