import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

/// dart:ffi bindings to libleaf (leaf proxy core).
///
/// All functions are synchronous and block the calling thread.
/// Long-running functions (leaf_run*) should be called from an Isolate.
class LeafBindings {
  late final DynamicLibrary _lib;

  // ---- Core lifecycle ----
  late final int Function(
    int rtId,
    Pointer<Utf8> configPath,
    bool autoReload,
    bool multiThread,
    bool autoThreads,
    int threads,
    int stackSize,
  ) leafRunWithOptions;

  late final int Function(int rtId, Pointer<Utf8> configPath) leafRun;

  late final int Function(int rtId, Pointer<Utf8> config)
      leafRunWithConfigString;

  late final int Function(
    int rtId,
    Pointer<Utf8> config,
    bool multiThread,
    bool autoThreads,
    int threads,
    int stackSize,
  ) leafRunWithOptionsConfigString;

  late final int Function(int rtId) leafReload;

  late final int Function(int rtId, Pointer<Utf8> config)
      leafReloadWithConfigString;

  late final bool Function(int rtId) leafShutdown;

  late final int Function(Pointer<Utf8> configPath) leafTestConfig;

  late final int Function(Pointer<Utf8> config) leafTestConfigString;

  // ---- Health check ----
  late final int Function(
    int rtId,
    Pointer<Utf8> outboundTag,
    int timeoutMs,
  ) leafHealthCheck;

  late final int Function(
    int rtId,
    Pointer<Utf8> outboundTag,
    int timeoutMs,
    Pointer<Uint64> tcpMs,
    Pointer<Uint64> udpMs,
  ) leafHealthCheckWithLatency;

  // ---- Last active ----
  late final int Function(
    int rtId,
    Pointer<Utf8> outboundTag,
    Pointer<Uint32> timestampS,
  ) leafGetLastActive;

  late final int Function(
    int rtId,
    Pointer<Utf8> outboundTag,
    Pointer<Uint32> sinceS,
  ) leafGetSinceLastActive;

  // ---- Outbound select (requires outbound-select feature) ----
  late final int Function(
    int rtId,
    Pointer<Utf8> outbound,
    Pointer<Utf8> select,
  ) leafSetOutboundSelected;

  late final int Function(
    int rtId,
    Pointer<Utf8> outbound,
    Pointer<Utf8> buf,
    int bufLen,
  ) leafGetOutboundSelected;

  late final int Function(
    int rtId,
    Pointer<Utf8> outbound,
    Pointer<Utf8> buf,
    int bufLen,
  ) leafGetOutboundSelects;

  // ---- Stats ----
  late final int Function(
    int rtId,
    Pointer<Utf8> buf,
    int bufLen,
  ) leafGetStats;

  // ---- Environment ----
  late final void Function(Pointer<Utf8> key, Pointer<Utf8> value) leafSetEnv;

  // ---- Memory ----
  late final void Function(Pointer<Utf8> s) leafFreeString;

  LeafBindings(DynamicLibrary lib) {
    _lib = lib;
    _bindAll();
  }

  /// Load the leaf library for the current platform.
  factory LeafBindings.open() {
    final lib = _openLibrary();
    return LeafBindings(lib);
  }

  static DynamicLibrary _openLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libleaf.so');
    } else if (Platform.isLinux) {
      return DynamicLibrary.open('libleaf.so');
    } else if (Platform.isMacOS) {
      return DynamicLibrary.open('libleaf.dylib');
    } else if (Platform.isWindows) {
      return DynamicLibrary.open('leaf.dll');
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }

  void _bindAll() {
    // leaf_run_with_options(rt_id, config_path, auto_reload, multi_thread, auto_threads, threads, stack_size) -> i32
    leafRunWithOptions = _lib
        .lookupFunction<
            Int32 Function(Uint16, Pointer<Utf8>, Bool, Bool, Bool, Int32,
                Int32),
            int Function(int, Pointer<Utf8>, bool, bool, bool, int,
                int)>('leaf_run_with_options');

    // leaf_run(rt_id, config_path) -> i32
    leafRun = _lib
        .lookupFunction<Int32 Function(Uint16, Pointer<Utf8>),
            int Function(int, Pointer<Utf8>)>('leaf_run');

    // leaf_run_with_config_string(rt_id, config) -> i32
    leafRunWithConfigString = _lib
        .lookupFunction<Int32 Function(Uint16, Pointer<Utf8>),
            int Function(int, Pointer<Utf8>)>('leaf_run_with_config_string');

    // leaf_run_with_options_config_string(rt_id, config, multi_thread, auto_threads, threads, stack_size) -> i32
    leafRunWithOptionsConfigString = _lib.lookupFunction<
        Int32 Function(Uint16, Pointer<Utf8>, Bool, Bool, Int32, Int32),
        int Function(int, Pointer<Utf8>, bool, bool, int,
            int)>('leaf_run_with_options_config_string');

    // leaf_reload(rt_id) -> i32
    leafReload = _lib.lookupFunction<Int32 Function(Uint16),
        int Function(int)>('leaf_reload');

    // leaf_reload_with_config_string(rt_id, config) -> i32
    leafReloadWithConfigString = _lib
        .lookupFunction<Int32 Function(Uint16, Pointer<Utf8>),
            int Function(int, Pointer<Utf8>)>('leaf_reload_with_config_string');

    // leaf_shutdown(rt_id) -> bool
    leafShutdown = _lib.lookupFunction<Bool Function(Uint16),
        bool Function(int)>('leaf_shutdown');

    // leaf_test_config(config_path) -> i32
    leafTestConfig = _lib
        .lookupFunction<Int32 Function(Pointer<Utf8>),
            int Function(Pointer<Utf8>)>('leaf_test_config');

    // leaf_test_config_string(config) -> i32
    leafTestConfigString = _lib
        .lookupFunction<Int32 Function(Pointer<Utf8>),
            int Function(Pointer<Utf8>)>('leaf_test_config_string');

    // leaf_health_check(rt_id, outbound_tag, timeout_ms) -> i32
    leafHealthCheck = _lib
        .lookupFunction<Int32 Function(Uint16, Pointer<Utf8>, Uint64),
            int Function(int, Pointer<Utf8>, int)>('leaf_health_check');

    // leaf_health_check_with_latency(rt_id, outbound_tag, timeout_ms, tcp_ms, udp_ms) -> i32
    leafHealthCheckWithLatency = _lib.lookupFunction<
        Int32 Function(
            Uint16, Pointer<Utf8>, Uint64, Pointer<Uint64>, Pointer<Uint64>),
        int Function(int, Pointer<Utf8>, int, Pointer<Uint64>,
            Pointer<Uint64>)>('leaf_health_check_with_latency');

    // leaf_get_last_active(rt_id, outbound_tag, timestamp_s) -> i32
    leafGetLastActive = _lib.lookupFunction<
        Int32 Function(Uint16, Pointer<Utf8>, Pointer<Uint32>),
        int Function(
            int, Pointer<Utf8>, Pointer<Uint32>)>('leaf_get_last_active');

    // leaf_get_since_last_active(rt_id, outbound_tag, since_s) -> i32
    leafGetSinceLastActive = _lib.lookupFunction<
        Int32 Function(Uint16, Pointer<Utf8>, Pointer<Uint32>),
        int Function(
            int, Pointer<Utf8>, Pointer<Uint32>)>('leaf_get_since_last_active');

    // leaf_set_outbound_selected(rt_id, outbound, select) -> i32
    leafSetOutboundSelected = _lib.lookupFunction<
        Int32 Function(Uint16, Pointer<Utf8>, Pointer<Utf8>),
        int Function(int, Pointer<Utf8>,
            Pointer<Utf8>)>('leaf_set_outbound_selected');

    // leaf_get_outbound_selected(rt_id, outbound, buf, buf_len) -> i32
    leafGetOutboundSelected = _lib.lookupFunction<
        Int32 Function(Uint16, Pointer<Utf8>, Pointer<Utf8>, Int32),
        int Function(int, Pointer<Utf8>, Pointer<Utf8>,
            int)>('leaf_get_outbound_selected');

    // leaf_get_outbound_selects(rt_id, outbound, buf, buf_len) -> i32
    leafGetOutboundSelects = _lib.lookupFunction<
        Int32 Function(Uint16, Pointer<Utf8>, Pointer<Utf8>, Int32),
        int Function(int, Pointer<Utf8>, Pointer<Utf8>,
            int)>('leaf_get_outbound_selects');

    // leaf_get_stats(rt_id, buf, buf_len) -> i32
    leafGetStats = _lib.lookupFunction<
        Int32 Function(Uint16, Pointer<Utf8>, Int32),
        int Function(int, Pointer<Utf8>, int)>('leaf_get_stats');

    // leaf_set_env(key, value)
    leafSetEnv = _lib.lookupFunction<
        Void Function(Pointer<Utf8>, Pointer<Utf8>),
        void Function(Pointer<Utf8>, Pointer<Utf8>)>('leaf_set_env');

    // leaf_free_string(s)
    leafFreeString = _lib.lookupFunction<Void Function(Pointer<Utf8>),
        void Function(Pointer<Utf8>)>('leaf_free_string');
  }
}
