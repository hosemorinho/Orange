import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/hotkey_manager.dart';
import 'package:fl_clash/manager/manager.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'controller.dart';
import 'xboard/xboard.dart';
import 'package:fl_clash/xboard/router/app_router.dart' as xboard_router;
import 'package:fl_clash/xboard/features/initialization/initialization.dart';

class Application extends ConsumerStatefulWidget {
  const Application({
    super.key,
  });

  @override
  ConsumerState<Application> createState() => ApplicationState();
}

class ApplicationState extends ConsumerState<Application> {
  Timer? _autoUpdateGroupTaskTimer;
  Timer? _autoUpdateProfilesTaskTimer;
  late final GoRouter _router;

  final _pageTransitionsTheme = const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CommonPageTransitionsBuilder(),
      TargetPlatform.windows: CommonPageTransitionsBuilder(),
      TargetPlatform.linux: CommonPageTransitionsBuilder(),
      TargetPlatform.macOS: CommonPageTransitionsBuilder(),
    },
  );

  ColorScheme _getAppColorScheme({
    required Brightness brightness,
    int? primaryColor,
  }) {
    return ref.read(genColorSchemeProvider(brightness));
  }

  @override
  void initState() {
    super.initState();
    _router = _createRouter();

    // 监听用户状态变化，刷新路由
    ref.listenManual(
      xboardUserProvider.select((state) => state.isInitialized),
      (previous, next) {
        debugPrint('[Application] isInitialized 变化: $previous -> $next');
        if (next) {
          _router.refresh();
        }
      },
      fireImmediately: false,
    );

    ref.listenManual(
      xboardUserProvider.select((state) => state.isAuthenticated),
      (previous, next) {
        debugPrint('[Application] isAuthenticated 变化: $previous -> $next');
        _router.refresh();
      },
      fireImmediately: false,
    );

    _autoUpdateGroupTask();
    _autoUpdateProfilesTask();
    globalState.appController = AppController(context, ref);

    // ✅ 后台预热：统一初始化服务（不阻塞 UI）
    // 这样快速认证和登录页都能使用已初始化的 SDK
    Future.microtask(() async {
      try {
        await ref.read(initializationProvider.notifier).initialize();
      } catch (e) {
        // 初始化失败，登录页会处理
        debugPrint('[Application] 预热初始化失败: $e');
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final currentContext = globalState.navigatorKey.currentContext;
      if (currentContext != null) {
        globalState.appController = AppController(currentContext, ref);
      }

      // 快速认证独立运行，不被 Clash 核心初始化阻塞
      _performQuickAuthWithDomainService();

      // Clash 核心初始化（可能耗时较长，不阻塞认证流程）
      await globalState.appController.init();
      app?.initShortcuts();

      // 启动后检查更新
      _checkForUpdates();

    });
  }

  /// 使用新域名服务架构进行快速认证检查
  void _performQuickAuthWithDomainService() {
    Future.microtask(() async {
      try {
        debugPrint('[Application] 开始快速认证检查...');

        // 等待初始化完成，最多 30 秒（与 initializationProvider 的超时一致）
        // 使用 Future.any 确保任一条件满足就继续
        await Future.any([
          // 等待初始化完成或失败
          Future(() async {
            while (true) {
              await Future.delayed(const Duration(milliseconds: 200));
              final current = ref.read(initializationProvider);
              if (current.isReady || current.isFailed) {
                debugPrint('[Application] 初始化状态: ${current.status}');
                debugPrint('[Application] 错误信息: ${current.errorMessage}');
                break;
              }
            }
          }),
          // 30秒超时兜底（匹配 Provider 的超时时间）
          Future.delayed(const Duration(seconds: 30), () {
            debugPrint('[Application] 初始化等待超时（30秒），继续执行 quickAuth');
            final current = ref.read(initializationProvider);
            debugPrint('[Application] 超时时的初始化状态: ${current.status}');
          }),
        ]);

        // 无论初始化成功与否，都执行 quickAuth
        // quickAuth 内部 finally 保证 isInitialized = true
        // 这样即使 SDK 未就绪，路由也能从 /loading 跳转到 /login
        final userNotifier = ref.read(xboardUserProvider.notifier);
        await userNotifier.quickAuth();

        debugPrint('[Application] 快速认证检查完成');
      } catch (e) {
        debugPrint('[Application] 快速认证检查失败: $e');
        // quickAuth 的 finally 已保证 isInitialized = true
        // 但如果连 quickAuth 都没执行到，兜底通过 forceInitialized 处理
        final userNotifier = ref.read(xboardUserProvider.notifier);
        userNotifier.forceInitialized();
      }
    });
  }


  /// 检查应用更新
  void _checkForUpdates() {
    // 延迟5秒后检查更新，确保应用完全启动
    Future.delayed(const Duration(seconds: 5), () async {
      try {
        debugPrint('[Application] 开始自动检查更新...');
        final updateNotifier = ref.read(updateCheckProvider.notifier);
        await updateNotifier.checkForUpdates();
        
        // 检查是否有更新
        final updateState = ref.read(updateCheckProvider);
        if (updateState.hasUpdate && mounted) {
          final currentContext = globalState.navigatorKey.currentContext;
          if (currentContext != null) {
            debugPrint('[Application] 发现新版本，显示更新弹窗');
            // 显示更新弹窗
            showDialog(
              context: currentContext,
              barrierDismissible: !updateState.forceUpdate, // 强制更新时不能取消
              builder: (context) => UpdateDialog(state: updateState),
            );
          }
        } else if (updateState.error != null) {
          debugPrint('[Application] 自动更新检查失败，忽略错误: ${updateState.error}');
          // 自动检查失败时静默处理，不打扰用户
        } else {
          debugPrint('[Application] 已是最新版本');
        }
      } catch (e) {
        debugPrint('[Application] 自动更新检查异常: $e');
        // 自动检查异常时静默处理，不影响应用正常使用
      }
    });
  }

  _autoUpdateGroupTask() {
    _autoUpdateGroupTaskTimer = Timer(const Duration(milliseconds: 20000), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        globalState.appController.updateGroupsDebounce();
        _autoUpdateGroupTask();
      });
    });
  }

  _autoUpdateProfilesTask() {
    _autoUpdateProfilesTaskTimer = Timer(const Duration(minutes: 20), () async {
      await globalState.appController.autoUpdateProfiles();
      _autoUpdateProfilesTask();
    });
  }

  _buildPlatformState(Widget child) {
    if (system.isDesktop) {
      return WindowManager(
        child: TrayManager(
          child: HotKeyManager(
            child: ProxyManager(
              child: child,
            ),
          ),
        ),
      );
    }
    return AndroidManager(
      child: TileManager(
        child: child,
      ),
    );
  }

  _buildState(Widget child) {
    return AppStateManager(
      child: ClashManager(
        child: ConnectivityManager(
          onConnectivityChanged: (results) async {
            if (!results.contains(ConnectivityResult.vpn)) {
              await clashCore.closeConnections();
            }
            globalState.appController.updateLocalIp();
            globalState.appController.addCheckIpNumDebounce();
          },
          child: child,
        ),
      ),
    );
  }

  _buildPlatformApp(Widget child) {
    if (system.isDesktop) {
      return WindowHeaderContainer(
        child: child,
      );
    }
    return VpnManager(
      child: child,
    );
  }

  _buildApp(Widget child) {
    return MessageManager(
      child: ThemeManager(
        child: child,
      ),
    );
  }

  @override
  Widget build(context) {
    return _buildPlatformState(
      _buildState(
        Consumer(
          builder: (_, ref, child) {
            final locale =
                ref.watch(appSettingProvider.select((state) => state.locale));
            final themeProps = ref.watch(themeSettingProvider);

            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate
              ],
              builder: (_, child) {
                return AppEnvManager(
                  child: _buildPlatformApp(
                    _buildApp(child!),
                  ),
                );
              },
              routerConfig: _router,
              scrollBehavior: BaseScrollBehavior(),
              title: appName,
              locale: utils.getLocaleForString(locale),
              supportedLocales: AppLocalizations.delegate.supportedLocales,
              themeMode: themeProps.themeMode,
              theme: ThemeData(
                useMaterial3: true,
                pageTransitionsTheme: _pageTransitionsTheme,
                colorScheme: _getAppColorScheme(
                  brightness: Brightness.light,
                  primaryColor: themeProps.primaryColor,
                ).toNeutralSurface(),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                pageTransitionsTheme: _pageTransitionsTheme,
                colorScheme: _getAppColorScheme(
                  brightness: Brightness.dark,
                  primaryColor: themeProps.primaryColor,
                ).toNeutralSurface().toPureBlack(themeProps.pureBlack),
              ),
            );
          },
        ),
      ),
    );
  }

  GoRouter _createRouter() {
    return GoRouter(
      navigatorKey: globalState.navigatorKey,
      initialLocation: '/',
      routes: xboard_router.routes,
      redirect: (context, state) {
        final userState = ref.read(xboardUserProvider);
        final isAuthenticated = userState.isAuthenticated;
        final isInitialized = userState.isInitialized;
        final isLoginPage = state.uri.path == '/login';

        if (!isInitialized) {
          return '/loading';
        }

        if (!isAuthenticated && !isLoginPage) {
          return '/login';
        }

        if (isAuthenticated && isLoginPage) {
          return '/';
        }

        return null;
      },
    );
  }

  @override
  Future<void> dispose() async {
    try {
      _autoUpdateGroupTaskTimer?.cancel();
      _autoUpdateProfilesTaskTimer?.cancel();

      await clashCore.destroy();
      await globalState.appController.savePreferences();
      await globalState.appController.handleExit();

    // ignore: empty_catches
    } catch (e) {
    }

    super.dispose();
  }
}

// ✅ 旧的 _AppHomeRouter 已被 go_router 替代
// go_router 通过 redirect 函数自动处理认证重定向