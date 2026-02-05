import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../xboard_database.dart';
import '../repositories/repositories.dart';

/// XBoard 数据库 Provider
///
/// 提供全局数据库实例
final xboardDatabaseProvider = Provider<XBoardDatabase>((ref) {
  return xboardDatabase;
});

/// 用户仓库 Provider
final userRepositoryProvider = Provider<DbUserRepository>((ref) {
  final db = ref.watch(xboardDatabaseProvider);
  return DbUserRepository(db);
});

/// 订阅仓库 Provider
final subscriptionRepositoryProvider = Provider<DbSubscriptionRepository>((ref) {
  final db = ref.watch(xboardDatabaseProvider);
  return DbSubscriptionRepository(db);
});

/// 套餐仓库 Provider
final planRepositoryProvider = Provider<DbPlanRepository>((ref) {
  final db = ref.watch(xboardDatabaseProvider);
  return DbPlanRepository(db);
});

/// 订单仓库 Provider
final orderRepositoryProvider = Provider<DbOrderRepository>((ref) {
  final db = ref.watch(xboardDatabaseProvider);
  return DbOrderRepository(db);
});

/// 认证仓库 Provider
final authRepositoryProvider = Provider<DbAuthRepository>((ref) {
  final db = ref.watch(xboardDatabaseProvider);
  return DbAuthRepository(db);
});

/// 公告仓库 Provider
final noticeRepositoryProvider = Provider<DbNoticeRepository>((ref) {
  final db = ref.watch(xboardDatabaseProvider);
  return DbNoticeRepository(db);
});

/// 域名仓库 Provider
final domainRepositoryProvider = Provider<DbDomainRepository>((ref) {
  final db = ref.watch(xboardDatabaseProvider);
  return DbDomainRepository(db);
});
