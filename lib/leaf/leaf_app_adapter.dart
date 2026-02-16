import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/leaf/leaf_controller.dart';
import 'package:fl_clash/leaf/models/leaf_node.dart';

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

  LeafAppAdapter(this.controller);

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

  /// Probe delay on a specific node by HTTP HEAD through local proxy.
  Future<int?> testDelay(String nodeTag, {int timeoutMs = 3000}) async {
    return controller.probeNodeLatencyByHttpHead(
      nodeTag,
      proxyPort: controller.mixedPort,
      timeoutMs: timeoutMs,
    );
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
    return appPath.homeDirPath;
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

  const LeafNodeGroup({required this.name, required this.nodes, this.selected});
}
