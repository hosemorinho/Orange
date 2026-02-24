/// V2Board 错误解析测试
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:fl_clash/xboard/infrastructure/api/v2board_error_parser.dart';

void main() {
  group('V2Board 错误解析', () {
    group('错误类型解析', () {
      test('邮箱或密码错误（500）应识别为 invalidCredentials', () {
        // Arrange
        const responseData = {'message': 'Incorrect email or password'};

        // Act
        final errorType = V2BoardErrorParser.parseError(
          statusCode: 500,
          responseData: responseData,
        );

        // Assert
        expect(errorType, equals(V2BoardErrorType.invalidCredentials));
      });

      test('账号被封禁（500）应识别为 accountSuspended', () {
        // Arrange
        const responseData = {'message': 'Your account has been suspended'};

        // Act
        final errorType = V2BoardErrorParser.parseError(
          statusCode: 500,
          responseData: responseData,
        );

        // Assert
        expect(errorType, equals(V2BoardErrorType.accountSuspended));
      });

      test('密码错误次数过多（500）应识别为 passwordLimitExceeded', () {
        // Arrange
        const responseData = {
          'message':
              'There are too many password errors, please try again after 10 minutes.',
        };

        // Act
        final errorType = V2BoardErrorParser.parseError(
          statusCode: 500,
          responseData: responseData,
        );

        // Assert
        expect(errorType, equals(V2BoardErrorType.passwordLimitExceeded));
      });

      test('表单验证失败（422）应识别为 validationError', () {
        // Arrange
        const responseData = {'message': 'Email format is incorrect'};

        // Act
        final errorType = V2BoardErrorParser.parseError(
          statusCode: 422,
          responseData: responseData,
        );

        // Assert
        expect(errorType, equals(V2BoardErrorType.validationError));
      });

      test('Token 过期（403）应识别为 tokenInvalid', () {
        // Arrange
        final responseData = {'message': '未登录或登陆已过期'};

        // Act
        final errorType = V2BoardErrorParser.parseError(
          statusCode: 403,
          responseData: responseData,
        );

        // Assert
        expect(errorType, equals(V2BoardErrorType.tokenInvalid));
      });

      test('频率限制应识别为 rateLimitExceeded', () {
        // Arrange
        const responseData = {
          'message': 'Operation too frequently, please try again later',
        };

        // Act
        final errorType = V2BoardErrorParser.parseError(
          statusCode: 500,
          responseData: responseData,
        );

        // Assert
        expect(errorType, equals(V2BoardErrorType.rateLimitExceeded));
      });

      test('注册频繁（500）应识别为 registerLimitExceeded', () {
        // Arrange
        const responseData = {
          'message': 'Register frequently, please try again after 60 minute',
        };

        // Act
        final errorType = V2BoardErrorParser.parseError(
          statusCode: 500,
          responseData: responseData,
        );

        // Assert
        expect(errorType, equals(V2BoardErrorType.registerLimitExceeded));
      });

      test('未知 500 错误应识别为 unknown', () {
        // Arrange
        const responseData = {'message': 'Database backend temporary fault'};

        // Act
        final errorType = V2BoardErrorParser.parseError(
          statusCode: 500,
          responseData: responseData,
        );

        // Assert
        expect(errorType, equals(V2BoardErrorType.unknown));
      });
    });

    group('重试策略', () {
      test('invalidCredentials 不应重试', () {
        expect(
          V2BoardErrorParser.shouldRetry(V2BoardErrorType.invalidCredentials),
          isFalse,
        );
      });

      test('accountSuspended 不应重试', () {
        expect(
          V2BoardErrorParser.shouldRetry(V2BoardErrorType.accountSuspended),
          isFalse,
        );
      });

      test('passwordLimitExceeded 不应重试', () {
        expect(
          V2BoardErrorParser.shouldRetry(
            V2BoardErrorType.passwordLimitExceeded,
          ),
          isFalse,
        );
      });

      test('rateLimitExceeded 应重试', () {
        expect(
          V2BoardErrorParser.shouldRetry(V2BoardErrorType.rateLimitExceeded),
          isTrue,
        );
      });

      test('validationError 不应重试', () {
        expect(
          V2BoardErrorParser.shouldRetry(V2BoardErrorType.validationError),
          isFalse,
        );
      });

      test('registerLimitExceeded 不应重试', () {
        expect(
          V2BoardErrorParser.shouldRetry(
            V2BoardErrorType.registerLimitExceeded,
          ),
          isFalse,
        );
      });
    });

    group('错误消息获取', () {
      test('应返回正确的中文错误消息', () {
        // Arrange
        const originalMessage = '邮箱或密码错误';

        // Act
        final message = V2BoardErrorParser.getErrorMessage(
          V2BoardErrorType.invalidCredentials,
          originalMessage,
        );

        // Assert
        expect(message, equals('邮箱或密码错误'));
      });

      test('未知错误应返回默认消息', () {
        // Act
        final message = V2BoardErrorParser.getErrorMessage(
          V2BoardErrorType.unknown,
          null,
        );

        // Assert
        expect(message, equals('操作失败，请稍后重试'));
      });
    });
  });
}
