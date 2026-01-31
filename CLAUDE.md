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
| Config | `xboard/config/` | Configuration loading (`xboard.config.yaml`), domain selection |
| Adapter | `xboard/adapter/` | Riverpod state providers (user, subscription, order, plan, etc.) and API service initialization |
| Features | `xboard/features/` | Feature modules: auth, subscription, payment, invite, notice, profile, domain_status, latency, update_check |
| Router | `xboard/router/` | GoRouter route definitions |
| Services | `xboard/services/` | Storage provider |

### Initialization Flow
1. `main()` loads `xboard.config.yaml` via `ConfigFileLoader` and initializes `XBoardConfig`
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
