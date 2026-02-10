import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/leaf/leaf_controller.dart';
import 'package:fl_clash/leaf/models/leaf_node.dart';
import 'package:fl_clash/providers/database.dart';
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

/// Helper to start leaf with the current profile's YAML.
///
/// Reads YAML from the current profile on disk. If [yamlContent] is provided,
/// uses it directly instead of reading from file.
Future<void> startLeaf(
  dynamic ref, {
  String? yamlContent,
  int? tunFd,
  int httpPort = 7890,
  int socksPort = 7891,
}) async {
  // Resolve ref.read regardless of WidgetRef or Ref
  T read<T>(ProviderListenable<T> provider) {
    if (ref is WidgetRef) return (ref as WidgetRef).read(provider);
    if (ref is Ref) return (ref as Ref).read(provider);
    throw ArgumentError('ref must be WidgetRef or Ref');
  }

  final controller = read(leafControllerProvider);

  // Auto-resolve YAML from current profile if not provided
  if (yamlContent == null) {
    final profile = read(currentProfileProvider);
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
  read(isLeafRunningProvider.notifier).state = true;
  read(leafNodesProvider.notifier).state = controller.nodes;
  read(selectedNodeTagProvider.notifier).state =
      controller.getSelectedNode();
}

/// Helper to stop leaf and update providers.
Future<void> stopLeaf(dynamic ref) async {
  T read<T>(ProviderListenable<T> provider) {
    if (ref is WidgetRef) return (ref as WidgetRef).read(provider);
    if (ref is Ref) return (ref as Ref).read(provider);
    throw ArgumentError('ref must be WidgetRef or Ref');
  }

  final controller = read(leafControllerProvider);
  await controller.stop();
  read(isLeafRunningProvider.notifier).state = false;
}

/// Helper to select a node and update providers.
Future<void> selectLeafNode(dynamic ref, String nodeTag) async {
  T read<T>(ProviderListenable<T> provider) {
    if (ref is WidgetRef) return (ref as WidgetRef).read(provider);
    if (ref is Ref) return (ref as Ref).read(provider);
    throw ArgumentError('ref must be WidgetRef or Ref');
  }

  final controller = read(leafControllerProvider);
  await controller.selectNode(nodeTag);
  read(selectedNodeTagProvider.notifier).state = nodeTag;
}

/// Helper to run health checks on all nodes.
Future<void> runHealthChecks(dynamic ref) async {
  T read<T>(ProviderListenable<T> provider) {
    if (ref is WidgetRef) return (ref as WidgetRef).read(provider);
    if (ref is Ref) return (ref as Ref).read(provider);
    throw ArgumentError('ref must be WidgetRef or Ref');
  }

  final controller = read(leafControllerProvider);
  final results = await controller.healthCheckAll();
  read(nodeDelaysProvider.notifier).state = results;
}
