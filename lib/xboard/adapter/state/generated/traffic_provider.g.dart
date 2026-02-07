// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../traffic_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Traffic logs provider

@ProviderFor(TrafficLogs)
const trafficLogsProvider = TrafficLogsProvider._();

/// Traffic logs provider
final class TrafficLogsProvider
    extends $NotifierProvider<TrafficLogs, TrafficLogsState> {
  /// Traffic logs provider
  const TrafficLogsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trafficLogsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trafficLogsHash();

  @$internal
  @override
  TrafficLogs create() => TrafficLogs();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrafficLogsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrafficLogsState>(value),
    );
  }
}

String _$trafficLogsHash() => r'b7b0caee18a6bf8307ae0c061dd99772877cdd54';

/// Traffic logs provider

abstract class _$TrafficLogs extends $Notifier<TrafficLogsState> {
  TrafficLogsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TrafficLogsState, TrafficLogsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TrafficLogsState, TrafficLogsState>,
              TrafficLogsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
