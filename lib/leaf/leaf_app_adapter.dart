import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/leaf/leaf_controller.dart';
import 'package:fl_clash/leaf/models/leaf_node.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Adapter that bridges [LeafController] into the existing FlClash
/// state management system.
///
/// This allows existing UI widgets (start_button, connect_button, etc.)
/// to work with leaf without modification, by keeping the same providers
/// and controller method signatures.
class LeafAppAdapter {
  final LeafController controller;

  /// Timer for periodic traffic stats polling.
  Timer? _trafficTimer;

  /// Callback to update the global state's runtime (for isStartProvider).
  Ref? _ref;

  LeafAppAdapter(this.controller);

  /// Attach to a Riverpod ref for state updates.
  void attach(Ref ref) {
    _ref = ref;
  }

  /// Initialize leaf with the app's data directory.
  Future<void> init() async {
    final homeDir = await _getHomeDir();
    await controller.init(homeDir);
  }

  /// Start/stop proxy — drop-in replacement for appController.updateStatus().
  ///
  /// [isStart] true to start, false to stop.
  /// [yamlContent] the Clash YAML subscription content (required when starting).
  /// [tunFd] Android VPN TUN file descriptor.
  Future<void> updateStatus(
    bool isStart, {
    String? yamlContent,
    int? tunFd,
    int mixedPort = 7890,
  }) async {
    if (isStart) {
      if (yamlContent == null) {
        throw ArgumentError('yamlContent required when starting');
      }
      await controller.startWithClashYaml(
        yamlContent,
        tunFd: tunFd,
        mixedPort: mixedPort,
      );
      _startTrafficPolling();
    } else {
      _stopTrafficPolling();
      await controller.stop();
    }
  }

  /// Select a proxy node — replaces appController.changeProxy().
  Future<void> changeProxy(String nodeTag) async {
    await controller.selectNode(nodeTag);
  }

  /// Get leaf nodes as a simplified "group" for the UI.
  /// Returns a single group named "proxy" with all nodes.
  LeafNodeGroup getNodeGroup() {
    return LeafNodeGroup(
      name: 'proxy',
      nodes: controller.nodes,
      selected: controller.getSelectedNode(),
    );
  }

  /// Run TCP ping on a specific node.
  Future<int?> testDelay(String nodeTag, {int timeoutMs = 3000}) async {
    final node = controller.nodes.where((n) => n.tag == nodeTag).firstOrNull;
    if (node == null) return null;
    return controller.tcpPing(node, timeoutMs: timeoutMs);
  }

  /// Get current traffic totals.
  ({int upload, int download}) getTraffic() {
    final totals = controller.getTrafficTotals();
    return (upload: totals.bytesSent, download: totals.bytesRecvd);
  }

  bool get isRunning => controller.isRunning;

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  void _startTrafficPolling() {
    _trafficTimer?.cancel();
    _trafficTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Traffic stats can be read by providers polling this adapter
    });
  }

  void _stopTrafficPolling() {
    _trafficTimer?.cancel();
    _trafficTimer = null;
  }

  Future<String> _getHomeDir() async {
    if (Platform.isAndroid) {
      // Android: use app's files directory
      return appPath.homePath;
    }
    // Desktop: use ~/.config/orange/leaf
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    final dir = '$home${Platform.pathSeparator}.config${Platform.pathSeparator}orange${Platform.pathSeparator}leaf';
    await Directory(dir).create(recursive: true);
    return dir;
  }

  void dispose() {
    _stopTrafficPolling();
  }
}

/// Simplified node group for leaf UI.
class LeafNodeGroup {
  final String name;
  final List<LeafNode> nodes;
  final String? selected;

  const LeafNodeGroup({
    required this.name,
    required this.nodes,
    this.selected,
  });
}
