/// Represents a proxy node available in leaf's select outbound.
class LeafNode {
  /// The outbound tag (user-visible name from Clash proxy `name` field).
  final String tag;

  /// Protocol type: "ss", "vmess", "trojan".
  final String protocol;

  /// Server address.
  final String server;

  /// Server port.
  final int port;

  const LeafNode({
    required this.tag,
    required this.protocol,
    required this.server,
    required this.port,
  });

  @override
  String toString() => 'LeafNode($tag, $protocol, $server:$port)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LeafNode && tag == other.tag;

  @override
  int get hashCode => tag.hashCode;
}

/// Connection statistics from leaf.
class LeafConnectionStat {
  final String network;
  final String inboundTag;
  final String source;
  final String destination;
  final String outboundTag;
  final int bytesSent;
  final int bytesRecvd;
  final bool sendCompleted;
  final bool recvCompleted;

  const LeafConnectionStat({
    required this.network,
    required this.inboundTag,
    required this.source,
    required this.destination,
    required this.outboundTag,
    required this.bytesSent,
    required this.bytesRecvd,
    required this.sendCompleted,
    required this.recvCompleted,
  });

  factory LeafConnectionStat.fromJson(Map<String, dynamic> json) =>
      LeafConnectionStat(
        network: json['network'] as String? ?? '',
        inboundTag: json['inbound_tag'] as String? ?? '',
        source: json['source'] as String? ?? '',
        destination: json['destination'] as String? ?? '',
        outboundTag: json['outbound_tag'] as String? ?? '',
        bytesSent: json['bytes_sent'] as int? ?? 0,
        bytesRecvd: json['bytes_recvd'] as int? ?? 0,
        sendCompleted: json['send_completed'] as bool? ?? false,
        recvCompleted: json['recv_completed'] as bool? ?? false,
      );

  bool get isActive => !sendCompleted || !recvCompleted;
}
