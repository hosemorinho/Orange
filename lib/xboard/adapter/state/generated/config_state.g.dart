// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../config_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 配置状态管理
/// 获取 V2Board 站点配置
///
/// 返回原始 Map，包含 is_email_verify, is_invite_force 等字段

@ProviderFor(getConfig)
const getConfigProvider = GetConfigProvider._();

/// 配置状态管理
/// 获取 V2Board 站点配置
///
/// 返回原始 Map，包含 is_email_verify, is_invite_force 等字段

final class GetConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  /// 配置状态管理
  /// 获取 V2Board 站点配置
  ///
  /// 返回原始 Map，包含 is_email_verify, is_invite_force 等字段
  const GetConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getConfigHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return getConfig(ref);
  }
}

String _$getConfigHash() => r'ae3bd017c4dd2cd650ab3a33e670e0ab08d271af';
