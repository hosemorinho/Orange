/// 磁盘日志实现
///
/// 将日志写入文件，同时输出到控制台。
/// Windows release 构建没有控制台，此实现确保日志可被追溯。
library;

import 'dart:io';

import 'logger_interface.dart';
import 'console_logger.dart';

/// 磁盘日志实现
///
/// 日志文件位于应用数据目录下的 `xboard.log`。
/// 每次启动会清空旧日志，避免文件无限增长。
class DiskLogger implements LoggerInterface {
  final ConsoleLogger _console = ConsoleLogger();
  late final File _file;
  bool _ready = false;

  @override
  LogLevel minLevel = LogLevel.debug;

  DiskLogger._();

  static DiskLogger? _instance;

  /// 初始化磁盘日志
  ///
  /// [logDir] 日志文件所在目录的路径
  static Future<DiskLogger> init(String logDir) async {
    if (_instance != null && _instance!._ready) return _instance!;
    final logger = DiskLogger._();
    logger._file = File('$logDir${Platform.pathSeparator}xboard.log');
    try {
      // 确保目录存在
      await logger._file.parent.create(recursive: true);
      // 每次启动清空旧日志
      await logger._file.writeAsString(
        '=== ${DateTime.now().toIso8601String()} ===\n',
        mode: FileMode.write,
      );
      logger._ready = true;
    } catch (e) {
      // 写文件失败时退化为纯控制台，但打印错误方便排查
      // ignore: avoid_print
      print('[DiskLogger] init failed: $e (path: ${logger._file.path})');
    }
    _instance = logger;
    return logger;
  }

  void _write(String line) {
    if (!_ready) return;
    try {
      _file.writeAsStringSync('$line\n', mode: FileMode.append, flush: true);
    } catch (_) {}
  }

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _console.debug(message, error, stackTrace);
    if (minLevel.index <= LogLevel.debug.index) {
      _write('[${_ts()}][DEBUG] $message${_err(error)}');
    }
  }

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _console.info(message, error, stackTrace);
    if (minLevel.index <= LogLevel.info.index) {
      _write('[${_ts()}][INFO] $message${_err(error)}');
    }
  }

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _console.warning(message, error, stackTrace);
    if (minLevel.index <= LogLevel.warning.index) {
      _write('[${_ts()}][WARN] $message${_err(error)}');
    }
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _console.error(message, error, stackTrace);
    if (minLevel.index <= LogLevel.error.index) {
      final buf = StringBuffer('[${_ts()}][ERROR] $message');
      if (error != null) buf.write('\n  Error: $error');
      if (stackTrace != null) buf.write('\n  StackTrace:\n$stackTrace');
      _write(buf.toString());
    }
  }

  String _ts() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}:'
        '${n.minute.toString().padLeft(2, '0')}:'
        '${n.second.toString().padLeft(2, '0')}';
  }

  String _err(Object? error) => error != null ? ' | $error' : '';
}
