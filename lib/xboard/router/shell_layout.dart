import 'dart:io';
import 'package:fl_clash/xboard/features/crisp/crisp_chat_button.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/notice/providers/notice_provider.dart';
import 'package:fl_clash/xboard/features/subscription/providers/xboard_subscription_provider.dart';
import 'package:fl_clash/xboard/features/invite/providers/invite_provider.dart';
import 'package:fl_clash/xboard/widgets/navigation/desktop_navigation_rail.dart';
import 'package:fl_clash/xboard/widgets/navigation/mobile_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 适配性的 Shell 布局
/// 桌面端：侧边栏 + 内容区
/// 移动端：底部导航栏 + 内容区
class AdaptiveShellLayout extends ConsumerWidget {
  final StatefulNavigationShell child;

  const AdaptiveShellLayout({
    super.key,
    required this.child,
  });

  void _onDestinationSelected(BuildContext context, WidgetRef ref, int index) {
    // 全局：每次标签页切换时刷新用户和订阅信息（火速转发，不阻塞UI）
    ref.read(xboardUserProvider.notifier).silentRefresh();

    // 页面特定刷新逻辑
    switch (index) {
      case 0:
        // 主页：刷新公告
        ref.read(noticeProvider.notifier).fetchNotices();
        break;
      case 1:
        // 计划页：刷新套餐列表
        ref.read(xboardSubscriptionProvider.notifier).autoRefreshIfNeeded();
        break;
      case 2:
        // 支持页：刷新公告和常见问题
        ref.read(noticeProvider.notifier).fetchNotices();
        break;
      case 3:
        // 邀请页：刷新邀请代码和统计数据
        ref.read(inviteDataProviderProvider.notifier).refresh();
        break;
      case 4:
        // 设置页：无需额外刷新（只显示本地设置）
        break;
    }

    // 执行路由导航（使用 goBranch 保持各分支的导航状态）
    child.goBranch(
      index,
      initialLocation: index == child.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
    final currentIndex = child.currentIndex;

    if (isDesktop) {
      return Row(
        children: [
          DesktopNavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => _onDestinationSelected(context, ref, index),
          ),
          Expanded(
            child: Stack(
              children: [
                child,
                const Positioned(
                  right: 16,
                  bottom: 16,
                  child: CrispChatButton(),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        body: child,
        floatingActionButton: const CrispChatButton(),
        bottomNavigationBar: MobileNavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) => _onDestinationSelected(context, ref, index),
        ),
      );
    }
  }
}

