/// 购买流程错误处理器
library;

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/features/payment/models/error_recovery.dart';

/// 购买流程错误处理器
class PurchaseErrorHandler {
  PurchaseErrorHandler._();

  /// 处理错误并返回恢复策略
  static ErrorRecovery handle(Object error) {
    // 处理 DioException
    if (error is DioException) {
      return _handleDioError(error);
    }

    // 处理 SocketException
    if (error is SocketException) {
      return ErrorRecovery.networkError();
    }

    // 处理 TimeoutException
    if (error is TimeoutException) {
      return ErrorRecovery.timeoutError();
    }

    // 处理 XBoardException
    if (error is XBoardException) {
      return _handleXBoardError(error);
    }

    // 默认错误
    return ErrorRecovery.genericError(
      message: ErrorSanitizer.sanitize(error.toString()),
    );
  }

  static ErrorRecovery _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ErrorRecovery.timeoutError();

      case DioExceptionType.connectionError:
        return ErrorRecovery.networkError();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return ErrorRecovery.authError();
        }
        if (statusCode == 429) {
          return ErrorRecovery(
            message: '请求过于频繁，请稍后重试',
            action: ErrorAction.retry,
            icon: Icons.hourglass_empty,
          );
        }
        return ErrorRecovery.serverError();

      case DioExceptionType.cancel:
        return ErrorRecovery(
          message: '请求已取消',
          action: ErrorAction.dismiss,
          icon: Icons.cancel_outlined,
        );

      default:
        return ErrorRecovery.networkError();
    }
  }

  static ErrorRecovery _handleXBoardError(XBoardException error) {
    final code = error.code.toUpperCase();

    // 支付相关错误
    if (code.contains('PAYMENT') || code.contains('PAY')) {
      return ErrorRecovery(
        message: error.message,
        action: ErrorAction.retry,
        icon: Icons.payment_outlined,
      );
    }

    // 优惠券相关错误
    if (code.contains('COUPON')) {
      return ErrorRecovery.couponError(message: error.message);
    }

    // 订单相关错误
    if (code.contains('ORDER')) {
      return ErrorRecovery.orderError(message: error.message);
    }

    // 余额不足
    if (code.contains('BALANCE') || code.contains('INSUFFICIENT')) {
      return ErrorRecovery(
        message: '余额不足',
        action: ErrorAction.dismiss,
        icon: Icons.account_balance_wallet_outlined,
      );
    }

    // 默认
    return ErrorRecovery.genericError(message: error.message);
  }
}