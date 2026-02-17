import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:fl_clash/leaf/core/leaf_bridge.dart' show Mode;
import 'package:fl_clash/leaf/config/config_writer.dart';
import 'package:fl_clash/leaf/config/leaf_config.dart';
import 'package:fl_clash/leaf/ffi/leaf_errors.dart';
import 'package:fl_clash/leaf/ffi/leaf_ffi.dart';
import 'package:fl_clash/leaf/models/leaf_node.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/xboard/core/logger/file_logger.dart';
import 'package:yaml/yaml.dart';

final _logger = FileLogger('leaf_controller.dart');

/// High-level controller for the leaf proxy core.
///
/// Manages the leaf lifecycle, config generation, node selection, and
/// health checks — all through FFI (no REST API).
///
/// In dual-process mode (Android with :core process), this controller
/// can communicate with the remote leaf in :core process via AIDL.
class LeafController {
  static const int _rtId = 1;

  final LeafFfi _ffi;
  LeafInstance? _instance;
  bool _remoteRunning = false;
  String? _remoteSelectedNode;

  /// Whether to use dual-process mode (Android with :core process).
  /// When true, leaf is started in :core process via AIDL.
  /// When false, leaf runs in the same process via FFI.
  bool useDualProcessMode = false;

  String? _homeDir;
  String? get homeDir => _homeDir;

  /// Nodes extracted from the last loaded Clash YAML.
  List<LeafNode> _nodes = [];

  /// Port used for local mixed (HTTP+SOCKS5) proxy.
  int _mixedPort = 7890;

  // --- State remembered from last start (for hot-reload) ---
  List<Map<String, dynamic>> _lastProxies = [];
  int? _lastTunFd;
  bool _lastTunEnabled = false;
  Mode _lastMode = Mode.global;

  LeafController() : _ffi = LeafFfi.open();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Initialize with the app's home directory.
  /// Sets ASSET_LOCATION so leaf can find geo.mmdb for GeoIP rule mode.
  Future<void> init(String homeDir) async {
    _homeDir = homeDir;
    await Directory(homeDir).create(recursive: true);
    _ffi.setEnv('ASSET_LOCATION', homeDir);
    _logger.info('init: homeDir=$homeDir, ASSET_LOCATION set');
  }

  /// Synchronize cached dual-process runtime state from :core service.
  Future<void> syncRemoteStatus() async {
    if (!useDualProcessMode) return;
    final svc = service;
    if (svc == null) {
      _remoteRunning = false;
      _remoteSelectedNode = null;
      return;
    }
    final status = await svc.getCoreStatus();
    _remoteRunning = status['isRunning'] == true;
    final selectedNode = status['selectedNode'];
    if (selectedNode is String && selectedNode.isNotEmpty) {
      _remoteSelectedNode = selectedNode;
    }
  }

  /// Load a Clash YAML subscription and start the proxy.
  ///
  /// [yamlContent] is the raw Clash YAML string from V2Board.
  /// [tunFd] is the Android VPN TUN file descriptor (null on desktop).
  /// [tunEnabled] enables TUN/NF inbound on desktop platforms.
  /// [mode] controls routing: global (all proxy), rule (CN direct), direct.
  /// [mmdbAvailable] whether geo.mmdb is in the ASSET_LOCATION directory.
  Future<void> startWithClashYaml(
    String yamlContent, {
    int? tunFd,
    bool tunEnabled = false,
    int mixedPort = 7890,
    Mode mode = Mode.global,
    bool mmdbAvailable = false,
  }) async {
    _mixedPort = mixedPort;

    // Parse Clash YAML proxies
    final proxies = _parseClashProxies(yamlContent);
    if (proxies.isEmpty) {
      _logger.warning(
        'parsed 0 proxies from YAML (${yamlContent.length} bytes). '
        'First 200 chars: ${yamlContent.substring(0, yamlContent.length.clamp(0, 200))}',
      );
    } else {
      // Log protocol distribution for debugging
      final typeCounts = <String, int>{};
      for (final p in proxies) {
        final t = (p['type'] as String? ?? 'unknown').toLowerCase();
        typeCounts[t] = (typeCounts[t] ?? 0) + 1;
      }
      _logger.info('parsed ${proxies.length} proxies: $typeCounts');
    }
    _nodes = _extractNodes(proxies);
    _logger.info(
      'supported nodes: ${_nodes.length} / ${proxies.length} total proxies, mode: ${mode.name}',
    );

    // Remember parameters for hot-reload
    _lastProxies = proxies;
    _lastTunFd = tunFd;
    _lastTunEnabled = tunEnabled;
    _lastMode = mode;

    // Build leaf config — log to leaf.log in homeDir for diagnostics
    final logOutput = '$_homeDir${Platform.pathSeparator}leaf.log';
    final config = ConfigWriter.build(
      proxies: proxies,
      mixedPort: _mixedPort,
      tunFd: tunFd,
      tunEnabled: tunEnabled,
      logOutput: logOutput,
      mode: mode,
      mmdbAvailable: mmdbAvailable,
    );

    // Use dual-process mode if enabled
    if (useDualProcessMode) {
      await _startRemote(config);
    } else {
      await _startWithConfig(config);
    }
  }

  /// Start leaf in remote :core process via AIDL.
  Future<void> _startRemote(LeafConfig config) async {
    if (_instance != null || _remoteRunning) {
      await stop();
    }

    final configJson = config.toJsonString();
    _logger.info(
      'starting leaf in :core process with config (${configJson.length} bytes)',
    );

    // Get the service instance
    final svc = service;
    if (svc == null) {
      _logger.error('service not available for dual-process mode');
      throw StateError('Service not available');
    }

    // Start the core service
    final success = await svc.startCore(configJson);
    if (!success) {
      throw LeafException(LeafError.runtimeManager);
    }

    _remoteRunning = true;
    final status = await svc.getCoreStatus();
    if (status['selectedNode'] is String) {
      _remoteSelectedNode = status['selectedNode'] as String;
    }

    _logger.info('leaf started in :core process successfully');
  }

  /// Start leaf with a pre-built config — fully in-memory, no file I/O.
  Future<void> _startWithConfig(LeafConfig config) async {
    if (_homeDir == null) throw StateError('Call init() first');

    if (_instance != null) {
      await stop();
    }

    final configJson = config.toJsonString();
    _logger.info(
      'starting leaf with in-memory config (${configJson.length} bytes)',
    );
    if (configJson.length < 8000) {
      _logger.info('config content:\n$configJson');
    }

    // Validate config from string (no file needed)
    final testResult = _ffi.testConfigString(configJson);
    if (!LeafError.isOk(testResult)) {
      throw LeafException(testResult);
    }

    // Start leaf from config string — decrypted credentials never touch disk
    _instance = await _ffi.startWithConfigString(
      rtId: _rtId,
      config: configJson,
    );

    await _waitForRuntimeReady();

    final hasTun = config.inbounds?.any((i) => i.protocol == 'tun') ?? false;
    if (hasTun) {
      await Future.delayed(const Duration(milliseconds: 500));
      final startupError = _instance?.startupError;
      if (startupError != null) {
        _logger.error(
          'leaf crashed after runtime ready (likely TUN failure): '
          'error $startupError (${LeafError.message(startupError)})',
        );
        await _dumpLeafLog('TUN startup failure');
        _instance?.shutdown();
        _instance = null;
        throw LeafException(startupError);
      }
      _logger.info('TUN inbound appears healthy after grace period');
    }
  }

  /// Poll until leaf's RUNTIME_MANAGER is populated and ready for FFI calls.
  ///
  /// Uses [getOutboundSelects] instead of [getOutboundSelected] because
  /// the selects function returns a JSON array (always >9 bytes with any
  /// nodes) which avoids the error-code / byte-count ambiguity in the
  /// FFI buffer return convention.
  ///
  /// Throws [LeafException] if:
  /// - The leaf isolate reports a startup error (e.g., TUN creation failed)
  /// - The runtime doesn't become ready within the timeout
  Future<void> _waitForRuntimeReady() async {
    const maxAttempts = 50; // 50 × 100ms = 5 seconds max
    for (var i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if the isolate reported a startup failure
      final startupError = _instance?.startupError;
      if (startupError != null) {
        _logger.error(
          'leaf startup failed with error code $startupError '
          '(${LeafError.message(startupError)}) after ${(i + 1) * 100}ms',
        );
        throw LeafException(startupError);
      }

      try {
        // getOutboundSelects returns a non-empty list when the runtime
        // is alive AND the outbound manager is populated with our config.
        final selects = _instance?.getOutboundSelects(ConfigWriter.selectorTag);
        if (selects != null && selects.isNotEmpty) {
          _logger.info(
            'runtime ready after ${(i + 1) * 100}ms '
            '(${selects.length} nodes in selector)',
          );
          return;
        }
      } catch (_) {
        // Not ready yet, keep polling
      }
    }
    _logger.error(
      'runtime not ready after ${maxAttempts * 100}ms — '
      'leaf likely failed to start (TUN creation or config error)',
    );
    await _dumpLeafLog('runtime timeout');
    throw LeafException(LeafError.runtimeManager);
  }

  Future<void> stop() async {
    // Use dual-process mode if enabled
    if (useDualProcessMode) {
      final svc = service;
      if (svc != null) {
        await svc.stopCore();
        _logger.info('leaf stopped in :core process');
      }
      _remoteRunning = false;
      _remoteSelectedNode = null;
    } else {
      _instance?.shutdown();
      _instance = null;
    }
  }

  /// Reload config from the existing config file on disk.
  Future<void> reload() async {
    final result = _instance?.reload();
    if (result != null && !LeafError.isOk(result)) {
      throw LeafException(result);
    }
  }

  /// Reload config from a JSON string via FFI (no file I/O).
  Future<void> reloadWithConfigString(String configJson) async {
    if (useDualProcessMode) {
      final svc = service;
      if (svc == null) {
        throw StateError('Service not available');
      }
      final success = await svc.syncConfig(configJson);
      if (!success) {
        throw LeafException(LeafError.runtimeManager);
      }
      return;
    }
    _requireRunning();
    final result = await _instance!.reloadWithConfigStringAsync(configJson);
    if (!LeafError.isOk(result)) {
      throw LeafException(result);
    }
  }

  // ---------------------------------------------------------------------------
  // Hot-reload: update routing mode without restarting the core
  // ---------------------------------------------------------------------------

  /// Hot-reload with a new routing mode. Rebuilds config and sends it
  /// directly via FFI — no file I/O, no core restart.
  ///
  /// Only router rules and outbound manager are reloaded (inbounds stay as-is).
  /// After reload, existing TCP connections are cancelled so new connections
  /// use the updated routing.
  Future<void> updateMode(Mode newMode, {required bool mmdbAvailable}) async {
    _requireRunning();

    _logger.info(
      'hotReload: mode ${_lastMode.name} → ${newMode.name}, '
      'mmdb=$mmdbAvailable',
    );

    // Build and serialize config off the UI isolate to avoid visible freezes
    // when users toggle modes rapidly on large subscription configs.
    final modeName = newMode.name;
    final proxies = _lastProxies
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
    final mixedPort = _mixedPort;
    final tunFd = _lastTunFd;
    final tunEnabled = _lastTunEnabled;
    final homeDir = _homeDir ?? '.';
    final configJson = await Isolate.run(() {
      final mode = Mode.values.firstWhere(
        (m) => m.name == modeName,
        orElse: () => Mode.global,
      );
      final logOutput = '$homeDir${Platform.pathSeparator}leaf.log';
      return ConfigWriter.build(
        proxies: proxies,
        mixedPort: mixedPort,
        tunFd: tunFd,
        tunEnabled: tunEnabled,
        logOutput: logOutput,
        mode: mode,
        mmdbAvailable: mmdbAvailable,
      ).toJsonString();
    });

    // Send config directly via FFI — no file I/O needed.
    _logger.info(
      'hotReload: sending config via FFI (${configJson.length} bytes)',
    );
    final stopwatch = Stopwatch()..start();
    await reloadWithConfigString(configJson);
    stopwatch.stop();
    _logger.info(
      'hotReload: reload finished in ${stopwatch.elapsedMilliseconds}ms',
    );

    // Update remembered state
    _lastMode = newMode;

    // Break existing TCP connections so they re-route with new rules
    closeConnections();
    _logger.info('hotReload: complete');
  }

  bool get isRunning {
    if (useDualProcessMode) {
      return _remoteRunning;
    }
    return _instance != null;
  }

  int get mixedPort => _mixedPort;

  Mode get currentMode => _lastMode;

  /// The list of proxy nodes from the current subscription.
  List<LeafNode> get nodes => List.unmodifiable(_nodes);

  /// Parse Clash YAML `proxies` into raw proxy maps without starting leaf.
  static List<Map<String, dynamic>> parseClashProxies(String yamlContent) {
    return _parseClashProxies(yamlContent);
  }

  /// Extract supported nodes from parsed Clash proxy entries.
  static List<LeafNode> extractNodesFromProxies(
    List<Map<String, dynamic>> proxies,
  ) {
    return _extractNodes(proxies);
  }

  /// Parse Clash YAML and extract supported nodes without starting leaf.
  static List<LeafNode> parseNodesFromClashYaml(String yamlContent) {
    return _extractNodes(_parseClashProxies(yamlContent));
  }

  // ---------------------------------------------------------------------------
  // Node selection (via FFI)
  // ---------------------------------------------------------------------------

  /// Select a proxy node by tag.
  ///
  /// If core is not running, this is a no-op (UI state is updated separately).
  /// The selection will be applied when core starts via [_ensureValidSelection].
  Future<void> selectNode(String nodeTag) async {
    if (useDualProcessMode) {
      if (!isRunning) {
        _logger.info(
          'selectNode: core not running, skipping remote call (requested=$nodeTag)',
        );
        return;
      }
      final svc = service;
      if (svc == null) {
        throw StateError('Service not available');
      }
      final success = await svc.selectCoreNode(nodeTag);
      if (!success) {
        throw StateError('selectCoreNode failed for $nodeTag');
      }
      final before = _remoteSelectedNode;
      _remoteSelectedNode = nodeTag;
      _logger.info(
        'selectNode(remote): $before -> $_remoteSelectedNode (requested=$nodeTag)',
      );
      return;
    }

    if (!isRunning) {
      _logger.info(
        'selectNode: core not running, skipping FFI call (requested=$nodeTag)',
      );
      return;
    }
    final before = getSelectedNode();
    final result = _instance!.setOutboundSelected(
      ConfigWriter.selectorTag,
      nodeTag,
    );
    if (!LeafError.isOk(result)) {
      _logger.error('selectNode: FFI returned error $result for tag=$nodeTag');
      throw LeafException(result);
    }
    final after = getSelectedNode();
    _logger.info(
      'selectNode: $before → $after (requested=$nodeTag, match=${after == nodeTag})',
    );

    // Cancel existing TCP relay connections so new connections use the new node
    closeConnections();
  }

  /// Cancel all active TCP relay connections.
  ///
  /// After selecting a new node, existing connections are still relaying
  /// through the old proxy server. This forces them to close so new
  /// connections go through the newly selected outbound.
  void closeConnections() {
    if (_instance == null) return;
    final ok = _instance!.closeConnections();
    _logger.info('closeConnections: $ok');
  }

  /// Get the currently selected node tag.
  String? getSelectedNode() {
    if (useDualProcessMode) {
      return _remoteSelectedNode;
    }
    if (_instance == null) return null;
    return _instance!.getOutboundSelected(ConfigWriter.selectorTag);
  }

  /// Get the list of available node tags from leaf's runtime.
  List<String> getAvailableNodes() {
    if (useDualProcessMode) {
      return _nodes.map((node) => node.tag).toList(growable: false);
    }
    if (_instance == null) return [];
    return _instance!.getOutboundSelects(ConfigWriter.selectorTag);
  }

  // ---------------------------------------------------------------------------
  // Health check (via FFI)
  // ---------------------------------------------------------------------------

  /// Run a health check for a node. Returns latency in ms, or null on failure.
  Future<({int tcpMs, int udpMs})?> healthCheck(
    String nodeTag, {
    int timeoutMs = 4000,
  }) async {
    if (useDualProcessMode) {
      final results = await healthCheckNodes([nodeTag], timeoutMs: timeoutMs);
      final delay = results[nodeTag];
      if (delay == null || delay <= 0) {
        return null;
      }
      return (tcpMs: delay, udpMs: 0);
    }
    _requireRunning();
    return _instance!.healthCheckAsync(nodeTag, timeoutMs: timeoutMs);
  }

  /// Run health checks for a set of nodes. Returns a map of tag -> latency ms.
  ///
  /// Values are chosen as TCP delay when available, otherwise UDP delay.
  /// `null` means failed/timeout.
  Future<Map<String, int?>> healthCheckNodes(
    Iterable<String> nodeTags, {
    int timeoutMs = 4000,
  }) async {
    final tags = <String>[];
    final dedup = <String>{};
    for (final tag in nodeTags) {
      final normalized = tag.trim();
      if (normalized.isEmpty || !dedup.add(normalized)) continue;
      tags.add(normalized);
    }
    if (tags.isEmpty) return {};

    _requireRunning();
    final results = <String, int?>{for (final tag in tags) tag: null};

    if (useDualProcessMode) {
      final svc = service;
      if (svc == null) {
        throw StateError('Service not available');
      }
      final remote = await svc.healthCheckCoreNodes(tags, timeoutMs: timeoutMs);
      for (final tag in tags) {
        final delay = remote[tag];
        results[tag] = (delay != null && delay > 0) ? delay : null;
      }
      return results;
    }

    final instance = _instance!;
    const maxConcurrency = 6;
    for (var i = 0; i < tags.length; i += maxConcurrency) {
      final end = (i + maxConcurrency > tags.length)
          ? tags.length
          : i + maxConcurrency;
      final chunk = tags.sublist(i, end);
      final chunkEntries = await Future.wait(
        chunk.map((tag) async {
          final result = await instance.healthCheckAsync(
            tag,
            timeoutMs: timeoutMs,
          );
          int? delay;
          if (result != null) {
            if (result.tcpMs > 0) {
              delay = result.tcpMs;
            } else if (result.udpMs > 0) {
              delay = result.udpMs;
            }
          }
          return MapEntry(tag, delay);
        }),
      );
      for (final entry in chunkEntries) {
        results[entry.key] = entry.value;
      }
    }
    return results;
  }

  /// Run health checks for all known nodes. Returns a map of tag -> latency ms.
  Future<Map<String, int?>> healthCheckAll({int timeoutMs = 4000}) async {
    return healthCheckNodes(
      _nodes.map((node) => node.tag),
      timeoutMs: timeoutMs,
    );
  }

  // ---------------------------------------------------------------------------
  // Latency probe (HTTP HEAD via local proxy)
  // ---------------------------------------------------------------------------

  /// Default endpoint for latency probes.
  static const String defaultLatencyTestUrl =
      'https://www.google.com/generate_204';

  /// Measure latency by sending an HTTP HEAD request through local proxy.
  ///
  /// Returns round-trip time in milliseconds, or `null` on failure.
  Future<int?> proxyHttpHeadLatency({
    required int proxyPort,
    String testUrl = defaultLatencyTestUrl,
    int timeoutMs = 8000,
    String? userAgent,
  }) async {
    final timeout = Duration(milliseconds: timeoutMs);
    HttpClient? client;
    final stopwatch = Stopwatch()..start();
    try {
      client = HttpClient()..connectionTimeout = timeout;
      client.badCertificateCallback = (_, _, _) => true;
      client.findProxy = (_) => 'PROXY 127.0.0.1:$proxyPort';
      if (userAgent != null && userAgent.isNotEmpty) {
        client.userAgent = userAgent;
      }

      final request = await client.headUrl(Uri.parse(testUrl)).timeout(timeout);
      request.followRedirects = true;
      request.maxRedirects = 3;

      final response = await request.close().timeout(timeout);
      await response.drain<void>();
      stopwatch.stop();

      if (response.statusCode >= 200 && response.statusCode < 500) {
        return stopwatch.elapsedMilliseconds;
      }
      _logger.warning(
        'proxyHttpHeadLatency: unexpected status=${response.statusCode}, '
        'url=$testUrl, port=$proxyPort',
      );
      return null;
    } catch (e) {
      _logger.warning(
        'proxyHttpHeadLatency: failed url=$testUrl, port=$proxyPort, error=$e',
      );
      return null;
    } finally {
      client?.close(force: true);
    }
  }

  /// Probe one node by selecting it, issuing HTTP HEAD via proxy, then restoring
  /// the previous selected node.
  Future<int?> probeNodeLatencyByHttpHead(
    String nodeTag, {
    required int proxyPort,
    String testUrl = defaultLatencyTestUrl,
    int timeoutMs = 8000,
    String? userAgent,
  }) async {
    if (!isRunning) {
      _logger.warning(
        'probeNodeLatencyByHttpHead: core is not running (node=$nodeTag)',
      );
      return null;
    }
    final exists = _nodes.any((node) => node.tag == nodeTag);
    if (!exists) {
      _logger.warning('probeNodeLatencyByHttpHead: node not found: $nodeTag');
      return null;
    }

    final originalSelected = getSelectedNode();
    final shouldRestore =
        originalSelected != null &&
        originalSelected.isNotEmpty &&
        originalSelected != nodeTag;
    try {
      if (shouldRestore) {
        await selectNode(nodeTag);
      }
      return await proxyHttpHeadLatency(
        proxyPort: proxyPort,
        testUrl: testUrl,
        timeoutMs: timeoutMs,
        userAgent: userAgent,
      );
    } catch (e) {
      _logger.warning(
        'probeNodeLatencyByHttpHead: failed node=$nodeTag, error=$e',
      );
      return null;
    } finally {
      if (shouldRestore) {
        try {
          await selectNode(originalSelected);
        } catch (e) {
          _logger.warning(
            'probeNodeLatencyByHttpHead: restore failed '
            '(from=$nodeTag,to=$originalSelected,error=$e)',
          );
        }
      }
    }
  }

  /// Probe all nodes by HTTP HEAD through local proxy.
  ///
  /// Each node is selected temporarily during probe and the original selection
  /// is restored before returning.
  Future<Map<String, int?>> probeAllNodesLatencyByHttpHead({
    required int proxyPort,
    String testUrl = defaultLatencyTestUrl,
    int timeoutMs = 8000,
    String? userAgent,
  }) async {
    final results = <String, int?>{};
    final tags = _nodes.map((node) => node.tag).toList(growable: false);
    for (final tag in tags) {
      results[tag] = null;
    }
    if (!isRunning || tags.isEmpty) {
      if (!isRunning) {
        _logger.warning(
          'probeAllNodesLatencyByHttpHead: core is not running; '
          'returning null delays',
        );
      }
      return results;
    }

    final originalSelected = getSelectedNode();
    try {
      for (final tag in tags) {
        try {
          final current = getSelectedNode();
          if (current == null || current != tag) {
            await selectNode(tag);
          }
          results[tag] = await proxyHttpHeadLatency(
            proxyPort: proxyPort,
            testUrl: testUrl,
            timeoutMs: timeoutMs,
            userAgent: userAgent,
          );
        } catch (e) {
          _logger.warning(
            'probeAllNodesLatencyByHttpHead: failed node=$tag, error=$e',
          );
          results[tag] = null;
        }
      }
    } finally {
      if (originalSelected != null &&
          originalSelected.isNotEmpty &&
          tags.contains(originalSelected)) {
        try {
          await selectNode(originalSelected);
        } catch (e) {
          _logger.warning(
            'probeAllNodesLatencyByHttpHead: restore failed '
            '(selected=$originalSelected,error=$e)',
          );
        }
      }
    }
    return results;
  }

  // ---------------------------------------------------------------------------
  // Stats (via FFI)
  // ---------------------------------------------------------------------------

  /// Get current connection statistics.
  List<LeafConnectionStat> getConnectionStats() {
    if (_instance == null) return [];
    final json = _instance!.getStatsJson();
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => LeafConnectionStat.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get traffic totals (sum of all active connections).
  ({int bytesSent, int bytesRecvd}) getTrafficTotals() {
    final stats = getConnectionStats();
    var sent = 0;
    var recvd = 0;
    for (final s in stats) {
      sent += s.bytesSent;
      recvd += s.bytesRecvd;
    }
    return (bytesSent: sent, bytesRecvd: recvd);
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  void _requireRunning() {
    if (useDualProcessMode) {
      if (!_remoteRunning) throw StateError('Leaf is not running');
      return;
    }
    if (_instance == null) throw StateError('Leaf is not running');
    // Detect post-startup crashes (e.g. TUN creation failed asynchronously
    // after the runtime was briefly registered in RUNTIME_MANAGER).
    final startupError = _instance!.startupError;
    if (startupError != null) {
      _logger.error(
        'leaf runtime has crashed: error $startupError '
        '(${LeafError.message(startupError)})',
      );
      _instance!.shutdown();
      _instance = null;
      throw LeafException(startupError);
    }
  }

  Future<void> _dumpLeafLog(String context) async {
    if (_homeDir == null) return;
    final logFile = File('$_homeDir${Platform.pathSeparator}leaf.log');
    try {
      if (await logFile.exists()) {
        final content = await logFile.readAsString();
        final tail = content.length > 2000
            ? content.substring(content.length - 2000)
            : content;
        _logger.error(
          '=== leaf.log ($context) last ${tail.length} chars ===\n$tail',
        );
      } else {
        _logger.error(
          'leaf.log not found at ${logFile.path} — '
          'leaf may have crashed before writing any logs',
        );
      }
    } catch (e) {
      _logger.error('failed to read leaf.log: $e');
    }
  }

  /// Parse Clash YAML `proxies:` section into a list of maps.
  static List<Map<String, dynamic>> _parseClashProxies(String yamlContent) {
    dynamic doc;
    try {
      doc = loadYaml(yamlContent);
    } catch (_) {
      // Retry with quoted name values — some subscriptions produce
      // unquoted names containing YAML-special characters (|, :, {, }, etc.)
      try {
        doc = loadYaml(_quoteProxyNames(yamlContent));
      } catch (_) {
        return [];
      }
    }
    if (doc is! YamlMap) return [];
    final proxies = doc['proxies'];
    if (proxies is! YamlList) return [];
    return proxies.map((p) {
      if (p is YamlMap) {
        return _yamlMapToMap(p);
      }
      return <String, dynamic>{};
    }).toList();
  }

  /// Quote unquoted `name:` values in YAML proxy entries.
  ///
  /// Handles both flow-style (`- { name: value, ... }`) and block-style
  /// (`  name: value`) entries.
  static String _quoteProxyNames(String yaml) {
    return yaml.replaceAllMapped(
      RegExp(
        r'name:\s*([^"'
        '\n,}]+)',
      ),
      (m) {
        final value = m.group(1)!.trim();
        if (value.isEmpty) return m.group(0)!;
        return 'name: "${value.replaceAll('"', r'\"')}"';
      },
    );
  }

  /// Recursively convert YamlMap to `Map<String, dynamic>`.
  static Map<String, dynamic> _yamlMapToMap(YamlMap yamlMap) {
    final result = <String, dynamic>{};
    for (final entry in yamlMap.entries) {
      final key = entry.key.toString();
      result[key] = _yamlValueToValue(entry.value);
    }
    return result;
  }

  static dynamic _yamlValueToValue(dynamic value) {
    if (value is YamlMap) return _yamlMapToMap(value);
    if (value is YamlList) return value.map(_yamlValueToValue).toList();
    return value;
  }

  /// Extract LeafNode metadata from Clash proxy entries.
  static List<LeafNode> _extractNodes(List<Map<String, dynamic>> proxies) {
    final nodes = <LeafNode>[];
    for (final proxy in proxies) {
      final name = proxy['name'] as String?;
      final type = (proxy['type'] as String?)?.toLowerCase();
      final server = proxy['server'] as String?;
      final port = proxy['port'] as int?;
      if (name == null || type == null || server == null || port == null) {
        continue;
      }
      // Only include protocols we support
      if (type != 'ss' && type != 'vmess' && type != 'trojan') continue;
      nodes.add(
        LeafNode(tag: name, protocol: type, server: server, port: port),
      );
    }
    return nodes;
  }
}
