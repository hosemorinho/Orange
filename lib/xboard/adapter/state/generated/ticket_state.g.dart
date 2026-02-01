// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../ticket_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getTicketsHash() => r'909aa6ea43cb83f6841c864934b5eb2ee3b844cc';

/// 工单状态管理
/// 获取工单列表
///
/// Copied from [getTickets].
@ProviderFor(getTickets)
final getTicketsProvider =
    AutoDisposeFutureProvider<List<DomainTicket>>.internal(
  getTickets,
  name: r'getTicketsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getTicketsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetTicketsRef = AutoDisposeFutureProviderRef<List<DomainTicket>>;
String _$getTicketHash() => r'a19bb090f63c7ab20e014a403218482349823c8f';

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

/// 获取单个工单
///
/// Copied from [getTicket].
@ProviderFor(getTicket)
const getTicketProvider = GetTicketFamily();

/// 获取单个工单
///
/// Copied from [getTicket].
class GetTicketFamily extends Family<AsyncValue<DomainTicket?>> {
  /// 获取单个工单
  ///
  /// Copied from [getTicket].
  const GetTicketFamily();

  /// 获取单个工单
  ///
  /// Copied from [getTicket].
  GetTicketProvider call(
    int id,
  ) {
    return GetTicketProvider(
      id,
    );
  }

  @override
  GetTicketProvider getProviderOverride(
    covariant GetTicketProvider provider,
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
  String? get name => r'getTicketProvider';
}

/// 获取单个工单
///
/// Copied from [getTicket].
class GetTicketProvider extends AutoDisposeFutureProvider<DomainTicket?> {
  /// 获取单个工单
  ///
  /// Copied from [getTicket].
  GetTicketProvider(
    int id,
  ) : this._internal(
          (ref) => getTicket(
            ref as GetTicketRef,
            id,
          ),
          from: getTicketProvider,
          name: r'getTicketProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getTicketHash,
          dependencies: GetTicketFamily._dependencies,
          allTransitiveDependencies: GetTicketFamily._allTransitiveDependencies,
          id: id,
        );

  GetTicketProvider._internal(
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
    FutureOr<DomainTicket?> Function(GetTicketRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetTicketProvider._internal(
        (ref) => create(ref as GetTicketRef),
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
  AutoDisposeFutureProviderElement<DomainTicket?> createElement() {
    return _GetTicketProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetTicketProvider && other.id == id;
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
mixin GetTicketRef on AutoDisposeFutureProviderRef<DomainTicket?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _GetTicketProviderElement
    extends AutoDisposeFutureProviderElement<DomainTicket?> with GetTicketRef {
  _GetTicketProviderElement(super.provider);

  @override
  int get id => (origin as GetTicketProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
