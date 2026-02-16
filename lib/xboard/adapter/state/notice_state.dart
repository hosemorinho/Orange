import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/infrastructure/api/api.dart';
import 'package:fl_clash/xboard/domain/domain.dart';

part 'generated/notice_state.g.dart';

/// 公告状态管理

/// 获取公告列表
@riverpod
Future<List<DomainNotice>> getNotices(Ref ref) async {
  final api = await ref.watch(xboardSdkProvider.future);
  final json = await api.fetchNotices();
  final dataList = json['data'] as List<dynamic>? ?? [];
  return dataList
      .whereType<Map<String, dynamic>>()
      .map(mapNotice)
      .toList();
}
