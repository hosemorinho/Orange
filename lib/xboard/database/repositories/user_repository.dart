import 'package:fl_clash/xboard/domain/domain.dart';
import '../xboard_database.dart';
import '../converters/converters.dart';

/// 用户数据仓库
///
/// 封装用户相关的数据库操作，提供领域模型接口
class UserRepository {
  final XBoardDatabase _db;

  UserRepository(this._db);

  /// 获取当前用户
  Future<DomainUser?> getCurrentUser() async {
    final row = await _db.xBoardUsersDao.getCurrentUser();
    return row?.toDomain();
  }

  /// 根据邮箱获取用户
  Future<DomainUser?> getUserByEmail(String email) async {
    final row = await _db.xBoardUsersDao.getUserByEmail(email);
    return row?.toDomain();
  }

  /// 保存用户（插入或更新）
  Future<void> saveUser(DomainUser user) async {
    await _db.xBoardUsersDao.upsertUser(user.toCompanion());
  }

  /// 删除用户
  Future<void> deleteUser(String email) async {
    await _db.xBoardUsersDao.deleteUser(email);
  }

  /// 清空所有用户
  Future<void> clearAll() async {
    await _db.xBoardUsersDao.clearAll();
  }

  /// 监听当前用户变化
  Stream<DomainUser?> watchCurrentUser() {
    return _db.xBoardUsersDao.watchCurrentUser().map((row) => row?.toDomain());
  }
}
