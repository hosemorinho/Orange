// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../plan_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 套餐状态管理
/// 获取套餐列表

@ProviderFor(getPlans)
const getPlansProvider = GetPlansProvider._();

/// 套餐状态管理
/// 获取套餐列表

final class GetPlansProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DomainPlan>>,
          List<DomainPlan>,
          FutureOr<List<DomainPlan>>
        >
    with $FutureModifier<List<DomainPlan>>, $FutureProvider<List<DomainPlan>> {
  /// 套餐状态管理
  /// 获取套餐列表
  const GetPlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPlansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPlansHash();

  @$internal
  @override
  $FutureProviderElement<List<DomainPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DomainPlan>> create(Ref ref) {
    return getPlans(ref);
  }
}

String _$getPlansHash() => r'eca949177a954d6303168afb6987b27fc3c4fc55';

/// 获取单个套餐

@ProviderFor(getPlan)
const getPlanProvider = GetPlanFamily._();

/// 获取单个套餐

final class GetPlanProvider
    extends
        $FunctionalProvider<
          AsyncValue<DomainPlan?>,
          DomainPlan?,
          FutureOr<DomainPlan?>
        >
    with $FutureModifier<DomainPlan?>, $FutureProvider<DomainPlan?> {
  /// 获取单个套餐
  const GetPlanProvider._({
    required GetPlanFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'getPlanProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getPlanHash();

  @override
  String toString() {
    return r'getPlanProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DomainPlan?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DomainPlan?> create(Ref ref) {
    final argument = this.argument as int;
    return getPlan(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetPlanProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getPlanHash() => r'48e7daa66ef9eed0044bd75e5fa4bbaa86ef31c1';

/// 获取单个套餐

final class GetPlanFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DomainPlan?>, int> {
  const GetPlanFamily._()
    : super(
        retry: null,
        name: r'getPlanProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 获取单个套餐

  GetPlanProvider call(int id) => GetPlanProvider._(argument: id, from: this);

  @override
  String toString() => r'getPlanProvider';
}
