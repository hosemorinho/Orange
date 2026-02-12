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

  /// Starts leaf in a background Isolate. Returns when leaf is running.
  /// The returned [LeafInstance] can be used to control the running instance.
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

    // Wait for the isolate to signal it has started (or errored)
    final firstMessage = await receivePort.first;
    if (firstMessage is int && firstMessage != LeafError.ok) {
      throw LeafException(firstMessage);
    }

    return LeafInstance._(
      rtId: rtId,
      isolate: isolate,
      bindings: _bindings,
    );
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

  // ---------------------------------------------------------------------------
  // Isolate entry point (runs leaf_run_with_options, blocking)
  // ---------------------------------------------------------------------------

  static void _isolateEntry(_LeafStartParams params) {
    final bindings = LeafBindings.open();
    final pathPtr = params.configPath.toNativeUtf8();

    // Signal that we're about to start
    params.sendPort.send(LeafError.ok);

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
      // leaf_run_with_options returns when shutdown is called
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

  LeafInstance._({
    required this.rtId,
    required Isolate isolate,
    required LeafBindings bindings,
  })  : _isolate = isolate,
        _bindings = bindings;

  /// Reload config (DNS, outbounds, routing rules).
  int reload() => _bindings.leafReload(rtId);

  /// Graceful shutdown.
  bool shutdown() {
    final result = _bindings.leafShutdown(rtId);
    _isolate.kill(priority: Isolate.beforeNextEvent);
    return result;
  }

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

  /// Simple health check (OK/fail only).
  bool healthCheckSimple(String outboundTag, {int timeoutMs = 4000}) {
    final tagPtr = outboundTag.toNativeUtf8();
    try {
      return _bindings.leafHealthCheck(rtId, tagPtr, timeoutMs) ==
          LeafError.ok;
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
      if (result <= LeafError.noData) {
        // It's an error code (0-9), not a byte count
        // result == 0 could be either ERR_OK or 0 bytes written — ambiguous.
        // For buffer functions, 0 means empty string which is valid.
        if (result > 0) return null;
      }

      return buf.cast<Utf8>().toDartString(length: result);
    } finally {
      calloc.free(buf);
    }
  }
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
