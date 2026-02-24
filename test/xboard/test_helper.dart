/// XBoard 测试辅助工具
///
/// 提供测试通用 Mock 和工具函数
library;

import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/infrastructure/storage/storage_interface.dart';

/// Mock 存储实现
class MockStorage implements StorageInterface {
  final Map<String, dynamic> _data = {};

  @override
  Future<Result<String?>> getString(String key) async {
    return Result.success(_data[key] as String?);
  }

  @override
  Future<Result<bool>> setString(String key, String value) async {
    _data[key] = value;
    return Result.success(true);
  }

  @override
  Future<Result<bool>> remove(String key) async {
    _data.remove(key);
    return Result.success(true);
  }

  @override
  Future<Result<bool>> clear() async {
    _data.clear();
    return Result.success(true);
  }

  @override
  Future<Result<bool>> containsKey(String key) async {
    return Result.success(_data.containsKey(key));
  }

  @override
  Future<Result<Set<String>>> getKeys() async {
    return Result.success(_data.keys.toSet());
  }

  // 其他方法的空实现
  @override
  Future<Result<int?>> getInt(String key) async => Result.success(_data[key] as int?);

  @override
  Future<Result<bool>> setInt(String key, int value) async {
    _data[key] = value;
    return Result.success(true);
  }

  @override
  Future<Result<bool?>> getBool(String key) async => Result.success(_data[key] as bool?);

  @override
  Future<Result<bool>> setBool(String key, bool value) async {
    _data[key] = value;
    return Result.success(true);
  }

  @override
  Future<Result<double?>> getDouble(String key) async => Result.success(_data[key] as double?);

  @override
  Future<Result<bool>> setDouble(String key, double value) async {
    _data[key] = value;
    return Result.success(true);
  }

  @override
  Future<Result<List<String>?>> getStringList(String key) async => Result.success(_data[key] as List<String>?);

  @override
  Future<Result<bool>> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return Result.success(true);
  }
}

/// 测试数据工厂
class TestDataFactory {
  static DomainUser createTestUser({
    String email = 'test@example.com',
    int planId = 1,
    DateTime? expiredAt,
  }) {
    return DomainUser(
      email: email,
      uuid: 'test-uuid-123',
      avatarUrl: 'https://example.com/avatar.png',
      planId: planId,
      transferLimit: 107374182400,
      uploadedBytes: 0,
      downloadedBytes: 0,
      balanceInCents: 10000,
      commissionBalanceInCents: 0,
      createdAt: DateTime.now(),
      expiredAt: expiredAt ?? DateTime.now().add(const Duration(days: 30)),
    );
  }

  static DomainSubscription createTestSubscription({
    int planId = 1,
    String? planName,
    int transferLimit = 107374182400,
    int uploadedBytes = 0,
    int downloadedBytes = 0,
    DateTime? expiredAt,
  }) {
    return DomainSubscription(
      subscribeUrl: 'https://example.com/sub/123',
      email: 'test@example.com',
      uuid: 'test-uuid-123',
      planId: planId,
      planName: planName ?? 'Pro Plan',
      transferLimit: transferLimit,
      uploadedBytes: uploadedBytes,
      downloadedBytes: downloadedBytes,
      expiredAt: expiredAt ?? DateTime.now().add(const Duration(days: 30)),
      nextResetAt: DateTime.now().add(const Duration(days: 30)),
    );
  }

  static DomainPlan createTestPlan({
    int id = 1,
    String name = 'Pro Plan',
    double price = 100.0,
    double? discountPrice,
  }) {
    return DomainPlan(
      id: id,
      groupId: 1,
      transferQuota: 107374182400,
      name: name,
      monthlyPrice: discountPrice ?? price,
    );
  }
}
