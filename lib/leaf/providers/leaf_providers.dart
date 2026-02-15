import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/leaf/leaf_controller.dart';
import 'package:fl_clash/leaf/models/leaf_node.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/xboard/core/logger/file_logger.dart';
import 'package:fl_clash/xboard/infrastructure/crypto/profile_cipher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/leaf_providers.g.dart';

/// Singleton LeafController provider.
@Riverpod(keepAlive: true)
LeafController leafController(Ref ref) {
  final controller = LeafController();
  // Enable dual-process mode on Android
  // In this mode, leaf runs in :core process instead of UI process
  if (Platform.isAndroid) {
    controller.useDualProcessMode = true;
  }
  return controller;
}

/// Whether leaf is currently running.
@Riverpod(keepAlive: true)
class IsLeafRunning extends _$IsLeafRunning {
  @override
  bool build() => false;
}

/// Currently selected node tag.
@Riverpod(keepAlive: true)
class SelectedNodeTag extends _$SelectedNodeTag {
  @override
  String? build() => null;
}

/// List of proxy nodes from the current subscription.
@Riverpod(keepAlive: true)
class LeafNodes extends _$LeafNodes {
  @override
  List<LeafNode> build() => [];
}

/// Node delays from health checks. Tag → TCP latency ms (null = untested).
@Riverpod(keepAlive: true)
class NodeDelays extends _$NodeDelays {
  @override
  Map<String, int?> build() => {};
}

/// The actual port the proxy is listening on (may differ from config after fallback).
@Riverpod(keepAlive: true)
class ActivePort extends _$ActivePort {
  @override
  int? build() => null;
}

/// Traffic stats: periodic polling of leaf connection stats.
@Riverpod(keepAlive: true)
class LeafTraffic extends _$LeafTraffic {
  @override
  ({int bytesSent, int bytesRecvd}) build() => (bytesSent: 0, bytesRecvd: 0);
}

/// Helper to start leaf with the current profile's YAML.
///
/// Reads YAML from the current profile on disk. If [yamlContent] is provided,
/// uses it directly instead of reading from file.
Future<void> startLeaf(
  WidgetRef ref, {
  String? yamlContent,
  int? tunFd,
  int mixedPort = 7890,
}) async {
  final controller = ref.read(leafControllerProvider);

  // Auto-resolve YAML from current profile if not provided
  if (yamlContent == null) {
    final profile = ref.read(currentProfileProvider);
    if (profile != null) {
      final profilePath = await appPath.getProfilePath(profile.id.toString());
      final file = File(profilePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        if (ProfileCipher.isEncryptedFormat(bytes)) {
          final token = ProfileCipher.extractToken(profile.url);
          if (token != null && token.isNotEmpty) {
            yamlContent = utf8.decode(ProfileCipher.decrypt(bytes, token));
          }
        } else {
          yamlContent = utf8.decode(bytes);
        }
      }
    }
  }

  if (yamlContent == null || yamlContent.isEmpty) {
    throw StateError('No subscription YAML available');
  }

  await controller.startWithClashYaml(
    yamlContent,
    tunFd: tunFd,
    mixedPort: mixedPort,
  );
  ref.read(isLeafRunningProvider.notifier).state = true;
  ref.read(leafNodesProvider.notifier).state = controller.nodes;
  ref.read(selectedNodeTagProvider.notifier).state = controller
      .getSelectedNode();
}

/// Helper to stop leaf and update providers.
Future<void> stopLeaf(WidgetRef ref) async {
  final controller = ref.read(leafControllerProvider);
  await controller.stop();
  ref.read(isLeafRunningProvider.notifier).state = false;
}

/// Helper to select a node and update providers.
///
/// If core is not running, only updates UI state (pre-selection).
/// The selection will be applied when core starts.
Future<void> selectLeafNode(WidgetRef ref, String nodeTag) async {
  final controller = ref.read(leafControllerProvider);
  final wasRunning = controller.isRunning;
  await controller.selectNode(nodeTag);
  // Always update UI state, even if core wasn't running
  ref.read(selectedNodeTagProvider.notifier).state = nodeTag;

  // Persist user-selected leaf node so reconnects can restore it instead of
  // falling back to the first actor in the select outbound.
  final profile = ref.read(currentProfileProvider);
  if (profile != null) {
    final key = GroupName.GLOBAL.name;
    if (profile.selectedMap[key] != nodeTag) {
      final selectedMap = Map<String, String>.from(profile.selectedMap)
        ..[key] = nodeTag;
      ref
          .read(profilesProvider.notifier)
          .put(profile.copyWith(selectedMap: selectedMap));
    }
  }

  if (!wasRunning) {
    FileLogger('leaf_providers.dart').info(
      'selectLeafNode: core not running, pre-selected $nodeTag (will apply on start)',
    );
  }
}

/// Helper to run health checks (TCP ping) on all nodes.
Future<void> runHealthChecks(WidgetRef ref) async {
  final controller = ref.read(leafControllerProvider);
  final nodeDelaysNotifier = ref.read(nodeDelaysProvider.notifier);
  final fallbackNodes = List<LeafNode>.from(ref.read(leafNodesProvider));
  final results = <String, int?>{};
  if (controller.nodes.isNotEmpty) {
    results.addAll(await controller.tcpPingAll());
  } else {
    for (final node in fallbackNodes) {
      results[node.tag] = await controller.tcpPing(node);
    }
  }
  nodeDelaysNotifier.state = results;
}
