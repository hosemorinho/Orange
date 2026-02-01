import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/features/domain_status/providers/domain_status_provider.dart';
import 'package:fl_clash/xboard/features/domain_status/models/domain_status_state.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';

import '../models/initialization_state.dart';

// 初始化文件级日志器
final _logger = FileLogger('initialization_provider.dart');

/// XBoard 统一初始化 Provider
///
/// 封装整个初始化流程：
/// 1. 域名检查（域名竞速）
/// 2. SDK 初始化
///
/// 提供统一的初始化入口和状态管理
class XBoardInitializationNotifier extends StateNotifier<InitializationState> {
  final Ref ref;

  // 初始化超时配置
  static const Duration _initializationTimeout = Duration(seconds: 30);
  static const int _maxRetries = 2;

  XBoardInitializationNotifier(this.ref) : super(const InitializationState()) {
    _logger.info('[Initialization] Provider 已创建');
  }
  
  /// 统一初始化入口
  ///
  /// 执行完整的初始化流程，包括：
  /// - 域名检查（竞速）
  /// - SDK 初始化
  ///
  /// 如果已经初始化完成，会直接返回（幂等性）
  ///
  /// 支持：
  /// - 整体超时保护（30秒）
  /// - 失败重试（最多2次）
  /// - 降级方案（使用环境变量或缓存）
  Future<void> initialize() async {
    // 如果已经就绪，跳过初始化
    if (state.isReady) {
      _logger.info('[Initialization] ✅ 已初始化，跳过重复执行');
      return;
    }

    // 如果正在初始化，避免重复触发
    if (state.isInitializing) {
      _logger.info('[Initialization] ⏳ 正在初始化中，跳过重复触发');
      return;
    }

    // 添加整体超时保护
    try {
      await _initializeWithRetry().timeout(
        _initializationTimeout,
        onTimeout: () {
          _logger.warning('[Initialization] ⏱️ 初始化超时（30秒），尝试降级方案');
          throw TimeoutException('初始化超时');
        },
      );
    } on TimeoutException {
      _logger.warning('[Initialization] ⏱️ 初始化超时，尝试使用降级方案');
      await _fallbackInitialization();
    } catch (e, stackTrace) {
      _logger.error('[Initialization] ❌ 初始化失败', e, stackTrace);

      // 最后的降级尝试
      try {
        await _fallbackInitialization();
      } catch (fallbackError) {
        _logger.error('[Initialization] ❌ 降级方案也失败', fallbackError);
        state = state.copyWith(
          status: InitializationStatus.failed,
          errorMessage: '初始化失败: ${e.toString()}',
          currentStepDescription: '初始化失败，请检查网络连接',
        );
        rethrow;
      }
    }
  }

  /// 带重试的初始化流程
  Future<void> _initializeWithRetry() async {
    int retryCount = 0;
    Exception? lastError;

    while (retryCount <= _maxRetries) {
      try {
        if (retryCount > 0) {
          _logger.info('[Initialization] 🔄 第 $retryCount 次重试...');
          state = state.copyWith(
            currentStepDescription: '重试中... (${retryCount}/$_maxRetries)',
          );
          // 重试前等待一小段时间
          await Future.delayed(Duration(seconds: retryCount * 2));
        }

        await _performInitialization();
        return; // 成功则直接返回
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        _logger.warning('[Initialization] ⚠️ 尝试 ${retryCount + 1} 失败: $e');
        retryCount++;

        if (retryCount > _maxRetries) {
          throw lastError;
        }
      }
    }
  }

  /// 执行实际的初始化逻辑
  Future<void> _performInitialization() async {
    _logger.info('[Initialization] 🚀 开始初始化流程');

    // ========== 步骤 1: 检查域名 ==========
    _logger.info('[Initialization] 📡 步骤 1/2: 检查域名');
    state = state.copyWith(
      status: InitializationStatus.checkingDomain,
      errorMessage: null,
      currentStepDescription: '正在检查域名可用性...',
    );

    // 触发域名检查（带超时）
    await ref.read(domainStatusProvider.notifier).checkDomain()
        .timeout(const Duration(seconds: 20));

    // 获取域名检查结果
    final domainStatus = ref.read(domainStatusProvider);

    if (domainStatus.status == DomainStatus.failed) {
      throw Exception(domainStatus.errorMessage ?? '域名不可用');
    }

    if (!domainStatus.isReady) {
      throw Exception('域名状态未就绪');
    }

    _logger.info('[Initialization] ✅ 域名检查完成: ${domainStatus.currentDomain}');

    // ========== 步骤 2: 初始化 SDK ==========
    _logger.info('[Initialization] 🔧 步骤 2/2: 初始化 SDK');
    state = state.copyWith(
      status: InitializationStatus.initializingSDK,
      currentDomain: domainStatus.currentDomain,
      latency: domainStatus.latency,
      currentStepDescription: '正在初始化 SDK...',
    );

    // 等待 SDK 初始化完成（带超时）
    await ref.read(xboardSdkProvider.future)
        .timeout(const Duration(seconds: 10));

    _logger.info('[Initialization] ✅ SDK 初始化完成');

    // ========== 完成 ==========
    _logger.info('[Initialization] 🎉 初始化流程完成');
    state = state.copyWith(
      status: InitializationStatus.ready,
      lastChecked: DateTime.now(),
      currentStepDescription: '初始化完成',
      errorMessage: null,
    );
  }

  /// 降级初始化方案
  ///
  /// 当正常初始化失败时，尝试：
  /// 1. 使用环境变量中的 API 地址
  /// 2. 使用缓存的域名
  /// 3. 标记为失败但允许进入登录页
  Future<void> _fallbackInitialization() async {
    _logger.info('[Initialization] 🔄 尝试降级初始化方案');

    try {
      state = state.copyWith(
        status: InitializationStatus.initializingSDK,
        currentStepDescription: '尝试降级方案...',
        errorMessage: null,
      );

      // 尝试直接初始化 SDK（会使用环境变量或缓存）
      await ref.read(xboardSdkProvider.future)
          .timeout(const Duration(seconds: 5));

      _logger.info('[Initialization] ✅ 降级方案成功');
      state = state.copyWith(
        status: InitializationStatus.ready,
        lastChecked: DateTime.now(),
        currentStepDescription: '已使用降级方案初始化',
        errorMessage: '使用降级方案',
      );
    } catch (e) {
      _logger.warning('[Initialization] ⚠️ 降级方案失败，标记为部分就绪');

      // 即使降级失败，也标记为 ready，但带有错误信息
      // 这样用户可以进入登录页，由登录页处理后续初始化
      state = state.copyWith(
        status: InitializationStatus.ready,
        lastChecked: DateTime.now(),
        currentStepDescription: '初始化部分失败，可尝试登录',
        errorMessage: '初始化失败: ${e.toString()}，将在登录时重试',
      );
    }
  }
  
  /// 刷新（重新初始化）
  /// 
  /// 重置状态并重新执行完整的初始化流程
  Future<void> refresh() async {
    _logger.info('[Initialization] 🔄 刷新初始化状态');
    
    // 重置状态
    state = const InitializationState();
    
    // 重新初始化
    await initialize();
  }
  
  /// 重置为初始状态
  void reset() {
    _logger.info('[Initialization] 🔄 重置初始化状态');
    state = const InitializationState();
  }
}

/// XBoard 统一初始化 Provider
final initializationProvider = 
    StateNotifierProvider<XBoardInitializationNotifier, InitializationState>(
  (ref) => XBoardInitializationNotifier(ref),
);

/// 便捷 Provider: 是否已初始化
final isInitializedProvider = Provider<bool>((ref) {
  return ref.watch(initializationProvider).isReady;
});

/// 便捷 Provider: 是否正在初始化
final isInitializingProvider = Provider<bool>((ref) {
  return ref.watch(initializationProvider).isInitializing;
});

/// 便捷 Provider: 初始化进度百分比
final initializationProgressProvider = Provider<int>((ref) {
  return ref.watch(initializationProvider).progressPercentage;
});
