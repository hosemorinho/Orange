import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/infrastructure/api/api.dart';
import 'package:fl_clash/xboard/domain/domain.dart';

part 'generated/ticket_state.g.dart';

/// 工单状态管理

/// 获取工单列表
@riverpod
Future<List<DomainTicket>> getTickets(Ref ref) async {
  final api = await ref.watch(xboardSdkProvider.future);
  final json = await api.fetchTickets();
  final dataList = json['data'] as List<dynamic>? ?? [];
  return dataList
      .whereType<Map<String, dynamic>>()
      .map(mapTicket)
      .toList();
}

/// 获取单个工单
@riverpod
Future<DomainTicket?> getTicket(Ref ref, int id) async {
  final api = await ref.watch(xboardSdkProvider.future);
  final json = await api.fetchTicketDetail(id);
  final data = json['data'];
  if (data is Map<String, dynamic>) {
    return mapTicket(data);
  }
  return null;
}
