/// XBoard 认证功能测试
///
/// 测试范围：
/// - Token 管理
/// - 认证状态判断
/// - 用户信息存储
// ignore_for_file: depend_on_referenced_packages
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/infrastructure/api/v2board_token_storage.dart';
import '../xboard/test_helper.dart';
import 'fakes/fake_path_provider_platform.dart';

void main() {
  // 初始化 Flutter 测试绑定
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();

  group('XBoard 认证功能', () {
    setUp(() async {
      // 每个测试前清理状态
      await V2BoardTokenStorage.clearAuth();
    });

    group('Token 存储', () {
      test('应能成功保存和读取 token', () async {
        // Arrange
        const testToken = 'test_auth_token_12345';
        const testEmail = 'test@example.com';

        // Act
        await V2BoardTokenStorage.saveToken(testToken, email: testEmail);
        final hasToken = await V2BoardTokenStorage.hasToken();

        // Assert
        expect(hasToken, isTrue);
      });

      test('应能正确清除 token', () async {
        // Arrange
        await V2BoardTokenStorage.saveToken(
          'test_token',
          email: 'test@example.com',
        );

        // Act
        await V2BoardTokenStorage.clearAuth();
        final hasToken = await V2BoardTokenStorage.hasToken();

        // Assert
        expect(hasToken, isFalse);
      });
    });

    group('认证状态判断', () {
      test('无 token 时应返回未认证', () async {
        // Arrange
        await V2BoardTokenStorage.clearAuth();

        // Act
        final hasToken = await V2BoardTokenStorage.hasToken();

        // Assert
        expect(hasToken, isFalse);
      });

      test('有 token 时应返回已认证', () async {
        // Arrange
        await V2BoardTokenStorage.saveToken(
          'valid_token',
          email: 'test@example.com',
        );

        // Act
        final hasToken = await V2BoardTokenStorage.hasToken();

        // Assert
        expect(hasToken, isTrue);
      });
    });

    group('用户信息序列化', () {
      test('应能正确序列化和反序列化用户信息', () {
        // Arrange
        final testUser = TestDataFactory.createTestUser();

        // Act
        final userMap = testUser.toJson();
        final loadedUser = DomainUser.fromJson(userMap);

        // Assert
        expect(loadedUser.email, equals(testUser.email));
        expect(loadedUser.planId, equals(testUser.planId));
        expect(loadedUser.balanceInCents, equals(testUser.balanceInCents));
      });

      test('应能正确序列化和反序列化订阅信息', () {
        // Arrange
        final testSub = TestDataFactory.createTestSubscription();

        // Act
        final subMap = testSub.toJson();
        final loadedSub = DomainSubscription.fromJson(subMap);

        // Assert
        expect(loadedSub.email, equals(testSub.email));
        expect(loadedSub.planId, equals(testSub.planId));
        expect(loadedSub.transferLimit, equals(testSub.transferLimit));
      });
    });

    group('Result 类型', () {
      test('Success 应能正确携带数据', () {
        // Arrange & Act
        final result = Result<String>.success('test data');

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals('test data'));
      });

      test('Failure 应能正确携带错误', () {
        // Arrange & Act
        final error = XBoardException(
          code: 'TEST_ERROR',
          message: 'test error',
        );
        final result = Result<String>.failure(error);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.exceptionOrNull, equals(error));
      });

      test('when 方法应正确分支', () {
        // Arrange
        final success = Result<int>.success(42);
        final failure = Result<int>.failure(
          XBoardException(code: 'TEST_ERROR', message: 'error'),
        );

        // Act & Assert
        var capturedValue = 0;
        var capturedError = '';

        success.when(
          success: (data) => capturedValue = data,
          failure: (_) => capturedError = 'should not happen',
        );

        expect(capturedValue, 42);

        failure.when(
          success: (_) => capturedValue = -1,
          failure: (e) => capturedError = e.message,
        );

        expect(capturedError, 'error');
      });
    });
  });
}
