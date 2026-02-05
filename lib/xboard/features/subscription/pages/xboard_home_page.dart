import 'dart:async';
import 'dart:io';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fl_clash/xboard/features/shared/shared.dart';
import 'package:fl_clash/xboard/features/notice/notice.dart';
import 'package:fl_clash/xboard/features/latency/services/auto_latency_service.dart';
import 'package:fl_clash/xboard/features/subscription/services/subscription_status_checker.dart';
import 'package:fl_clash/xboard/features/profile/providers/profile_import_provider.dart';

import '../widgets/vpn_hero_card.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/traffic_history_card.dart';
class XBoardHomePage extends ConsumerStatefulWidget {
  const XBoardHomePage({super.key});
  @override
  ConsumerState<XBoardHomePage> createState() => _XBoardHomePageState();
}
class _XBoardHomePageState extends ConsumerState<XBoardHomePage>
    with AutomaticKeepAliveClientMixin {
  bool _hasInitialized = false;
  bool _hasStartedLatencyTesting = false;
  bool _hasCheckedSubscriptionStatus = false;
  Timer? _subscriptionRefreshTimer;  // 订阅信息定时刷新计时器

  @override
  bool get wantKeepAlive => true;  // 保持页面状态，防止重建
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasInitialized) return;
      _hasInitialized = true;
      final userState = ref.read(xboardUserProvider);
      if (userState.isAuthenticated) {
        // 等待订阅导入完成后再检查订阅状态
        _waitForSubscriptionImportThenCheck();
        // 启动订阅信息定时刷新（每 5 分钟）
        _startSubscriptionRefreshTimer();
      }
      autoLatencyService.initialize(ref);
      _waitForGroupsAndStartTesting();
    });
    ref.listenManual(xboardUserProvider, (previous, next) {
      if (next.errorMessage == 'TOKEN_EXPIRED') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showTokenExpiredDialog();
        });
      }
    });
    
    // 监听订阅导入完成事件
    ref.listenManual(profileImportProvider, (previous, next) {
      // 从导入中变为完成（成功或失败）
      if (previous?.isImporting == true && !next.isImporting && !_hasCheckedSubscriptionStatus) {
        _hasCheckedSubscriptionStatus = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            subscriptionStatusChecker.checkSubscriptionStatusOnStartup(context, ref);
          }
        });
      }
    });
    
    ref.listenManual(currentProfileProvider, (previous, next) {
      if (previous?.label != next?.label && previous != null) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            autoLatencyService.testCurrentNode(forceTest: true);
          }
        });
      }
    });
    ref.listenManual(groupsProvider, (previous, next) {
      if ((previous?.isEmpty ?? true) && next.isNotEmpty && !_hasStartedLatencyTesting) {
        _hasStartedLatencyTesting = true;
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _performInitialLatencyTest();
          }
        });
      }
    });
  }
  @override
  void dispose() {
    _subscriptionRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);  // 必须调用，配合 AutomaticKeepAliveClientMixin

    // 根据操作系统平台判断设备类型
    final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
    
    return Scaffold(
      appBar: isDesktop ? null : AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          appName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          const CoreStatusIndicator(),
          const SizedBox(width: 4),
          const LanguageSelector(),
          _buildNoticeIconButton(),
        ],
      ),
      body: Consumer(
        builder: (_, ref, __) {
          // 获取屏幕高度并计算自适应间距
          final screenHeight = MediaQuery.of(context).size.height;
        final appBarHeight = kToolbarHeight;
        final statusBarHeight = MediaQuery.of(context).padding.top;
        final bottomNavHeight = 60.0; // 底部导航栏高度
        final availableHeight = screenHeight - appBarHeight - statusBarHeight - bottomNavHeight;
        
        // 根据可用高度调整间距
        double sectionSpacing;
        double verticalPadding;
        double horizontalPadding;

        if (availableHeight < 500) {
          // 小屏幕：紧凑布局
          sectionSpacing = 12.0;
          verticalPadding = 12.0;
          horizontalPadding = 16.0;
        } else if (availableHeight < 650) {
          // 中等屏幕：适中布局
          sectionSpacing = 16.0;
          verticalPadding = 16.0;
          horizontalPadding = 20.0;
        } else {
          // 大屏幕：标准布局
          sectionSpacing = 20.0;
          verticalPadding = 20.0;
          horizontalPadding = 24.0;
        }
        
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: verticalPadding),
                  child: Center(
                    child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 768,
                      minHeight: constraints.maxHeight - (2 * verticalPadding),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isDesktop)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const CoreStatusIndicator(),
                                const SizedBox(width: 8),
                                const LanguageSelector(),
                                const SizedBox(width: 4),
                                _buildNoticeIconButton(),
                              ],
                            ),
                          ),
                        const NoticeBanner(),
                        SizedBox(height: sectionSpacing * 0.5),
                        // VPN Hero Card (connection + subscription + mode controls)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: const VpnHeroCard(),
                        ),
                        SizedBox(height: sectionSpacing),
                        // Quick actions
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: const QuickActionsCard(),
                        ),
                        SizedBox(height: sectionSpacing),
                        // Traffic history (collapsible)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: TrafficHistoryCard(
                            initiallyExpanded: isDesktop,
                          ),
                        ),
                        SizedBox(height: sectionSpacing),
                      ],
                    ),
                  ),
                  ),
                );
              },
            ),
          ),
        );
        },
      ),
    );
  }
  Widget _buildNoticeIconButton() {
    return Consumer(
      builder: (context, ref, _) {
        final noticeState = ref.watch(noticeProvider);
        final hasNotices = noticeState.notices.isNotEmpty;
        return IconButton(
          icon: Badge(
            isLabelVisible: hasNotices,
            smallSize: 8,
            child: const Icon(Icons.notifications_outlined),
          ),
          onPressed: () {
            final notices = noticeState.notices;
            if (notices.isNotEmpty) {
              showDialog(
                context: context,
                builder: (context) => NoticeDetailDialog(
                  notices: notices,
                  initialIndex: 0,
                ),
              );
            }
          },
        );
      },
    );
  }

  /// 等待订阅导入完成后再检查订阅状态（备用方案）
  /// 如果3秒后还没有触发导入完成监听器，则主动检查
  void _waitForSubscriptionImportThenCheck() async {
    await Future.delayed(const Duration(seconds: 3));
    
    // 如果已经通过监听器检查过了，就不再检查
    if (_hasCheckedSubscriptionStatus) {
      return;
    }
    
    _hasCheckedSubscriptionStatus = true;
    if (mounted) {
      subscriptionStatusChecker.checkSubscriptionStatusOnStartup(context, ref);
    }
  }
  
  void _showTokenExpiredDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(appLocalizations.xboardTokenExpiredTitle),
        content: Text(appLocalizations.xboardTokenExpiredContent),
        actions: [
          TextButton(
            onPressed: () async {
              final userNotifier = ref.read(xboardUserProvider.notifier);
              // 先关闭对话框
              if (context.mounted) {
                Navigator.of(context).pop();
              }
              // 清除错误状态
              userNotifier.clearTokenExpiredError();
              // 处理 Token 过期（清除数据）
              await userNotifier.handleTokenExpired();
              // 使用 go_router 导航到登录页（会清除所有路由）
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(appLocalizations.xboardRelogin),
          ),
        ],
      ),
    );
  }

  void _waitForGroupsAndStartTesting() {
    if (_hasStartedLatencyTesting) {
      return;
    }
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      try {
        final groups = ref.read(groupsProvider);
        if (groups.isNotEmpty && !_hasStartedLatencyTesting) {
          timer.cancel();
          _hasStartedLatencyTesting = true;
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _performInitialLatencyTest();
            }
          });
        }
      } catch (e) {
      }
    });
  }
  void _performInitialLatencyTest() {
    if (!mounted) return;
    autoLatencyService.testCurrentNode();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final userState = ref.read(xboardUserProvider);
        if (userState.isAuthenticated) {
          autoLatencyService.testCurrentGroupNodes();
        }
      }
    });
  }

  /// 启动订阅信息定时刷新（每 5 分钟）
  void _startSubscriptionRefreshTimer() {
    _subscriptionRefreshTimer?.cancel();
    _subscriptionRefreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) async {
        if (!mounted) return;
        final userState = ref.read(xboardUserProvider);
        if (userState.isAuthenticated) {
          try {
            await ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();
          } catch (e) {
            // 静默失败，不影响用户体验
          }
        }
      },
    );
  }
} 