/// V2Board Token 数据库存储
///
/// 使用 Drift 数据库存储 auth token
import 'package:fl_clash/xboard/database/database.dart';
import 'package:fl_clash/xboard/database/repositories/repositories.dart';

/// V2Board Token 数据库存储
///
/// 使用 Drift 数据库替代 SharedPreferences
class V2BoardDbTokenStorage {
  final AuthRepository _authRepo;

  V2BoardDbTokenStorage(this._authRepo);

  /// 保存 token
  Future<void> saveToken(String email, String token) async {
    await _authRepo.saveToken(email, token);
  }

  /// 获取 token
  Future<String?> getToken() async {
    return _authRepo.getCurrentToken();
  }

  /// 根据邮箱获取 token
  Future<String?> getTokenByEmail(String email) async {
    return _authRepo.getTokenByEmail(email);
  }

  /// 清除认证信息
  Future<void> clearAuth() async {
    await _authRepo.clearAll();
  }

  /// 删除特定邮箱的 token
  Future<void> deleteToken(String email) async {
    await _authRepo.deleteToken(email);
  }

  /// 是否有 token
  Future<bool> hasToken() async {
    return _authRepo.hasToken();
  }
}

/// 静态方法版本（兼容现有代码）
///
/// 使用全局数据库实例
class V2BoardTokenStorageCompat {
  static final _authRepo = AuthRepository(xboardDatabase);

  /// 保存 token
  static Future<void> saveToken(String email, String token) async {
    await _authRepo.saveToken(email, token);
  }

  /// 获取 token
  static Future<String?> getToken() async {
    return _authRepo.getCurrentToken();
  }

  /// 清除认证信息
  static Future<void> clearAuth() async {
    await _authRepo.clearAll();
  }

  /// 是否有 token
  static Future<bool> hasToken() async {
    return _authRepo.hasToken();
  }
}
