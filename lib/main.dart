import 'dart:async';
import 'dart:io';

import 'package:fl_clash/pages/error.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/xboard/config/xboard_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'application.dart';
import 'common/common.dart';
import 'xboard/core/core.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // 启用磁盘日志
    try {
      String logDir;
      if (system.isDesktop) {
        logDir = await appPath.homeDirPath;
      } else {
        // Android: 写到外部应用目录，文件管理器可见
        // /sdcard/Android/data/包名/files/xboard.log
        final extDir = await getExternalStorageDirectory();
        logDir = extDir?.path ?? await appPath.homeDirPath;
      }
      final diskLogger = await DiskLogger.init(logDir);
      if (kReleaseMode) {
        diskLogger.minLevel = LogLevel.info;
      }
      XBoardLogger.setLogger(diskLogger);
      debugPrint('[Main] 磁盘日志已启用: $logDir/xboard.log');
    } catch (e) {
      debugPrint('[Main] 磁盘日志初始化失败: $e');
    }

    // TV 检测
    await system.initTVDetection();

    // 初始化XBoard配置模块
    await _initializeXBoardServices();

    final version = await system.version;
    final container = await globalState.init(version);
    HttpOverrides.global = FlClashHttpOverrides();
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const Application(),
      ),
    );
  } catch (e, s) {
    return runApp(
      MaterialApp(
        home: InitErrorScreen(error: e, stack: s),
      ),
    );
  }
}

/// 初始化XBoard配置模块
Future<void> _initializeXBoardServices() async {
  try {
    debugPrint('[Main] 开始初始化XBoard配置模块...');

    await XBoardConfig.initialize();
    debugPrint('[Main] XBoard配置模块初始化成功');

    // V2Board API 初始化已移至 xboardSdkProvider，由 Riverpod 统一管理
    debugPrint('[Main] V2Board API 将在应用启动后由 xboardSdkProvider 初始化');
  } catch (e) {
    debugPrint('[Main] XBoard服务初始化失败: $e');
    rethrow;
  }
}
