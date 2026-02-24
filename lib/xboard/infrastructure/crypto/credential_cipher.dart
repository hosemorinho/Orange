/// 设备绑定的凭据加密/解密
///
/// 使用设备唯一标识 + 固定盐值派生 AES-256-CBC 密钥，
/// 对保存的密码等敏感信息进行加密存储。
///
/// 加密格式: base64( 16字节IV + AES密文 )
/// 密钥派生: SHA-256( deviceFingerprint + salt )
///
/// 平台指纹来源:
/// - Android: Build.fingerprint
/// - Windows: deviceId
/// - macOS: systemGUID
/// - Linux: machineId
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:fl_clash/xboard/core/core.dart';

final _logger = FileLogger('credential_cipher.dart');

class CredentialCipher {
  static String? _cachedFingerprint;
  static const _salt = 'xboard_credential_v1';
  static const _v1Prefix = 'enc:v1:';

  /// 加密明文，返回 base64 编码的密文；失败返回 null
  static Future<String?> encrypt(String plaintext) async {
    try {
      final key = await _deriveKey();
      if (key == null) return null;

      final iv = enc.IV.fromSecureRandom(16);
      final encrypter = enc.Encrypter(
        enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'),
      );
      final encrypted = encrypter.encrypt(plaintext, iv: iv);

      // 格式: base64( IV(16) + ciphertext )
      final combined = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
      return '$_v1Prefix${base64.encode(combined)}';
    } catch (e) {
      _logger.error('加密凭据失败: $e');
      return null;
    }
  }

  /// 解密 base64 密文，返回明文；失败返回 null
  static Future<String?> decrypt(String encryptedBase64) async {
    try {
      if (!isEncryptedPayload(encryptedBase64)) return null;

      final key = await _deriveKey();
      if (key == null) return null;

      final raw = encryptedBase64.substring(_v1Prefix.length);
      final combined = base64.decode(raw);
      return _decryptCombined(combined, key);
    } catch (e) {
      _logger.debug('解密凭据失败（可能是旧版明文数据）: $e');
      return null;
    }
  }

  static bool isEncryptedPayload(String value) {
    return value.startsWith(_v1Prefix);
  }

  static Future<String?> decryptLegacy(String encryptedBase64) async {
    try {
      final key = await _deriveKey();
      if (key == null) return null;

      final combined = base64.decode(encryptedBase64);
      return _decryptCombined(combined, key);
    } catch (_) {
      return null;
    }
  }

  static String? _decryptCombined(List<int> combined, enc.Key key) {
    // 最小长度: 16字节 IV + 16字节 AES 块
    if (combined.length < 32) return null;

    final iv = enc.IV(Uint8List.fromList(combined.sublist(0, 16)));
    final ciphertext = Uint8List.fromList(combined.sublist(16));
    final encrypter = enc.Encrypter(
      enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'),
    );
    return encrypter.decrypt(enc.Encrypted(ciphertext), iv: iv);
  }

  /// 从设备指纹 + 盐值派生 AES-256 密钥
  static Future<enc.Key?> _deriveKey() async {
    final fingerprint = await _getDeviceFingerprint();
    if (fingerprint == null || fingerprint.isEmpty) return null;

    final combined = '$fingerprint:$_salt';
    final hash = sha256.convert(utf8.encode(combined));
    return enc.Key(Uint8List.fromList(hash.bytes));
  }

  /// 获取设备唯一标识（缓存）
  static Future<String?> _getDeviceFingerprint() async {
    if (_cachedFingerprint != null) return _cachedFingerprint;

    try {
      final deviceInfo = DeviceInfoPlugin();
      final fingerprint = switch (Platform.operatingSystem) {
        'android' => (await deviceInfo.androidInfo).fingerprint,
        'windows' => (await deviceInfo.windowsInfo).deviceId,
        'macos' => (await deviceInfo.macOsInfo).systemGUID,
        'linux' => (await deviceInfo.linuxInfo).machineId,
        _ => null,
      };

      if (fingerprint != null && fingerprint.isNotEmpty) {
        _cachedFingerprint = fingerprint;
      }
      return _cachedFingerprint;
    } catch (e) {
      _logger.error('获取设备指纹失败: $e');
      return null;
    }
  }
}
