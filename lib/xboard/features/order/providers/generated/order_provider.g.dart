// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cancel an order by trade number

@ProviderFor(cancelOrder)
const cancelOrderProvider = CancelOrderFamily._();

/// Cancel an order by trade number

final class CancelOrderProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Cancel an order by trade number
  const CancelOrderProvider._({
    required CancelOrderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cancelOrderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cancelOrderHash();

  @override
  String toString() {
    return r'cancelOrderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return cancelOrder(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CancelOrderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cancelOrderHash() => r'0777f4fdaa56aa5f8b16b39254ee166da4873733';

/// Cancel an order by trade number

final class CancelOrderFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  const CancelOrderFamily._()
    : super(
        retry: null,
        name: r'cancelOrderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Cancel an order by trade number

  CancelOrderProvider call(String tradeNo) =>
      CancelOrderProvider._(argument: tradeNo, from: this);

  @override
  String toString() => r'cancelOrderProvider';
}
