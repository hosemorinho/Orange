import '../xboard_database.dart';

/// 认证数据仓库
///
/// 管理认证令牌和用户登录状态
class AuthRepository {
  final XBoardDatabase _db;

  AuthRepository(this._db);

  /// 获取当前令牌
  Future<String?> getCurrentToken() async {
    final row = await _db.xBoardAuthTokensDao.getCurrentToken();
    return row?.token;
  }

  /// 根据邮箱获取令牌
  Future<String?> getTokenByEmail(String email) async {
    final row = await _db.xBoardAuthTokensDao.getTokenByEmail(email);
    return row?.token;
  }

  /// 保存令牌
  Future<void> saveToken(String email, String token) async {
    await _db.xBoardAuthTokensDao.saveToken(email, token);
  }

  /// 更新最后使用时间
  Future<void> updateLastUsed(String email) async {
    await _db.xBoardAuthTokensDao.updateLastUsed(email);
  }

  /// 删除令牌
  Future<void> deleteToken(String email) async {
    await _db.xBoardAuthTokensDao.deleteToken(email);
  }

  /// 清空所有令牌
  Future<void> clearAll() async {
    await _db.xBoardAuthTokensDao.clearAll();
  }

  /// 检查是否有有效令牌
  Future<bool> hasToken() async {
    return _db.xBoardAuthTokensDao.hasToken();
  }
}
