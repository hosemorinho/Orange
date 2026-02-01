// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../sdk_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$xboardSdkHash() => r'9f5fe8bb626772bdd6c07725c452de2541fbe21c';

/// V2Board API Service Provider
///
/// 替代原有的 XBoardSDK Provider
/// - 等待 InitializationProvider 完成域名检查
/// - 使用已缓存的域名竞速结果
/// - 创建 V2BoardApiService 实例
/// - 加载已存储的 token
///
/// Copied from [xboardSdk].
@ProviderFor(xboardSdk)
final xboardSdkProvider = FutureProvider<V2BoardApiService>.internal(
  xboardSdk,
  name: r'xboardSdkProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$xboardSdkHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef XboardSdkRef = FutureProviderRef<V2BoardApiService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
