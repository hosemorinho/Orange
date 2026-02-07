// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../ticket_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 工单状态管理
/// 获取工单列表

@ProviderFor(getTickets)
const getTicketsProvider = GetTicketsProvider._();

/// 工单状态管理
/// 获取工单列表

final class GetTicketsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DomainTicket>>,
          List<DomainTicket>,
          FutureOr<List<DomainTicket>>
        >
    with
        $FutureModifier<List<DomainTicket>>,
        $FutureProvider<List<DomainTicket>> {
  /// 工单状态管理
  /// 获取工单列表
  const GetTicketsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getTicketsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getTicketsHash();

  @$internal
  @override
  $FutureProviderElement<List<DomainTicket>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DomainTicket>> create(Ref ref) {
    return getTickets(ref);
  }
}

String _$getTicketsHash() => r'909aa6ea43cb83f6841c864934b5eb2ee3b844cc';

/// 获取单个工单

@ProviderFor(getTicket)
const getTicketProvider = GetTicketFamily._();

/// 获取单个工单

final class GetTicketProvider
    extends
        $FunctionalProvider<
          AsyncValue<DomainTicket?>,
          DomainTicket?,
          FutureOr<DomainTicket?>
        >
    with $FutureModifier<DomainTicket?>, $FutureProvider<DomainTicket?> {
  /// 获取单个工单
  const GetTicketProvider._({
    required GetTicketFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'getTicketProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getTicketHash();

  @override
  String toString() {
    return r'getTicketProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DomainTicket?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DomainTicket?> create(Ref ref) {
    final argument = this.argument as int;
    return getTicket(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetTicketProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getTicketHash() => r'a19bb090f63c7ab20e014a403218482349823c8f';

/// 获取单个工单

final class GetTicketFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DomainTicket?>, int> {
  const GetTicketFamily._()
    : super(
        retry: null,
        name: r'getTicketProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 获取单个工单

  GetTicketProvider call(int id) =>
      GetTicketProvider._(argument: id, from: this);

  @override
  String toString() => r'getTicketProvider';
}
