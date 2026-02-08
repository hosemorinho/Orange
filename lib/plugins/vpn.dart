import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract mixin class VpnListener {
  void onDnsChanged() {}
}

class Vpn {
  static Vpn? _instance;
  late MethodChannel methodChannel;

  final ObserverList<VpnListener> _listeners = ObserverList<VpnListener>();

  factory Vpn() {
    _instance ??= Vpn._internal();
    return _instance!;
  }

  Vpn._internal() {
    methodChannel = const MethodChannel('vpn');
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'dnsChanged':
          for (final listener in _listeners) {
            listener.onDnsChanged();
          }
          break;
        case 'getStartForegroundParams':
          return {
            'title': appController.sharedState.currentProfileName,
            'stopText': appController.sharedState.stopText,
          };
        default:
          throw MissingPluginException();
      }
    });
  }

  Future<bool> start(VpnOptions options) async {
    return await methodChannel.invokeMethod<bool>(
          'start',
          json.encode(options),
        ) ??
        false;
  }

  Future<bool> stop() async {
    return await methodChannel.invokeMethod<bool>('stop') ?? false;
  }

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void addListener(VpnListener listener) {
    _listeners.add(listener);
  }

  void removeListener(VpnListener listener) {
    _listeners.remove(listener);
  }
}

Vpn? get vpn => system.isAndroid ? Vpn() : null;
