import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/infrastructure/api/api.dart';
import 'package:fl_clash/xboard/domain/domain.dart';

part 'generated/order_state.g.dart';

/// 订单状态管理

/// 获取订单列表
@riverpod
Future<List<DomainOrder>> getOrders(Ref ref) async {
  final api = await ref.watch(xboardSdkProvider.future);
  final json = await api.fetchOrders();
  final dataList = json['data'] as List<dynamic>? ?? [];
  return dataList
      .whereType<Map<String, dynamic>>()
      .map(mapOrder)
      .toList();
}

/// Provider alias for backward compatibility
final getOrdersProvider = getOrdersProvider;

/// 获取单个订单
@riverpod
Future<DomainOrder?> getOrder(Ref ref, String tradeNo) async {
  final api = await ref.watch(xboardSdkProvider.future);
  final json = await api.fetchOrderDetail(tradeNo);
  final data = json['data'];
  if (data is Map<String, dynamic>) {
    return mapOrder(data);
  }
  return null;
}
