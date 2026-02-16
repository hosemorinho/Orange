import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/infrastructure/api/api.dart';
import 'package:fl_clash/xboard/domain/domain.dart';

part 'generated/user_state.g.dart';

/// 用户状态管理

/// 获取用户信息
@riverpod
Future<DomainUser> getUserInfo(Ref ref) async {
  final api = await ref.watch(xboardSdkProvider.future);
  final json = await api.getUserInfo();
  final data = json['data'] as Map<String, dynamic>? ?? json;
  return mapUserInfo(data);
}
