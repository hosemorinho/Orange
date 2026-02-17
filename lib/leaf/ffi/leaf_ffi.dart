import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import 'leaf_bindings.dart';
import 'leaf_errors.dart';

/// High-level Dart wrapper over raw leaf FFI bindings.
///
/// Handles memory allocation/deallocation, buffer management for
/// string-returning functions, and provides typed return values.
///
/// Most methods are synchronous (intended to be called from an Isolate
/// or the main thread for quick operations). [start] runs leaf in a
/// separate Isolate since it blocks.
class LeafFfi {
  final LeafBindings _bindings;

  /// Default buffer size for string-returning FFI calls.
  static const int _defaultBufSize = 16 * 1024; // 16 KB

  LeafFfi(this._bindings);

  factory LeafFfi.open() => LeafFfi(LeafBindings.open());

  // ---------------------------------------------------------------------------
  // Environment (must be called before start)
  // ---------------------------------------------------------------------------

  void setEnv(String key, String value) {
    final keyPtr = key.toNativeUtf8();
    final valuePtr = value.toNativeUtf8();
    try {
      _bindings.leafSetEnv(keyPtr, valuePtr);
    } finally {
      calloc.free(keyPtr);
      calloc.free(valuePtr);
    }
  }

  // ---------------------------------------------------------------------------
  // Core lifecycle
  // ---------------------------------------------------------------------------

  /// Starts leaf in a background Isolate.
  /// The returned [LeafInstance] can be used to control the running instance.
  /// Check [LeafInstance.startupError] after [_waitForRuntimeReady] to detect
  /// startup failures.
  Future<LeafInstance> start({
    required int rtId,
    required String configPath,
    bool multiThread = true,
    bool autoThreads = true,
    int threads = 0,
    int stackSize = 0,
  }) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      _isolateEntry,
      _LeafStartParams(
        rtId: rtId,
        configPath: configPath,
        multiThread: multiThread,
        autoThreads: autoThreads,
        threads: threads,
        stackSize: stackSize,
        sendPort: receivePort.sendPort,
      ),
    );

    final instance = LeafInstance._(
      rtId: rtId,
      isolate: isolate,
      bindings: _bindings,
    );

    receivePort.listen((message) {
      if (message is int && message != LeafError.ok) {
        instance._startupError = message;
      }
      receivePort.close();
    });

    return instance;
  }

  /// Validates a config file without starting leaf.
  int testConfig(String configPath) {
    final pathPtr = configPath.toNativeUtf8();
    try {
      return _bindings.leafTestConfig(pathPtr);
    } finally {
      calloc.free(pathPtr);
    }
  }

  /// Validates a config JSON string without starting leaf.
  int testConfigString(String config) {
    final configPtr = config.toNativeUtf8();
    try {
      return _bindings.leafTestConfigString(configPtr);
    } finally {
      calloc.free(configPtr);
    }
  }

  /// Starts leaf from a JSON config string (no file I/O).
  ///
  /// The isolate runs leaf_run_with_options_config_string which blocks until
  /// leaf shuts down or fails to start. On startup failure, the blocking call
  /// returns immediately with an error code. We listen for this error on the
  /// port and surface it via [LeafInstance.startupError].
  Future<LeafInstance> startWithConfigString({
    required int rtId,
    required String config,
    bool multiThread = true,
    bool autoThreads = true,
    int threads = 0,
    int stackSize = 0,
  }) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      _isolateEntryConfigString,
      _LeafStartConfigStringParams(
        rtId: rtId,
        config: config,
        multiThread: multiThread,
        autoThreads: autoThreads,
        threads: threads,
        stackSize: stackSize,
        sendPort: receivePort.sendPort,
      ),
    );

    // Don't await receivePort.first — leaf_run blocks the isolate until
    // shutdown or startup failure. Instead, listen asynchronously for
    // error codes (startup failure) or ok (normal shutdown).
    final instance = LeafInstance._(
      rtId: rtId,
      isolate: isolate,
      bindings: _bindings,
    );

    // Listen for the leaf return code asynchronously.
    // On startup failure, leaf returns immediately with an error code.
    // On success, it blocks until shutdown, then returns ok.
    receivePort.listen((message) {
      if (message is int && message != LeafError.ok) {
        instance._startupError = message;
      }
      receivePort.close();
    });

    return instance;
  }

  static void _isolateEntryConfigString(_LeafStartConfigStringParams params) {
    final bindings = LeafBindings.open();
    final configPtr = params.config.toNativeUtf8();

    // Do NOT send ok prematurely. The blocking call returns when leaf
    // finishes (either startup failure or normal shutdown).
    try {
      final result = bindings.leafRunWithOptionsConfigString(
        params.rtId,
        configPtr,
        params.multiThread,
        params.autoThreads,
        params.threads,
        params.stackSize,
      );
      params.sendPort.send(result);
    } finally {
      calloc.free(configPtr);
    }
  }

  // ---------------------------------------------------------------------------
  // Isolate entry point (runs leaf_run_with_options, blocking)
  // ---------------------------------------------------------------------------

  static void _isolateEntry(_LeafStartParams params) {
    final bindings = LeafBindings.open();
    final pathPtr = params.configPath.toNativeUtf8();

    try {
      final result = bindings.leafRunWithOptions(
        params.rtId,
        pathPtr,
        false, // auto_reload
        params.multiThread,
        params.autoThreads,
        params.threads,
        params.stackSize,
      );
      params.sendPort.send(result);
    } finally {
      calloc.free(pathPtr);
    }
  }
}

/// Represents a running leaf instance. Provides control methods.
class LeafInstance {
  final int rtId;
  final Isolate _isolate;
  final LeafBindings _bindings;

  /// Set asynchronously when the leaf isolate returns a non-ok error code.
  /// This indicates a startup failure (e.g., TUN creation failed).
  int? _startupError;

  /// If leaf failed to start, returns the error code. Null means either
  /// still starting or started successfully.
  int? get startupError => _startupError;

  LeafInstance._({
    required this.rtId,
    required Isolate isolate,
    required LeafBindings bindings,
  }) : _isolate = isolate,
       _bindings = bindings;

  /// Reload config from file (DNS, outbounds, routing rules).
  int reload() => _bindings.leafReload(rtId);

  /// Reload config from a JSON string (no file I/O).
  int reloadWithConfigString(String config) {
    final configPtr = config.toNativeUtf8();
    try {
      return _bindings.leafReloadWithConfigString(rtId, configPtr);
    } finally {
      calloc.free(configPtr);
    }
  }

  /// Reload config from a JSON string on a background isolate.
  ///
  /// `leaf_reload_with_config_string` is a synchronous FFI call and may block
  /// while core tasks are in progress. Running it off the UI isolate prevents
  /// desktop "application not responding" freezes during mode switching.
  Future<int> reloadWithConfigStringAsync(String config) async {
    final runtimeId = rtId;
    return Isolate.run(() {
      final bindings = LeafBindings.open();
      final configPtr = config.toNativeUtf8();
      try {
        return bindings.leafReloadWithConfigString(runtimeId, configPtr);
      } finally {
        calloc.free(configPtr);
      }
    });
  }

  /// Graceful shutdown.
  bool shutdown() {
    final result = _bindings.leafShutdown(rtId);
    _isolate.kill(priority: Isolate.beforeNextEvent);
    return result;
  }

  /// Cancel all active TCP relay connections.
  ///
  /// After a proxy node switch, existing TCP connections are still relaying
  /// through the old proxy server. This breaks all active relay loops so
  /// new connections use the newly selected outbound.
  bool closeConnections() => _bindings.leafCloseConnections(rtId);

  /// Set selected outbound for a selector group.
  int setOutboundSelected(String outbound, String select) {
    final outboundPtr = outbound.toNativeUtf8();
    final selectPtr = select.toNativeUtf8();
    try {
      return _bindings.leafSetOutboundSelected(rtId, outboundPtr, selectPtr);
    } finally {
      calloc.free(outboundPtr);
      calloc.free(selectPtr);
    }
  }

  /// Get the currently selected outbound tag for a selector group.
  String? getOutboundSelected(String outbound) {
    return _callWithStringBuf((buf, len) {
      final outboundPtr = outbound.toNativeUtf8();
      try {
        return _bindings.leafGetOutboundSelected(rtId, outboundPtr, buf, len);
      } finally {
        calloc.free(outboundPtr);
      }
    });
  }

  /// Get list of available outbound tags for a selector group.
  List<String> getOutboundSelects(String outbound) {
    final json = _callWithStringBuf((buf, len) {
      final outboundPtr = outbound.toNativeUtf8();
      try {
        return _bindings.leafGetOutboundSelects(rtId, outboundPtr, buf, len);
      } finally {
        calloc.free(outboundPtr);
      }
    });
    if (json == null) return [];
    final decoded = jsonDecode(json);
    return (decoded as List).cast<String>();
  }

  /// Health check with latency results.
  /// Returns (tcpMs, udpMs) where 0 means that protocol check failed.
  ({int tcpMs, int udpMs})? healthCheck(
    String outboundTag, {
    int timeoutMs = 4000,
  }) {
    final tagPtr = outboundTag.toNativeUtf8();
    final tcpMs = calloc<Uint64>();
    final udpMs = calloc<Uint64>();
    try {
      final result = _bindings.leafHealthCheckWithLatency(
        rtId,
        tagPtr,
        timeoutMs,
        tcpMs,
        udpMs,
      );
      if (result == LeafError.ok || result == LeafError.io) {
        return (tcpMs: tcpMs.value, udpMs: udpMs.value);
      }
      return null;
    } finally {
      calloc.free(tagPtr);
      calloc.free(tcpMs);
      calloc.free(udpMs);
    }
  }

  /// Async health check executed off the UI isolate.
  ///
  /// Uses a fresh FFI binding inside [Isolate.run] to avoid blocking Flutter
  /// rendering while the native check waits on network I/O.
  Future<({int tcpMs, int udpMs})?> healthCheckAsync(
    String outboundTag, {
    int timeoutMs = 4000,
  }) async {
    final runtimeId = rtId;
    final tag = outboundTag;
    return Isolate.run(() {
      final bindings = LeafBindings.open();
      final tagPtr = tag.toNativeUtf8();
      final tcpMsPtr = calloc<Uint64>();
      final udpMsPtr = calloc<Uint64>();
      try {
        final result = bindings.leafHealthCheckWithLatency(
          runtimeId,
          tagPtr,
          timeoutMs,
          tcpMsPtr,
          udpMsPtr,
        );
        if (result == LeafError.ok || result == LeafError.io) {
          return (tcpMs: tcpMsPtr.value, udpMs: udpMsPtr.value);
        }
        return null;
      } finally {
        calloc.free(tagPtr);
        calloc.free(tcpMsPtr);
        calloc.free(udpMsPtr);
      }
    });
  }

  /// Simple health check (OK/fail only).
  bool healthCheckSimple(String outboundTag, {int timeoutMs = 4000}) {
    final tagPtr = outboundTag.toNativeUtf8();
    try {
      return _bindings.leafHealthCheck(rtId, tagPtr, timeoutMs) == LeafError.ok;
    } finally {
      calloc.free(tagPtr);
    }
  }

  /// Get connection statistics as JSON string.
  String? getStatsJson() {
    return _callWithStringBuf((buf, len) {
      return _bindings.leafGetStats(rtId, buf, len);
    });
  }

  /// Get last active timestamp for an outbound.
  int? getLastActive(String outboundTag) {
    final tagPtr = outboundTag.toNativeUtf8();
    final ts = calloc<Uint32>();
    try {
      final result = _bindings.leafGetLastActive(rtId, tagPtr, ts);
      if (result == LeafError.ok) return ts.value;
      return null;
    } finally {
      calloc.free(tagPtr);
      calloc.free(ts);
    }
  }

  /// Get seconds since last active for an outbound.
  int? getSinceLastActive(String outboundTag) {
    final tagPtr = outboundTag.toNativeUtf8();
    final since = calloc<Uint32>();
    try {
      final result = _bindings.leafGetSinceLastActive(rtId, tagPtr, since);
      if (result == LeafError.ok) return since.value;
      return null;
    } finally {
      calloc.free(tagPtr);
      calloc.free(since);
    }
  }

  // ---------------------------------------------------------------------------
  // Buffer helper: calls an FFI function that writes into a buffer,
  // retrying with a larger buffer if needed.
  // ---------------------------------------------------------------------------
  String? _callWithStringBuf(
    int Function(Pointer<Utf8> buf, int bufLen) ffiCall,
  ) {
    var bufSize = LeafFfi._defaultBufSize;
    var buf = calloc<Uint8>(bufSize);

    try {
      var result = ffiCall(buf.cast<Utf8>(), bufSize);

      // Negative = buffer too small, -result = needed size
      if (LeafError.isBufferTooSmall(result)) {
        bufSize = -result;
        calloc.free(buf);
        buf = calloc<Uint8>(bufSize);
        result = ffiCall(buf.cast<Utf8>(), bufSize);
      }

      if (result < 0) return null; // Still too small (shouldn't happen)

      // Disambiguate error codes (1-9) from valid byte counts (1-9).
      // On error, the FFI does NOT write to the buffer — buf[0] stays 0
      // (calloc zeroes memory). On success, write_to_buf writes data
      // followed by a NUL terminator, so buf[0] is non-zero for any
      // non-empty string.
      if (result == 0) {
        return ''; // 0 bytes written = empty string (or ERR_OK, same effect)
      }
      if (result <= LeafError.noData && buf[0] == 0) {
        // No data was written to buffer — this is an error code, not a byte count
        return null;
      }

      return buf.cast<Utf8>().toDartString(length: result);
    } finally {
      calloc.free(buf);
    }
  }
}

/// Parameters for starting leaf from a config string.
class _LeafStartConfigStringParams {
  final int rtId;
  final String config;
  final bool multiThread;
  final bool autoThreads;
  final int threads;
  final int stackSize;
  final SendPort sendPort;

  _LeafStartConfigStringParams({
    required this.rtId,
    required this.config,
    required this.multiThread,
    required this.autoThreads,
    required this.threads,
    required this.stackSize,
    required this.sendPort,
  });
}

/// Parameters passed to the leaf isolate.
class _LeafStartParams {
  final int rtId;
  final String configPath;
  final bool multiThread;
  final bool autoThreads;
  final int threads;
  final int stackSize;
  final SendPort sendPort;

  _LeafStartParams({
    required this.rtId,
    required this.configPath,
    required this.multiThread,
    required this.autoThreads,
    required this.threads,
    required this.stackSize,
    required this.sendPort,
  });
}

/// Exception thrown when a leaf FFI call fails.
class LeafException implements Exception {
  final int code;
  LeafException(this.code);

  String get message => LeafError.message(code);

  @override
  String toString() => 'LeafException($code): $message';
}
