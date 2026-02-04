// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../invite_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Invite data provider
///
/// Fetches invite codes and statistics from API

@ProviderFor(InviteDataProvider)
const inviteDataProviderProvider = InviteDataProviderProvider._();

/// Invite data provider
///
/// Fetches invite codes and statistics from API
final class InviteDataProviderProvider
    extends $AsyncNotifierProvider<InviteDataProvider, InviteData> {
  /// Invite data provider
  ///
  /// Fetches invite codes and statistics from API
  const InviteDataProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inviteDataProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inviteDataProviderHash();

  @$internal
  @override
  InviteDataProvider create() => InviteDataProvider();
}

String _$inviteDataProviderHash() =>
    r'83e717339d46abd92f5fea9aaa08c43f031e738b';

/// Invite data provider
///
/// Fetches invite codes and statistics from API

abstract class _$InviteDataProvider extends $AsyncNotifier<InviteData> {
  FutureOr<InviteData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<InviteData>, InviteData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<InviteData>, InviteData>,
              AsyncValue<InviteData>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Create a new invite code

@ProviderFor(createInviteCode)
const createInviteCodeProvider = CreateInviteCodeProvider._();

/// Create a new invite code

final class CreateInviteCodeProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Create a new invite code
  const CreateInviteCodeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createInviteCodeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createInviteCodeHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return createInviteCode(ref);
  }
}

String _$createInviteCodeHash() => r'c60900a1241fbcd0c52f17dea8925d8c29e45463';

/// Transfer commission to balance

@ProviderFor(transferCommission)
const transferCommissionProvider = TransferCommissionFamily._();

/// Transfer commission to balance

final class TransferCommissionProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Transfer commission to balance
  const TransferCommissionProvider._({
    required TransferCommissionFamily super.from,
    required double super.argument,
  }) : super(
         retry: null,
         name: r'transferCommissionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transferCommissionHash();

  @override
  String toString() {
    return r'transferCommissionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as double;
    return transferCommission(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TransferCommissionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transferCommissionHash() =>
    r'a941b9a4450184ac7f0b5aa40b31f7810a6f957e';

/// Transfer commission to balance

final class TransferCommissionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, double> {
  const TransferCommissionFamily._()
    : super(
        retry: null,
        name: r'transferCommissionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Transfer commission to balance

  TransferCommissionProvider call(double amount) =>
      TransferCommissionProvider._(argument: amount, from: this);

  @override
  String toString() => r'transferCommissionProvider';
}

/// Get commission config (withdrawal methods)

@ProviderFor(commissionConfig)
const commissionConfigProvider = CommissionConfigProvider._();

/// Get commission config (withdrawal methods)

final class CommissionConfigProvider
    extends $FunctionalProvider<AsyncValue<Map<String, dynamic>>, Map<String, dynamic>, FutureOr<Map<String, dynamic>>>
    with $FutureModifier<Map<String, dynamic>>, $FutureProvider<Map<String, dynamic>> {
  /// Get commission config (withdrawal methods)
  const CommissionConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commissionConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commissionConfigHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return commissionConfig(ref);
  }
}

String _$commissionConfigHash() => r'b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0';

/// Submit withdrawal ticket

@ProviderFor(withdrawCommission)
const withdrawCommissionProvider = WithdrawCommissionFamily._();

/// Submit withdrawal ticket

final class WithdrawCommissionProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Submit withdrawal ticket
  const WithdrawCommissionProvider._({
    required WithdrawCommissionFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'withdrawCommissionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$withdrawCommissionHash();

  @override
  String toString() {
    return r'withdrawCommissionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as (String, String);
    return withdrawCommission(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is WithdrawCommissionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$withdrawCommissionHash() =>
    r'c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1';

/// Submit withdrawal ticket

final class WithdrawCommissionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, (String, String)> {
  const WithdrawCommissionFamily._()
    : super(
        retry: null,
        name: r'withdrawCommissionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Submit withdrawal ticket

  WithdrawCommissionProvider call(String method, String account) =>
      WithdrawCommissionProvider._(argument: (method, account), from: this);

  @override
  String toString() => r'withdrawCommissionProvider';
}
