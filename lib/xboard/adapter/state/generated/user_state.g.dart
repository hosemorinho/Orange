// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../user_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 用户状态管理
/// 获取用户信息

@ProviderFor(getUserInfo)
const getUserInfoProvider = GetUserInfoProvider._();

/// 用户状态管理
/// 获取用户信息

final class GetUserInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<DomainUser>,
          DomainUser,
          FutureOr<DomainUser>
        >
    with $FutureModifier<DomainUser>, $FutureProvider<DomainUser> {
  /// 用户状态管理
  /// 获取用户信息
  const GetUserInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getUserInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getUserInfoHash();

  @$internal
  @override
  $FutureProviderElement<DomainUser> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DomainUser> create(Ref ref) {
    return getUserInfo(ref);
  }
}

String _$getUserInfoHash() => r'2bcf81883ad474e402b9488619c54e5dfe2a58ea';
