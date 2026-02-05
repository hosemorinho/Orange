part of '../xboard_database.dart';

@DriftAccessor(tables: [XBoardAuthTokens])
class XBoardAuthTokensDao extends DatabaseAccessor<XBoardDatabase>
    with _$XBoardAuthTokensDaoMixin {
  XBoardAuthTokensDao(super.attachedDatabase);

  /// 获取当前令牌（最近使用的）
  Future<XBoardAuthTokenRow?> getCurrentToken() async {
    final query = select(xBoardAuthTokens)
      ..orderBy([(t) => OrderingTerm.desc(t.lastUsedAt)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  /// 根据邮箱获取令牌
  Future<XBoardAuthTokenRow?> getTokenByEmail(String email) {
    return (select(xBoardAuthTokens)..where((t) => t.email.equals(email)))
        .getSingleOrNull();
  }

  /// 保存令牌
  Future<int> saveToken(String email, String token) {
    return into(xBoardAuthTokens).insertOnConflictUpdate(
      XBoardAuthTokensCompanion.insert(
        email: email,
        token: token,
        createdAt: DateTime.now(),
        lastUsedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 更新最后使用时间
  Future<int> updateLastUsed(String email) {
    return (update(xBoardAuthTokens)..where((t) => t.email.equals(email)))
        .write(XBoardAuthTokensCompanion(lastUsedAt: Value(DateTime.now())));
  }

  /// 删除令牌
  Future<int> deleteToken(String email) {
    return (delete(xBoardAuthTokens)..where((t) => t.email.equals(email))).go();
  }

  /// 清空所有令牌
  Future<int> clearAll() {
    return delete(xBoardAuthTokens).go();
  }

  /// 检查是否有有效令牌
  Future<bool> hasToken() async {
    final count = await xBoardAuthTokens.count().getSingle();
    return count > 0;
  }
}
