/// XBoard 数据存储服务
///
/// 提供XBoard相关数据的存储和读取
library;

import 'dart:convert';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/infrastructure/infrastructure.dart';
import 'package:fl_clash/xboard/domain/domain.dart';

/// XBoard 存储服务
///
/// 负责存储和读取XBoard相关数据，如用户信息、订阅信息等
class XBoardStorageService {
  final StorageInterface _storage;

  XBoardStorageService(this._storage);

  // 存储键定义
  static const String _userEmailKey = 'xboard_user_email';
  static const String _userInfoKey = 'xboard_user_info'; // 保留兼容
  static const String _subscriptionInfoKey = 'xboard_subscription_info'; // 保留兼容
  static const String _domainUserKey = 'xboard_domain_user'; // 新：领域模型
  static const String _domainSubscriptionKey =
      'xboard_domain_subscription'; // 新：领域模型
  static const String _tunFirstUseKey = 'xboard_tun_first_use_shown';
  static const String _savedEmailKey = 'xboard_saved_email';
  static const String _savedPasswordKey = 'xboard_saved_password';
  static const String _rememberPasswordKey = 'xboard_remember_password';
  static const String _noticeDialogReadPrefix =
      'xboard_notice_dialog_read_'; // 前缀 + noticeId
  static const String _noticeBannerDismissedKey =
      'xboard_notice_banner_dismissed_until'; // 通知横幅关闭时间戳

  Future<Result<bool>> saveUserEmail(String email) async {
    return await _storage.setString(_userEmailKey, email);
  }

  Future<Result<String?>> getUserEmail() async {
    return await _storage.getString(_userEmailKey);
  }

  Future<Result<bool>> saveDomainUser(DomainUser user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      return await _storage.setString(_domainUserKey, userJson);
    } catch (e, stackTrace) {
      return Result.failure(
        XBoardStorageException(
          message: '保存领域用户信息失败',
          operation: 'write',
          key: _domainUserKey,
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<DomainUser?>> getDomainUser() async {
    final result = await _storage.getString(_domainUserKey);
    return result.when(
      success: (userJson) {
        if (userJson == null) return Result.success(null);
        try {
          final Map<String, dynamic> userMap = jsonDecode(userJson);
          return Result.success(DomainUser.fromJson(userMap));
        } catch (e, stackTrace) {
          return Result.failure(
            XBoardParseException(
              message: '解析领域用户信息失败',
              dataType: 'DomainUser',
              originalError: e,
              stackTrace: stackTrace,
            ),
          );
        }
      },
      failure: (error) => Result.failure(error),
    );
  }

  // ===== 领域模型：订阅信息 =====

  Future<Result<bool>> saveDomainSubscription(
    DomainSubscription subscription,
  ) async {
    try {
      final subscriptionJson = jsonEncode(subscription.toJson());
      return await _storage.setString(_domainSubscriptionKey, subscriptionJson);
    } catch (e, stackTrace) {
      return Result.failure(
        XBoardStorageException(
          message: '保存领域订阅信息失败',
          operation: 'write',
          key: _domainSubscriptionKey,
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<DomainSubscription?>> getDomainSubscription() async {
    final result = await _storage.getString(_domainSubscriptionKey);
    return result.when(
      success: (subscriptionJson) {
        if (subscriptionJson == null) return Result.success(null);
        try {
          final Map<String, dynamic> subscriptionMap = jsonDecode(
            subscriptionJson,
          );
          return Result.success(DomainSubscription.fromJson(subscriptionMap));
        } catch (e, stackTrace) {
          return Result.failure(
            XBoardParseException(
              message: '解析领域订阅信息失败',
              dataType: 'DomainSubscription',
              originalError: e,
              stackTrace: stackTrace,
            ),
          );
        }
      },
      failure: (error) => Result.failure(error),
    );
  }

  // ===== 订阅信息（已移除，使用DomainSubscription代替） =====

  // ===== 认证数据清理 =====

  Future<Result<bool>> clearAuthData() async {
    final results = await Future.wait([
      _storage.remove(_userEmailKey),
      _storage.remove(_userInfoKey),
      _storage.remove(_subscriptionInfoKey),
      _storage.remove(_domainUserKey), // 清理领域模型
      _storage.remove(_domainSubscriptionKey), // 清理领域模型
    ]);

    final allSuccess = results.every((r) => r.dataOrNull == true);
    return Result.success(allSuccess);
  }

  // ===== 离线数据管理 =====

  Future<Result<bool>> clearDomainUser() async {
    return await _storage.remove(_domainUserKey);
  }

  Future<Result<bool>> clearDomainSubscription() async {
    return await _storage.remove(_domainSubscriptionKey);
  }

  // ===== TUN 首次使用标记 =====

  Future<Result<bool>> hasTunFirstUseShown() async {
    final result = await _storage.getBool(_tunFirstUseKey);
    return result.map((value) => value ?? false);
  }

  Future<Result<bool>> markTunFirstUseShown() async {
    return await _storage.setBool(_tunFirstUseKey, true);
  }

  // ===== 登录凭据（设备绑定加密） =====

  /// 保存登录凭据
  ///
  /// 密码使用设备绑定 AES-256-CBC 加密后存储，不保存明文。
  /// 如果加密失败（极端情况），密码不会被存储。
  Future<Result<bool>> saveCredentials(
    String email,
    String password,
    bool rememberPassword,
  ) async {
    String encryptedPassword = '';
    if (rememberPassword && password.isNotEmpty) {
      final encrypted = await CredentialCipher.encrypt(password);
      // 加密失败时不存储密码，保证安全底线
      encryptedPassword = encrypted ?? '';
    }

    final results = await Future.wait([
      _storage.setString(_savedEmailKey, email),
      _storage.setString(_savedPasswordKey, encryptedPassword),
      _storage.setBool(_rememberPasswordKey, rememberPassword),
    ]);

    final allSuccess = results.every((r) => r.dataOrNull == true);
    return Result.success(allSuccess);
  }

  Future<Result<Map<String, dynamic>>> getSavedCredentials() async {
    final emailResult = await _storage.getString(_savedEmailKey);
    final password = await getSavedPassword();
    final rememberResult = await _storage.getBool(_rememberPasswordKey);

    return Result.success({
      'email': emailResult.dataOrNull,
      'password': password,
      'rememberPassword': rememberResult.dataOrNull ?? false,
    });
  }

  // 便捷方法：获取单个保存的凭据字段
  Future<String?> getSavedEmail() async {
    final result = await _storage.getString(_savedEmailKey);
    return result.dataOrNull;
  }

  /// 读取保存的密码（自动解密）
  ///
  /// 兼容策略：
  /// 1) 新版密文（enc:v1:）→ 解密失败则安全失败并清理；
  /// 2) 旧版无前缀密文（历史加密数据）→ 解密成功后迁移到新格式；
  /// 3) 旧版明文 → 迁移到新格式。
  Future<String?> getSavedPassword() async {
    final result = await _storage.getString(_savedPasswordKey);
    final stored = result.dataOrNull;
    if (stored == null || stored.isEmpty) return null;

    // 新版带版本前缀密文：解密失败视为损坏数据，安全失败
    if (CredentialCipher.isEncryptedPayload(stored)) {
      final decrypted = await CredentialCipher.decrypt(stored);
      if (decrypted != null) return decrypted;
      await _storage.remove(_savedPasswordKey);
      return null;
    }

    // 兼容历史无前缀密文（上个版本）
    final legacyDecrypted = await CredentialCipher.decryptLegacy(stored);
    if (legacyDecrypted != null) {
      final migrated = await CredentialCipher.encrypt(legacyDecrypted);
      if (migrated != null) {
        await _storage.setString(_savedPasswordKey, migrated);
      }
      return legacyDecrypted;
    }

    // 旧版明文数据，静默迁移为新版加密存储
    final migrated = await CredentialCipher.encrypt(stored);
    if (migrated != null) {
      await _storage.setString(_savedPasswordKey, migrated);
    }
    return stored;
  }

  Future<bool> getRememberPassword() async {
    final result = await _storage.getBool(_rememberPasswordKey);
    return result.dataOrNull ?? false;
  }

  Future<Result<bool>> clearSavedCredentials() async {
    final results = await Future.wait([
      _storage.remove(_savedEmailKey),
      _storage.remove(_savedPasswordKey),
      _storage.remove(_rememberPasswordKey),
    ]);

    final allSuccess = results.every((r) => r.dataOrNull == true);
    return Result.success(allSuccess);
  }

  // ===== 公告弹窗已读时间戳 =====

  /// 保存公告弹窗已读时间戳
  Future<Result<bool>> saveNoticeDialogReadTime(int noticeId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return await _storage.setInt(
      '$_noticeDialogReadPrefix$noticeId',
      timestamp,
    );
  }

  /// 获取公告弹窗已读时间戳
  Future<Result<int?>> getNoticeDialogReadTime(int noticeId) async {
    return await _storage.getInt('$_noticeDialogReadPrefix$noticeId');
  }

  /// 判断公告弹窗是否需要显示（24小时内不再显示）
  Future<bool> shouldShowNoticeDialog(int noticeId) async {
    final result = await getNoticeDialogReadTime(noticeId);
    final timestamp = result.dataOrNull;

    if (timestamp == null) {
      // 从未显示过，需要显示
      return true;
    }

    final readTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(readTime);

    // 如果超过24小时，需要显示
    return difference.inHours >= 24;
  }

  // ===== 通知横幅关闭时间戳 =====

  /// 保存通知横幅关闭时间戳
  Future<Result<bool>> saveDismissalTimestamp(int timestamp) async {
    return await _storage.setInt(_noticeBannerDismissedKey, timestamp);
  }

  /// 获取通知横幅关闭时间戳
  Future<Result<int?>> getDismissalTimestamp() async {
    return await _storage.getInt(_noticeBannerDismissedKey);
  }
}
