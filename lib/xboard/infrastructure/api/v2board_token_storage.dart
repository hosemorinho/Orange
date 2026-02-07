/// V2Board Token 持久化存储
///
/// 使用 Drift 数据库存储 auth token
///
/// 注意：此文件现在使用数据库存储，保持接口兼容
import 'package:fl_clash/xboard/database/database.dart';
import 'package:fl_clash/xboard/database/repositories/repositories.dart';

class V2BoardTokenStorage {
  static final _authRepo = DbAuthRepository(xboardDatabase);
  static final _userRepo = DbUserRepository(xboardDatabase);

  /// 保存 token
  ///
  /// [token] 认证令牌
  /// [email] 用户邮箱（用于关联 token，如未提供则尝试从当前用户获取）
  static Future<void> saveToken(String token, {String? email}) async {
    // 如果没有提供 email，尝试从现有用户获取
    final userEmail = email ?? await _getCurrentUserEmail();
    if (userEmail != null) {
      await _authRepo.saveToken(userEmail, token);
    }
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

  /// 获取当前用户邮箱
  static Future<String?> _getCurrentUserEmail() async {
    final user = await _userRepo.getCurrentUser();
    return user?.email;
  }
}
