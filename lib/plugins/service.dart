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
