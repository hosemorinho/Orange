// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../order_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 订单状态管理
/// 获取订单列表

@ProviderFor(getOrders)
const getOrdersProvider = GetOrdersProvider._();

/// 订单状态管理
/// 获取订单列表

final class GetOrdersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DomainOrder>>,
          List<DomainOrder>,
          FutureOr<List<DomainOrder>>
        >
    with
        $FutureModifier<List<DomainOrder>>,
        $FutureProvider<List<DomainOrder>> {
  /// 订单状态管理
  /// 获取订单列表
  const GetOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getOrdersHash();

  @$internal
  @override
  $FutureProviderElement<List<DomainOrder>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DomainOrder>> create(Ref ref) {
    return getOrders(ref);
  }
}

String _$getOrdersHash() => r'935f807e5afa90507dabfaad70d703255e1821c7';

/// 获取单个订单

@ProviderFor(getOrder)
const getOrderProvider = GetOrderFamily._();

/// 获取单个订单

final class GetOrderProvider
    extends
        $FunctionalProvider<
          AsyncValue<DomainOrder?>,
          DomainOrder?,
          FutureOr<DomainOrder?>
        >
    with $FutureModifier<DomainOrder?>, $FutureProvider<DomainOrder?> {
  /// 获取单个订单
  const GetOrderProvider._({
    required GetOrderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'getOrderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getOrderHash();

  @override
  String toString() {
    return r'getOrderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DomainOrder?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DomainOrder?> create(Ref ref) {
    final argument = this.argument as String;
    return getOrder(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetOrderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getOrderHash() => r'4d556a21cb2ffe9cf790b0f22d857adb8698b171';

/// 获取单个订单

final class GetOrderFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DomainOrder?>, String> {
  const GetOrderFamily._()
    : super(
        retry: null,
        name: r'getOrderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 获取单个订单

  GetOrderProvider call(String tradeNo) =>
      GetOrderProvider._(argument: tradeNo, from: this);

  @override
  String toString() => r'getOrderProvider';
}
