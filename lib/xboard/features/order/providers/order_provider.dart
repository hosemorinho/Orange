import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';

part 'generated/order_provider.g.dart';

/// Cancel an order by trade number
@riverpod
Future<void> cancelOrder(Ref ref, String tradeNo) async {
  final api = await ref.read(xboardSdkProvider.future);
  await api.cancelOrder(tradeNo);
}
