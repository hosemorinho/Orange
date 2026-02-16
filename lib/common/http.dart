import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';

class FlClashHttpOverrides extends HttpOverrides {
  /// Hosts that should always bypass the proxy (e.g. panel API domains).
  /// Updated at runtime when domain racing completes or the active domain
  /// changes via [DomainPool].
  static final Set<String> _bypassHosts = {};

  /// Register one or more hosts that must bypass the proxy.
  /// Accepts full URLs (the host is extracted) or bare hostnames.
  static void addBypassHosts(Iterable<String> hostsOrUrls) {
    for (final value in hostsOrUrls) {
      final host = _extractHost(value);
      if (host.isNotEmpty) _bypassHosts.add(host);
    }
  }

  /// Remove all previously registered bypass hosts.
  static void clearBypassHosts() => _bypassHosts.clear();

  static String _extractHost(String value) {
    final uri = Uri.tryParse(value);
    if (uri != null && uri.host.isNotEmpty) return uri.host;
    return value; // treat as bare hostname
  }

  static String handleFindProxy(Uri url) {
    if ([localhost].contains(url.host)) {
      return 'DIRECT';
    }
    // Panel API domains always bypass the proxy so the app can
    // fetch configs / renew subscriptions even when the proxy is down.
    if (_bypassHosts.contains(url.host)) {
      return 'DIRECT';
    }
    try {
      if (!appController.isAttach) return 'DIRECT';
      final port = appController.activePort ?? appController.config.patchClashConfig.mixedPort;
      final isStart = appController.isStart;
      commonPrint.log('find $url proxy:$isStart');
      if (!isStart) return 'DIRECT';
      return 'PROXY localhost:$port';
    } catch (_) {
      return 'DIRECT';
    }
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (_, _, _) => true;
    client.findProxy = handleFindProxy;
    return client;
  }
}
