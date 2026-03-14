/// 带重试的异步操作处理器
library;

import 'dart:async';
import 'dart:math';

import 'package:fl_clash/xboard/core/core.dart';

/// 重试配置
class RetryConfig {
  /// 最大重试次数
  final int maxRetries;

  /// 初始延迟
  final Duration initialDelay;

  /// 最大延迟
  final Duration maxDelay;

  /// 延迟倍数（指数退避）
  final double backoffMultiplier;

  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
  });

  /// 默认配置
  static const RetryConfig defaultConfig = RetryConfig();

  /// 网络请求推荐配置
  static const RetryConfig networkConfig = RetryConfig(
    maxRetries: 3,
    initialDelay: Duration(seconds: 2),
    maxDelay: Duration(seconds: 60),
  );
}

/// 带重试的异步操作处理器
class RetryableOperation<T> {
  final Future<T> Function() operation;
  final RetryConfig config;
  final bool Function(Exception)? shouldRetry;
  final void Function(int attempt, Exception error)? onRetry;

  final _logger = FileLogger('RetryableOperation');
  final _random = Random();

  RetryableOperation({
    required this.operation,
    this.config = RetryConfig.defaultConfig,
    this.shouldRetry,
    this.onRetry,
  });

  /// 执行操作（带指数退避重试）
  Future<T> execute() async {
    int attempts = 0;
    Duration currentDelay = config.initialDelay;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempts++;

        // 检查是否达到最大重试次数
        if (attempts >= config.maxRetries) {
          _logger.warning('[Retry] 达到最大重试次数: ');
          rethrow;
        }

        // 检查是否应该重试
        if (e is Exception) {
          if (shouldRetry != null && !shouldRetry!(e)) {
            _logger.info('[Retry] 错误不可重试: ');
            rethrow;
          }
        } else {
          rethrow;
        }

        // 计算延迟（带抖动）
        final jitter = _random.nextDouble() * 0.3 + 0.85;
        final delay = Duration(
          milliseconds: (currentDelay.inMilliseconds * jitter).round(),
        );

        _logger.info(
          '[Retry] 第  次重试，等待 ms',
        );

        // 回调
        if (onRetry != null && e is Exception) {
          onRetry!(attempts, e);
        }

        // 等待
        await Future.delayed(delay);

        // 更新延迟（指数退避）
        currentDelay = Duration(
          milliseconds: (currentDelay.inMilliseconds * config.backoffMultiplier)
              .clamp(0, config.maxDelay.inMilliseconds)
              .round(),
        );
      }
    }
  }

  /// 静态方法：执行带重试的操作
  static Future<T> run<T>(
    Future<T> Function() operation, {
    RetryConfig config = RetryConfig.defaultConfig,
    bool Function(Exception)? shouldRetry,
    void Function(int attempt, Exception error)? onRetry,
  }) {
    return RetryableOperation<T>(
      operation: operation,
      config: config,
      shouldRetry: shouldRetry,
      onRetry: onRetry,
    ).execute();
  }
}