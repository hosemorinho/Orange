/// 支付模块 UI State Provider
///
/// 独立管理支付流程的 UI 状态，避免与其他模块耦合
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/features/auth/models/auth_state.dart';

/// 支付 UI State Provider
final paymentUIStateProvider = Provider<UIState>((ref) {
  return const UIState();
});

/// 支付 UI State Notifier
class PaymentUIStateNotifier extends Notifier<UIState> {
  @override
  UIState build() => const UIState();

  void setState(UIState next) {
    state = next;
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? message) {
    state = state.copyWith(errorMessage: message);
  }

  void clearError() {
    state = state.clearError();
  }
}

/// 支付 UI State Notifier Provider
final paymentUIStateNotifierProvider =
    NotifierProvider<PaymentUIStateNotifier, UIState>(
      PaymentUIStateNotifier.new,
    );
