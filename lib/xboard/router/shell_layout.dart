import 'dart:io';
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

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/plans');
        break;
      case 2:
        context.go('/support');
        break;
      case 3:
        context.go('/invite');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location == '/') return 0;
    if (location.startsWith('/plans')) return 1;
    if (location.startsWith('/support')) return 2;
    if (location.startsWith('/invite')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
    final currentIndex = _getCurrentIndex(context);

    if (isDesktop) {
      return Row(
        children: [
          DesktopNavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => _onDestinationSelected(context, index),
          ),
          Expanded(
            child: child,
          ),
        ],
      );
    } else {
      return Scaffold(
        body: child,
        bottomNavigationBar: MobileNavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) => _onDestinationSelected(context, index),
        ),
      );
    }
  }
}

