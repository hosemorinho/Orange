/// CryptoJS-compatible AES-256-CBC Decryptor
///
/// Implements OpenSSL's EVP_BytesToKey key derivation and AES decryption
/// compatible with CryptoJS.AES.encrypt() default format.
library;

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:fl_clash/xboard/core/core.dart';

final _logger = FileLogger('cryptojs_aes_decryptor.dart');

/// CryptoJS AES Decryptor
class CryptoJsAesDecryptor {
  /// Decrypt CryptoJS AES encrypted data
  ///
  /// [encryptedBase64] Base64-encoded ciphertext with "Salted__" prefix
  /// [password] Password used for key derivation
  ///
  /// Returns decrypted plaintext or null on failure
  static String? decrypt(String encryptedBase64, String password) {
    try {
      _logger.info('[AES] 开始解密，密码长度: ${password.length}');

      // 1. Base64 decode
      final encryptedBytes = base64.decode(encryptedBase64);
      _logger.info('[AES] Base64 解码完成，字节数: ${encryptedBytes.length}');

      // 2. Check "Salted__" prefix (8 bytes: 0x53616c7465645f5f)
      if (encryptedBytes.length < 16) {
        _logger.error('[AES] 数据太短（< 16 字节）');
        return null;
      }

      final saltedPrefix = utf8.decode(encryptedBytes.sublist(0, 8));
      if (saltedPrefix != 'Salted__') {
        _logger.error('[AES] 缺少 "Salted__" 前缀，实际: $saltedPrefix');
        return null;
      }

      // 3. Extract salt (bytes 8-16) and ciphertext (bytes 16+)
      final salt = Uint8List.fromList(encryptedBytes.sublist(8, 16));
      final ciphertext = Uint8List.fromList(encryptedBytes.sublist(16));
      _logger.info('[AES] Salt 提取成功，密文长度: ${ciphertext.length}');

      // 4. Derive key and IV using EVP_BytesToKey
      final (key, iv) = _evpBytesToKey(password, salt);
      _logger.info('[AES] 密钥和 IV 派生完成');

      // 5. Decrypt using AES-256-CBC
      final encrypter = encrypt.Encrypter(
        encrypt.AES(
          encrypt.Key(key),
          mode: encrypt.AESMode.cbc,
          padding: 'PKCS7',
        ),
      );

      final decrypted = encrypter.decrypt(
        encrypt.Encrypted(ciphertext),
        iv: encrypt.IV(iv),
      );

      _logger.info('[AES] 解密成功，明文长度: ${decrypted.length}');
      return decrypted;
    } catch (e, stackTrace) {
      _logger.error('[AES] 解密失败', e, stackTrace);
      return null;
    }
  }

  /// EVP_BytesToKey - OpenSSL's key derivation function
  ///
  /// Derives a 32-byte key and 16-byte IV from password and salt using MD5.
  /// Compatible with OpenSSL and CryptoJS default behavior.
  ///
  /// Algorithm:
  /// - D_0 = empty
  /// - D_i = MD5(D_(i-1) || password || salt)
  /// - key = D_0 || D_1 (32 bytes)
  /// - iv = D_2 (first 16 bytes)
  static (Uint8List key, Uint8List iv) _evpBytesToKey(
    String password,
    Uint8List salt,
  ) {
    final passwordBytes = utf8.encode(password);
    final result = <int>[];
    Uint8List? prevBlock;

    // Generate 48 bytes (32 for key + 16 for IV)
    while (result.length < 48) {
      final data = <int>[];
      if (prevBlock != null) {
        data.addAll(prevBlock);
      }
      data.addAll(passwordBytes);
      data.addAll(salt);

      final block = md5.convert(data).bytes;
      result.addAll(block);
      prevBlock = Uint8List.fromList(block);
    }

    final key = Uint8List.fromList(result.sublist(0, 32));
    final iv = Uint8List.fromList(result.sublist(32, 48));

    return (key, iv);
  }
}
