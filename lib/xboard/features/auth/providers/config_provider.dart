import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/adapter/state/config_state.dart';

/// 配置数据Provider
/// 获取系统配置信息，如邮箱验证、邀请码等设置
/// 使用 autoDispose 确保每次进入注册页面都重新获取最新配置
final configProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  try {
    return await ref.watch(getConfigProvider.future);
  } catch (e) {
    // 配置获取失败时返回null，使用默认值
    return null;
  }
});

/// 配置状态Provider
/// 提供配置的加载状态和错误信息
final configStateProvider = NotifierProvider<ConfigStateNotifier, ConfigState>(
  ConfigStateNotifier.new,
);

class ConfigState {
  final Map<String, dynamic>? data;
  final bool isLoading;
  final String? error;

  const ConfigState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  ConfigState copyWith({
    Map<String, dynamic>? data,
    bool? isLoading,
    String? error,
  }) {
    return ConfigState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ConfigStateNotifier extends Notifier<ConfigState> {
  @override
  ConfigState build() {
    loadConfig();
    return const ConfigState(isLoading: false);
  }

  Future<void> loadConfig() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final config = await ref.read(getConfigProvider.future);
      state = state.copyWith(
        data: config,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshConfig() async {
    await loadConfig();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
