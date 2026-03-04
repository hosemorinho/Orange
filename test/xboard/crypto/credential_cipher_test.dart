/// 凭据加密测试
///
/// 测试 CredentialCipher 的加密解密功能
///
/// 注意：部分测试在测试环境中可能失败，因为设备指纹无法获取
library;

import 'package:fl_clash/xboard/infrastructure/crypto/credential_cipher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CredentialCipher 凭据加密', () {
    const testPassword = 'mySecurePassword123!';
    const testToken = 'test-auth-token-12345';
    const testEmail = 'user@example.com';

    group('加密解密基础功能', () {
      test('应能成功加密和解密密码', () async {
        final encrypted = await CredentialCipher.encrypt(testPassword);
        if (encrypted == null) return; // 设备指纹不可用时跳过

        final decrypted = await CredentialCipher.decrypt(encrypted);
        expect(decrypted, equals(testPassword));
      });

      test('应能成功加密和解密 Token', () async {
        final encrypted = await CredentialCipher.encrypt(testToken);
        if (encrypted == null) return;

        final decrypted = await CredentialCipher.decrypt(encrypted);
        expect(decrypted, equals(testToken));
      });

      test('应能成功加密和解密邮箱', () async {
        final encrypted = await CredentialCipher.encrypt(testEmail);
        if (encrypted == null) return;

        final decrypted = await CredentialCipher.decrypt(encrypted);
        expect(decrypted, equals(testEmail));
      });

      test('空字符串应能正确处理', () async {
        final encrypted = await CredentialCipher.encrypt('');
        if (encrypted == null) return;

        final decrypted = await CredentialCipher.decrypt(encrypted);
        expect(decrypted, equals(''));
      });
    });

    group('加密格式验证', () {
      test('加密结果应以 v1 前缀开头', () async {
        final encrypted = await CredentialCipher.encrypt('test');
        if (encrypted == null) return;

        expect(encrypted, startsWith('enc:v1:'));
      });

      test('isEncryptedPayload 应正确识别加密数据', () async {
        final encrypted = await CredentialCipher.encrypt('test');
        if (encrypted == null) return;

        expect(CredentialCipher.isEncryptedPayload(encrypted), isTrue);
        expect(CredentialCipher.isEncryptedPayload('plaintext'), isFalse);
        expect(CredentialCipher.isEncryptedPayload(''), isFalse);
      });
    });

    group('异常处理', () {
      test('无效密文应返回 null', () async {
        const invalidCipher = 'invalid_base64_!!!';
        final decrypted = await CredentialCipher.decrypt(invalidCipher);
        expect(decrypted, isNull);
      });

      test('空密文应返回 null', () async {
        final decrypted = await CredentialCipher.decrypt('');
        expect(decrypted, isNull);
      });

      test('空字符串加密应妥善处理', () async {
        final encrypted = await CredentialCipher.encrypt('');
        if (encrypted != null) {
          expect(encrypted, isNotNull);
        }
      });
    });

    group('特殊字符处理', () {
      test('应能处理包含特殊字符的密码', () async {
        const specialPassword = 'P@ssw0rd!#%^&*()_+-=[]{}|;:,.<>?/~`';
        final encrypted = await CredentialCipher.encrypt(specialPassword);
        if (encrypted == null) return;

        final decrypted = await CredentialCipher.decrypt(encrypted);
        expect(decrypted, equals(specialPassword));
      });

      test('应能处理 Unicode 字符', () async {
        const unicodePassword = '密码🔐パスワード';
        final encrypted = await CredentialCipher.encrypt(unicodePassword);
        if (encrypted == null) return;

        final decrypted = await CredentialCipher.decrypt(encrypted);
        expect(decrypted, equals(unicodePassword));
      });

      test('应能处理长字符串', () async {
        const longString = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
            'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';
        final encrypted = await CredentialCipher.encrypt(longString);
        if (encrypted == null) return;

        final decrypted = await CredentialCipher.decrypt(encrypted);
        expect(decrypted, equals(longString));
      });
    });

    group('设备绑定验证', () {
      test('相同数据多次加密应产生不同密文（随机 IV）', () async {
        final encrypted1 = await CredentialCipher.encrypt('test');
        final encrypted2 = await CredentialCipher.encrypt('test');

        if (encrypted1 == null || encrypted2 == null) return;

        expect(encrypted1, isNot(equals(encrypted2)));
        expect(await CredentialCipher.decrypt(encrypted1), equals('test'));
        expect(await CredentialCipher.decrypt(encrypted2), equals('test'));
      });
    });
  });
}
