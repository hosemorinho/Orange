import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/infrastructure/api/api.dart';
import 'package:fl_clash/xboard/domain/domain.dart';

part 'generated/payment_state.g.dart';

/// 支付状态管理

/// 获取支付方式列表
@riverpod
Future<List<DomainPaymentMethod>> getPaymentMethods(Ref ref) async {
  final api = await ref.watch(xboardSdkProvider.future);
  final json = await api.getPaymentMethod();
  final dataList = json['data'] as List<dynamic>? ?? [];
  return dataList
      .whereType<Map<String, dynamic>>()
      .map(mapPaymentMethod)
      .toList();
}
