import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/core.dart';
import 'package:fl_clash/plugins/service.dart';

import 'interface.dart';

class CoreLib extends CoreHandlerInterface {
  static CoreLib? _instance;

  Completer<bool> _connectedCompleter = Completer();

  CoreLib._internal();

  @override
  Future<String> preload() async {
    commonPrint.log('CoreLib.preload: service.init() start');
    final res = await service?.init();
    commonPrint.log('CoreLib.preload: service.init() done, res="${res ?? "null"}"');
    if (res?.isEmpty != true) {
      return res ?? '';
    }
    _connectedCompleter.complete(true);
    commonPrint.log('CoreLib.preload: syncState start');
    final syncRes = await service?.syncState(appController.sharedState);
    commonPrint.log('CoreLib.preload: syncState done, res="${syncRes ?? "null"}"');
    return syncRes ?? '';
  }

  factory CoreLib() {
    _instance ??= CoreLib._internal();
    return _instance!;
  }

  @override
  destroy() async {
    return true;
  }

  @override
  Future<bool> shutdown(_) async {
    if (!_connectedCompleter.isCompleted) {
      return false;
    }
    _connectedCompleter = Completer();
    return service?.shutdown() ?? true;
  }

  @override
  Future<T?> invoke<T>({
    required ActionMethod method,
    dynamic data,
    Duration? timeout,
  }) async {
    final id = '${method.name}#${utils.id}';
    commonPrint.log(
      'CoreLib.invoke: ${method.name} sending via AIDL (id=$id)',
      logLevel: LogLevel.debug,
    );
    final result = await service
        ?.invokeAction(Action(id: id, method: method, data: data))
        .withTimeout(onTimeout: () {
      commonPrint.log(
        'CoreLib.invoke: ${method.name} TIMEOUT (3min) id=$id',
        logLevel: LogLevel.error,
      );
      return null;
    });
    if (result == null) {
      commonPrint.log(
        'CoreLib.invoke: ${method.name} returned null (id=$id)',
        logLevel: LogLevel.error,
      );
      return null;
    }
    return parasResult<T>(result);
  }

  @override
  Completer get completer => _connectedCompleter;
}

CoreLib? get coreLib => system.isAndroid ? CoreLib() : null;
