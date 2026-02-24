/// XBoard 核心功能测试
///
/// 测试范围：
/// - Result 类型
/// - 用户信息序列化
/// - 订阅信息序列化
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import '../xboard/test_helper.dart';

void main() {
  group('XBoard 核心功能', () {
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

      test('应能正确计算剩余流量百分比', () {
        // Arrange
        final subscription = TestDataFactory.createTestSubscription(
          transferLimit: 100,
          uploadedBytes: 20,
          downloadedBytes: 30,
        );

        // Act
        final used = subscription.uploadedBytes + subscription.downloadedBytes;
        final remaining = subscription.transferLimit - used;
        final percentage = remaining / subscription.transferLimit;

        // Assert
        expect(used, equals(50));
        expect(remaining, equals(50));
        expect(percentage, equals(0.5));
      });
    });

    group('订阅信息序列化', () {
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

      test('map 方法应能转换成功值', () {
        // Arrange
        final result = Result<int>.success(42);

        // Act
        final mapped = result.map((data) => data * 2);

        // Assert
        expect(mapped.dataOrNull, equals(84));
      });

      test('map 方法应保持失败状态', () {
        // Arrange
        final error = XBoardException(
          code: 'TEST_ERROR',
          message: 'test error',
        );
        final result = Result<int>.failure(error);

        // Act
        final mapped = result.map((data) => data * 2);

        // Assert
        expect(mapped.isSuccess, isFalse);
        expect(mapped.exceptionOrNull, equals(error));
      });
    });

    group('XBoardException', () {
      test('应能正确创建异常', () {
        // Arrange & Act
        final exception = XBoardException(
          code: 'TEST_ERROR',
          message: 'test error message',
        );

        // Assert
        expect(exception.code, equals('TEST_ERROR'));
        expect(exception.message, equals('test error message'));
      });

      test('应能正确判断错误类型', () {
        // Arrange & Act
        final networkException = XBoardNetworkException(
          code: 'NETWORK_ERROR',
          message: 'network failed',
          url: 'https://example.com',
        );

        // Assert
        expect(networkException, isA<XBoardException>());
        expect(networkException is XBoardAuthException, isFalse);
      });
    });
  });
}
