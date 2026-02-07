import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'database_provider.dart';

/// 当前用户数据流 Provider
///
/// 实时监听用户数据变化
final currentUserStreamProvider = StreamProvider<DomainUser?>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.watchCurrentUser();
});

/// 当前订阅数据流 Provider
///
/// 实时监听订阅数据变化
final currentSubscriptionStreamProvider = StreamProvider<DomainSubscription?>((ref) {
  final subscriptionRepo = ref.watch(subscriptionRepositoryProvider);
  return subscriptionRepo.watchCurrentSubscription();
});

/// 认证状态 Provider
///
/// 检查是否有有效的认证令牌
final hasAuthTokenProvider = FutureProvider<bool>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.hasToken();
});

/// 当前认证令牌 Provider
final currentAuthTokenProvider = FutureProvider<String?>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getCurrentToken();
});
