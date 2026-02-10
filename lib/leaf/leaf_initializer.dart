import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/leaf/leaf_controller.dart';
import 'package:fl_clash/leaf/providers/leaf_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Initializes the leaf proxy core.
///
/// Call [initLeaf] during app startup (in place of `appController.attach()`).
/// This sets up the LeafController with the app's home directory.
class LeafInitializer {
  LeafInitializer._();

  static bool _initialized = false;

  /// Initialize the leaf core. Safe to call multiple times.
  ///
  /// This replaces `appController.attach()` for the leaf branch.
  static Future<void> initLeaf(dynamic ref) async {
    if (_initialized) return;

    T read<T>(ProviderListenable<T> provider) {
      if (ref is WidgetRef) return (ref as WidgetRef).read(provider);
      if (ref is Ref) return (ref as Ref).read(provider);
      throw ArgumentError('ref must be WidgetRef or Ref');
    }

    final controller = read(leafControllerProvider);

    final homeDir = await _getHomeDir();
    debugPrint('[LeafInitializer] Initializing with homeDir: $homeDir');
    await controller.init(homeDir);

    _initialized = true;
    debugPrint('[LeafInitializer] Initialized successfully');
  }

  /// Whether leaf has been initialized.
  static bool get isInitialized => _initialized;

  static Future<String> _getHomeDir() async {
    if (Platform.isAndroid) {
      return appPath.homePath;
    }
    // Desktop: use ~/.config/orange/leaf
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    final dir =
        '$home${Platform.pathSeparator}.config${Platform.pathSeparator}orange${Platform.pathSeparator}leaf';
    await Directory(dir).create(recursive: true);
    return dir;
  }
}
