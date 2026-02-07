/// API Text Resolver
///
/// Resolves and decrypts API configuration from DNS TXT records:
/// 1. Query TXT record via DoH
/// 2. Decrypt with CryptoJS-compatible AES
/// 3. Parse JSON configuration
library;

import 'dart:convert';
import 'package:fl_clash/xboard/core/core.dart';
import 'doh_txt_resolver.dart';
import 'cryptojs_aes_decryptor.dart';

final _logger = FileLogger('api_text_resolver.dart');

/// Resolved API configuration from TXT record
class ApiTextResolvedConfig {
  /// Crisp website ID (optional)
  final String? crispWebsiteId;

  /// API host URLs (required, non-empty)
  final List<String> hosts;

  const ApiTextResolvedConfig({
    this.crispWebsiteId,
    required this.hosts,
  });

  @override
  String toString() {
    return 'ApiTextResolvedConfig(crisp: $crispWebsiteId, hosts: ${hosts.length})';
  }
}

/// API Text Resolver
class ApiTextResolver {
  /// Cached resolved configuration (in-memory)
  static ApiTextResolvedConfig? _resolvedConfig;

  /// Get cached resolved configuration
  static ApiTextResolvedConfig? get resolvedConfig => _resolvedConfig;

  /// Get resolved Crisp website ID
  static String? get resolvedCrispWebsiteId => _resolvedConfig?.crispWebsiteId;

  /// Get resolved host URLs
  static List<String> get resolvedHosts => _resolvedConfig?.hosts ?? [];

  /// Resolve API configuration from DNS TXT record
  ///
  /// [domain] Domain name to query (e.g., "txt.example.com")
  /// [password] Password for AES decryption
  ///
  /// Returns resolved configuration or null on failure.
  /// Result is cached in memory for the app session.
  static Future<ApiTextResolvedConfig?> resolve(
    String domain,
    String password,
  ) async {
    try {
      _logger.info('[ApiText] 开始解析: $domain');

      // 1. Resolve TXT record via DoH
      final encryptedData = await DohTxtResolver.resolveTxt(domain);
      if (encryptedData == null || encryptedData.isEmpty) {
        _logger.error('[ApiText] TXT 记录为空');
        return null;
      }

      _logger.info('[ApiText] TXT 记录获取成功，长度: ${encryptedData.length}');

      // 2. Decrypt with CryptoJS AES
      final decryptedJson = CryptoJsAesDecryptor.decrypt(
        encryptedData,
        password,
      );

      if (decryptedJson == null || decryptedJson.isEmpty) {
        _logger.error('[ApiText] 解密失败或结果为空');
        return null;
      }

      _logger.info('[ApiText] 解密成功，JSON 长度: ${decryptedJson.length}');

      // 3. Parse JSON
      final Map<String, dynamic> json;
      try {
        json = jsonDecode(decryptedJson) as Map<String, dynamic>;
      } catch (e) {
        _logger.error('[ApiText] JSON 解析失败: $e');
        return null;
      }

      // 4. Validate and extract fields
      final String? crispWebsiteId;
      if (json.containsKey('crisp')) {
        final crispValue = json['crisp'];
        if (crispValue is String && crispValue.isNotEmpty) {
          crispWebsiteId = crispValue;
          _logger.info('[ApiText] Crisp ID: $crispWebsiteId');
        } else {
          crispWebsiteId = null;
          _logger.info('[ApiText] Crisp 字段无效或为空');
        }
      } else {
        crispWebsiteId = null;
        _logger.info('[ApiText] 未配置 Crisp');
      }

      if (!json.containsKey('hosts')) {
        _logger.error('[ApiText] 缺少 hosts 字段');
        return null;
      }

      final hostsValue = json['hosts'];
      if (hostsValue is! List) {
        _logger.error('[ApiText] hosts 字段不是数组');
        return null;
      }

      final hosts = <String>[];
      for (final item in hostsValue) {
        if (item is String && item.trim().isNotEmpty) {
          hosts.add(item.trim());
        }
      }

      if (hosts.isEmpty) {
        _logger.error('[ApiText] hosts 数组为空或无有效元素');
        return null;
      }

      _logger.info('[ApiText] 解析成功: ${hosts.length} 个主机');

      // 5. Cache result
      _resolvedConfig = ApiTextResolvedConfig(
        crispWebsiteId: crispWebsiteId,
        hosts: hosts,
      );

      return _resolvedConfig;
    } catch (e, stackTrace) {
      _logger.error('[ApiText] 解析失败', e, stackTrace);
      return null;
    }
  }

  /// Clear cached configuration (for testing or refresh)
  static void clearCache() {
    _resolvedConfig = null;
    _logger.info('[ApiText] 缓存已清除');
  }
}
