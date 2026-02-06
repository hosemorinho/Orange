/// DNS-over-HTTPS TXT Record Resolver
///
/// Resolves DNS TXT records using multiple DoH servers with direct IP connection:
/// - Alibaba Cloud DNS: 223.5.5.5 / 223.6.6.6 (fast in China)
/// - Cloudflare DNS: 1.1.1.1 / 1.0.0.1 (global backup)
///
/// All servers race concurrently, fastest response wins.
/// Bypasses proxy/TUN via direct HTTPS connection using RFC 8484 wire format.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:fl_clash/xboard/core/core.dart';

final _logger = FileLogger('doh_txt_resolver.dart');

/// DoH TXT Resolver
class DohTxtResolver {
  /// DoH servers (direct IP connection, bypass proxy)
  /// - 223.5.5.5 / 223.6.6.6: Alibaba Cloud DNS (fast in China)
  /// - 1.1.1.1 / 1.0.0.1: Cloudflare DNS (global backup)
  static const _dohServers = ['223.5.5.5', '223.6.6.6', '1.1.1.1', '1.0.0.1'];
  static const _timeout = Duration(seconds: 5);

  /// Resolve TXT records for a domain
  ///
  /// [domain] Domain name to query
  ///
  /// Returns the first TXT record value or null if resolution fails
  static Future<String?> resolveTxt(String domain) async {
    _logger.info('[DoH] 开始解析 TXT 记录: $domain (使用 ${_dohServers.length} 个 DoH 服务器竞速)');

    // Race all DoH servers (Alibaba + Cloudflare)
    final futures = _dohServers.map((server) => _queryServer(server, domain));

    try {
      final result = await Future.any(futures).timeout(_timeout);
      if (result != null) {
        _logger.info('[DoH] TXT 解析成功: ${result.length} 字符');
      } else {
        _logger.warning('[DoH] TXT 解析返回空值');
      }
      return result;
    } on TimeoutException {
      _logger.error('[DoH] 所有 ${_dohServers.length} 个 DoH 服务器超时 (${_dohServers.join(", ")})');
      return null;
    } catch (e, stackTrace) {
      _logger.error('[DoH] TXT 解析失败', e, stackTrace);
      return null;
    }
  }

  /// Query a single DoH server
  static Future<String?> _queryServer(String serverIp, String domain) async {
    HttpClient? client;
    try {
      _logger.info('[DoH] 查询服务器 $serverIp: $domain');

      // Build DNS query (RFC 1035 wire format)
      final queryId = DateTime.now().millisecondsSinceEpoch % 65536;
      final dnsQuery = _buildDnsQuery(domain, queryId);

      // RFC 8484: GET /dns-query?dns=<base64url_no_padding>
      final base64url = base64Url.encode(dnsQuery).replaceAll('=', '');
      final uri = Uri.parse('https://$serverIp/dns-query?dns=$base64url');

      // Direct IP connection with certificate bypass
      client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      client.connectionTimeout = _timeout;

      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/dns-message');
      request.headers.set(HttpHeaders.userAgentHeader, 'Orange-DoH/1.0');

      final response = await request.close().timeout(_timeout);

      if (response.statusCode != 200) {
        _logger.warning('[DoH] 服务器 $serverIp 返回状态码: ${response.statusCode}');
        return null;
      }

      final responseBytes = await response.fold<BytesBuilder>(
        BytesBuilder(),
        (builder, chunk) {
          builder.add(chunk);
          return builder;
        },
      ).then((builder) => builder.takeBytes());

      final txtValue = _parseDnsResponse(responseBytes);
      if (txtValue != null) {
        _logger.info('[DoH] 服务器 $serverIp 解析成功');
      }
      return txtValue;
    } catch (e) {
      _logger.warning('[DoH] 服务器 $serverIp 查询失败: $e');
      return null;
    } finally {
      client?.close();
    }
  }

  /// Build DNS query in RFC 1035 wire format
  ///
  /// Query structure:
  /// - 12 bytes header
  /// - Question section: domain name + QTYPE (16=TXT) + QCLASS (1=IN)
  static Uint8List _buildDnsQuery(String domain, int queryId) {
    final builder = BytesBuilder();

    // Header (12 bytes)
    builder.add([
      queryId >> 8, queryId & 0xFF, // ID
      0x01, 0x00, // Flags: standard query with recursion
      0x00, 0x01, // QDCOUNT: 1 question
      0x00, 0x00, // ANCOUNT: 0 answers
      0x00, 0x00, // NSCOUNT: 0 authority records
      0x00, 0x00, // ARCOUNT: 0 additional records
    ]);

    // Question section: domain name (label format)
    for (final label in domain.split('.')) {
      final labelBytes = utf8.encode(label);
      builder.addByte(labelBytes.length);
      builder.add(labelBytes);
    }
    builder.addByte(0); // End of domain name

    // QTYPE: 16 (TXT)
    builder.add([0x00, 0x10]);

    // QCLASS: 1 (IN)
    builder.add([0x00, 0x01]);

    return builder.toBytes();
  }

  /// Parse DNS response and extract TXT record
  ///
  /// RFC 1035 response format:
  /// - Header (12 bytes)
  /// - Question section (variable)
  /// - Answer section (variable, contains TXT RDATA)
  static String? _parseDnsResponse(Uint8List response) {
    try {
      if (response.length < 12) {
        _logger.error('[DoH] 响应太短（< 12 字节）');
        return null;
      }

      // Parse header
      final ancount = (response[6] << 8) | response[7];
      if (ancount == 0) {
        _logger.warning('[DoH] 无应答记录');
        return null;
      }

      int offset = 12;

      // Skip question section
      // Read domain name labels until null terminator
      while (offset < response.length && response[offset] != 0) {
        final labelLen = response[offset];
        if (labelLen >= 0xC0) {
          // Compressed pointer (2 bytes)
          offset += 2;
          break;
        }
        offset += labelLen + 1;
      }
      offset++; // Skip null terminator
      offset += 4; // Skip QTYPE (2) + QCLASS (2)

      // Parse answer section
      for (int i = 0; i < ancount; i++) {
        if (offset >= response.length) break;

        // Skip NAME (may be compressed)
        if (response[offset] >= 0xC0) {
          offset += 2; // Compressed pointer
        } else {
          while (offset < response.length && response[offset] != 0) {
            offset += response[offset] + 1;
          }
          offset++; // Skip null terminator
        }

        if (offset + 10 > response.length) break;

        final type = (response[offset] << 8) | response[offset + 1];
        offset += 8; // Skip TYPE (2) + CLASS (2) + TTL (4)

        final rdlength = (response[offset] << 8) | response[offset + 1];
        offset += 2;

        if (type == 16) {
          // TXT record found
          if (offset + rdlength > response.length) break;

          // TXT RDATA format: one or more character-strings
          // Each string: 1-byte length + data
          final txtData = <int>[];
          int pos = offset;
          while (pos < offset + rdlength) {
            final len = response[pos];
            pos++;
            if (pos + len <= offset + rdlength) {
              txtData.addAll(response.sublist(pos, pos + len));
              pos += len;
            }
          }

          final txtValue = utf8.decode(txtData, allowMalformed: true);
          _logger.info('[DoH] TXT 记录解析成功: ${txtValue.length} 字符');
          return txtValue;
        }

        offset += rdlength;
      }

      _logger.warning('[DoH] 未找到 TXT 记录');
      return null;
    } catch (e, stackTrace) {
      _logger.error('[DoH] DNS 响应解析失败', e, stackTrace);
      return null;
    }
  }
}
