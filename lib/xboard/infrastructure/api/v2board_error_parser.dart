/// V2Board 错误解析器
///
/// 解析 V2Board 后端返回的错误信息，将消息映射到具体的错误类型
library;

import 'package:fl_clash/l10n/l10n.dart';

/// V2Board 错误类型
enum V2BoardErrorType {
  /// 认证失败（邮箱或密码错误）
  invalidCredentials,

  /// 账号被封禁
  accountSuspended,

  /// 密码错误次数过多
  passwordLimitExceeded,

  /// 表单验证失败（422）
  validationError,

  /// Token 无效或过期（403）
  tokenInvalid,

  /// 频率限制
  rateLimitExceeded,

  /// 邀请码相关错误
  inviteCodeRequired,

  /// 邮箱验证码相关
  emailCodeRequired,

  /// IP 注册限制
  registerLimitExceeded,

  /// 未知错误
  unknown,
}

/// V2Board 错误信息（用于 i18n）
class V2BoardErrorMessage {
  static const String invalidCredentials = '邮箱或密码错误';
  static const String accountSuspended = '账号已被封禁，请联系客服';
  static const String passwordLimitExceeded = '密码错误次数过多，请稍后再试';
  static const String validationError = '输入信息格式不正确';
  static const String tokenInvalid = '登录已过期，请重新登录';
  static const String rateLimitExceeded = '操作过于频繁，请稍后再试';
  static const String inviteCodeRequired = '必须使用邀请码注册';
  static const String emailCodeRequired = '请输入邮箱验证码';
  static const String registerLimitExceeded = '注册频繁，请稍后再试';
  static const String unknown = '操作失败，请稍后重试';
}

/// V2Board 错误解析器
class V2BoardErrorParser {
  /// 从响应体和状态码解析错误类型
  static V2BoardErrorType parseError({
    required int? statusCode,
    Map<String, dynamic>? responseData,
  }) {
    final message = responseData?['message']?.toString().toLowerCase() ?? '';

    // 403: Token 无效
    if (statusCode == 403) {
      return V2BoardErrorType.tokenInvalid;
    }

    // 422: 表单验证失败
    if (statusCode == 422) {
      return V2BoardErrorType.validationError;
    }

    // 500: 业务逻辑错误 - 通过 message 区分
    if (statusCode == 500) {
      // 账号或密码错误
      if (message.contains('incorrect email or password') ||
          message.contains('email or password') ||
          message.contains('邮箱或密码')) {
        return V2BoardErrorType.invalidCredentials;
      }

      // 账号被封禁
      if (message.contains('suspended') || message.contains('封禁')) {
        return V2BoardErrorType.accountSuspended;
      }

      // 密码错误次数过多
      if ((message.contains('password') && message.contains('too many')) ||
          message.contains('password errors') ||
          message.contains('too many password') ||
          (message.contains('频繁') && message.contains('密码')) ||
          message.contains('password limit')) {
        return V2BoardErrorType.passwordLimitExceeded;
      }

      // IP 注册限制
      if ((message.contains('register') && message.contains('frequent')) ||
          (message.contains('register') && message.contains('too many')) ||
          message.contains('register frequently') ||
          message.contains('注册频繁')) {
        return V2BoardErrorType.registerLimitExceeded;
      }

      // 邀请码相关
      if (message.contains('invitation') || message.contains('invite')) {
        return V2BoardErrorType.inviteCodeRequired;
      }

      // 邮箱验证码
      if (message.contains('email code') || message.contains('邮箱验证码')) {
        return V2BoardErrorType.emailCodeRequired;
      }

      // 频率限制
      if ((message.contains('too many') && message.contains('request')) ||
          (message.contains('too many') && message.contains('send')) ||
          message.contains('too many requests') ||
          message.contains('sending frequently') ||
          message.contains('operation too frequently') ||
          message.contains('操作过于频繁')) {
        return V2BoardErrorType.rateLimitExceeded;
      }

      // 对 500 默认按未知错误处理，避免误归类为认证失败
      return V2BoardErrorType.unknown;
    }

    return V2BoardErrorType.unknown;
  }

  /// 获取用户友好的错误消息
  static String getErrorMessage(
    V2BoardErrorType errorType,
    String? originalMessage, {
    AppLocalizations? l10n,
  }) {
    // 优先使用原始消息（如果服务器返回了具体的错误信息）
    if (originalMessage != null && originalMessage.isNotEmpty) {
      // 中文错误消息可以直接使用
      if (!_isEnglishError(originalMessage)) {
        return originalMessage;
      }
    }

    // 根据 i18n 或默认中文消息返回
    switch (errorType) {
      case V2BoardErrorType.invalidCredentials:
        return V2BoardErrorMessage.invalidCredentials;
      case V2BoardErrorType.accountSuspended:
        return V2BoardErrorMessage.accountSuspended;
      case V2BoardErrorType.passwordLimitExceeded:
        return V2BoardErrorMessage.passwordLimitExceeded;
      case V2BoardErrorType.validationError:
        return V2BoardErrorMessage.validationError;
      case V2BoardErrorType.tokenInvalid:
        return V2BoardErrorMessage.tokenInvalid;
      case V2BoardErrorType.rateLimitExceeded:
        return V2BoardErrorMessage.rateLimitExceeded;
      case V2BoardErrorType.inviteCodeRequired:
        return V2BoardErrorMessage.inviteCodeRequired;
      case V2BoardErrorType.emailCodeRequired:
        return V2BoardErrorMessage.emailCodeRequired;
      case V2BoardErrorType.registerLimitExceeded:
        return V2BoardErrorMessage.registerLimitExceeded;
      case V2BoardErrorType.unknown:
        return originalMessage ?? V2BoardErrorMessage.unknown;
    }
  }

  /// 判断是否为英文错误消息
  static bool _isEnglishError(String message) {
    // 简单的英文检测：不含中文字符
    return !RegExp(r'[\u4e00-\u9fff]').hasMatch(message);
  }

  /// 是否应该重试（基于错误类型）
  static bool shouldRetry(V2BoardErrorType errorType) {
    switch (errorType) {
      case V2BoardErrorType.validationError:
      case V2BoardErrorType.invalidCredentials:
      case V2BoardErrorType.accountSuspended:
      case V2BoardErrorType.inviteCodeRequired:
      case V2BoardErrorType.emailCodeRequired:
        return false; // 业务错误，不应重试
      case V2BoardErrorType.rateLimitExceeded:
        return true; // 频率限制，应延迟重试
      case V2BoardErrorType.passwordLimitExceeded:
      case V2BoardErrorType.registerLimitExceeded:
        return false; // 鉴权场景业务限制，不应触发域名切换
      case V2BoardErrorType.unknown:
      case V2BoardErrorType.tokenInvalid:
        return false;
    }
  }
}
