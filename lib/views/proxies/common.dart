import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';

const _googleHeadTestUrl = 'https://www.google.com/generate_204';
const _probeTimeout = Duration(seconds: 8);

Future<void> _latencyQueue = Future.value();

Future<void> _enqueueLatencyTask(Future<void> Function() task) {
  final completer = Completer<void>();
  _latencyQueue = _latencyQueue
      .catchError((_) {})
      .then((_) async {
        try {
          await task();
          completer.complete();
        } catch (e) {
          commonPrint.log('latency task failed: $e', logLevel: LogLevel.warning);
          if (!completer.isCompleted) completer.complete();
        }
      });
  return completer.future;
}

Future<int> _httpHeadLatencyViaLocalProxy() async {
  final port =
      appController.activePort ?? appController.config.patchClashConfig.mixedPort;
  HttpClient? client;
  final stopwatch = Stopwatch()..start();
  try {
    client = HttpClient()..connectionTimeout = _probeTimeout;
    client.badCertificateCallback = (_, _, _) => true;
    client.findProxy = (_) => 'PROXY 127.0.0.1:$port';
    client.userAgent = appController.ua;

    final request = await client
        .headUrl(Uri.parse(_googleHeadTestUrl))
        .timeout(_probeTimeout);
    request.followRedirects = true;
    request.maxRedirects = 3;

    final response = await request.close().timeout(_probeTimeout);
    await response.drain<void>();
    stopwatch.stop();

    // 2xx/3xx/4xx still means the node path is reachable.
    if (response.statusCode >= 200 && response.statusCode < 500) {
      return stopwatch.elapsedMilliseconds;
    }
    return -1;
  } catch (_) {
    return -1;
  } finally {
    client?.close(force: true);
  }
}

Future<int> _probeNodeLatency(String nodeTag) async {
  try {
    if (!appController.isStart) return -1;
    await appController.selectNodeForLatencyTest(nodeTag);
    return await _httpHeadLatencyViaLocalProxy();
  } catch (e) {
    commonPrint.log(
      'probe node failed ($nodeTag): $e',
      logLevel: LogLevel.warning,
    );
    return -1;
  }
}

Future<void> _tryRestoreNode(String? nodeTag, [String? currentNode]) async {
  if (nodeTag == null || nodeTag.isEmpty) return;
  if (currentNode != null && currentNode == nodeTag) return;
  try {
    await appController.selectNodeForLatencyTest(nodeTag);
  } catch (e) {
    commonPrint.log(
      'restore node failed ($nodeTag): $e',
      logLevel: LogLevel.warning,
    );
  }
}

double get listHeaderHeight {
  final measure = globalState.measure;
  return 20 + measure.titleMediumHeight + 4 + measure.bodyMediumHeight + 2;
}

double getItemHeight(ProxyCardType proxyCardType) {
  final measure = globalState.measure;
  final baseHeight =
      16 + measure.bodyMediumHeight * 2 + measure.bodySmallHeight + 8 + 4;
  return switch (proxyCardType) {
    ProxyCardType.expand => baseHeight + measure.labelSmallHeight + 6,
    ProxyCardType.shrink => baseHeight,
    ProxyCardType.min => baseHeight - measure.bodyMediumHeight,
  };
}

Future<void> proxyDelayTest(Proxy proxy, [String? testUrl]) async {
  await _enqueueLatencyTask(() async {
    final groups = appController.groups;
    final selectedMap = appController.currentProfile?.selectedMap ?? {};
    final state = computeRealSelectedProxyState(
      proxy.name,
      groups: groups,
      selectedMap: selectedMap,
    );
    final currentTestUrl = state.testUrl.takeFirstValid([
      appController.getRealTestUrl(testUrl),
    ]);
    final nodeTag = state.proxyName;
    if (nodeTag.isEmpty) {
      return;
    }

    final originalNode = appController.getSelectedNodeTag();
    appController.setDelay(Delay(url: currentTestUrl, name: nodeTag, value: 0));

    int delay = -1;
    try {
      delay = await _probeNodeLatency(nodeTag);
    } finally {
      await _tryRestoreNode(originalNode, nodeTag);
    }
    appController.setDelay(
      Delay(url: currentTestUrl, name: nodeTag, value: delay),
    );
  });
}

Future<void> delayTest(List<Proxy> proxies, [String? testUrl]) async {
  await _enqueueLatencyTask(() async {
    final proxyNames = proxies.map((proxy) => proxy.name).toSet().toList();
    final groups = appController.groups;
    final selectedMap = appController.currentProfile?.selectedMap ?? {};

    final targets = <({String nodeTag, String delayKeyUrl})>[];
    for (final proxyName in proxyNames) {
      final state = computeRealSelectedProxyState(
        proxyName,
        groups: groups,
        selectedMap: selectedMap,
      );
      final delayKeyUrl = state.testUrl.takeFirstValid([
        appController.getRealTestUrl(testUrl),
      ]);
      final nodeTag = state.proxyName;
      if (nodeTag.isEmpty) continue;
      targets.add((nodeTag: nodeTag, delayKeyUrl: delayKeyUrl));
      appController.setDelay(Delay(url: delayKeyUrl, name: nodeTag, value: 0));
    }

    if (targets.isEmpty) {
      return;
    }

    final originalNode = appController.getSelectedNodeTag();
    try {
      for (final target in targets) {
        final delay = await _probeNodeLatency(target.nodeTag);
        appController.setDelay(
          Delay(url: target.delayKeyUrl, name: target.nodeTag, value: delay),
        );
        // Re-sort progressively so each completed node can update list order.
        appController.addSortNum();
      }
    } finally {
      final currentNode = appController.getSelectedNodeTag();
      await _tryRestoreNode(originalNode, currentNode);
    }
  });
}

double getScrollToSelectedOffset({
  required String groupName,
  required List<Proxy> proxies,
}) {
  final columns = appController.getProxiesColumns();
  final proxyCardType = appController.config.proxiesStyleProps.cardType;
  final selectedProxyName = appController.getSelectedProxyName(groupName);
  final findSelectedIndex = proxies.indexWhere(
    (proxy) => proxy.name == selectedProxyName,
  );
  final selectedIndex = findSelectedIndex != -1 ? findSelectedIndex : 0;
  final rows = (selectedIndex / columns).floor();
  return rows * getItemHeight(proxyCardType) + (rows - 1) * 8;
}
