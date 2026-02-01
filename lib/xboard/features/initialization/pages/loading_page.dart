import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/features/initialization/providers/initialization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:go_router/go_router.dart';

/// 应用初始化加载页面
///
/// 显示初始化进度、错误信息和重试选项
class LoadingPage extends ConsumerWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(initializationProvider);
    final userState = ref.watch(xboardUserProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // 如果用户状态已初始化，触发路由刷新
    if (userState.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          if (userState.isAuthenticated) {
            context.go('/');
          } else {
            context.go('/login');
          }
        }
      });
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo 或应用名称
                Icon(
                  Icons.cloud_sync,
                  size: 64,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 32),

                // 标题
                Text(
                  '正在初始化',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // 进度条
                SizedBox(
                  width: 280,
                  child: LinearProgressIndicator(
                    value: initState.progressPercentage / 100.0,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      initState.isFailed ? colorScheme.error : colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 进度百分比
                Text(
                  '${initState.progressPercentage}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),

                // 当前步骤描述
                if (initState.currentStepDescription != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      initState.currentStepDescription!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // 错误信息
                if (initState.errorMessage != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '初始化失败',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          initState.errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onErrorContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 操作按钮
                if (initState.isFailed || initState.errorMessage != null) ...[
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 重试按钮
                      ElevatedButton.icon(
                        onPressed: () async {
                          await ref.read(initializationProvider.notifier).refresh();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('重试'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 跳过按钮（强制进入登录页）
                      TextButton.icon(
                        onPressed: () {
                          // 强制设置用户状态为已初始化
                          ref.read(xboardUserProvider.notifier).forceInitialized();
                          context.go('/login');
                        },
                        icon: const Icon(Icons.skip_next),
                        label: const Text('跳过'),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],

                // 提示信息
                const SizedBox(height: 48),
                Text(
                  '首次启动可能需要一些时间\n请耐心等待...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
