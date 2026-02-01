// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../plan_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getPlansHash() => r'eca949177a954d6303168afb6987b27fc3c4fc55';

/// 套餐状态管理
/// 获取套餐列表
///
/// Copied from [getPlans].
@ProviderFor(getPlans)
final getPlansProvider = AutoDisposeFutureProvider<List<DomainPlan>>.internal(
  getPlans,
  name: r'getPlansProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getPlansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetPlansRef = AutoDisposeFutureProviderRef<List<DomainPlan>>;
String _$getPlanHash() => r'48e7daa66ef9eed0044bd75e5fa4bbaa86ef31c1';

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

/// 获取单个套餐
///
/// Copied from [getPlan].
@ProviderFor(getPlan)
const getPlanProvider = GetPlanFamily();

/// 获取单个套餐
///
/// Copied from [getPlan].
class GetPlanFamily extends Family<AsyncValue<DomainPlan?>> {
  /// 获取单个套餐
  ///
  /// Copied from [getPlan].
  const GetPlanFamily();

  /// 获取单个套餐
  ///
  /// Copied from [getPlan].
  GetPlanProvider call(
    int id,
  ) {
    return GetPlanProvider(
      id,
    );
  }

  @override
  GetPlanProvider getProviderOverride(
    covariant GetPlanProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'getPlanProvider';
}

/// 获取单个套餐
///
/// Copied from [getPlan].
class GetPlanProvider extends AutoDisposeFutureProvider<DomainPlan?> {
  /// 获取单个套餐
  ///
  /// Copied from [getPlan].
  GetPlanProvider(
    int id,
  ) : this._internal(
          (ref) => getPlan(
            ref as GetPlanRef,
            id,
          ),
          from: getPlanProvider,
          name: r'getPlanProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getPlanHash,
          dependencies: GetPlanFamily._dependencies,
          allTransitiveDependencies: GetPlanFamily._allTransitiveDependencies,
          id: id,
        );

  GetPlanProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<DomainPlan?> Function(GetPlanRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetPlanProvider._internal(
        (ref) => create(ref as GetPlanRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DomainPlan?> createElement() {
    return _GetPlanProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetPlanProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GetPlanRef on AutoDisposeFutureProviderRef<DomainPlan?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _GetPlanProviderElement
    extends AutoDisposeFutureProviderElement<DomainPlan?> with GetPlanRef {
  _GetPlanProviderElement(super.provider);

  @override
  int get id => (origin as GetPlanProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
