// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../notice_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 公告状态管理
/// 获取公告列表

@ProviderFor(getNotices)
const getNoticesProvider = GetNoticesProvider._();

/// 公告状态管理
/// 获取公告列表

final class GetNoticesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DomainNotice>>,
          List<DomainNotice>,
          FutureOr<List<DomainNotice>>
        >
    with
        $FutureModifier<List<DomainNotice>>,
        $FutureProvider<List<DomainNotice>> {
  /// 公告状态管理
  /// 获取公告列表
  const GetNoticesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getNoticesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getNoticesHash();

  @$internal
  @override
  $FutureProviderElement<List<DomainNotice>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DomainNotice>> create(Ref ref) {
    return getNotices(ref);
  }
}

String _$getNoticesHash() => r'1a9b11a572fcf3bb6a9f569abdf61c556ef4d15f';
