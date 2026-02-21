/// API Text Resolver
///
/// Resolves and decrypts API configuration from DNS TXT records:
/// 1. Query TXT record via DoH
/// 2. Decrypt with CryptoJS-compatible AES
/// 3. Parse JSON configuration
library;

import 'dart:convert';

import 'package:fl_clash/xboard/core/core.dart';

import 'cryptojs_aes_decryptor.dart';
import 'doh_txt_resolver.dart';

final _logger = FileLogger('api_text_resolver.dart');

class ApiTextResolvedConfig {
  final String? crispWebsiteId;
  final List<String> hosts;

  const ApiTextResolvedConfig({this.crispWebsiteId, required this.hosts});

  @override
  String toString() {
    return 'ApiTextResolvedConfig(crisp: $crispWebsiteId, hosts: ${hosts.length})';
  }
}

class ApiTextResolver {
  static ApiTextResolvedConfig? _resolvedConfig;
  static String? _resolvedDomain;
  static int? _resolvedCredentialHash;

  static ApiTextResolvedConfig? get resolvedConfig => _resolvedConfig;
  static String? get resolvedCrispWebsiteId => _resolvedConfig?.crispWebsiteId;
  static List<String> get resolvedHosts => _resolvedConfig?.hosts ?? [];

  /// Returns resolved configuration or null on failure.
  /// Result is cached in memory for this app session.
  static Future<ApiTextResolvedConfig?> resolve(
    String domain,
    String password,
  ) async {
    final normalizedDomain = domain.trim();
    final credentialHash = Object.hash(normalizedDomain, password);

    try {
      if (_resolvedConfig != null &&
          _resolvedDomain == normalizedDomain &&
          _resolvedCredentialHash == credentialHash) {
        _logger.info('[ApiText] cache hit for $normalizedDomain');
        return _resolvedConfig;
      }

      _logger.info('[ApiText] resolving $normalizedDomain');

      final encryptedData = await DohTxtResolver.resolveTxt(normalizedDomain);
      if (encryptedData == null || encryptedData.isEmpty) {
        _logger.error('[ApiText] empty TXT payload');
        return null;
      }

      final decryptedJson = CryptoJsAesDecryptor.decrypt(
        encryptedData,
        password,
      );
      if (decryptedJson == null || decryptedJson.isEmpty) {
        _logger.error('[ApiText] decrypt failed or empty payload');
        return null;
      }

      final Map<String, dynamic> json;
      try {
        json = jsonDecode(decryptedJson) as Map<String, dynamic>;
      } catch (e) {
        _logger.error('[ApiText] JSON parse failed: $e');
        return null;
      }

      final crispValue = json['crisp'];
      final crispWebsiteId = (crispValue is String && crispValue.isNotEmpty)
          ? crispValue
          : null;

      final hostsValue = json['hosts'];
      if (hostsValue is! List) {
        _logger.error('[ApiText] hosts is missing or not a list');
        return null;
      }

      final hosts = <String>[];
      for (final item in hostsValue) {
        if (item is String && item.trim().isNotEmpty) {
          hosts.add(item.trim());
        }
      }

      if (hosts.isEmpty) {
        _logger.error('[ApiText] hosts list is empty');
        return null;
      }

      _resolvedConfig = ApiTextResolvedConfig(
        crispWebsiteId: crispWebsiteId,
        hosts: hosts,
      );
      _resolvedDomain = normalizedDomain;
      _resolvedCredentialHash = credentialHash;

      return _resolvedConfig;
    } catch (e, stackTrace) {
      _logger.error('[ApiText] resolve failed', e, stackTrace);
      return null;
    }
  }

  static void clearCache() {
    _resolvedConfig = null;
    _resolvedDomain = null;
    _resolvedCredentialHash = null;
    _logger.info('[ApiText] cache cleared');
  }
}
