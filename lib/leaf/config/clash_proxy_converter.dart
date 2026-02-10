import 'leaf_config.dart';

/// Converts Clash YAML proxy entries into leaf JSON outbounds.
///
/// Clash YAML format (V2Board subscription):
/// ```yaml
/// proxies:
///   - name: "node1"
///     type: ss
///     server: 1.2.3.4
///     port: 443
///     cipher: aes-256-gcm
///     password: "pass"
///   - name: "node2"
///     type: vmess
///     server: 1.2.3.4
///     port: 443
///     uuid: "..."
///     alterId: 0
///     cipher: auto
///     tls: true
///     network: ws
///     ws-opts:
///       path: /path
///       headers:
///         Host: example.com
/// ```
///
/// leaf uses chain outbounds for transport layering:
///   vmess + tls + ws → chain: [tls, ws, vmess]
///   trojan + ws     → chain: [tls, ws, trojan]
class ClashProxyConverter {
  ClashProxyConverter._();

  /// Convert a list of Clash proxy maps to leaf outbounds.
  /// Returns (outbounds, nodeTagMap) where nodeTagMap maps
  /// user-visible name → the tag to use in the select outbound.
  static ({List<LeafOutbound> outbounds, List<String> nodeTags})
      convertAll(List<Map<String, dynamic>> proxies) {
    final outbounds = <LeafOutbound>[];
    final nodeTags = <String>[];

    for (final proxy in proxies) {
      final name = proxy['name'] as String?;
      if (name == null || name.isEmpty) continue;

      final result = _convertOne(proxy);
      if (result == null) continue;

      outbounds.addAll(result.outbounds);
      nodeTags.add(result.userTag);
    }

    return (outbounds: outbounds, nodeTags: nodeTags);
  }

  static ({List<LeafOutbound> outbounds, String userTag})? _convertOne(
    Map<String, dynamic> proxy,
  ) {
    final type = (proxy['type'] as String?)?.toLowerCase();
    final name = proxy['name'] as String;

    return switch (type) {
      'ss' => _convertShadowsocks(proxy, name),
      'vmess' => _convertVMess(proxy, name),
      'trojan' => _convertTrojan(proxy, name),
      _ => null, // Unsupported protocol, skip silently
    };
  }

  // ---------------------------------------------------------------------------
  // Shadowsocks
  // ---------------------------------------------------------------------------

  static ({List<LeafOutbound> outbounds, String userTag})
      _convertShadowsocks(Map<String, dynamic> proxy, String name) {
    final server = proxy['server'] as String;
    final port = proxy['port'] as int;
    final cipher = proxy['cipher'] as String? ?? 'chacha20-ietf-poly1305';
    final password = proxy['password']?.toString() ?? '';

    final outbound = LeafOutbound.shadowsocks(
      tag: name,
      address: server,
      port: port,
      method: _mapCipher(cipher),
      password: password,
    );

    return (outbounds: [outbound], userTag: name);
  }

  // ---------------------------------------------------------------------------
  // VMess
  // ---------------------------------------------------------------------------

  static ({List<LeafOutbound> outbounds, String userTag})? _convertVMess(
    Map<String, dynamic> proxy,
    String name,
  ) {
    final server = proxy['server'] as String;
    final port = proxy['port'] as int;
    final uuid = proxy['uuid'] as String;
    final cipher = proxy['cipher'] as String? ?? 'auto';
    final tls = proxy['tls'] == true;
    final network = (proxy['network'] as String?)?.toLowerCase();
    final sni = proxy['servername'] as String? ??
        proxy['sni'] as String? ??
        (tls ? server : null);
    final skipCertVerify = proxy['skip-cert-verify'] == true;

    // Core VMess outbound
    final vmessTag = _internalTag(name, 'vmess');
    final vmessOut = LeafOutbound.vmess(
      tag: vmessTag,
      address: server,
      port: port,
      uuid: uuid,
      security: _mapVMessSecurity(cipher),
    );

    final outbounds = <LeafOutbound>[vmessOut];
    final chainActors = <String>[];

    // TLS layer
    if (tls) {
      final tlsTag = _internalTag(name, 'tls');
      outbounds.add(LeafOutbound.tls(
        tag: tlsTag,
        serverName: sni,
        insecure: skipCertVerify ? true : null,
      ));
      chainActors.add(tlsTag);
    }

    // WebSocket layer
    if (network == 'ws') {
      final wsOpts =
          proxy['ws-opts'] as Map<String, dynamic>? ?? const {};
      final path = wsOpts['path'] as String? ?? '/';
      final headers = (wsOpts['headers'] as Map?)?.cast<String, String>();

      final wsTag = _internalTag(name, 'ws');
      outbounds.add(LeafOutbound.ws(
        tag: wsTag,
        path: path,
        headers: headers,
      ));
      chainActors.add(wsTag);
    }

    // If we have transport layers, chain them: [tls?, ws?, vmess]
    if (chainActors.isNotEmpty) {
      chainActors.add(vmessTag);
      outbounds.add(LeafOutbound.chain(tag: name, actors: chainActors));
      return (outbounds: outbounds, userTag: name);
    }

    // Plain VMess, rename tag to user-visible name
    return (
      outbounds: [
        LeafOutbound.vmess(
          tag: name,
          address: server,
          port: port,
          uuid: uuid,
          security: _mapVMessSecurity(cipher),
        )
      ],
      userTag: name,
    );
  }

  // ---------------------------------------------------------------------------
  // Trojan
  // ---------------------------------------------------------------------------

  static ({List<LeafOutbound> outbounds, String userTag})? _convertTrojan(
    Map<String, dynamic> proxy,
    String name,
  ) {
    final server = proxy['server'] as String;
    final port = proxy['port'] as int;
    final password = proxy['password']?.toString() ?? '';
    final sni = proxy['sni'] as String? ??
        proxy['servername'] as String? ??
        server;
    final skipCertVerify = proxy['skip-cert-verify'] == true;
    final network = (proxy['network'] as String?)?.toLowerCase();

    // Core Trojan outbound
    final trojanTag = _internalTag(name, 'trojan');
    final trojanOut = LeafOutbound.trojan(
      tag: trojanTag,
      address: server,
      port: port,
      password: password,
    );

    final outbounds = <LeafOutbound>[trojanOut];
    final chainActors = <String>[];

    // TLS layer (Trojan always uses TLS)
    final tlsTag = _internalTag(name, 'tls');
    outbounds.add(LeafOutbound.tls(
      tag: tlsTag,
      serverName: sni,
      insecure: skipCertVerify ? true : null,
    ));
    chainActors.add(tlsTag);

    // WebSocket layer (optional)
    if (network == 'ws') {
      final wsOpts =
          proxy['ws-opts'] as Map<String, dynamic>? ?? const {};
      final path = wsOpts['path'] as String? ?? '/';
      final headers = (wsOpts['headers'] as Map?)?.cast<String, String>();

      final wsTag = _internalTag(name, 'ws');
      outbounds.add(LeafOutbound.ws(
        tag: wsTag,
        path: path,
        headers: headers,
      ));
      chainActors.add(wsTag);
    }

    // Chain: [tls, ws?, trojan]
    chainActors.add(trojanTag);
    outbounds.add(LeafOutbound.chain(tag: name, actors: chainActors));

    return (outbounds: outbounds, userTag: name);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Internal tag for chain components (not user-visible).
  static String _internalTag(String name, String component) =>
      '${name}__$component';

  /// Map Clash cipher names to leaf cipher names.
  static String _mapCipher(String clashCipher) {
    // leaf uses the same names as Clash for most ciphers
    return switch (clashCipher.toLowerCase()) {
      'aes-128-gcm' => 'aes-128-gcm',
      'aes-256-gcm' => 'aes-256-gcm',
      'chacha20-ietf-poly1305' => 'chacha20-ietf-poly1305',
      'xchacha20-ietf-poly1305' => 'xchacha20-ietf-poly1305',
      'aes-128-cfb' => 'aes-128-cfb',
      'aes-256-cfb' => 'aes-256-cfb',
      'rc4-md5' => 'rc4-md5',
      _ => clashCipher.toLowerCase(), // Pass through
    };
  }

  /// Map Clash VMess security to leaf VMess security.
  static String _mapVMessSecurity(String clashSecurity) {
    return switch (clashSecurity.toLowerCase()) {
      'auto' => 'auto',
      'aes-128-gcm' => 'aes-128-gcm',
      'chacha20-poly1305' => 'chacha20-poly1305',
      'none' => 'none',
      _ => 'auto',
    };
  }
}
