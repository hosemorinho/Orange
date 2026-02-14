import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract mixin class ServiceListener {
  void onServiceCrash(String message) {}

  void onVpnStatusChanged({
    required String status,
    required bool connected,
  }) {}

  /// Called when core status changes in :core process.
  void onCoreStatusChanged(Map<String, dynamic> status) {}

  /// Called when core encounters an error.
  void onCoreError(String message) {}
}

class Service {
  static Service? _instance;
  late MethodChannel methodChannel;
  ReceivePort? receiver;

  final ObserverList<ServiceListener> _listeners =
      ObserverList<ServiceListener>();

  factory Service() {
    _instance ??= Service._internal();
    return _instance!;
  }

  Service._internal() {
    methodChannel = const MethodChannel('$packageName/service');
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'crash':
          final message = call.arguments as String? ?? '';
          for (final listener in _listeners) {
            listener.onServiceCrash(message);
          }
          break;
        case 'vpnStatus':
          final args = call.arguments;
          if (args is Map) {
            final status = args['status'] as String? ?? 'unknown';
            final connected = args['connected'] as bool? ?? false;
            for (final listener in _listeners) {
              listener.onVpnStatusChanged(
                status: status,
                connected: connected,
              );
            }
          }
          break;
        case 'coreStatus':
          // Core status changed in :core process
          final args = call.arguments;
          if (args is Map) {
            final status = Map<String, dynamic>.from(args);
            for (final listener in _listeners) {
              listener.onCoreStatusChanged(status);
            }
          }
          break;
        case 'coreError':
          // Core error in :core process
          final message = call.arguments as String? ?? '';
          for (final listener in _listeners) {
            listener.onCoreError(message);
          }
          break;
        default:
          commonPrint.log('unhandled service method: ${call.method}');
          break;
      }
    });
  }

  Future<bool> start() async {
    return await methodChannel.invokeMethod<bool>('start') ?? false;
  }

  Future<bool> stop() async {
    return await methodChannel.invokeMethod<bool>('stop') ?? false;
  }

  Future<String> init() async {
    return await methodChannel.invokeMethod<String>('init') ?? '';
  }

  Future<String> syncState(SharedState state) async {
    return await methodChannel.invokeMethod<String>(
          'syncState',
          json.encode(state),
        ) ??
        '';
  }

  /// Sync leaf runtime config JSON for iOS packet tunnel extension.
  Future<String> syncLeafConfig(String configJson) async {
    return await methodChannel.invokeMethod<String>(
          'syncLeafConfig',
          configJson,
        ) ??
        '';
  }

  /// Select node tag in iOS packet tunnel extension runtime.
  Future<bool> selectNode(String nodeTag) async {
    return await methodChannel.invokeMethod<bool>('selectNode', nodeTag) ??
        false;
  }

  Future<bool> shutdown() async {
    return await methodChannel.invokeMethod<bool>('shutdown') ?? true;
  }

  Future<DateTime?> getRunTime() async {
    final ms = await methodChannel.invokeMethod<int>('getRunTime') ?? 0;
    if (ms == 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Get the TUN file descriptor from the VPN service (remote process).
  /// Returns null if VPN is not running or fd is not available.
  Future<int?> getTunFd() async {
    return await methodChannel.invokeMethod<int>('getTunFd');
  }

  /// Enable socket protection for TUN mode.
  /// Must be called before starting leaf with a TUN fd.
  Future<void> enableSocketProtection() async {
    await methodChannel.invokeMethod<void>('enableSocketProtection');
  }

  /// Disable socket protection when TUN mode is stopped.
  Future<void> disableSocketProtection() async {
    await methodChannel.invokeMethod<void>('disableSocketProtection');
  }

  /// Check if TUN is ready in :core process.
  /// Returns true if VpnService has established and tunPfd is available.
  Future<bool> isTunReady() async {
    return await methodChannel.invokeMethod<bool>('isTunReady') ?? false;
  }

  // --- Event listeners for core service status ---

  /// Add listener for core status changes from :core process.
  void addCoreStatusListener(void Function(Map<String, dynamic>) listener) {
    // This will be called when core status changes
    // Implementation via MethodChannel handler
  }

  /// Add listener for core errors from :core process.
  void addCoreErrorListener(void Function(String) listener) {
    // This will be called when core encounters an error
  }

  // --- Dual-process core service methods ---

  /// Start the core service (leaf) in :core process.
  /// @param configJson The Clash/YAML config as JSON string
  Future<bool> startCore(String configJson) async {
    return await methodChannel.invokeMethod<bool>(
          'startCore',
          {'configJson': configJson},
        ) ??
        false;
  }

  /// Stop the core service (leaf) in :core process.
  Future<bool> stopCore() async {
    return await methodChannel.invokeMethod<bool>('stopCore') ?? false;
  }

  /// Sync config to the core service (reload without restart).
  /// @param configJson The new config as JSON string
  Future<bool> syncConfig(String configJson) async {
    return await methodChannel.invokeMethod<bool>(
          'syncConfig',
          {'configJson': configJson},
        ) ??
        false;
  }

  /// Get core service status.
  /// Returns a Map with: isRunning, mode, selectedNode, etc.
  Future<Map<String, dynamic>> getCoreStatus() async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getCoreStatus');
    return Map<String, dynamic>.from(result ?? {});
  }

  /// Get the TUN file descriptor from the core service.
  /// Returns -1 if not available.
  Future<int> getCoreTunFd() async {
    return await methodChannel.invokeMethod<int>('getCoreTunFd') ?? -1;
  }

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void addListener(ServiceListener listener) {
    _listeners.add(listener);
  }

  void removeListener(ServiceListener listener) {
    _listeners.remove(listener);
  }
}

Service? get service =>
    (Platform.isAndroid || Platform.isIOS) ? Service() : null;
