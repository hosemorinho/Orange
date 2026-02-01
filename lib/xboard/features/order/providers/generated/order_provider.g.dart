// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cancelOrderHash() => r'0777f4fdaa56aa5f8b16b39254ee166da4873733';

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

/// Cancel an order by trade number
///
/// Copied from [cancelOrder].
@ProviderFor(cancelOrder)
const cancelOrderProvider = CancelOrderFamily();

/// Cancel an order by trade number
///
/// Copied from [cancelOrder].
class CancelOrderFamily extends Family<AsyncValue<void>> {
  /// Cancel an order by trade number
  ///
  /// Copied from [cancelOrder].
  const CancelOrderFamily();

  /// Cancel an order by trade number
  ///
  /// Copied from [cancelOrder].
  CancelOrderProvider call(
    String tradeNo,
  ) {
    return CancelOrderProvider(
      tradeNo,
    );
  }

  @override
  CancelOrderProvider getProviderOverride(
    covariant CancelOrderProvider provider,
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
  String? get name => r'cancelOrderProvider';
}

/// Cancel an order by trade number
///
/// Copied from [cancelOrder].
class CancelOrderProvider extends AutoDisposeFutureProvider<void> {
  /// Cancel an order by trade number
  ///
  /// Copied from [cancelOrder].
  CancelOrderProvider(
    String tradeNo,
  ) : this._internal(
          (ref) => cancelOrder(
            ref as CancelOrderRef,
            tradeNo,
          ),
          from: cancelOrderProvider,
          name: r'cancelOrderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cancelOrderHash,
          dependencies: CancelOrderFamily._dependencies,
          allTransitiveDependencies:
              CancelOrderFamily._allTransitiveDependencies,
          tradeNo: tradeNo,
        );

  CancelOrderProvider._internal(
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
    FutureOr<void> Function(CancelOrderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CancelOrderProvider._internal(
        (ref) => create(ref as CancelOrderRef),
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
  AutoDisposeFutureProviderElement<void> createElement() {
    return _CancelOrderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CancelOrderProvider && other.tradeNo == tradeNo;
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
mixin CancelOrderRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `tradeNo` of this provider.
  String get tradeNo;
}

class _CancelOrderProviderElement extends AutoDisposeFutureProviderElement<void>
    with CancelOrderRef {
  _CancelOrderProviderElement(super.provider);

  @override
  String get tradeNo => (origin as CancelOrderProvider).tradeNo;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
