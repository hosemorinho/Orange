/// XBoard Storage Service Provider
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/infrastructure/infrastructure.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/database/database.dart';
import 'xboard_storage_service.dart';
import 'xboard_db_storage_service.dart';

/// Storage 接口 FutureProvider
/// 提供默认的 SharedPreferences 实现
/// 如需自定义实现，可在应用初始化时使用ProviderScope.overrides覆盖此provider
final storageProvider = FutureProvider<StorageInterface>((ref) async {
  return await SharedPrefsStorage.create();
});

/// 存储就绪状态 Provider
///
/// - loading: 存储正在初始化
/// - ready: 存储可用
/// - failed: 存储初始化失败
final storageStateProvider = Provider<StorageState>((ref) {
  final storageAsync = ref.watch(storageProvider);
  return storageAsync.when(
    data: (_) => StorageState.ready,
    loading: () => StorageState.loading,
    error: (_, __) => StorageState.failed,
  );
});

/// XBoard Storage Service Provider
final storageServiceProvider = Provider<XBoardStorageService>((ref) {
  final storageAsync = ref.watch(storageProvider);
  // 读取操作使用 Placeholder 避免崩溃，写入操作会检测并报告失败
  final storage = storageAsync.maybeWhen(
    data: (storage) => storage,
    orElse: () => _PlaceholderStorage(),
  );
  return XBoardStorageService(storage);
});

enum StorageState { loading, ready, failed }

/// 占位符存储实现，用于存储未初始化时的临时使用
///
/// 策略：
/// - 读取操作：返回空值（避免崩溃）
/// - 写入操作：记录警告并返回失败（可感知）
class _PlaceholderStorage implements StorageInterface {
  final _logger = FileLogger('_PlaceholderStorage');

  @override
  Future<Result<String?>> getString(String key) async => Result.success(null);

  @override
  Future<Result<bool>> setString(String key, String value) async {
    _logger.warn('存储未就绪，无法写入: $key');
    return Result.success(false);
  }

  @override
  Future<Result<int?>> getInt(String key) async => Result.success(null);

  @override
  Future<Result<bool>> setInt(String key, int value) async {
    _logger.warn('存储未就绪，无法写入: $key');
    return Result.success(false);
  }

  @override
  Future<Result<bool?>> getBool(String key) async => Result.success(null);

  @override
  Future<Result<bool>> setBool(String key, bool value) async {
    _logger.warn('存储未就绪，无法写入: $key');
    return Result.success(false);
  }

  @override
  Future<Result<double?>> getDouble(String key) async => Result.success(null);

  @override
  Future<Result<bool>> setDouble(String key, double value) async {
    _logger.warn('存储未就绪，无法写入: $key');
    return Result.success(false);
  }

  @override
  Future<Result<List<String>?>> getStringList(String key) async => Result.success(null);

  @override
  Future<Result<bool>> setStringList(String key, List<String> value) async {
    _logger.warn('存储未就绪，无法写入: $key');
    return Result.success(false);
  }

  @override
  Future<Result<bool>> remove(String key) async {
    _logger.warn('存储未就绪，无法删除: $key');
    return Result.success(false);
  }

  @override
  Future<Result<bool>> clear() async {
    _logger.warn('存储未就绪，无法清空');
    return Result.success(false);
  }

  @override
  Future<Result<bool>> containsKey(String key) async => Result.success(false);

  @override
  Future<Result<Set<String>>> getKeys() async => Result.success({});
}

/// XBoard 数据库存储服务 Provider
///
/// 使用 Drift 数据库的存储服务
final dbStorageServiceProvider = Provider<XBoardDbStorageService>((ref) {
  return XBoardDbStorageService(
    userRepo: ref.watch(userRepositoryProvider),
    subscriptionRepo: ref.watch(subscriptionRepositoryProvider),
    authRepo: ref.watch(authRepositoryProvider),
    noticeRepo: ref.watch(noticeRepositoryProvider),
  );
});
