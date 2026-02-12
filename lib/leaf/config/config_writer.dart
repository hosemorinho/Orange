import 'dart:io';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/xboard/core/logger/file_logger.dart';

import 'clash_proxy_converter.dart';
import 'leaf_config.dart';

final _logger = FileLogger('config_writer.dart');

/// Assembles a complete leaf JSON config from Clash YAML proxy entries.
///
/// Generates:
/// - Inbounds: HTTP + SOCKS (+ TUN on Android)
/// - Outbounds: direct + all converted proxy nodes + select group
/// - Router: mode-aware routing rules
/// - DNS: public servers
class ConfigWriter {
  ConfigWriter._();

  /// Selector outbound tag — used in FFI calls to select/get nodes.
  static const String selectorTag = 'proxy';

  /// Build a leaf config from Clash proxy entries.
  ///
  /// [mode] controls routing behavior:
  /// - [Mode.global]: all traffic through proxy (FINAL → proxy)
  /// - [Mode.rule]: CN traffic direct via GeoIP, rest through proxy
  /// - [Mode.direct]: all traffic direct (FINAL → direct)
  ///
  /// For rule mode, geo.mmdb must be in the ASSET_LOCATION directory
  /// (set via LeafController.init → leaf_set_env).
  static LeafConfig build({
    required List<Map<String, dynamic>> proxies,
    required int mixedPort,
    int? tunFd,
    bool tunEnabled = false,
    String logLevel = 'warn',
    Mode mode = Mode.global,
    bool mmdbAvailable = false,
  }) {
    // Convert Clash proxies to leaf outbounds
    final converted = ClashProxyConverter.convertAll(proxies);

    // Assemble inbounds — mixed HTTP+SOCKS5 on a single port.
    // Leaf's mixed inbound peeks the first byte: 0x05 → SOCKS5, else → HTTP.
    final inbounds = <LeafInbound>[
      LeafInbound.mixed(port: mixedPort),
      // Android: TUN via VPN service fd
      if (tunFd != null) LeafInbound.tun(fd: tunFd),
      // macOS/Linux: TUN auto mode (leaf creates device + routes)
      if (tunEnabled && tunFd == null && (Platform.isMacOS || Platform.isLinux))
        LeafInbound.tunAuto(),
      if (tunEnabled && Platform.isWindows && _isNfDriverAvailable())
        LeafInbound.nf(),
    ];

    // Assemble outbounds: direct + proxy nodes + select group
    final outbounds = <LeafOutbound>[
      LeafOutbound.direct(),
      ...converted.outbounds,
      if (converted.nodeTags.isNotEmpty)
        LeafOutbound.select(
          tag: selectorTag,
          actors: converted.nodeTags,
        ),
    ];

    // Router: mode-aware routing rules
    final rules = _buildRules(
      mode: mode,
      mmdbAvailable: mmdbAvailable,
      hasNodes: converted.nodeTags.isNotEmpty,
    );
    _logger.info('build: mode=${mode.name}, mmdbAvailable=$mmdbAvailable, '
        'rules=${rules.length}, nodes=${converted.nodeTags.length}');
    if (mode == Mode.rule) {
      for (final r in rules) {
        _logger.info('build: rule target=${r.target}, type=${r.type}, '
            'external=${r.external}');
      }
    }
    final router = LeafRouter(
      rules: rules,
      domainResolve: true,
    );

    // DNS
    final dns = LeafDns(
      servers: ['8.8.8.8', '1.1.1.1', '223.5.5.5'],
    );

    return LeafConfig(
      log: LeafLog(level: logLevel),
      inbounds: inbounds,
      outbounds: outbounds,
      router: router,
      dns: dns,
    );
  }

  /// Build routing rules based on the selected mode.
  ///
  /// Uses `mmdb:cn` (2-part format) — leaf resolves the file via
  /// ASSET_LOCATION/geo.mmdb. This avoids Windows drive letter colon
  /// conflicts in the 3-part `mmdb:path:code` format.
  static List<LeafRule> _buildRules({
    required Mode mode,
    required bool mmdbAvailable,
    required bool hasNodes,
  }) {
    if (!hasNodes) return [];

    return switch (mode) {
      Mode.global => [
        LeafRule.final_(target: selectorTag),
      ],
      Mode.rule => [
        if (mmdbAvailable)
          LeafRule(
            target: 'direct',
            external: ['mmdb:cn'],
          )
        else
          ..._logMissingMmdb(),
        LeafRule.final_(target: selectorTag),
      ],
      Mode.direct => [
        LeafRule.final_(target: 'direct'),
      ],
    };
  }

  static List<LeafRule> _logMissingMmdb() {
    _logger.warning(
      'Rule mode active but geo.mmdb is unavailable in ASSET_LOCATION. '
      'CN traffic will NOT be routed directly — behaving like global mode.',
    );
    return [];
  }

  static bool _isNfDriverAvailable() {
    if (!Platform.isWindows) return false;
    final systemRoot =
        Platform.environment['SystemRoot'] ?? r'C:\Windows';
    final driverPath =
        '$systemRoot\\system32\\drivers\\nfdriver.sys';
    final exists = File(driverPath).existsSync();
    if (!exists) {
      _logger.warning(
        'nfdriver.sys not found at $driverPath — TUN/NF mode unavailable. '
        'Install the NF driver to enable TUN on Windows.',
      );
    }
    return exists;
  }

  /// Write a leaf config to a JSON file.
  static Future<String> writeToFile({
    required LeafConfig config,
    required String directory,
    String filename = 'leaf_config.json',
  }) async {
    final path = '$directory${Platform.pathSeparator}$filename';
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(config.toJsonString());
    return path;
  }
}
