/// V2Board Token 持久化存储
///
/// 使用 SharedPreferences 存储 auth token
import 'package:shared_preferences/shared_preferences.dart';

class V2BoardTokenStorage {
  static const String _tokenKey = 'v2board_auth_token';

  /// 保存 token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// 获取 token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// 清除认证信息
  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// 是否有 token
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
