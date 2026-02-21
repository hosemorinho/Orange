/// Domain racing service.
///
/// Runs concurrent connectivity tests across candidate domains and selects
/// the first successful one.
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/infrastructure/http/user_agent_config.dart';
import 'package:flutter/services.dart';

final _logger = FileLogger('domain_racing_service.dart');

class DomainRacingService {
  static const Duration _connectionTimeout = Duration(seconds: 5);
  static const Duration _responseTimeout = Duration(seconds: 8);

  static SecurityContext? _securityContext;
  static String? _configuredCertPath;

  /// Set custom CA certificate asset path used for IP:port direct TLS testing.
  static void setCertificatePath(String path) {
    _configuredCertPath = path;
    _securityContext = null;
  }

  static Future<SecurityContext> _getSecurityContext() async {
    if (_securityContext != null) {
      return _securityContext!;
    }

    try {
      if (_configuredCertPath == null || _configuredCertPath!.isEmpty) {
        _logger.info(
          '[DomainRacing] no custom cert path configured, use default context',
        );
        return SecurityContext.defaultContext;
      }

      final ByteData certData = await rootBundle
          .load(_configuredCertPath!)
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () => throw TimeoutException('certificate load timeout'),
          );
      final Uint8List certBytes = certData.buffer.asUint8List();

      final context = SecurityContext();
      context.setTrustedCertificatesBytes(certBytes);
      _securityContext = context;
      return _securityContext!;
    } catch (e) {
      _logger.warning(
        '[DomainRacing] failed to load custom cert, fallback to default: $e',
      );
      _securityContext = SecurityContext.defaultContext;
      return _securityContext!;
    }
  }

  /// [domains] Domains to test.
  /// [testPath] Optional custom health-check path.
  /// [forceHttpsResult] Whether to force https:// in returned winner domain.
  static Future<DomainRacingResult?> raceSelectFastestDomain(
    List<String> domains, {
    String testPath = '',
    bool forceHttpsResult = false,
  }) async {
    if (domains.isEmpty) return null;

    final normalizedDomains = domains
        .map((d) => d.trim())
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();
    if (normalizedDomains.isEmpty) return null;

    _logger.info(
      '[DomainRacing] start direct racing for ${normalizedDomains.length} domains',
    );

    final futures = <Future<DomainTestResult>>[];
    final cancelTokens = <CancelToken>[];

    for (var i = 0; i < normalizedDomains.length; i++) {
      final token = CancelToken();
      cancelTokens.add(token);
      futures.add(_testSingleDomain(normalizedDomains[i], testPath, token, i));
    }

    try {
      final completer = Completer<DomainRacingResult?>();
      var completedCount = 0;
      final errors = <String>[];

      for (var i = 0; i < futures.length; i++) {
        futures[i]
            .then((result) {
              if (!completer.isCompleted && result.success) {
                _logger.info(
                  '[DomainRacing] winner #$i (${result.domain}), ${result.responseTime}ms',
                );
                completer.complete(
                  DomainRacingResult(
                    domain: result.domain,
                    useProxy: false,
                    proxyUrl: null,
                    responseTime: result.responseTime,
                  ),
                );

                for (var j = 0; j < cancelTokens.length; j++) {
                  if (j != i) {
                    cancelTokens[j].cancel();
                  }
                }
                return;
              }

              completedCount++;
              if (result.error != null) {
                errors.add('domain#$i (${result.domain}): ${result.error}');
              }

              if (completedCount == futures.length && !completer.isCompleted) {
                _logger.warning(
                  '[DomainRacing] all tests failed: ${errors.join('; ')}',
                );
                completer.complete(null);
              }
            })
            .catchError((e) {
              completedCount++;
              errors.add('domain#$i exception: $e');
              if (completedCount == futures.length && !completer.isCompleted) {
                _logger.warning(
                  '[DomainRacing] all tests failed: ${errors.join('; ')}',
                );
                completer.complete(null);
              }
            });
      }

      final winner = await completer.future;
      if (winner != null && forceHttpsResult) {
        return DomainRacingResult(
          domain: _convertToHttpsUrl(winner.domain),
          useProxy: false,
          proxyUrl: null,
          responseTime: winner.responseTime,
        );
      }
      return winner;
    } catch (e) {
      _logger.error('[DomainRacing] race failed', e);
      return null;
    }
  }

  static Future<DomainTestResult> _testSingleDomain(
    String domain,
    String testPath,
    CancelToken cancelToken,
    int index,
  ) async {
    final stopwatch = Stopwatch()..start();
    HttpClient? client;

    try {
      final testUrl = _buildTestUrl(domain, testPath);
      final withoutProtocol = domain.replaceFirst(RegExp(r'^https?://'), '');
      final isIpWithPort = _isIpWithPort(withoutProtocol);

      if (isIpWithPort) {
        final securityContext = await _getSecurityContext();
        client = HttpClient(context: securityContext);
      } else {
        client = HttpClient();
      }

      client.findProxy = (uri) => 'DIRECT';

      cancelToken.onCancel(() {
        try {
          client?.close(force: true);
        } catch (_) {}
      });

      if (cancelToken.isCancelled) {
        return DomainTestResult.failure(
          domain,
          'cancelled',
          stopwatch.elapsedMilliseconds,
        );
      }

      if (isIpWithPort) {
        client.badCertificateCallback = (_, __, ___) => true;
      }

      client.connectionTimeout = _connectionTimeout;

      final request = await client.getUrl(Uri.parse(testUrl));
      if (_isIpWithPort(withoutProtocol)) {
        request.headers.set(
          HttpHeaders.userAgentHeader,
          UserAgentConfig.get(UserAgentScenario.api),
        );
      } else {
        request.headers.set(
          HttpHeaders.userAgentHeader,
          UserAgentConfig.get(UserAgentScenario.domainRacingTest),
        );
      }
      request.headers.set(HttpHeaders.acceptHeader, '*/*');

      final response = await request.close().timeout(_responseTimeout);
      stopwatch.stop();

      if (cancelToken.isCancelled) {
        return DomainTestResult.failure(
          domain,
          'cancelled',
          stopwatch.elapsedMilliseconds,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 400) {
        return DomainTestResult.success(domain, stopwatch.elapsedMilliseconds);
      }

      return DomainTestResult.failure(
        domain,
        'HTTP ${response.statusCode}',
        stopwatch.elapsedMilliseconds,
      );
    } on TimeoutException {
      stopwatch.stop();
      return DomainTestResult.failure(
        domain,
        'timeout',
        stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      if (cancelToken.isCancelled) {
        return DomainTestResult.failure(
          domain,
          'cancelled',
          stopwatch.elapsedMilliseconds,
        );
      }
      return DomainTestResult.failure(
        domain,
        'connect failed: $e',
        stopwatch.elapsedMilliseconds,
      );
    } finally {
      try {
        client?.close(force: true);
      } catch (_) {}
    }
  }

  static String _buildTestUrl(String domain, String testPath) {
    String baseUrl;

    if (domain.startsWith('http')) {
      final withoutProtocol = domain.replaceFirst(RegExp(r'^https?://'), '');
      baseUrl = 'https://$withoutProtocol';
    } else {
      baseUrl = 'https://$domain';
    }

    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    if (testPath.isEmpty) {
      return '$baseUrl/api/v1/guest/comm/config';
    }

    final path = testPath.startsWith('/') ? testPath : '/$testPath';
    return '$baseUrl$path';
  }

  static bool _isIpWithPort(String domain) {
    final ipPortPattern = RegExp(
      r'^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|'
      r'\[?[0-9a-fA-F:]+\]?)'
      r':\d+$',
    );
    return ipPortPattern.hasMatch(domain);
  }

  static String _convertToHttpsUrl(String domain) {
    if (domain.startsWith('https://')) return domain;
    if (domain.startsWith('http://')) return 'https://${domain.substring(7)}';
    return 'https://$domain';
  }

  /// Test all domains and return sorted results (success first, then latency).
  static Future<List<DomainTestResult>> testAllDomains(
    List<String> domains, {
    String testPath = '',
  }) async {
    if (domains.isEmpty) return [];

    final futures = domains.asMap().entries.map((entry) {
      return _testSingleDomain(entry.value, testPath, CancelToken(), entry.key);
    }).toList();

    final results = await Future.wait(futures);
    results.sort((a, b) {
      if (a.success && !b.success) return -1;
      if (!a.success && b.success) return 1;
      if (a.success && b.success)
        return a.responseTime.compareTo(b.responseTime);
      return 0;
    });

    return results;
  }
}

class DomainRacingResult {
  final String domain;
  final bool useProxy;
  final String? proxyUrl;
  final int responseTime;

  const DomainRacingResult({
    required this.domain,
    required this.useProxy,
    this.proxyUrl,
    required this.responseTime,
  });

  @override
  String toString() {
    final mode = useProxy ? 'proxy: $proxyUrl' : 'direct';
    return 'DomainRacingResult(domain: $domain, mode: $mode, responseTime: ${responseTime}ms)';
  }
}

class DomainTestResult {
  final String domain;
  final bool success;
  final int responseTime;
  final String? error;
  final bool useProxy;
  final String? proxyUrl;

  const DomainTestResult._({
    required this.domain,
    required this.success,
    required this.responseTime,
    this.error,
    this.useProxy = false,
    this.proxyUrl,
  });

  factory DomainTestResult.success(
    String domain,
    int responseTime, {
    bool useProxy = false,
    String? proxyUrl,
  }) {
    return DomainTestResult._(
      domain: domain,
      success: true,
      responseTime: responseTime,
      useProxy: useProxy,
      proxyUrl: proxyUrl,
    );
  }

  factory DomainTestResult.failure(
    String domain,
    String error,
    int responseTime, {
    bool useProxy = false,
    String? proxyUrl,
  }) {
    return DomainTestResult._(
      domain: domain,
      success: false,
      responseTime: responseTime,
      error: error,
      useProxy: useProxy,
      proxyUrl: proxyUrl,
    );
  }

  @override
  String toString() {
    final mode = useProxy ? 'proxy: $proxyUrl' : 'direct';
    if (success) {
      return 'DomainTestResult(domain: $domain, mode: $mode, responseTime: ${responseTime}ms)';
    }
    return 'DomainTestResult(domain: $domain, mode: $mode, error: $error, responseTime: ${responseTime}ms)';
  }
}

class CancelToken {
  bool _isCancelled = false;
  final List<void Function()> _callbacks = [];

  bool get isCancelled => _isCancelled;

  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    for (final callback in _callbacks) {
      callback();
    }
    _callbacks.clear();
  }

  void onCancel(void Function() callback) {
    if (_isCancelled) {
      callback();
      return;
    }
    _callbacks.add(callback);
  }
}
