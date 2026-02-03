import 'dart:async';
import 'dart:io';

import 'package:fl_clash/pages/error.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/xboard/config/xboard_config.dart';
import 'package:fl_clash/xboard/config/utils/config_file_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application.dart';
import 'common/common.dart';
import 'xboard/core/core.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // 桌面平台启用磁盘日志（Windows release 无控制台）
    if (system.isDesktop) {
      try {
        final logDir = await appPath.homeDirPath;
        final diskLogger = await DiskLogger.init(logDir);
        XBoardLogger.setLogger(diskLogger);
        debugPrint('[Main] 磁盘日志已启用: $logDir/xboard.log');
      } catch (e) {
        debugPrint('[Main] 磁盘日志初始化失败: $e');
      }
    }

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

    // 从配置文件加载配置
    final configSettings = await ConfigFileLoader.loadFromFile();
    debugPrint('[Main] 配置文件加载成功，Provider: ${configSettings.currentProvider}');

    // 初始化配置模块
    await XBoardConfig.initialize(settings: configSettings);
    debugPrint('[Main] XBoard配置模块初始化成功');

    // V2Board API 初始化已移至 xboardSdkProvider，由 Riverpod 统一管理
    debugPrint('[Main] V2Board API 将在应用启动后由 xboardSdkProvider 初始化');
  } catch (e) {
    debugPrint('[Main] XBoard服务初始化失败: $e');
    rethrow;
  }
}
