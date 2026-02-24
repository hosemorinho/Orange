// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../subscription_ui_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 订阅 UI State Provider

@ProviderFor(SubscriptionUIState)
const subscriptionUIStateProvider = SubscriptionUIStateProvider._();

/// 订阅 UI State Provider
final class SubscriptionUIStateProvider
    extends $NotifierProvider<SubscriptionUIState, UIState> {
  /// 订阅 UI State Provider
  const SubscriptionUIStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionUIStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionUIStateHash();

  @$internal
  @override
  SubscriptionUIState create() => SubscriptionUIState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UIState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UIState>(value),
    );
  }
}

String _$subscriptionUIStateHash() =>
    r'076e11234c5e4fa3ca0fc5e7fb82abbcc77b7f3e';

/// 订阅 UI State Provider

abstract class _$SubscriptionUIState extends $Notifier<UIState> {
  UIState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<UIState, UIState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UIState, UIState>,
              UIState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
