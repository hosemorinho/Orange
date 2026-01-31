<div align="center">

# Orange

**基于 FlClash 的多平台代理客户端，集成 V2Board 面板支持，支持环境变量自定义构建**

</div>

---

## 项目简介

Orange 是基于 [FlClash](https://github.com/chen08209/FlClash) 的增强版本，集成了 **V2Board v1.7.2** 面板支持。所有面板相关功能封装在独立的 `lib/xboard` 模块中，与上游 FlClash 代码解耦。

### 设计特点

- **模块化架构**：V2Board 功能独立于 FlClash 核心，便于跟进上游更新
- **直接 HTTP 调用**：不依赖第三方 SDK，直接对接 V2Board API
- **自定义构建**：通过 `--dart-define` 环境变量配置包名、API 地址、主题色
- **Material 3 主题**：使用 Google tonal 算法从种子色衍生完整色板

---

## 核心功能

| 功能 | 说明 |
|------|------|
| 用户认证 | 登录、注册、找回密码、邮箱验证 |
| 订阅管理 | 查看/刷新订阅、流量统计、到期提醒 |
| 套餐购买 | 浏览套餐、下单、多支付方式、订单管理 |
| 邀请返利 | 邀请码生成、佣金查看、提现 |
| 公告通知 | V2Board 公告展示 |
| 工单系统 | 通过 V2Board 工单与客服沟通 |
| 多域名竞速 | 自动选择最快面板域名 |
| 自动更新 | 应用版本检查与更新 |

---

## 平台支持

| 平台 | 状态 | 备注 |
|------|------|------|
| Android | 支持 | Android 7.0+ |
| Windows | 支持 | Windows 10+ |
| macOS | 支持 | macOS 10.14+ |
| Linux | 支持 | 需安装依赖 |

---

## 自定义构建

通过 `--dart-define` 环境变量在编译时配置应用参数，无需修改源代码：

| 环境变量 | 说明 | 默认值 |
|----------|------|--------|
| `APP_NAME` | 应用显示名称（窗口标题、安装包名等） | `Flclash` |
| `APP_PACKAGE_NAME` | Android 包名 (applicationId) | `com.follow.clash` |
| `API_BASE_URL` | V2Board 面板地址（跳过域名竞速） | 空（使用配置文件竞速） |
| `THEME_COLOR` | 主题种子色 (6位 hex) | `66558E` |

### 构建示例

```bash
# 默认构建
flutter build apk

# 自定义构建
flutter build apk \
  --dart-define=APP_NAME=MyVPN \
  --dart-define=APP_PACKAGE_NAME=com.example.myvpn \
  --dart-define=API_BASE_URL=https://panel.example.com \
  --dart-define=THEME_COLOR=FF5722
```

通过 `setup.dart` 构建（与 CI 一致）：

```bash
dart setup.dart android \
  --env stable \
  --app-name MyVPN \
  --package-name com.example.myvpn \
  --api-url https://panel.example.com \
  --theme-color FF5722
```

### 主题色

`THEME_COLOR` 作为 Material 3 的种子色，通过 `ColorScheme.fromSeed()` 自动衍生完整色板（primary、secondary、tertiary、surface 等），无需手动配置每个颜色。

默认色 `#66558E`（深紫色）。传入任意 6 位 hex 值即可改变整个应用配色。

---

## GitHub Actions CI

项目包含自动构建工作流，支持三种触发方式：

### 1. 推送到 main 分支

每次 push 到 `main` 自动构建，产物以 zip 形式上传到 **workflow artifacts**，可在 Actions 页面直接下载测试。

### 2. 创建 Release

在 GitHub 页面手动创建 Release 后，自动触发构建并将产物（含 SHA256 校验）上传到该 Release。

### 3. 手动触发 (workflow_dispatch)

进入 GitHub → Actions → build → Run workflow，可输入：
- `package_name`：覆盖包名
- `api_url`：覆盖 API 地址
- `theme_color`：覆盖主题色

### Secrets 配置

进入 Settings → Secrets and variables → Actions → **Secrets**，添加：

| Secret | 说明 |
|--------|------|
| `APP_NAME` | 应用显示名称（如 MyVPN） |
| `APP_PACKAGE_NAME` | 自定义包名 |
| `API_BASE_URL` | V2Board 面板地址 |
| `THEME_COLOR` | 主题种子色 hex |
| `KEYSTORE` | Android keystore 文件 base64 编码 |
| `KEY_ALIAS` | 密钥别名 |
| `STORE_PASSWORD` | keystore 密码 |
| `KEY_PASSWORD` | 密钥密码 |

> **注意**：`APP_PACKAGE_NAME`、`API_BASE_URL`、`THEME_COLOR` 必须放在 Secrets（而非 Variables）中，避免在 Actions 日志中泄露。

### 构建产物

| 平台 | 产物 |
|------|------|
| Android | APK (split per ABI) |
| Windows | EXE + ZIP |
| macOS | DMG |
| Linux | DEB + AppImage + RPM |

---

## 面板配置

### xboard.config.yaml

在 `assets/config/` 下创建 `xboard.config.yaml`：

```yaml
provider: v2board

panel:
  urls:
    - https://your-panel.example.com

proxy:
  urls: []

update:
  urls: []

subscription:
  urls:
    - https://your-panel.example.com
```

或通过 `API_BASE_URL` 环境变量直接指定面板地址，跳过配置文件和域名竞速。

---

## 项目结构

```
lib/
  xboard/
    adapter/          # 状态适配层（Riverpod providers）
    config/           # 配置加载与管理
    core/             # 基础工具（日志、Result、异常）
    domain/           # 领域模型（User, Plan, Order 等）
    features/         # 功能模块
      auth/           # 认证（登录、注册、找回密码）
      invite/         # 邀请返利
      notice/         # 公告
      payment/        # 支付与订单
      subscription/   # 订阅管理
    infrastructure/   # 基础设施
      api/            # V2Board API 客户端与映射
      http/           # HTTP 客户端封装
    router/           # 路由配置
    services/         # 存储等服务
    widgets/          # 通用 UI 组件
```

---

## 上游项目

- [FlClash](https://github.com/chen08209/FlClash) - 多平台 Clash 客户端
- [Clash Meta](https://github.com/MetaCubeX/Clash.Meta) - Clash 内核

---

## 免责声明

本软件仅供学习和研究使用。用户需自行承担使用本软件的风险。