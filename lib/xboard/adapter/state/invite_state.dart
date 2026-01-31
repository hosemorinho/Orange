import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/infrastructure/api/api.dart';
import 'package:fl_clash/xboard/domain/domain.dart';

part 'generated/invite_state.g.dart';

/// 邀请状态管理

/// 获取邀请信息
@riverpod
Future<DomainInvite> getInviteInfo(Ref ref) async {
  final api = await ref.watch(xboardSdkProvider.future);
  final json = await api.fetchInvite();
  final data = json['data'] as Map<String, dynamic>? ?? json;
  return mapInvite(data);
}

/// 获取佣金详情
@riverpod
Future<List<DomainCommission>> getCommissionDetails(Ref ref, {int page = 1}) async {
  final api = await ref.watch(xboardSdkProvider.future);
  final json = await api.fetchInviteDetails();
  final dataList = json['data'] as List<dynamic>? ?? [];
  return dataList
      .whereType<Map<String, dynamic>>()
      .map(mapCommission)
      .toList();
}
