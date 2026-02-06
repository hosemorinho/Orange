# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Orange is a multi-platform proxy client based on [FlClash](https://github.com/chen08209/FlClash), with integrated V2Board v1.7.2 panel support. Built with Flutter/Dart, it targets Android, Windows, macOS, and Linux. All V2Board functionality lives in `lib/xboard/`, fully decoupled from the FlClash core.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Code generation (freezed models, Riverpod providers, JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Code generation in watch mode
dart run build_runner watch

# Run on connected device
flutter run

# Build (using CI-equivalent setup.dart script)
dart setup.dart android --arch arm64
dart setup.dart macos --arch arm64
dart setup.dart linux --arch amd64
dart setup.dart windows --arch amd64

# Build with customization
dart setup.dart android --env stable --package-name com.example.app --api-url https://panel.example.com --theme-color FF5722

# Build directly with Flutter
flutter build apk
flutter build macos
flutter build windows
flutter build linux

# Lint
dart analyze

# Run tests
flutter test

# Makefile shortcuts
make android_app          # Full Android build
make android_arm64        # Android ARM64 core
make macos_arm64          # macOS ARM64 core
```

## Architecture

The app uses a **layered architecture** with two main pillars:

### FlClash Core (inherited upstream)
- `lib/main.dart` — Entry point: initializes XBoard config, Clash core, then runs the app in a Riverpod `ProviderScope`
- `lib/application.dart` — Root widget: sets up GoRouter with auth-based redirects, Material 3 theming, platform-specific managers
- `lib/controller.dart` — Main app controller
- `lib/state.dart` — Global state management
- `lib/clash/` — Clash Meta integration (Go core via FFI through `core/dart-bridge/`)
- `lib/models/` — Core data models (with freezed code generation)
- `lib/providers/` — Riverpod state providers for FlClash features
- `lib/pages/`, `lib/views/`, `lib/widgets/` — UI layer
- `lib/common/constant.dart` — App-wide constants and `--dart-define` env var parsing

### XBoard Module (`lib/xboard/`) — V2Board panel integration
Self-contained module with its own layered architecture, exported via `lib/xboard/xboard.dart`:

| Layer | Directory | Purpose |
|---|---|---|
| Core | `xboard/core/` | Zero-dependency utilities: logger, exceptions, Result type |
| Domain | `xboard/domain/` | Business models (User, Plan, Order, Subscription) and repository interfaces |
| Infrastructure | `xboard/infrastructure/` | API client (`v2board_api_service.dart`), HTTP wrapper, domain racing, cache, storage |
| Config | `xboard/config/` | Configuration models, domain selection |
| Adapter | `xboard/adapter/` | Riverpod state providers (user, subscription, order, plan, etc.) and API service initialization |
| Features | `xboard/features/` | Feature modules: auth, subscription, payment, invite, notice, profile, domain_status, latency, update_check |
| Router | `xboard/router/` | GoRouter route definitions |
| Services | `xboard/services/` | Storage provider |

### Initialization Flow
1. `main()` initializes `XBoardConfig` with default `ConfigSettings`
2. `Application.initState()` triggers `initializationProvider` (domain racing + API service setup) in background
3. After initialization, quick auth check runs; GoRouter redirects based on auth state (`/login` vs `/`)

### Key Patterns
- **State management**: Riverpod (`flutter_riverpod`) with code-generated providers (`riverpod_generator`)
- **Routing**: GoRouter with auth-aware redirects in `application.dart`
- **Models**: Freezed for immutable models with JSON serialization
- **HTTP**: Dio-based client (`xboard_http_client.dart`) wrapping V2Board API calls
- **Domain racing**: Multiple panel URLs tested concurrently, fastest wins (skipped if `API_BASE_URL` env var is set)
- **Theming**: Material 3 with `ColorScheme.fromSeed()` using configurable seed color

## Build-time Configuration

All customization via `--dart-define` (no source changes needed):

| Variable | Default | Purpose |
|---|---|---|
| `APP_NAME` | `Flclash` | App display name (window titles, installers, etc.) |
| `APP_PACKAGE_NAME` | `com.follow.clash` | Android applicationId |
| `API_BASE_URL` | *(empty)* | V2Board panel URL; if set, skips domain racing |
| `THEME_COLOR` | `66558E` | Material 3 seed color (6-digit hex) |

These are parsed in `lib/common/constant.dart`.

## Code Generation

Generated files go to `generated/` subdirectories (configured in `build.yaml`):
- `lib/models/generated/` — Core model serialization
- `lib/xboard/domain/models/generated/` — Domain model serialization + freezed
- `lib/xboard/adapter/state/generated/` — Riverpod provider generation
- `lib/xboard/adapter/initialization/generated/` — API service provider generation

Always run `dart run build_runner build --delete-conflicting-outputs` after modifying models or providers annotated with `@freezed`, `@JsonSerializable`, or `@riverpod`.

## Platform-specific Code

- **Android**: Kotlin (`android/`), proxy plugin (`plugins/proxy/`), signing via GitHub Secrets
- **macOS**: Swift (`macos/`)
- **Go core**: Clash Meta in `core/Clash.Meta/` (git submodule), bridged via `core/dart-bridge/` FFI
- **Submodules**: `core/Clash.Meta` and `plugins/flutter_distributor` — initialize with `git submodule update --init --recursive`

## Localization

- ARB files in `arb/` directory, output to `lib/l10n/`
- Class: `AppLocalizations` (configured in `pubspec.yaml` under `flutter_intl`)
- Languages: Chinese (primary), English

## Theme System (Material 3)

### Color Scheme

**Default Theme**: Slate Purple (`#66558E`) with **Tonal Spot** variant

The app uses Material 3's `ColorScheme.fromSeed()` with `DynamicSchemeVariant.tonalSpot` (configured in `lib/models/config.dart`):

```dart
@Default(DynamicSchemeVariant.tonalSpot) DynamicSchemeVariant schemeVariant,
```

### Color Roles

| Role | Light Mode | Dark Mode | Usage |
|------|-----------|-----------|-------|
| `primary` | `#66558E` (deep purple) | `#CDB5FF` (bright purple) | Main actions, brand identity |
| `primaryContainer` | `#E7DEFF` (light purple) | `#4E3D76` (dark purple) | Large containers, cards |
| `tertiary` | `#7E525E` (pink-purple) | `#F3B8C6` (light pink) | Status indicators (e.g., VPN running) |
| `tertiaryContainer` | `#FFD8E2` (light pink) | `#643A47` (dark pink) | Status containers |
| `error` | System red | System red | Error states |
| `surface` | `#FFF8FF` | `#141316` | Backgrounds, surfaces |
| `onPrimary` / `onTertiary` | White | Dark | Text on colored backgrounds |

### Code Guidelines

**Always use theme colors** instead of hardcoded values:

```dart
// ✅ Good
color: Theme.of(context).colorScheme.primary,
backgroundColor: colorScheme.primaryContainer,
foregroundColor: colorScheme.onPrimaryContainer,

// ❌ Bad
color: Colors.blue,
backgroundColor: Colors.white,
foregroundColor: Colors.black,
```

**VPN Button States**:
- Stopped: `primary` / `primaryContainer`
- Running: `tertiary` / `tertiaryContainer`

**Always pair with `on*` colors**:
```dart
Container(
  color: colorScheme.primary,
  child: Text('Hello', style: TextStyle(color: colorScheme.onPrimary)),
)
```

### Contrast Requirements

All color combinations must meet **WCAG AA** (≥ 4.5:1 contrast). Material 3's `ColorScheme.fromSeed()` automatically ensures this.

## UI Component Patterns

### Start Button (`lib/views/dashboard/widgets/start_button.dart`)

Uses state-based colors:
- Background: `isStart ? tertiary : primary`
- Foreground: `isStart ? onTertiary : onPrimary`

### XBoard Connect Button (`lib/xboard/features/subscription/widgets/xboard_connect_button.dart`)

Two modes:
- **Floating**: Uses `tertiary`/`primary` for background
- **Inline**: Uses `tertiaryContainer`/`primaryContainer` for better contrast on large surfaces

### Subscription Plans (`lib/xboard/features/payment/pages/plans.dart`)

- Price tags: `primary` gradient with `onPrimary` text
- Buy buttons: `primary` background with `onPrimary` foreground
- Error states: `error` color
- Empty states: `onSurfaceVariant` color

## CI/CD

### GitHub Actions Workflows

**`build.yaml`** (Main build workflow):
1. Triggers on push to `main`, releases, or manual dispatch
2. Builds for Android, Linux, Windows, macOS (Intel + ARM)
3. Runs code generation before building
4. Uploads artifacts and creates releases

**`codegen.yaml`** (Code generation workflow):
1. Triggers on push/PR when `.dart`, `pubspec.yaml`, or `build.yaml` changes
2. Runs `flutter pub run intl_utils:generate`
3. Runs `dart run build_runner build --delete-conflicting-outputs`
4. Verifies generation success (does NOT commit `.g.dart` or `.freezed.dart` files)
5. Only commits localization and platform-specific files if needed

**Important**: Generated `.g.dart` and `.freezed.dart` files are in `.gitignore` and regenerated during build. Do NOT commit them manually.

## Change Log (Recent)

### 2026-02-06: API_TEXT_DOMAIN Integration & Theme Default Update

**DNS TXT Resolution with Dynamic Configuration**:
- Added comprehensive API configuration resolution via encrypted DNS TXT records
- Implemented DoH (DNS-over-HTTPS) resolver with 4-server redundancy:
  - Alibaba Cloud DNS: 223.5.5.5 / 223.6.6.6 (optimized for China)
  - Cloudflare DNS: 1.1.1.1 / 1.0.0.1 (global backup)
  - All servers race concurrently, fastest response wins
- Added CryptoJS-compatible AES-256-CBC decryptor with EVP_BytesToKey key derivation
- Supports encrypted JSON config with `crisp` and `hosts` fields
- No new package dependencies required (uses existing `crypto` + `encrypt` packages)

**Domain Racing Integration**:
- Integrated TXT resolution into domain status service with 3-path logic:
  - **PATH 1**: `API_TEXT_DOMAIN` → resolve TXT → race (resolved hosts + `API_BASE_URL`)
  - **PATH 2**: `API_BASE_URL` only → direct use (existing behavior)
  - **PATH 3**: neither → config file racing (existing behavior)
- Added `XBoardConfig.setLastRacingResult()` for external racing result storage
- Automatic fallback to `API_BASE_URL` or config file if TXT resolution fails

**Dynamic Crisp Chat Integration**:
- Added `crisp_config.dart` with `effectiveCrispWebsiteId` getter
- Priority: `CRISP_WEBSITE_ID` env var > TXT-resolved value > none
- Updated `crisp_chat_service.dart` and `crisp_chat_button.dart` to use dynamic ID
- Button auto-rebuilds after TXT resolution completes (watches `initializationProvider`)

**GitHub Actions Workflow Fix**:
- Fixed missing environment variables in build workflow
- Added `API_TEXT_DOMAIN` and `CRISP_WEBSITE_ID` to env propagation
- Added `workflow_dispatch` inputs for manual override on manual triggers
- Now properly passes all configured secrets to build process

**Theme Default Mode**:
- Changed default theme mode from `ThemeMode.dark` to `ThemeMode.system`
- App now follows system light/dark mode automatically by default
- Users can still manually select light/dark/auto in settings

**New Files** (4):
- `lib/xboard/infrastructure/network/doh_txt_resolver.dart` (222 lines)
- `lib/xboard/infrastructure/network/cryptojs_aes_decryptor.dart` (111 lines)
- `lib/xboard/infrastructure/network/api_text_resolver.dart` (153 lines)
- `lib/xboard/features/crisp/crisp_config.dart` (24 lines)

**Modified Files** (9):
- `lib/common/constant.dart` - Added `apiTextDomain` constant
- `lib/xboard/features/domain_status/services/domain_status_service.dart` - Core TXT integration
- `lib/xboard/config/xboard_config.dart` - Added `setLastRacingResult()` setter
- `lib/xboard/features/crisp/crisp_chat_service.dart` - Dynamic Crisp ID
- `lib/xboard/features/crisp/crisp_chat_button.dart` - Dynamic Crisp ID + rebuild watch
- `lib/xboard/infrastructure/network/network.dart` - Export new modules
- `lib/xboard/xboard.dart` - Export crisp_config
- `setup.dart` - Support `API_TEXT_DOMAIN` and `CRISP_WEBSITE_ID` in env.json
- `.github/workflows/build.yaml` - Fix env var propagation
- `lib/models/config.dart` - Default theme mode to system

**Configuration Usage**:
```bash
# Via GitHub Secrets (recommended for CI/CD)
# Set in repo Settings → Secrets and variables → Actions:
# - CRISP_WEBSITE_ID=your-crisp-id
# - API_TEXT_DOMAIN=txt.example.com

# Via command line
dart setup.dart android --arch arm64 \
  --dart-define=API_TEXT_DOMAIN=txt.example.com \
  --dart-define=CRISP_WEBSITE_ID=your-crisp-id
```

**TXT Record Format** (encrypted with AES, password = `appName`):
```json
{
  "crisp": "your-crisp-website-id",
  "hosts": ["https://api1.example.com", "https://api2.example.com"]
}
```

**Commits**:
- `b5e5d56` - feat: add API_TEXT_DOMAIN support with DNS TXT resolution and dynamic Crisp integration
- `[pending]` - feat: change default theme mode to system (auto light/dark)

---

### 2026-02-01: Theme System & UI Refactor

**Theme Changes**:
- Changed default color scheme variant from `content` to `tonalSpot` for better tonal palette generation
- Maintains slate purple (`#66558E`) as seed color
- Auto-generates harmonious colors for light/dark modes with proper contrast

**UI Component Refactor**:
1. **Subscription Plans** (`plans.dart`):
   - Price tags: Blue gradient → Primary theme color gradient
   - Buy button: Hardcoded blue → Theme primary
   - Error states: Hardcoded red → Theme error color
   - Empty states: Hardcoded grey → Theme onSurfaceVariant

2. **VPN Start Buttons** (`start_button.dart`, `xboard_connect_button.dart`):
   - Removed hardcoded green/blue/black/white colors
   - Stop state: Uses `primary` color (slate purple)
   - Running state: Uses `tertiary` color (pink-purple accent)
   - Auto-adapts to light/dark modes with proper contrast
   - Uses semantic color roles (`primaryContainer`, `tertiaryContainer`, etc.)

3. **CI/CD Workflow**:
   - Added `codegen.yaml` for automatic code generation
   - Fixed issue where workflow tried to commit `.gitignore`d files
   - Only commits localization and platform-specific generated files

**Color Mapping**:

| Component | State | Light Mode | Dark Mode |
|-----------|-------|------------|-----------|
| Start Button | Stopped | Deep purple `#66558E` | Bright purple `#CDB5FF` |
| Start Button | Running | Pink-purple `#7E525E` | Light pink `#F3B8C6` |
| Price Tag | - | Purple gradient | Bright purple gradient |
| Buy Button | - | Deep purple | Bright purple |

**Files Modified**:
- `lib/models/config.dart` - Default scheme variant
- `lib/xboard/features/payment/pages/plans.dart` - Plan colors
- `lib/xboard/features/subscription/widgets/xboard_connect_button.dart` - Button colors
- `lib/views/dashboard/widgets/start_button.dart` - Button colors
- `.github/workflows/codegen.yaml` - New workflow
- `.gitignore` - Added MD file exclusions

**Commits**:
- `a3cc146` - feat: change default color scheme to tonalSpot
- `e15be60` - fix: adapt subscription plan colors to theme system
- `24d3d1e` - refactor: modernize VPN start button with Material 3 colors
- `e5b881e` - docs: add theme implementation documentation
- `4f757de` - fix: codegen workflow should not commit ignored generated files
