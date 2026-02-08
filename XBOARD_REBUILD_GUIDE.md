# XBoard 集成重建指南

> 基于 FlClash 最新版本 (v0.8.92)，重新集成 Orange 的 V2Board (XBoard) 模块

## 背景

Orange 项目基于 Orange2（FlClash v0.8.85）合并最新 FlClash 开发而来。由于 FlClash v0.8.85 → v0.8.92 之间有一个 **重大架构变更**（Android 核心进程分离，AIDL IPC），导致合并后 Android 端持续出现：

- "正在加载订阅配置" 转圈
- "配置加载失败，内核未能解析节点"
- `groups` 始终为空

根因是 **初始化时序竞态**：XBoard 的 `quickAuth` 与 FlClash 核心的 `_init()` 并行运行，导致配置应用时机混乱。

本文档记录从零在最新 FlClash 上重建 XBoard 集成的完整步骤。

---

## 第一阶段：基础准备

### 1.1 FlClash 基线确认

```bash
cd /home/FlClash
git log --oneline -1   # 确认版本: 672eacc (v0.8.92)
flutter run             # 确认 FlClash 本身可正常运行
```

### 1.2 添加 XBoard 依赖

**pubspec.yaml** — 在 `dependencies:` 中追加：

```yaml
  # === XBoard 模块依赖 ===
  go_router: ^14.6.2           # 声明式路由 + 认证 redirect
  encrypt: ^5.0.1              # AES-256-CBC 解密 DNS TXT 配置
  pointycastle: ^3.9.1         # 加密原语 (EVP_BytesToKey)
  http: ^1.1.0                 # DoH DNS-over-HTTPS 解析
  flutter_markdown: ^0.7.4+1   # V2Board 公告 Markdown 渲染
  flutter_widget_from_html: ^0.17.1  # V2Board HTML 内容渲染
  uuid: ^4.4.0                 # UUID 生成
  qr_flutter: ^4.1.0           # 邀请码 QR 码
  socks5_proxy: ^2.1.1         # SOCKS5 代理支持
  crisp_chat: ^2.4.3           # Crisp 在线客服
```

**移除 FlClash 独有（XBoard 不需要）的依赖**：
```yaml
  # 可选移除（如果不需要深链接和 Windows 注册表）
  # app_links: ^6.4.0        # 深链接（XBoard 有自己的路由）
  # win32_registry: ^2.0.0   # Windows 注册表
```

**dev_dependencies 追加**：
```yaml
  custom_lint: ^0.8.1
  intl_utils: ^2.8.11
  mockito: ^5.4.4
```

### 1.3 添加 build.yaml 代码生成映射

在 `build.yaml` 中追加 XBoard 的 `source_gen|combining_builder` 和 `freezed|freezed` 映射：

```yaml
targets:
  $default:
    builders:
      source_gen|combining_builder:
        options:
          build_extensions:
            # FlClash 原有
            "lib/models/{{file}}.dart": "lib/models/generated/{{file}}.g.dart"
            "lib/providers/{{file}}.dart": "lib/providers/generated/{{file}}.g.dart"
            # XBoard 模块
            "lib/xboard/database/{{file}}.dart": "lib/xboard/database/generated/{{file}}.g.dart"
            "lib/xboard/adapter/state/{{file}}.dart": "lib/xboard/adapter/state/generated/{{file}}.g.dart"
            "lib/xboard/adapter/initialization/{{file}}.dart": "lib/xboard/adapter/initialization/generated/{{file}}.g.dart"
            "lib/xboard/domain/models/{{file}}.dart": "lib/xboard/domain/models/generated/{{file}}.g.dart"
            "lib/xboard/features/auth/providers/{{file}}.dart": "lib/xboard/features/auth/providers/generated/{{file}}.g.dart"
            "lib/xboard/features/order/providers/{{file}}.dart": "lib/xboard/features/order/providers/generated/{{file}}.g.dart"
            "lib/xboard/features/invite/providers/{{file}}.dart": "lib/xboard/features/invite/providers/generated/{{file}}.g.dart"
            "lib/xboard/features/ticket/providers/{{file}}.dart": "lib/xboard/features/ticket/providers/generated/{{file}}.g.dart"
            "lib/xboard/features/notice/providers/{{file}}.dart": "lib/xboard/features/notice/providers/generated/{{file}}.g.dart"
            "lib/xboard/features/subscription/providers/{{file}}.dart": "lib/xboard/features/subscription/providers/generated/{{file}}.g.dart"
            "lib/xboard/features/latency/providers/{{file}}.dart": "lib/xboard/features/latency/providers/generated/{{file}}.g.dart"
            "lib/xboard/features/domain_status/providers/{{file}}.dart": "lib/xboard/features/domain_status/providers/generated/{{file}}.g.dart"
      freezed|freezed:
        options:
          build_extensions:
            # FlClash 原有
            "lib/models/{{file}}.dart": "lib/models/generated/{{file}}.freezed.dart"
            # XBoard 模块
            "lib/xboard/domain/models/{{file}}.dart": "lib/xboard/domain/models/generated/{{file}}.freezed.dart"
            "lib/xboard/features/initialization/models/{{file}}.dart": "lib/xboard/features/initialization/models/generated/{{file}}.freezed.dart"
```

### 1.4 添加资源文件

```bash
# 证书文件（用于 TLS pinning / 自定义 CA）
mkdir -p assets/cer/
# 从 Orange 复制证书（如有）
cp /home/Orange/assets/cer/* assets/cer/ 2>/dev/null || true
```

在 `pubspec.yaml` 的 `flutter.assets` 中追加：
```yaml
    - assets/cer/
```

---

## 第二阶段：复制 XBoard 模块

### 2.1 复制核心模块（自包含，无需修改）

```bash
# XBoard 模块（286 个 Dart 文件，完全自包含）
cp -r /home/Orange/lib/xboard/ lib/xboard/

# 国际化文件（包含 619 个 xboard 相关翻译条目）
cp /home/Orange/arb/intl_zh_CN.arb arb/intl_zh_CN.arb
cp /home/Orange/arb/intl_en.arb arb/intl_en.arb
```

### 2.2 验证模块独立性

```bash
# 确认 xboard 模块只依赖 fl_clash 公共 API
grep -rh "^import 'package:fl_clash" lib/xboard/ | sort -u
```

XBoard 对 FlClash 的依赖应仅限于：
- `package:fl_clash/common/common.dart` — 工具函数
- `package:fl_clash/models/models.dart` — Profile 等核心模型
- `package:fl_clash/providers/providers.dart` — Riverpod providers
- `package:fl_clash/controller.dart` — appController 单例
- `package:fl_clash/state.dart` — globalState
- `package:fl_clash/core/core.dart` — coreController
- `package:fl_clash/enum/enum.dart` — 枚举类型

---

## 第三阶段：修改 FlClash 入口文件

### 3.1 `lib/common/constant.dart` — 添加构建时配置

在文件顶部追加 Orange 的环境变量解析：

```dart
// === XBoard 构建时配置（通过 --dart-define 传入）===
const _envPackageName = String.fromEnvironment('APP_PACKAGE_NAME');
const _envApiBaseUrl = String.fromEnvironment('API_BASE_URL');
const _envThemeColor = String.fromEnvironment('THEME_COLOR');
const _envAppName = String.fromEnvironment('APP_NAME');
const _envCrispWebsiteId = String.fromEnvironment('CRISP_WEBSITE_ID');
const _envApiTextDomain = String.fromEnvironment('API_TEXT_DOMAIN');

// 修改原有 appName 常量
const appName = _envAppName == '' ? 'FlClash' : _envAppName;  // 默认值改为你的品牌名
const crispWebsiteId = _envCrispWebsiteId;
const apiTextDomain = _envApiTextDomain;
const packageName = _envPackageName == '' ? 'com.follow.clash' : _envPackageName;
const apiBaseUrl = _envApiBaseUrl;
const themeColorHex = _envThemeColor == '' ? '66558E' : _envThemeColor;

int parseThemeColor() {
  if (themeColorHex.isEmpty) return 0xFF66558E;
  final hex = themeColorHex.replaceFirst('#', '');
  final value = int.tryParse(hex, radix: 16);
  if (value == null) return 0xFF66558E;
  return hex.length <= 6 ? (0xFF000000 | value) : value;
}
```

### 3.2 `lib/main.dart` — 添加 XBoard 初始化

在 FlClash 原有初始化之后，添加 XBoard 服务初始化：

```dart
import 'package:fl_clash/xboard/config/xboard_config.dart';

// 在 main() 函数中，FlClash init 之后追加：
await _initializeXBoardServices();

Future<void> _initializeXBoardServices() async {
  try {
    await XBoardConfig.initialize();
    debugPrint('[Main] XBoard 服务初始化完成');
  } catch (e) {
    debugPrint('[Main] XBoard 服务初始化失败: $e');
    rethrow;
  }
}
```

### 3.3 `lib/application.dart` — 核心改造

这是改动最大的文件。**关键原则：quickAuth 必须在 `_init()` 完成之后执行**。

#### 改造要点：

1. **路由**：`MaterialApp` → `MaterialApp.router` + GoRouter
2. **认证感知**：监听 `xboardUserProvider` 进行路由 redirect
3. **初始化时序**：`_attachWithRetry()` 完成后才触发 `quickAuth`

```dart
// 新增 imports
import 'package:go_router/go_router.dart';
import 'xboard/xboard.dart';
import 'package:fl_clash/xboard/router/app_router.dart' as xboard_router;
import 'package:fl_clash/xboard/features/initialization/initialization.dart';

class ApplicationState extends ConsumerState<Application> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _createRouter();

    // 监听认证状态变化，刷新路由
    ref.listenManual(
      xboardUserProvider.select((state) => state.isInitialized),
      (previous, next) {
        if (next) _router.refresh();
      },
      fireImmediately: false,
    );
    ref.listenManual(
      xboardUserProvider.select((state) => state.isAuthenticated),
      (previous, next) => _router.refresh(),
      fireImmediately: false,
    );

    // 后台预热域名竞速（不阻塞 UI）
    Future.microtask(() async {
      try {
        await ref.read(initializationProvider.notifier).initialize();
      } catch (e) {
        debugPrint('[Application] 初始化失败: $e');
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ⚠️ 关键：先完成核心初始化，再执行 quickAuth
      await _attachWithRetry();

      // 核心已就绪，现在安全执行 quickAuth
      _performQuickAuth();

      _autoUpdateProfilesTask();
      app?.initShortcuts();
    });
  }

  /// quickAuth 在 _init() 完成后执行，避免竞态
  void _performQuickAuth() {
    Future.microtask(() async {
      try {
        // 等待域名竞速完成（带超时）
        final completer = Completer<void>();
        final sub = ref.listenManual(
          initializationProvider,
          (previous, current) {
            if ((current.isReady || current.isFailed) && !completer.isCompleted) {
              completer.complete();
            }
          },
          fireImmediately: true,
        );
        await completer.future.timeout(const Duration(seconds: 30), onTimeout: () {});
        sub.close();

        if (!mounted) return;
        await ref.read(xboardUserProvider.notifier).quickAuth();
      } catch (e) {
        debugPrint('[Application] quickAuth 失败: $e');
        if (mounted) ref.read(xboardUserProvider.notifier).forceInitialized();
      }
    });
  }

  GoRouter _createRouter() {
    return GoRouter(
      navigatorKey: globalState.navigatorKey,
      initialLocation: '/',
      routes: xboard_router.routes,
      redirect: (context, state) {
        final userState = ref.read(xboardUserProvider);
        if (!userState.isInitialized) return '/loading';
        if (!userState.isAuthenticated && state.uri.path != '/login') return '/login';
        if (userState.isAuthenticated && state.uri.path == '/login') return '/';
        return null;
      },
    );
  }

  // build() 中：MaterialApp → MaterialApp.router
  // routerConfig: _router,
  // 去掉 home: const HomePage()
}
```

### 3.4 `lib/controller.dart` — 最小化改动

仅添加 Orange 的改进，**不改变上游核心逻辑**：

```dart
// _init() 中：
// 1. 移除 _handlerDisclaimer() 和 _showCrashlyticsTip()（如果不需要）
// 2. 保持 _connectCore() → _initCore() → _initStatus() 原有顺序

// _setupConfig() 中：
// 1. 可选：添加 Android IPC 重试逻辑（getProfile 3次重试 + setupConfig 3次重试）
// 2. 可选：添加端口可用性检查（非 Android）
```

**不要修改 `_initCore()`**，保持上游原样：
```dart
// FlClash 原版（不要改）
Future<void> _initCore() async {
  final isInit = await coreController.isInit;
  final version = _ref.read(versionProvider);
  if (!isInit) {
    await coreController.init(version);
  } else {
    await updateGroups();
  }
}
```

`_initStatus()` 负责 `applyProfile(force: true)`，这才是正确的配置加载入口。

### 3.5 `lib/state.dart` — 可选改动

```dart
// 可选：自动检测语言（首次启动）
if (config.appSettingProps.locale == null) {
  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
  final detectedLocale = deviceLocale.languageCode.startsWith('zh') ? 'zh_CN' : 'en';
  config = config.copyWith(
    appSettingProps: config.appSettingProps.copyWith(locale: detectedLocale),
  );
}
```

### 3.6 `lib/common/http.dart` — 安全检查

添加 `isAttach` 检查，防止 `appController._ref` 在 `attach()` 前被访问：

```dart
// FlClashHttpOverrides.handleFindProxy 中：
if (!appController.isAttach) {
  return 'DIRECT';
}
```

---

## 第四阶段：Android 平台改动

### 4.1 移除 Firebase/Crashlytics（可选）

如果不需要 Firebase，删除以下内容：

| 文件 | 改动 |
|------|------|
| `android/settings.gradle.kts` | 移除 `com.google.gms.google-services` 和 `com.google.firebase.crashlytics` 插件 |
| `android/app/build.gradle.kts` | 移除 Firebase 插件和依赖 |
| `android/common/build.gradle.kts` | 移除 Firebase 依赖 |
| `android/gradle/libs.versions.toml` | 移除 Firebase 版本和库声明 |
| `GlobalState.kt` | 移除 `setCrashlytics()` 方法和 Firebase imports |
| `State.kt` | 移除 `setCrashlytics()` 调用 |
| `Service.kt` | 移除 `setCrashlytics()` 方法 |
| `models/State.kt` | 移除 `crashlytics` 字段 |
| `RemoteService.kt` | 移除 `setCrashlytics()` AIDL 实现 |
| `IRemoteInterface.aidl` | 移除 `void setCrashlytics(in boolean enable)` |
| `android/app/google-services.json` | 删除此文件 |

### 4.2 添加安全检查（推荐）

**`GlobalState.kt`**：
```kotlin
// 替换 force-unwrap
val isInitialized: Boolean get() = _application != null
val application: Application
    get() = _application
        ?: throw IllegalStateException("GlobalState.application accessed before init()")
```

**`State.kt`**：
```kotlin
// 在访问 GlobalState.application 前检查
if (GlobalState.isInitialized) {
    GlobalState.application.showToast(sharedState.stopTip)
}
```

### 4.3 品牌字符串替换

将 "FlClash" 替换为你的品牌名（如 "Orange"）：
- `GlobalState.kt`: `NOTIFICATION_CHANNEL`, `log()` tag
- `VpnService.kt`: `setSession()`
- `NotificationParams.kt`, `NotificationModule.kt`
- `AndroidManifest.xml`: `android:label`

---

## 第五阶段：构建与测试

### 5.1 代码生成

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter pub run intl_utils:generate
```

### 5.2 渐进式测试

```bash
# 第一步：确认 FlClash 基础功能正常（不加 XBoard 路由）
flutter run

# 第二步：加入 XBoard 路由和认证逻辑
# 测试 /login → / 跳转

# 第三步：测试 quickAuth + 订阅导入
# 确认 _init() 完成后才触发 importSubscription

# 第四步：测试 Android 全流程
flutter run -d android
```

### 5.3 构建发布

```bash
dart setup.dart android --arch arm64 \
  --dart-define=APP_NAME=Orange \
  --dart-define=API_BASE_URL=https://panel.example.com \
  --dart-define=THEME_COLOR=66558E
```

---

## 关键架构决策

### 初始化时序（最重要）

```
正确的时序：
  main() → FlClash init → XBoardConfig.initialize()
  ↓
  Application.initState()
    ├─ Future.microtask: initializationProvider (后台域名竞速)
    └─ addPostFrameCallback:
        1. await _attachWithRetry()     ← 等待核心完全就绪
        2. _performQuickAuth()          ← 核心就绪后才执行认证+导入
        3. _autoUpdateProfilesTask()

错误的时序（旧 Orange 的问题）：
  addPostFrameCallback:
    1. _performQuickAuth()     ← 与核心初始化并行！竞态！
    2. await _attachWithRetry()
```

### 订阅导入策略

XBoard 的 `SubscriptionDownloader` 使用独立的 DIRECT Dio 实例下载，不依赖 Clash 核心。这是正确的。

但 `_addProfile()` 中的 `applyProfile()` 调用必须在核心就绪后执行：

```dart
// profile_import_service.dart _addProfile() 中：
if (!appController.isAttach) {
  // 不尝试应用，核心初始化完成后 _initStatus() 会自动加载
  return;
}
await _applyProfileWithRetry();
```

### FlClash 上游不要改的部分

以下代码保持上游原样，**不要修改**：

| 文件 | 方法 | 原因 |
|------|------|------|
| `lib/core/interface.dart` | `_invoke()` | 上游已有 10s 超时 + handleWatch |
| `lib/core/controller.dart` | 全部 | 核心桥接层保持一致 |
| `lib/core/service.dart` | 全部 | 桌面端 socket 通信 |
| `lib/core/lib.dart` | 全部 | Android AIDL 通信 |
| `lib/core/event.dart` | 全部 | 事件分发 |
| `lib/controller.dart` | `_initCore()` | 不要加 `applyProfile()`，由 `_initStatus()` 处理 |

---

## XBoard 模块结构参考

```
lib/xboard/                          # 286 个 Dart 文件
├── xboard.dart                      # 模块导出入口
├── core/                            # 零依赖工具层 (10 files)
│   ├── exceptions/                  # 异常定义
│   ├── logger/                      # 日志系统 (Console/Disk/File)
│   ├── result/                      # Result<T> 类型
│   └── utils/                       # 通用工具
├── domain/                          # 业务模型层 (30 files)
│   ├── models/                      # User, Plan, Order, Subscription 等 (freezed)
│   └── repositories/                # 仓库接口
├── infrastructure/                  # 基础设施层 (29 files)
│   ├── api/                         # V2Board API 客户端
│   ├── http/                        # HTTP 客户端 + User-Agent
│   ├── network/                     # 域名竞速, DoH, AES 解密
│   ├── cache/                       # 内存缓存
│   └── storage/                     # 本地存储
├── config/                          # 配置层 (34 files)
│   ├── core/                        # ConfigSettings, ServiceLocator
│   ├── models/                      # 配置模型
│   ├── parsers/                     # 配置解析
│   └── services/                    # 面板/代理/更新服务
├── adapter/                         # Riverpod 适配层 (20 files)
│   ├── initialization/              # SDK Provider
│   └── state/                       # 用户/订阅/订单/计划等 state
├── database/                        # Drift 数据库层 (38 files)
│   ├── tables/                      # 表定义
│   ├── dao/                         # 数据访问对象
│   ├── converters/                  # 类型转换器
│   ├── repositories/                # 数据库仓库实现
│   └── providers/                   # 数据库 Provider
├── features/                        # 功能模块 (100+ files)
│   ├── auth/                        # 登录/注册/忘记密码
│   ├── subscription/                # 订阅管理 + VPN 英雄卡
│   ├── payment/                     # 套餐购买/支付
│   ├── profile/                     # 配置导入/管理
│   ├── crisp/                       # Crisp 在线客服
│   ├── domain_status/               # 域名状态监控
│   ├── latency/                     # 延迟测试
│   ├── update_check/                # 应用更新检查
│   ├── notice/                      # 公告通知
│   ├── ticket/                      # 工单支持
│   ├── invite/                      # 邀请返利
│   ├── order/                       # 订单管理
│   ├── settings/                    # XBoard 设置
│   ├── initialization/              # 初始化状态
│   └── shared/                      # 共享组件
├── router/                          # GoRouter 路由 (3 files)
├── services/                        # 存储服务 (5 files)
└── widgets/                         # 导航组件 (2 files)
```

## 构建时配置变量

| 变量 | 默认值 | 用途 |
|------|--------|------|
| `APP_NAME` | `FlClash` | 应用显示名称 |
| `APP_PACKAGE_NAME` | `com.follow.clash` | Android applicationId |
| `API_BASE_URL` | *(空)* | V2Board 面板地址；设置后跳过域名竞速 |
| `API_TEXT_DOMAIN` | *(空)* | DNS TXT 配置域名（加密配置分发） |
| `THEME_COLOR` | `66558E` | Material 3 种子色（6位 hex） |
| `CRISP_WEBSITE_ID` | *(空)* | Crisp 在线客服 ID |

---

## 国际化

XBoard 共 619 个翻译条目（中/英），全部以 `xboard` 前缀命名，在 `arb/` 目录中定义。

运行生成：
```bash
flutter pub run intl_utils:generate
```

输出到 `lib/l10n/`，使用 `AppLocalizations.of(context).xboardXxx` 访问。
