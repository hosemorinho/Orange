import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';

part 'generated/order_provider.g.dart';

/// Order operations provider
///
/// Handles order mutations like:
/// - Cancel order
/// - (Future: Refund, etc.)
@riverpod
class OrderProvider extends _$OrderProvider {
  @override
  void build() {
    // No initial state needed
  }

  /// Cancel an order by trade number
  Future<void> cancelOrder(String tradeNo) async {
    final api = await ref.read(xboardSdkProvider.future);
    await api.cancelOrder(tradeNo);
  }
}
