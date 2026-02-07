// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../payment_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 支付状态管理
/// 获取支付方式列表

@ProviderFor(getPaymentMethods)
const getPaymentMethodsProvider = GetPaymentMethodsProvider._();

/// 支付状态管理
/// 获取支付方式列表

final class GetPaymentMethodsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DomainPaymentMethod>>,
          List<DomainPaymentMethod>,
          FutureOr<List<DomainPaymentMethod>>
        >
    with
        $FutureModifier<List<DomainPaymentMethod>>,
        $FutureProvider<List<DomainPaymentMethod>> {
  /// 支付状态管理
  /// 获取支付方式列表
  const GetPaymentMethodsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPaymentMethodsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPaymentMethodsHash();

  @$internal
  @override
  $FutureProviderElement<List<DomainPaymentMethod>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DomainPaymentMethod>> create(Ref ref) {
    return getPaymentMethods(ref);
  }
}

String _$getPaymentMethodsHash() => r'7be1cd506490d5ca31a15a18d20a1401c11d1cf9';
