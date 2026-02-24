/// 订阅模块 UI State Provider
///
/// 独立管理订阅流程的 UI 状态，避免与其他模块耦合
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/features/auth/models/auth_state.dart';

/// 订阅 UI State Provider
final subscriptionUIStateProvider = Provider<UIState>((ref) {
  return const UIState();
});

/// 订阅 UI State Notifier
class SubscriptionUIStateNotifier extends Notifier<UIState> {
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

/// 订阅 UI State Notifier Provider
final subscriptionUIStateNotifierProvider =
    NotifierProvider<SubscriptionUIStateNotifier, UIState>(
      SubscriptionUIStateNotifier.new,
    );
