import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/leaf/config/clash_proxy_converter.dart';
import 'package:fl_clash/leaf/config/config_writer.dart';
import 'package:fl_clash/leaf/config/leaf_config.dart';
import 'package:fl_clash/leaf/ffi/leaf_errors.dart';
import 'package:fl_clash/leaf/ffi/leaf_ffi.dart';
import 'package:fl_clash/leaf/models/leaf_node.dart';
import 'package:fl_clash/xboard/core/core.dart';  // FileLogger
import 'package:yaml/yaml.dart';

final _logger = FileLogger('leaf_controller.dart');

/// High-level controller for the leaf proxy core.
///
/// Manages the leaf lifecycle, config generation, node selection, and
/// health checks — all through FFI (no REST API).
class LeafController {
  static const int _rtId = 1;

  final LeafFfi _ffi;
  LeafInstance? _instance;

  String? _homeDir;
  String? _configPath;

  /// Nodes extracted from the last loaded Clash YAML.
  List<LeafNode> _nodes = [];

  /// Ports used for local proxy.
  int _httpPort = 7890;
  int _socksPort = 7891;

  LeafController() : _ffi = LeafFfi.open();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Initialize with the app's home directory.
  Future<void> init(String homeDir) async {
    _homeDir = homeDir;
    await Directory(homeDir).create(recursive: true);
  }

  /// Load a Clash YAML subscription and start the proxy.
  ///
  /// [yamlContent] is the raw Clash YAML string from V2Board.
  /// [tunFd] is the Android VPN TUN file descriptor (null on desktop).
  Future<void> startWithClashYaml(
    String yamlContent, {
    int? tunFd,
    int httpPort = 7890,
    int socksPort = 7891,
  }) async {
    _httpPort = httpPort;
    _socksPort = socksPort;

    // Parse Clash YAML proxies
    final proxies = _parseClashProxies(yamlContent);
    if (proxies.isEmpty) {
      _logger.warning('parsed 0 proxies from YAML (${yamlContent.length} bytes). '
          'First 200 chars: ${yamlContent.substring(0, yamlContent.length.clamp(0, 200))}');
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
    _logger.info('supported nodes: ${_nodes.length} / ${proxies.length} total proxies');

    // Build leaf config
    final config = ConfigWriter.build(
      proxies: proxies,
      httpPort: _httpPort,
      socksPort: _socksPort,
      tunFd: tunFd,
    );

    await _startWithConfig(config);
  }

  /// Start leaf with a pre-built config.
  Future<void> _startWithConfig(LeafConfig config) async {
    if (_homeDir == null) throw StateError('Call init() first');

    // Stop existing instance if running
    if (_instance != null) {
      await stop();
    }

    // Write config to temp file (cleaned up on stop)
    _configPath = await ConfigWriter.writeToFile(
      config: config,
      directory: Directory.systemTemp.path,
    );

    // Validate config
    final testResult = _ffi.testConfig(_configPath!);
    if (!LeafError.isOk(testResult)) {
      throw LeafException(testResult);
    }

    // Start leaf in isolate
    _instance = await _ffi.start(
      rtId: _rtId,
      configPath: _configPath!,
    );
  }

  /// Stop the proxy and clean up temp config.
  Future<void> stop() async {
    _instance?.shutdown();
    _instance = null;
    await _deleteConfigFile();
  }

  /// Reload config (e.g., after modifying the JSON file).
  Future<void> reload() async {
    final result = _instance?.reload();
    if (result != null && !LeafError.isOk(result)) {
      throw LeafException(result);
    }
  }

  bool get isRunning => _instance != null;

  int get httpPort => _httpPort;
  int get socksPort => _socksPort;

  /// The list of proxy nodes from the current subscription.
  List<LeafNode> get nodes => List.unmodifiable(_nodes);

  // ---------------------------------------------------------------------------
  // Node selection (via FFI)
  // ---------------------------------------------------------------------------

  /// Select a proxy node by tag.
  Future<void> selectNode(String nodeTag) async {
    _requireRunning();
    final result = _instance!.setOutboundSelected(
      ConfigWriter.selectorTag,
      nodeTag,
    );
    if (!LeafError.isOk(result)) {
      throw LeafException(result);
    }
  }

  /// Get the currently selected node tag.
  String? getSelectedNode() {
    if (_instance == null) return null;
    return _instance!.getOutboundSelected(ConfigWriter.selectorTag);
  }

  /// Get the list of available node tags from leaf's runtime.
  List<String> getAvailableNodes() {
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
    _requireRunning();
    return _instance!.healthCheck(nodeTag, timeoutMs: timeoutMs);
  }

  /// Run health checks for all nodes. Returns a map of tag → tcp latency ms.
  Future<Map<String, int?>> healthCheckAll({int timeoutMs = 4000}) async {
    _requireRunning();
    final results = <String, int?>{};
    for (final node in _nodes) {
      final result = _instance!.healthCheck(node.tag, timeoutMs: timeoutMs);
      results[node.tag] = result?.tcpMs;
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
    if (_instance == null) throw StateError('Leaf is not running');
  }

  /// Delete the temp config file from disk.
  Future<void> _deleteConfigFile() async {
    if (_configPath == null) return;
    try {
      final file = File(_configPath!);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
    _configPath = null;
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
      RegExp(r'name:\s*([^"''\n,}]+)'),
      (m) {
        final value = m.group(1)!.trim();
        if (value.isEmpty) return m.group(0)!;
        return 'name: "${value.replaceAll('"', r'\"')}"';
      },
    );
  }

  /// Recursively convert YamlMap to Map<String, dynamic>.
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
      nodes.add(LeafNode(tag: name, protocol: type, server: server, port: port));
    }
    return nodes;
  }
}
