// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../leaf_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Singleton LeafController provider.

@ProviderFor(leafController)
const leafControllerProvider = LeafControllerProvider._();

/// Singleton LeafController provider.

final class LeafControllerProvider
    extends $FunctionalProvider<LeafController, LeafController, LeafController>
    with $Provider<LeafController> {
  /// Singleton LeafController provider.
  const LeafControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leafControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leafControllerHash();

  @$internal
  @override
  $ProviderElement<LeafController> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LeafController create(Ref ref) {
    return leafController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LeafController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LeafController>(value),
    );
  }
}

String _$leafControllerHash() => r'a742a4deae91753484af11cb25af552d8e5b1b85';

/// Whether leaf is currently running.

@ProviderFor(IsLeafRunning)
const isLeafRunningProvider = IsLeafRunningProvider._();

/// Whether leaf is currently running.
final class IsLeafRunningProvider
    extends $NotifierProvider<IsLeafRunning, bool> {
  /// Whether leaf is currently running.
  const IsLeafRunningProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isLeafRunningProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isLeafRunningHash();

  @$internal
  @override
  IsLeafRunning create() => IsLeafRunning();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isLeafRunningHash() => r'310f995224fff56a0d5d7a636d1f40aa9363a6c3';

/// Whether leaf is currently running.

abstract class _$IsLeafRunning extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Currently selected node tag.

@ProviderFor(SelectedNodeTag)
const selectedNodeTagProvider = SelectedNodeTagProvider._();

/// Currently selected node tag.
final class SelectedNodeTagProvider
    extends $NotifierProvider<SelectedNodeTag, String?> {
  /// Currently selected node tag.
  const SelectedNodeTagProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedNodeTagProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedNodeTagHash();

  @$internal
  @override
  SelectedNodeTag create() => SelectedNodeTag();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedNodeTagHash() => r'632d84ffc82406f6e206f95c22b77f8428aead9e';

/// Currently selected node tag.

abstract class _$SelectedNodeTag extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// List of proxy nodes from the current subscription.

@ProviderFor(LeafNodes)
const leafNodesProvider = LeafNodesProvider._();

/// List of proxy nodes from the current subscription.
final class LeafNodesProvider
    extends $NotifierProvider<LeafNodes, List<LeafNode>> {
  /// List of proxy nodes from the current subscription.
  const LeafNodesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leafNodesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leafNodesHash();

  @$internal
  @override
  LeafNodes create() => LeafNodes();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<LeafNode> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<LeafNode>>(value),
    );
  }
}

String _$leafNodesHash() => r'31db436a3fe7a81ac1b6b740771b9fc500a7be32';

/// List of proxy nodes from the current subscription.

abstract class _$LeafNodes extends $Notifier<List<LeafNode>> {
  List<LeafNode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<LeafNode>, List<LeafNode>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<LeafNode>, List<LeafNode>>,
              List<LeafNode>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Node delays from health checks. Tag → TCP latency ms (null = untested).

@ProviderFor(NodeDelays)
const nodeDelaysProvider = NodeDelaysProvider._();

/// Node delays from health checks. Tag → TCP latency ms (null = untested).
final class NodeDelaysProvider
    extends $NotifierProvider<NodeDelays, Map<String, int?>> {
  /// Node delays from health checks. Tag → TCP latency ms (null = untested).
  const NodeDelaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nodeDelaysProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nodeDelaysHash();

  @$internal
  @override
  NodeDelays create() => NodeDelays();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, int?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, int?>>(value),
    );
  }
}

String _$nodeDelaysHash() => r'b6689c3a293cab2a0d9c8465f02a9c4d4202c0f4';

/// Node delays from health checks. Tag → TCP latency ms (null = untested).

abstract class _$NodeDelays extends $Notifier<Map<String, int?>> {
  Map<String, int?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Map<String, int?>, Map<String, int?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, int?>, Map<String, int?>>,
              Map<String, int?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// The actual port the proxy is listening on (may differ from config after fallback).

@ProviderFor(ActivePort)
const activePortProvider = ActivePortProvider._();

/// The actual port the proxy is listening on (may differ from config after fallback).
final class ActivePortProvider extends $NotifierProvider<ActivePort, int?> {
  /// The actual port the proxy is listening on (may differ from config after fallback).
  const ActivePortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activePortProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activePortHash();

  @$internal
  @override
  ActivePort create() => ActivePort();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$activePortHash() => r'0882e8aade54dfecb8d705f3123db993309482f8';

/// The actual port the proxy is listening on (may differ from config after fallback).

abstract class _$ActivePort extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Traffic stats: periodic polling of leaf connection stats.

@ProviderFor(LeafTraffic)
const leafTrafficProvider = LeafTrafficProvider._();

/// Traffic stats: periodic polling of leaf connection stats.
final class LeafTrafficProvider
    extends $NotifierProvider<LeafTraffic, ({int bytesRecvd, int bytesSent})> {
  /// Traffic stats: periodic polling of leaf connection stats.
  const LeafTrafficProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leafTrafficProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leafTrafficHash();

  @$internal
  @override
  LeafTraffic create() => LeafTraffic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({int bytesRecvd, int bytesSent}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<({int bytesRecvd, int bytesSent})>(
        value,
      ),
    );
  }
}

String _$leafTrafficHash() => r'15eadad52f344f9a635a0266cb847f28415aff3e';

/// Traffic stats: periodic polling of leaf connection stats.

abstract class _$LeafTraffic
    extends $Notifier<({int bytesRecvd, int bytesSent})> {
  ({int bytesRecvd, int bytesSent}) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              ({int bytesRecvd, int bytesSent}),
              ({int bytesRecvd, int bytesSent})
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({int bytesRecvd, int bytesSent}),
                ({int bytesRecvd, int bytesSent})
              >,
              ({int bytesRecvd, int bytesSent}),
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
