import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/services.dart';

abstract mixin class ServiceListener {
  void onServiceEvent(CoreEvent event) {}

  void onServiceCrash(String message) {}
}

class Service {
  static Service? _instance;
  late MethodChannel methodChannel;

  final List<ServiceListener> _listeners = [];

  factory Service() {
    _instance ??= Service._internal();
    return _instance!;
  }

  Service._internal() {
    methodChannel = const MethodChannel('service');
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'event':
          final eventData = call.arguments as String?;
          if (eventData != null) {
            try {
              final resultJson = json.decode(eventData);
              final actionResult = ActionResult.fromJson(resultJson);
              if (actionResult.data != null) {
                final event = CoreEvent.fromJson(
                  actionResult.data is Map<String, dynamic>
                      ? actionResult.data
                      : json.decode(actionResult.data.toString()),
                );
                for (final listener in _listeners) {
                  listener.onServiceEvent(event);
                }
              }
            } catch (_) {}
          }
          break;
        default:
          throw MissingPluginException();
      }
    });
  }

  Future<String> init() async {
    return await methodChannel.invokeMethod<String>('init') ?? '';
  }

  Future<bool> destroy() async {
    return await methodChannel.invokeMethod<bool>('destroy') ?? true;
  }

  Future<ActionResult?> invokeAction(Action action) async {
    final data = await methodChannel.invokeMethod<String>(
      'invokeAction',
      json.encode(action),
    );
    if (data == null) {
      return null;
    }
    final dataJson = json.decode(data);
    return ActionResult.fromJson(dataJson);
  }

  Future<bool> setEventListener() async {
    return await methodChannel.invokeMethod<bool>('setEventListener') ?? false;
  }

  Future<bool> removeEventListener() async {
    return await methodChannel.invokeMethod<bool>('removeEventListener') ??
        false;
  }

  Future<String?> quickSetup(String initParams, String setupParams) async {
    return await methodChannel.invokeMethod<String>('quickSetup', {
      'initParams': initParams,
      'setupParams': setupParams,
    });
  }

  Future<bool> startVpn(VpnOptions options) async {
    return await methodChannel.invokeMethod<bool>(
          'startVpn',
          json.encode(options),
        ) ??
        false;
  }

  Future<bool> stopVpn() async {
    return await methodChannel.invokeMethod<bool>('stopVpn') ?? false;
  }

  void addListener(ServiceListener listener) {
    _listeners.add(listener);
  }

  void removeListener(ServiceListener listener) {
    _listeners.remove(listener);
  }
}

Service? get service => system.isAndroid ? Service() : null;
