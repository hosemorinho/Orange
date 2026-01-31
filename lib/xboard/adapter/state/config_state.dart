import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';

part 'generated/config_state.g.dart';

/// 配置状态管理

/// 获取 V2Board 站点配置
///
/// 返回原始 Map，包含 is_email_verify, is_invite_force 等字段
@riverpod
Future<Map<String, dynamic>> getConfig(Ref ref) async {
  final api = await ref.watch(xboardSdkProvider.future);
  final json = await api.getGuestConfig();
  final data = json['data'] as Map<String, dynamic>? ?? json;
  return data;
}
