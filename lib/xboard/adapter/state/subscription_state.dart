import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/infrastructure/api/api.dart';
import 'package:fl_clash/xboard/domain/domain.dart';

part 'generated/subscription_state.g.dart';

/// 订阅状态管理

/// 获取订阅信息
@riverpod
Future<DomainSubscription> getSubscription(Ref ref) async {
  final api = await ref.watch(xboardSdkProvider.future);
  final json = await api.getSubscribe();
  final data = json['data'] as Map<String, dynamic>? ?? json;
  return mapSubscription(data, baseUrl: api.baseUrl);
}

/// 获取订阅链接
@riverpod
Future<String> getSubscribeUrl(Ref ref) async {
  final api = await ref.watch(xboardSdkProvider.future);
  final json = await api.getSubscribe();
  final data = json['data'] as Map<String, dynamic>? ?? json;
  final token = data['token'] as String? ?? '';
  if (token.isEmpty) return '';
  return api.buildSubscribeUrl(token);
}
