// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../invite_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$createInviteCodeHash() => r'c60900a1241fbcd0c52f17dea8925d8c29e45463';

/// Create a new invite code
///
/// Copied from [createInviteCode].
@ProviderFor(createInviteCode)
final createInviteCodeProvider = AutoDisposeFutureProvider<void>.internal(
  createInviteCode,
  name: r'createInviteCodeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createInviteCodeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreateInviteCodeRef = AutoDisposeFutureProviderRef<void>;
String _$transferCommissionHash() =>
    r'a941b9a4450184ac7f0b5aa40b31f7810a6f957e';

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

/// Transfer commission to balance
///
/// Copied from [transferCommission].
@ProviderFor(transferCommission)
const transferCommissionProvider = TransferCommissionFamily();

/// Transfer commission to balance
///
/// Copied from [transferCommission].
class TransferCommissionFamily extends Family<AsyncValue<void>> {
  /// Transfer commission to balance
  ///
  /// Copied from [transferCommission].
  const TransferCommissionFamily();

  /// Transfer commission to balance
  ///
  /// Copied from [transferCommission].
  TransferCommissionProvider call(
    double amount,
  ) {
    return TransferCommissionProvider(
      amount,
    );
  }

  @override
  TransferCommissionProvider getProviderOverride(
    covariant TransferCommissionProvider provider,
  ) {
    return call(
      provider.amount,
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
  String? get name => r'transferCommissionProvider';
}

/// Transfer commission to balance
///
/// Copied from [transferCommission].
class TransferCommissionProvider extends AutoDisposeFutureProvider<void> {
  /// Transfer commission to balance
  ///
  /// Copied from [transferCommission].
  TransferCommissionProvider(
    double amount,
  ) : this._internal(
          (ref) => transferCommission(
            ref as TransferCommissionRef,
            amount,
          ),
          from: transferCommissionProvider,
          name: r'transferCommissionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$transferCommissionHash,
          dependencies: TransferCommissionFamily._dependencies,
          allTransitiveDependencies:
              TransferCommissionFamily._allTransitiveDependencies,
          amount: amount,
        );

  TransferCommissionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.amount,
  }) : super.internal();

  final double amount;

  @override
  Override overrideWith(
    FutureOr<void> Function(TransferCommissionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TransferCommissionProvider._internal(
        (ref) => create(ref as TransferCommissionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        amount: amount,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _TransferCommissionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransferCommissionProvider && other.amount == amount;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, amount.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TransferCommissionRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `amount` of this provider.
  double get amount;
}

class _TransferCommissionProviderElement
    extends AutoDisposeFutureProviderElement<void> with TransferCommissionRef {
  _TransferCommissionProviderElement(super.provider);

  @override
  double get amount => (origin as TransferCommissionProvider).amount;
}

String _$inviteDataProviderHash() =>
    r'83e717339d46abd92f5fea9aaa08c43f031e738b';

/// Invite data provider
///
/// Fetches invite codes and statistics from API
///
/// Copied from [InviteDataProvider].
@ProviderFor(InviteDataProvider)
final inviteDataProviderProvider =
    AutoDisposeAsyncNotifierProvider<InviteDataProvider, InviteData>.internal(
  InviteDataProvider.new,
  name: r'inviteDataProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inviteDataProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InviteDataProvider = AutoDisposeAsyncNotifier<InviteData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
