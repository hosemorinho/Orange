import 'dart:convert';

/// Leaf proxy core JSON configuration model.
/// Maps 1:1 to leaf's config/common.rs structs.

class LeafConfig {
  final LeafLog? log;
  final List<LeafInbound>? inbounds;
  final List<LeafOutbound>? outbounds;
  final LeafRouter? router;
  final LeafDns? dns;

  const LeafConfig({
    this.log,
    this.inbounds,
    this.outbounds,
    this.router,
    this.dns,
  });

  Map<String, dynamic> toJson() => {
        if (log != null) 'log': log!.toJson(),
        if (inbounds != null)
          'inbounds': inbounds!.map((e) => e.toJson()).toList(),
        if (outbounds != null)
          'outbounds': outbounds!.map((e) => e.toJson()).toList(),
        if (router != null) 'router': router!.toJson(),
        if (dns != null) 'dns': dns!.toJson(),
      };

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());
}

class LeafLog {
  final String? level;

  const LeafLog({this.level});

  Map<String, dynamic> toJson() => {
        if (level != null) 'level': level,
      };
}

class LeafDns {
  final List<String>? servers;
  final Map<String, List<String>>? hosts;

  const LeafDns({this.servers, this.hosts});

  Map<String, dynamic> toJson() => {
        if (servers != null) 'servers': servers,
        if (hosts != null) 'hosts': hosts,
      };
}

// ---------------------------------------------------------------------------
// Inbound
// ---------------------------------------------------------------------------

class LeafInbound {
  final String? tag;
  final String? address;
  final int? port;
  final String protocol;
  final Map<String, dynamic>? settings;

  const LeafInbound({
    this.tag,
    this.address,
    this.port,
    required this.protocol,
    this.settings,
  });

  Map<String, dynamic> toJson() => {
        if (tag != null) 'tag': tag,
        if (address != null) 'address': address,
        if (port != null) 'port': port,
        'protocol': protocol,
        if (settings != null) 'settings': settings,
      };

  /// HTTP proxy inbound on localhost.
  factory LeafInbound.http({required int port, String? tag}) => LeafInbound(
        tag: tag ?? 'http_in',
        address: '127.0.0.1',
        port: port,
        protocol: 'http',
      );

  /// SOCKS5 proxy inbound on localhost.
  factory LeafInbound.socks({required int port, String? tag}) => LeafInbound(
        tag: tag ?? 'socks_in',
        address: '127.0.0.1',
        port: port,
        protocol: 'socks',
      );

  /// Mixed HTTP+SOCKS5 inbound on a single port.
  /// Leaf detects the protocol by peeking the first byte:
  /// 0x05 → SOCKS5, otherwise → HTTP.
  factory LeafInbound.mixed({required int port, String? tag}) => LeafInbound(
        tag: tag ?? 'mixed_in',
        address: '127.0.0.1',
        port: port,
        protocol: 'mixed',
      );

  factory LeafInbound.tun({required int fd, int mtu = 9000, String? tag}) =>
      LeafInbound(
        tag: tag ?? 'tun_in',
        protocol: 'tun',
        settings: {'fd': fd, 'mtu': mtu},
      );

  /// TUN inbound with auto mode (macOS/Linux/Windows).
  /// Leaf auto-creates the TUN device and configures routes via sys.rs.
  /// - macOS/Linux: requires root or CAP_NET_ADMIN (SUID)
  /// - Windows: uses Wintun (wintun.dll must be next to executable), requires admin
  factory LeafInbound.tunAuto({String? tag}) => LeafInbound(
        tag: tag ?? 'tun_in',
        protocol: 'tun',
        settings: {'auto': true, 'fd': -1, 'mtu': 1500},
      );

}

// ---------------------------------------------------------------------------
// Outbound
// ---------------------------------------------------------------------------

class LeafOutbound {
  final String? tag;
  final String protocol;
  final Map<String, dynamic>? settings;

  const LeafOutbound({
    this.tag,
    required this.protocol,
    this.settings,
  });

  Map<String, dynamic> toJson() => {
        if (tag != null) 'tag': tag,
        'protocol': protocol,
        if (settings != null) 'settings': settings,
      };

  /// Direct outbound (no proxy).
  factory LeafOutbound.direct({String? tag}) => LeafOutbound(
        tag: tag ?? 'direct',
        protocol: 'direct',
      );

  /// Select outbound (user picks one of actors).
  factory LeafOutbound.select({
    required String tag,
    required List<String> actors,
  }) =>
      LeafOutbound(
        tag: tag,
        protocol: 'select',
        settings: {'actors': actors},
      );

  /// Shadowsocks outbound.
  factory LeafOutbound.shadowsocks({
    required String tag,
    required String address,
    required int port,
    required String method,
    required String password,
  }) =>
      LeafOutbound(
        tag: tag,
        protocol: 'shadowsocks',
        settings: {
          'address': address,
          'port': port,
          'method': method,
          'password': password,
        },
      );

  /// VMess outbound (protocol layer only, no transport).
  factory LeafOutbound.vmess({
    required String tag,
    required String address,
    required int port,
    required String uuid,
    String security = 'auto',
  }) =>
      LeafOutbound(
        tag: tag,
        protocol: 'vmess',
        settings: {
          'address': address,
          'port': port,
          'uuid': uuid,
          'security': security,
        },
      );

  /// Trojan outbound (protocol layer only).
  factory LeafOutbound.trojan({
    required String tag,
    required String address,
    required int port,
    required String password,
  }) =>
      LeafOutbound(
        tag: tag,
        protocol: 'trojan',
        settings: {
          'address': address,
          'port': port,
          'password': password,
        },
      );

  /// TLS transport outbound.
  factory LeafOutbound.tls({
    required String tag,
    String? serverName,
    List<String>? alpn,
    bool? insecure,
  }) =>
      LeafOutbound(
        tag: tag,
        protocol: 'tls',
        settings: {
          if (serverName != null) 'serverName': serverName,
          if (alpn != null) 'alpn': alpn,
          if (insecure != null) 'insecure': insecure,
        },
      );

  /// WebSocket transport outbound.
  factory LeafOutbound.ws({
    required String tag,
    String? path,
    Map<String, String>? headers,
  }) =>
      LeafOutbound(
        tag: tag,
        protocol: 'ws',
        settings: {
          if (path != null) 'path': path,
          if (headers != null) 'headers': headers,
        },
      );

  /// Chain outbound (connects actors in order: first → … → last).
  factory LeafOutbound.chain({
    required String tag,
    required List<String> actors,
  }) =>
      LeafOutbound(
        tag: tag,
        protocol: 'chain',
        settings: {'actors': actors},
      );
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

class LeafRouter {
  final List<LeafRule>? rules;
  final bool? domainResolve;

  const LeafRouter({this.rules, this.domainResolve});

  Map<String, dynamic> toJson() => {
        if (rules != null) 'rules': rules!.map((e) => e.toJson()).toList(),
        if (domainResolve != null) 'domainResolve': domainResolve,
      };
}

class LeafRule {
  final String target;
  final String? type;
  final List<String>? ip;
  final List<String>? domain;
  final List<String>? domainKeyword;
  final List<String>? domainSuffix;
  final List<String>? network;
  final List<String>? inboundTag;
  final List<String>? portRange;
  final List<String>? external;

  const LeafRule({
    required this.target,
    this.type,
    this.ip,
    this.domain,
    this.domainKeyword,
    this.domainSuffix,
    this.network,
    this.inboundTag,
    this.portRange,
    this.external,
  });

  /// FINAL rule — makes the target outbound the default handler.
  const LeafRule.final_({required this.target})
      : type = 'FINAL',
        ip = null,
        domain = null,
        domainKeyword = null,
        domainSuffix = null,
        network = null,
        inboundTag = null,
        portRange = null,
        external = null;

  Map<String, dynamic> toJson() => {
        'target': target,
        if (type != null) 'type': type,
        if (ip != null) 'ip': ip,
        if (domain != null) 'domain': domain,
        if (domainKeyword != null) 'domainKeyword': domainKeyword,
        if (domainSuffix != null) 'domainSuffix': domainSuffix,
        if (network != null) 'network': network,
        if (inboundTag != null) 'inboundTag': inboundTag,
        if (portRange != null) 'portRange': portRange,
        if (external != null) 'external': external,
      };
}
