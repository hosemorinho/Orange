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
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final db = ref.watch(xboardDatabaseProvider);
  return UserRepository(db);
});

/// 订阅仓库 Provider
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final db = ref.watch(xboardDatabaseProvider);
  return SubscriptionRepository(db);
});

/// 套餐仓库 Provider
final planRepositoryProvider = Provider<PlanRepository>((ref) {
  final db = ref.watch(xboardDatabaseProvider);
  return PlanRepository(db);
});

/// 订单仓库 Provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final db = ref.watch(xboardDatabaseProvider);
  return OrderRepository(db);
});

/// 认证仓库 Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final db = ref.watch(xboardDatabaseProvider);
  return AuthRepository(db);
});

/// 公告仓库 Provider
final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  final db = ref.watch(xboardDatabaseProvider);
  return NoticeRepository(db);
});

/// 域名仓库 Provider
final domainRepositoryProvider = Provider<DomainRepository>((ref) {
  final db = ref.watch(xboardDatabaseProvider);
  return DomainRepository(db);
});
