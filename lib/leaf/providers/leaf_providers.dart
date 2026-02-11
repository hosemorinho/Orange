import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/leaf/leaf_controller.dart';
import 'package:fl_clash/leaf/models/leaf_node.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/leaf_providers.g.dart';

/// Singleton LeafController provider.
@riverpod
LeafController leafController(Ref ref) {
  return LeafController();
}

/// Whether leaf is currently running.
@riverpod
class IsLeafRunning extends _$IsLeafRunning {
  @override
  bool build() => false;
}

/// Currently selected node tag.
@riverpod
class SelectedNodeTag extends _$SelectedNodeTag {
  @override
  String? build() => null;
}

/// List of proxy nodes from the current subscription.
@riverpod
class LeafNodes extends _$LeafNodes {
  @override
  List<LeafNode> build() => [];
}

/// Node delays from health checks. Tag → TCP latency ms (null = untested).
@riverpod
class NodeDelays extends _$NodeDelays {
  @override
  Map<String, int?> build() => {};
}

/// Traffic stats: periodic polling of leaf connection stats.
@riverpod
class LeafTraffic extends _$LeafTraffic {
  @override
  ({int bytesSent, int bytesRecvd}) build() =>
      (bytesSent: 0, bytesRecvd: 0);
}

/// Helper to start leaf with the current profile's YAML.
///
/// Reads YAML from the current profile on disk. If [yamlContent] is provided,
/// uses it directly instead of reading from file.
Future<void> startLeaf(
  WidgetRef ref, {
  String? yamlContent,
  int? tunFd,
  int httpPort = 7890,
  int socksPort = 7891,
}) async {
  final controller = ref.read(leafControllerProvider);

  // Auto-resolve YAML from current profile if not provided
  if (yamlContent == null) {
    final profile = ref.read(currentProfileProvider);
    if (profile != null) {
      final profilePath =
          await appPath.getProfilePath(profile.id.toString());
      final file = File(profilePath);
      if (await file.exists()) {
        yamlContent = await file.readAsString();
      }
    }
  }

  if (yamlContent == null || yamlContent.isEmpty) {
    throw StateError('No subscription YAML available');
  }

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
