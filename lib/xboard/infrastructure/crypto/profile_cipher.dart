/// Profile encryption/decryption utility
///
/// Encrypts/decrypts subscription config files using AES-256-CBC
/// with SHA-256(subscription_token) as the key.
///
/// Encrypted format (JSON):
/// ```json
/// {
///   "format": "encrypted",
///   "cipher": "aes-256-cbc",
///   "iv": "<base64>",
///   "data": "<base64>"
/// }
/// ```
library;

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

class ProfileCipher {
  /// Extract subscription token from URL query parameter `token=XXX`
  static String? extractToken(String url) {
    final uri = Uri.tryParse(url);
    return uri?.queryParameters['token'];
  }

  /// Check if bytes are in encrypted JSON format
  static bool isEncryptedFormat(Uint8List bytes) {
    try {
      final str = utf8.decode(bytes).trimLeft();
      if (!str.startsWith('{')) return false;
      final json = jsonDecode(str);
      return json is Map && json['format'] == 'encrypted';
    } catch (_) {
      return false;
    }
  }

  /// Decrypt encrypted JSON bytes to plain YAML bytes
  static Uint8List decrypt(Uint8List encryptedBytes, String token) {
    final json = jsonDecode(utf8.decode(encryptedBytes));
    if (json['format'] != 'encrypted') {
      throw const FormatException('Not an encrypted profile format');
    }

    final iv = base64.decode(json['iv'] as String);
    final data = base64.decode(json['data'] as String);
    final key = _deriveKey(token);

    final encrypter = enc.Encrypter(
      enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'),
    );
    final decrypted = encrypter.decryptBytes(
      enc.Encrypted(Uint8List.fromList(data)),
      iv: enc.IV(Uint8List.fromList(iv)),
    );
    return Uint8List.fromList(decrypted);
  }

  /// Encrypt plain YAML bytes to encrypted JSON bytes
  static Uint8List encrypt(Uint8List yamlBytes, String token) {
    final key = _deriveKey(token);
    final iv = enc.IV.fromSecureRandom(16);

    final encrypter = enc.Encrypter(
      enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'),
    );
    final encrypted = encrypter.encryptBytes(yamlBytes, iv: iv);

    final json = {
      'format': 'encrypted',
      'cipher': 'aes-256-cbc',
      'iv': base64.encode(iv.bytes),
      'data': base64.encode(encrypted.bytes),
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(json)));
  }

  /// Derive AES-256 key from subscription token using SHA-256
  static enc.Key _deriveKey(String token) {
    final hash = sha256.convert(utf8.encode(token));
    return enc.Key(Uint8List.fromList(hash.bytes));
  }
}
