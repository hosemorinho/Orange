import 'dart:io';

import 'clash_proxy_converter.dart';
import 'leaf_config.dart';

/// Assembles a complete leaf JSON config from Clash YAML proxy entries.
///
/// Generates:
/// - Inbounds: HTTP + SOCKS (+ TUN on Android)
/// - Outbounds: direct + all converted proxy nodes + select group
/// - Router: route everything through the select group
/// - DNS: public servers
class ConfigWriter {
  ConfigWriter._();

  /// Selector outbound tag — used in FFI calls to select/get nodes.
  static const String selectorTag = 'proxy';

  /// Build a leaf config from Clash proxy entries.
  static LeafConfig build({
    required List<Map<String, dynamic>> proxies,
    required int mixedPort,
    int? tunFd,
    String logLevel = 'warn',
  }) {
    // Convert Clash proxies to leaf outbounds
    final converted = ClashProxyConverter.convertAll(proxies);

    // Assemble inbounds — single mixed port handles both HTTP and SOCKS5
    final inbounds = <LeafInbound>[
      LeafInbound.mixed(port: mixedPort),
      if (tunFd != null) LeafInbound.tun(fd: tunFd),
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

    // Router: route all traffic through the selector
    final router = LeafRouter(
      rules: [
        if (converted.nodeTags.isNotEmpty) LeafRule(target: selectorTag),
      ],
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
