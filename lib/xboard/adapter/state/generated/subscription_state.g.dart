// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../subscription_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 订阅状态管理
/// 获取订阅信息

@ProviderFor(getSubscription)
const getSubscriptionProvider = GetSubscriptionProvider._();

/// 订阅状态管理
/// 获取订阅信息

final class GetSubscriptionProvider
    extends
        $FunctionalProvider<
          AsyncValue<DomainSubscription>,
          DomainSubscription,
          FutureOr<DomainSubscription>
        >
    with
        $FutureModifier<DomainSubscription>,
        $FutureProvider<DomainSubscription> {
  /// 订阅状态管理
  /// 获取订阅信息
  const GetSubscriptionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSubscriptionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSubscriptionHash();

  @$internal
  @override
  $FutureProviderElement<DomainSubscription> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DomainSubscription> create(Ref ref) {
    return getSubscription(ref);
  }
}

String _$getSubscriptionHash() => r'a620294a1316fefabda4d14e6f943129b6de0447';

/// 获取订阅链接

@ProviderFor(getSubscribeUrl)
const getSubscribeUrlProvider = GetSubscribeUrlProvider._();

/// 获取订阅链接

final class GetSubscribeUrlProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// 获取订阅链接
  const GetSubscribeUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSubscribeUrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSubscribeUrlHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return getSubscribeUrl(ref);
  }
}

String _$getSubscribeUrlHash() => r'c4504f9f6e0fb0f1c3fbdf090f9dd2b8b95cb61e';
