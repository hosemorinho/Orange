import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/xboard/core/logger/logger.dart' as xlog;
import 'package:flutter/material.dart';

class CommonPrint {
  static CommonPrint? _instance;

  CommonPrint._internal();

  factory CommonPrint() {
    _instance ??= CommonPrint._internal();
    return _instance!;
  }

  void log(String? text, {LogLevel logLevel = LogLevel.info}) {
    final payload = '[APP] $text';
    debugPrint(payload);
    // 同时写入 xboard.log
    _writeToXBoardLog(payload, logLevel);
    if (!appController.isAttach) {
      return;
    }
    appController.addLog(Log.app(payload).copyWith(logLevel: logLevel));
  }

  void _writeToXBoardLog(String message, LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        xlog.XBoardLogger.debug(message);
      case LogLevel.info:
        xlog.XBoardLogger.info(message);
      case LogLevel.warning:
        xlog.XBoardLogger.warning(message);
      case LogLevel.error:
        xlog.XBoardLogger.error(message);
      case LogLevel.silent:
        break;
    }
  }
}

final commonPrint = CommonPrint();
