import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/leaf/providers/leaf_providers.dart';
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
  const Application({super.key});

  @override
  ConsumerState<Application> createState() => ApplicationState();
}

class ApplicationState extends ConsumerState<Application> {
  Timer? _autoUpdateProfilesTaskTimer;
  bool _preHasVpn = false;
  late final GoRouter _router;

  final _pageTransitionsTheme = const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: commonSharedXPageTransitions,
      TargetPlatform.windows: commonSharedXPageTransitions,
      TargetPlatform.linux: commonSharedXPageTransitions,
      TargetPlatform.macOS: commonSharedXPageTransitions,
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

    // 后台预热：统一初始化服务（不阻塞 UI）
    Future.microtask(() async {
      try {
        await ref.read(initializationProvider.notifier).initialize();
      } catch (e) {
        debugPrint('[Application] 预热初始化失败: $e');
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // 快速认证独立运行，不被 Clash 核心初始化阻塞
      _performQuickAuthWithDomainService();

      await _attachWithRetry();

      _autoUpdateProfilesTask();
      app?.initShortcuts();

      // 启动后检查更新
      _checkForUpdates();
    });
  }

  /// Attach appController with retry when navigator context is not yet available
  Future<void> _attachWithRetry() async {
    for (int i = 0; i < 5; i++) {
      final currentContext = globalState.navigatorKey.currentContext;
      if (currentContext != null) {
        await appController.attach(currentContext, ref);
        return;
      }
      debugPrint('[Application] Navigator context is null, retry ${i + 1}/5...');
      await Future.delayed(const Duration(milliseconds: 100));
    }
    debugPrint('[Application] Navigator context still null after retries, force exit');
    exit(0);
  }

  /// 使用新域名服务架构进行快速认证检查
  void _performQuickAuthWithDomainService() {
    Future.microtask(() async {
      try {
        debugPrint('[Application] 开始快速认证检查...');

        // Use Completer + listen instead of busy-wait polling
        final completer = Completer<void>();

        // Listen for initialization state changes
        final sub = ref.listenManual(
          initializationProvider,
          (previous, current) {
            if ((current.isReady || current.isFailed) && !completer.isCompleted) {
              debugPrint('[Application] 初始化状态: ${current.status}');
              debugPrint('[Application] 错误信息: ${current.errorMessage}');
              completer.complete();
            }
          },
          fireImmediately: true,
        );

        // Wait for init or timeout
        await completer.future.timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            debugPrint('[Application] 初始化等待超时（30秒），继续执行 quickAuth');
          },
        );
        sub.close();

        if (!mounted) return;

        final userNotifier = ref.read(xboardUserProvider.notifier);
        await userNotifier.quickAuth();

        debugPrint('[Application] 快速认证检查完成');
      } catch (e) {
        debugPrint('[Application] 快速认证检查失败: $e');
        if (!mounted) return;
        final userNotifier = ref.read(xboardUserProvider.notifier);
        userNotifier.forceInitialized();
      }
    });
  }

  /// 检查应用更新
  void _checkForUpdates() {
    Future.delayed(const Duration(seconds: 5), () async {
      try {
        debugPrint('[Application] 开始自动检查更新...');
        final updateNotifier = ref.read(updateCheckProvider.notifier);
        await updateNotifier.checkForUpdates();

        final updateState = ref.read(updateCheckProvider);
        if (updateState.hasUpdate && mounted) {
          final currentContext = globalState.navigatorKey.currentContext;
          if (currentContext != null) {
            debugPrint('[Application] 发现新版本，显示更新弹窗');
            showDialog(
              context: currentContext,
              barrierDismissible: !updateState.forceUpdate,
              builder: (context) => UpdateDialog(state: updateState),
            );
          }
        } else if (updateState.error != null) {
          debugPrint('[Application] 自动更新检查失败，忽略错误: ${updateState.error}');
        } else {
          debugPrint('[Application] 已是最新版本');
        }
      } catch (e) {
        debugPrint('[Application] 自动更新检查异常: $e');
      }
    });
  }

  void _autoUpdateProfilesTask() {
    _autoUpdateProfilesTaskTimer = Timer(const Duration(minutes: 20), () async {
      await appController.autoUpdateProfiles();
      _autoUpdateProfilesTask();
    });
  }

  Widget _buildPlatformState({required Widget child}) {
    if (system.isDesktop) {
      return WindowManager(
        child: TrayManager(
          child: HotKeyManager(child: ProxyManager(child: child)),
        ),
      );
    }
    return AndroidManager(child: TileManager(child: child));
  }

  Widget _buildState({required Widget child}) {
    return AppStateManager(
      child: CoreManager(
        child: ConnectivityManager(
          onConnectivityChanged: (results) async {
            commonPrint.log('connectivityChanged ${results.toString()}');
            appController.updateLocalIp();
            final hasVpn = results.contains(ConnectivityResult.vpn);
            if (_preHasVpn == hasVpn) {
              appController.addCheckIp();
            }
            _preHasVpn = hasVpn;
          },
          child: child,
        ),
      ),
    );
  }

  Widget _buildPlatformApp({required Widget child}) {
    if (system.isDesktop) {
      return VpnManager(child: WindowHeaderContainer(child: child));
    }
    return VpnManager(child: child);
  }

  Widget _buildApp({required Widget child}) {
    return StatusManager(child: ThemeManager(child: child));
  }

  @override
  Widget build(context) {
    return Consumer(
      builder: (_, ref, child) {
        final locale = ref.watch(
          appSettingProvider.select((state) => state.locale),
        );
        final themeProps = ref.watch(themeSettingProvider);
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          builder: (_, child) {
            return AppEnvManager(
              child: _buildApp(
                child: _buildPlatformState(
                  child: _buildState(child: _buildPlatformApp(child: child!)),
                ),
              ),
            );
          },
          routerConfig: _router,
          scrollBehavior: BaseScrollBehavior(),
          title: appName,
          locale: utils.getLocaleForString(locale) ?? _getAutoLocale(),
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          themeMode: themeProps.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            pageTransitionsTheme: _pageTransitionsTheme,
            colorScheme: _getAppColorScheme(
              brightness: Brightness.light,
              primaryColor: themeProps.primaryColor,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            pageTransitionsTheme: _pageTransitionsTheme,
            colorScheme: _getAppColorScheme(
              brightness: Brightness.dark,
              primaryColor: themeProps.primaryColor,
            ).toPureBlack(themeProps.pureBlack),
          ),
        );
      },
    );
  }

  Locale _getAutoLocale() {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return deviceLocale.languageCode.startsWith('zh')
        ? const Locale('zh', 'CN')
        : const Locale('en');
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
    _autoUpdateProfilesTaskTimer?.cancel();
    await appController.handleExit();
    super.dispose();
  }
}
