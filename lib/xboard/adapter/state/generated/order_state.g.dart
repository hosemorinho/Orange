// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../order_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getOrdersHash() => r'935f807e5afa90507dabfaad70d703255e1821c7';

/// 订单状态管理
/// 获取订单列表
///
/// Copied from [getOrders].
@ProviderFor(getOrders)
final getOrdersProvider = AutoDisposeFutureProvider<List<DomainOrder>>.internal(
  getOrders,
  name: r'getOrdersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetOrdersRef = AutoDisposeFutureProviderRef<List<DomainOrder>>;
String _$getOrderHash() => r'4d556a21cb2ffe9cf790b0f22d857adb8698b171';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 获取单个订单
///
/// Copied from [getOrder].
@ProviderFor(getOrder)
const getOrderProvider = GetOrderFamily();

/// 获取单个订单
///
/// Copied from [getOrder].
class GetOrderFamily extends Family<AsyncValue<DomainOrder?>> {
  /// 获取单个订单
  ///
  /// Copied from [getOrder].
  const GetOrderFamily();

  /// 获取单个订单
  ///
  /// Copied from [getOrder].
  GetOrderProvider call(
    String tradeNo,
  ) {
    return GetOrderProvider(
      tradeNo,
    );
  }

  @override
  GetOrderProvider getProviderOverride(
    covariant GetOrderProvider provider,
  ) {
    return call(
      provider.tradeNo,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'getOrderProvider';
}

/// 获取单个订单
///
/// Copied from [getOrder].
class GetOrderProvider extends AutoDisposeFutureProvider<DomainOrder?> {
  /// 获取单个订单
  ///
  /// Copied from [getOrder].
  GetOrderProvider(
    String tradeNo,
  ) : this._internal(
          (ref) => getOrder(
            ref as GetOrderRef,
            tradeNo,
          ),
          from: getOrderProvider,
          name: r'getOrderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getOrderHash,
          dependencies: GetOrderFamily._dependencies,
          allTransitiveDependencies: GetOrderFamily._allTransitiveDependencies,
          tradeNo: tradeNo,
        );

  GetOrderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tradeNo,
  }) : super.internal();

  final String tradeNo;

  @override
  Override overrideWith(
    FutureOr<DomainOrder?> Function(GetOrderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetOrderProvider._internal(
        (ref) => create(ref as GetOrderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tradeNo: tradeNo,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DomainOrder?> createElement() {
    return _GetOrderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetOrderProvider && other.tradeNo == tradeNo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tradeNo.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GetOrderRef on AutoDisposeFutureProviderRef<DomainOrder?> {
  /// The parameter `tradeNo` of this provider.
  String get tradeNo;
}

class _GetOrderProviderElement
    extends AutoDisposeFutureProviderElement<DomainOrder?> with GetOrderRef {
  _GetOrderProviderElement(super.provider);

  @override
  String get tradeNo => (origin as GetOrderProvider).tradeNo;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
