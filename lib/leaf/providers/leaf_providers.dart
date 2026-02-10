import 'dart:async';

import 'package:fl_clash/leaf/leaf_controller.dart';
import 'package:fl_clash/leaf/models/leaf_node.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Singleton LeafController provider.
final leafControllerProvider = Provider<LeafController>((ref) {
  return LeafController();
});

/// Whether leaf is currently running.
final isLeafRunningProvider = StateProvider<bool>((ref) {
  return ref.watch(leafControllerProvider).isRunning;
});

/// Currently selected node tag.
final selectedNodeTagProvider = StateProvider<String?>((ref) {
  return ref.watch(leafControllerProvider).getSelectedNode();
});

/// List of proxy nodes from the current subscription.
final leafNodesProvider = StateProvider<List<LeafNode>>((ref) {
  return ref.watch(leafControllerProvider).nodes;
});

/// Node delays from health checks. Tag → TCP latency ms (null = untested).
final nodeDelaysProvider = StateProvider<Map<String, int?>>((ref) {
  return {};
});

/// Traffic stats: periodic polling of leaf connection stats.
final leafTrafficProvider =
    StateProvider<({int bytesSent, int bytesRecvd})>((ref) {
  return (bytesSent: 0, bytesRecvd: 0);
});

/// Helper to start leaf and update providers.
Future<void> startLeaf(
  WidgetRef ref, {
  required String yamlContent,
  int? tunFd,
  int httpPort = 7890,
  int socksPort = 7891,
}) async {
  final controller = ref.read(leafControllerProvider);
  await controller.startWithClashYaml(
    yamlContent,
    tunFd: tunFd,
    httpPort: httpPort,
    socksPort: socksPort,
  );
  ref.read(isLeafRunningProvider.notifier).state = true;
  ref.read(leafNodesProvider.notifier).state = controller.nodes;
  ref.read(selectedNodeTagProvider.notifier).state =
      controller.getSelectedNode();
}

/// Helper to stop leaf and update providers.
Future<void> stopLeaf(WidgetRef ref) async {
  final controller = ref.read(leafControllerProvider);
  await controller.stop();
  ref.read(isLeafRunningProvider.notifier).state = false;
}

/// Helper to select a node and update providers.
Future<void> selectLeafNode(WidgetRef ref, String nodeTag) async {
  final controller = ref.read(leafControllerProvider);
  await controller.selectNode(nodeTag);
  ref.read(selectedNodeTagProvider.notifier).state = nodeTag;
}

/// Helper to run health checks on all nodes.
Future<void> runHealthChecks(WidgetRef ref) async {
  final controller = ref.read(leafControllerProvider);
  final results = await controller.healthCheckAll();
  ref.read(nodeDelaysProvider.notifier).state = results;
}
