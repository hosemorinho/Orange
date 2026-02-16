import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/infrastructure/api/api.dart';
import 'package:fl_clash/xboard/domain/domain.dart';

part 'generated/plan_state.g.dart';

/// 套餐状态管理

/// 获取套餐列表
@riverpod
Future<List<DomainPlan>> getPlans(Ref ref) async {
  final api = await ref.watch(xboardSdkProvider.future);
  final json = await api.fetchPlans();
  final dataList = json['data'] as List<dynamic>? ?? [];
  return dataList
      .whereType<Map<String, dynamic>>()
      .map(mapPlan)
      .toList();
}

/// 获取单个套餐
@riverpod
Future<DomainPlan?> getPlan(Ref ref, int id) async {
  final api = await ref.watch(xboardSdkProvider.future);
  final json = await api.fetchPlan(id);
  final data = json['data'];
  if (data is Map<String, dynamic>) {
    return mapPlan(data);
  }
  return null;
}
