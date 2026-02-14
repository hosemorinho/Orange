import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/features/subscription/widgets/subscription_status_dialog.dart';
import 'package:fl_clash/xboard/features/auth/auth.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/subscription/providers/xboard_subscription_provider.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'subscription_status_service.dart';

final _logger = FileLogger('subscription_status_checker.dart');

const _kLastShownDialogTypeKey = 'xboard_last_shown_subscription_dialog_type';

class SubscriptionStatusChecker {
  static final SubscriptionStatusChecker _instance =
      SubscriptionStatusChecker._internal();

  factory SubscriptionStatusChecker() => _instance;

  SubscriptionStatusChecker._internal();

  bool _isChecking = false;
  bool _hasPendingDeferredCheck = false;
  int _deferredRetryCount = 0;
  static const int _maxDeferredRetries = 3;
  DateTime? _lastCheckTime;

  Future<void> checkSubscriptionStatusOnStartup(
    BuildContext context,
    WidgetRef ref, {
    bool force = false,
  }) async {
    if (!context.mounted) return;

    final now = DateTime.now();
    if (_isChecking) {
      _logger.info('[subscription] status check already in progress, skip');
      return;
    }

    if (!force &&
        _lastCheckTime != null &&
        now.difference(_lastCheckTime!).inSeconds < 30) {
      _logger.info('[subscription] checked recently (<30s), skip');
      return;
    }

    _isChecking = true;
    _lastCheckTime = now;

    try {
      _logger.info('[subscription] start status check');
      final userState = ref.read(xboardUserProvider);
      if (!userState.isAuthenticated) {
        _logger.info('[subscription] user not authenticated, skip');
        return;
      }

      final domainSubscriptionInfo = ref.read(subscriptionInfoProvider);
      final effectiveSubscriptionInfo =
          domainSubscriptionInfo ?? userState.subscriptionInfo;
      _logger.info(
        '[subscription] subscriptionInfoProvider is ${domainSubscriptionInfo == null ? 'null' : 'ready'}',
      );

      if (!_isSubscriptionStateReady(userState, effectiveSubscriptionInfo)) {
        if (_deferredRetryCount < _maxDeferredRetries) {
          _scheduleDeferredRecheck(context, ref);
        } else {
          _logger.warning(
            '[subscription] data still not ready after max retries, skip this startup check',
          );
          _deferredRetryCount = 0;
        }
        return;
      }
      _deferredRetryCount = 0;

      final statusResult = subscriptionStatusService.checkSubscriptionStatus(
        userState: userState,
        subscriptionInfo: effectiveSubscriptionInfo,
      );
      _logger.info('[subscription] status result: ${statusResult.type}');
      _logger.info(
        '[subscription] needs dialog: ${statusResult.shouldShowDialog}',
      );

      final shouldShow = await _shouldShowDialog(statusResult);
      _logger.info('[subscription] dialog should actually show: $shouldShow');

      if (shouldShow &&
          subscriptionStatusService.shouldShowStartupDialog(statusResult)) {
        await _showSubscriptionStatusDialog(context, ref, statusResult);
      } else {
        _logger.info('[subscription] no dialog needed at this time');
      }
    } catch (e) {
      _logger.error('[subscription] status check failed', e);
    } finally {
      _isChecking = false;
    }
  }

  bool _isSubscriptionStateReady(
    UserAuthState userState,
    DomainSubscription? subscriptionInfo,
  ) {
    if (subscriptionInfo != null) return true;
    if (userState.subscriptionInfo != null) return true;
    if (userState.userInfo != null) return true;
    return false;
  }

  void _scheduleDeferredRecheck(BuildContext context, WidgetRef ref) {
    if (_hasPendingDeferredCheck) {
      _logger.info('[subscription] deferred check already scheduled, skip');
      return;
    }

    _hasPendingDeferredCheck = true;
    _deferredRetryCount += 1;
    _logger.info(
      '[subscription] data not ready, retry in 5s ($_deferredRetryCount/$_maxDeferredRetries)',
    );

    Future.delayed(const Duration(seconds: 5), () async {
      _hasPendingDeferredCheck = false;
      if (!context.mounted) return;
      await checkSubscriptionStatusOnStartup(context, ref, force: true);
    });
  }

  Future<bool> _shouldShowDialog(SubscriptionStatusResult statusResult) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastShownType = prefs.getString(_kLastShownDialogTypeKey);
      final currentType = statusResult.type.name;

      if (!subscriptionStatusService.shouldShowStartupDialog(statusResult)) {
        if (lastShownType != null) {
          await prefs.remove(_kLastShownDialogTypeKey);
          _logger.info(
            '[subscription] status recovered ($currentType), clear dialog history',
          );
        }
        return false;
      }

      final shouldShow = lastShownType != currentType;
      if (shouldShow) {
        await prefs.setString(_kLastShownDialogTypeKey, currentType);
        _logger.info(
          '[subscription] status changed: $lastShownType -> $currentType, show dialog',
        );
      } else {
        _logger.info(
          '[subscription] status unchanged: $currentType, skip dialog',
        );
      }
      return shouldShow;
    } catch (e) {
      _logger.error('[subscription] failed to read dialog history', e);
      return true;
    }
  }

  Future<void> _showSubscriptionStatusDialog(
    BuildContext context,
    WidgetRef ref,
    SubscriptionStatusResult statusResult,
  ) async {
    if (!context.mounted) return;

    _logger.info('[subscription] show dialog: ${statusResult.type}');
    final result = await SubscriptionStatusDialog.show(
      context,
      statusResult,
      onPurchase: () async {
        await _handleRenewFromDialog(context, ref);
      },
      onRefresh: () async {
        _logger.info('[subscription] refresh subscription from dialog');
        await ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();
        await resetDialogState();
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          context.pop();
        }
      },
    );

    _logger.info('[subscription] dialog result: $result');
    if (result == 'later' || result == null) {
      _logger.info('[subscription] user postponed handling');
    }
  }

  Future<void> resetDialogState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kLastShownDialogTypeKey);
      _logger.info('[subscription] dialog state reset');
    } catch (e) {
      _logger.error('[subscription] failed to reset dialog state', e);
    }
  }

  Future<void> _handleRenewFromDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final isDesktop =
        Platform.isLinux || Platform.isWindows || Platform.isMacOS;

    final userState = ref.read(xboardUserProvider);
    final currentPlanId = userState.subscriptionInfo?.planId;

    if (currentPlanId != null && currentPlanId > 0) {
      _logger.info('[subscription] resolve current plan id: $currentPlanId');

      var plans = ref.read(xboardSubscriptionProvider);
      if (plans.isEmpty) {
        _logger.info('[subscription] plans empty, load plans first');
        await ref.read(xboardSubscriptionProvider.notifier).loadPlans();
        plans = ref.read(xboardSubscriptionProvider);
      }

      DomainPlan? currentPlan;
      try {
        currentPlan = plans.firstWhere((plan) => plan.id == currentPlanId);
      } catch (_) {
        currentPlan = null;
      }

      if (currentPlan != null) {
        _logger.info(
          '[subscription] found current plan, navigate to purchase: ${currentPlan.name}',
        );
        if (isDesktop) {
          context.go('/plans');
        } else {
          context.push('/plans/purchase', extra: currentPlan);
        }
        return;
      }

      _logger.warning('[subscription] plan not found for id=$currentPlanId');
    }

    _logger.info('[subscription] fallback to plans list page');
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

      final domainSubscriptionInfo = ref.read(subscriptionInfoProvider);
      final statusResult = subscriptionStatusService.checkSubscriptionStatus(
        userState: userState,
        subscriptionInfo: domainSubscriptionInfo ?? userState.subscriptionInfo,
      );
      return subscriptionStatusService.shouldShowStartupDialog(statusResult);
    } catch (e) {
      _logger.error('[subscription] reminder check failed', e);
      return false;
    }
  }

  String getSubscriptionStatusText(BuildContext context, WidgetRef ref) {
    try {
      final userState = ref.read(xboardUserProvider);
      if (!userState.isAuthenticated) return '未登录';

      final domainSubscriptionInfo = ref.read(subscriptionInfoProvider);
      final statusResult = subscriptionStatusService.checkSubscriptionStatus(
        userState: userState,
        subscriptionInfo: domainSubscriptionInfo ?? userState.subscriptionInfo,
      );
      return statusResult.getMessage(context);
    } catch (_) {
      return '状态检查失败';
    }
  }
}

final subscriptionStatusChecker = SubscriptionStatusChecker();
