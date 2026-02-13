import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/features/subscription/widgets/subscription_status_dialog.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/subscription/providers/xboard_subscription_provider.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'subscription_status_service.dart';

// 初始化文件级日志器
final _logger = FileLogger('subscription_status_checker.dart');

// SharedPreferences key for storing last shown dialog type
const _kLastShownDialogTypeKey = 'xboard_last_shown_subscription_dialog_type';

class SubscriptionStatusChecker {
  static final SubscriptionStatusChecker _instance = SubscriptionStatusChecker._internal();
  factory SubscriptionStatusChecker() => _instance;
  SubscriptionStatusChecker._internal();
  bool _isChecking = false;
  DateTime? _lastCheckTime;
  Future<void> checkSubscriptionStatusOnStartup(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (!context.mounted) return;
    final now = DateTime.now();
    if (_isChecking) {
      _logger.info('[订阅状态检查] 检查正在进行中，跳过重复请求');
      return;
    }
    if (_lastCheckTime != null && now.difference(_lastCheckTime!).inSeconds < 30) {
      _logger.info('[订阅状态检查] 距离上次检查不到30秒，跳过重复请求');
      return;
    }
    _isChecking = true;
    _lastCheckTime = now;
    try {
      _logger.info('[订阅状态检查] 开始检查订阅状态...');
      final userState = ref.read(xboardUserProvider);
      if (!userState.isAuthenticated) {
        _logger.info('[订阅状态检查] 用户未登录，跳过检查');
        return;
      }
      _logger.info('[订阅状态检查] 用户已登录，使用现有订阅状态进行检查');
      // 不再调用 refreshSubscriptionInfo()，避免重复导入
      // Token验证成功后已经通过 _silentUpdateUserData() 获取了最新订阅信息
      final updatedUserState = userState;
      final profileSubscriptionInfo = ref.read(currentProfileProvider)?.subscriptionInfo;

      // 检查 XBoard API 缓存的订阅信息：如果有 subscribeUrl，说明用户确实有订阅，
      // 只是 Clash 核心可能还没解析完 profile（profileSubscriptionInfo 暂时为 null）
      final cachedSubscription = ref.read(subscriptionInfoProvider);
      final hasActiveSubscription = cachedSubscription?.subscribeUrl.isNotEmpty == true;

      final statusResult = subscriptionStatusService.checkSubscriptionStatus(
        userState: updatedUserState,
        profileSubscriptionInfo: profileSubscriptionInfo,
        hasActiveSubscription: hasActiveSubscription,
      );
      _logger.info('[订阅状态检查] 检查结果: ${statusResult.type}');
      _logger.info('[订阅状态检查] 是否需要弹窗: ${statusResult.shouldShowDialog}');

      // 检查是否应该显示弹窗（防止重复弹窗）
      final shouldShow = await _shouldShowDialog(statusResult);
      _logger.info('[订阅状态检查] 是否实际显示弹窗: $shouldShow');

      if (shouldShow && subscriptionStatusService.shouldShowStartupDialog(statusResult)) {
        await _showSubscriptionStatusDialog(
          context,
          ref,
          statusResult,
        );
      } else {
        // 订阅状态正常，不需要额外导入配置
        // 配置导入已由 Token 验证成功后的 _silentUpdateUserData() 完成
        _logger.info('[订阅状态检查] 订阅状态正常或已提示，无需额外操作（配置已在Token验证后导入）');
      }
    } catch (e) {
      _logger.error('[订阅状态检查] 检查时出错', e);
    } finally {
      _isChecking = false;
    }
  }
  /// 检查是否应该显示对话框（防止重复弹窗）
  ///
  /// 只在以下情况显示对话框：
  /// 1. 从未显示过此类型的对话框
  /// 2. 状态类型发生了变化（例如从"无订阅"变成了"已过期"）
  Future<bool> _shouldShowDialog(SubscriptionStatusResult statusResult) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastShownType = prefs.getString(_kLastShownDialogTypeKey);
      final currentType = statusResult.type.name;

      // 如果从未显示过对话框，或者状态类型发生了变化，则显示
      final shouldShow = lastShownType != currentType;

      if (shouldShow) {
        // 更新最后显示的对话框类型
        await prefs.setString(_kLastShownDialogTypeKey, currentType);
        _logger.info('[订阅状态弹窗] 状态变化: $lastShownType -> $currentType，显示对话框');
      } else {
        _logger.info('[订阅状态弹窗] 状态未变化: $currentType，跳过弹窗');
      }

      return shouldShow;
    } catch (e) {
      _logger.error('[订阅状态弹窗] 检查弹窗状态时出错', e);
      return true; // 出错时默认显示，避免用户错过重要通知
    }
  }

  Future<void> _showSubscriptionStatusDialog(
    BuildContext context,
    WidgetRef ref,
    SubscriptionStatusResult statusResult,
  ) async {
    if (!context.mounted) return;
    _logger.info('[订阅状态弹窗] 显示弹窗: ${statusResult.type}');
    final result = await SubscriptionStatusDialog.show(
      context,
      statusResult,
      onPurchase: () async {
        await _handleRenewFromDialog(context, ref);
      },
      onRefresh: () async {
        _logger.info('[订阅状态弹窗] 刷新订阅状态...');
        await ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();
        // 刷新后重置弹窗状态，以便下次检查时能再次弹窗
        await resetDialogState();
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          context.pop();
        }
      },
    );
    _logger.info('[订阅状态弹窗] 操作结果: $result');
    if (result == 'later' || result == null) {
      _logger.info('[订阅状态弹窗] 用户选择稍后处理');
    }
  }

  /// 重置弹窗状态（在用户刷新订阅或购买套餐后调用）
  Future<void> resetDialogState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kLastShownDialogTypeKey);
      _logger.info('[订阅状态弹窗] 已重置弹窗状态');
    } catch (e) {
      _logger.error('[订阅状态弹窗] 重置弹窗状态时出错', e);
    }
  }
  
  Future<void> _handleRenewFromDialog(BuildContext context, WidgetRef ref) async {
    final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
    
    // 尝试获取用户当前订阅的套餐ID
    final userState = ref.read(xboardUserProvider);
    final currentPlanId = userState.subscriptionInfo?.planId;
    
    if (currentPlanId != null) {
      _logger.info('[套餐续费] 查找套餐ID: $currentPlanId');
      
      // 确保套餐列表已加载
      var plans = ref.read(xboardSubscriptionProvider);
      if (plans.isEmpty) {
        _logger.info('[套餐续费] 套餐列表为空，先加载套餐列表');
        await ref.read(xboardSubscriptionProvider.notifier).loadPlans();
        plans = ref.read(xboardSubscriptionProvider);
      }
      
      DomainPlan? currentPlan;
      try {
        currentPlan = plans.firstWhere((plan) => plan.id == currentPlanId);
      } catch (e) {
        currentPlan = null;
      }
      
      if (currentPlan != null) {
        _logger.info('[套餐续费] 找到当前套餐，跳转到购买页面: ${currentPlan.name}');
        if (isDesktop) {
          context.go('/plans');
        } else {
          context.push('/plans/purchase', extra: currentPlan);
        }
        return;
      } else {
        _logger.warning('[套餐续费] 未找到ID为 $currentPlanId 的套餐');
      }
    }
    
    // 没找到套餐：跳转到套餐列表页面
    _logger.info('[套餐续费] 跳转到套餐列表页面');
    if (isDesktop) {
      context.go('/plans');
    } else {
      context.push('/plans');
    }
  }
  Future<void> manualCheckSubscriptionStatus(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await checkSubscriptionStatusOnStartup(context, ref);
  }
  bool shouldShowSubscriptionReminder(WidgetRef ref) {
    try {
      final userState = ref.read(xboardUserProvider);
      if (!userState.isAuthenticated) return false;
      final profileSubscriptionInfo = ref.read(currentProfileProvider)?.subscriptionInfo;
      final cachedSubscription = ref.read(subscriptionInfoProvider);
      final hasActiveSubscription = cachedSubscription?.subscribeUrl.isNotEmpty == true;
      final statusResult = subscriptionStatusService.checkSubscriptionStatus(
        userState: userState,
        profileSubscriptionInfo: profileSubscriptionInfo,
        hasActiveSubscription: hasActiveSubscription,
      );
      return subscriptionStatusService.shouldShowStartupDialog(statusResult);
    } catch (e) {
      _logger.error('[订阅状态检查] 检查订阅提醒状态出错', e);
      return false;
    }
  }
  String getSubscriptionStatusText(BuildContext context, WidgetRef ref) {
    try {
      final userState = ref.read(xboardUserProvider);
      if (!userState.isAuthenticated) return '未登录';
      final profileSubscriptionInfo = ref.read(currentProfileProvider)?.subscriptionInfo;
      final cachedSubscription = ref.read(subscriptionInfoProvider);
      final hasActiveSubscription = cachedSubscription?.subscribeUrl.isNotEmpty == true;
      final statusResult = subscriptionStatusService.checkSubscriptionStatus(
        userState: userState,
        profileSubscriptionInfo: profileSubscriptionInfo,
        hasActiveSubscription: hasActiveSubscription,
      );
      return statusResult.getMessage(context);
    } catch (e) {
      return '状态检查失败';
    }
  }
}
final subscriptionStatusChecker = SubscriptionStatusChecker();