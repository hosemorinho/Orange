// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../sdk_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// V2Board API Service Provider
///
/// 替代原有的 XBoardSDK Provider
/// - 等待 InitializationProvider 完成域名检查
/// - 使用已缓存的域名竞速结果
/// - 创建 V2BoardApiService 实例
/// - 加载已存储的 token

@ProviderFor(xboardSdk)
const xboardSdkProvider = XboardSdkProvider._();

/// V2Board API Service Provider
///
/// 替代原有的 XBoardSDK Provider
/// - 等待 InitializationProvider 完成域名检查
/// - 使用已缓存的域名竞速结果
/// - 创建 V2BoardApiService 实例
/// - 加载已存储的 token

final class XboardSdkProvider
    extends
        $FunctionalProvider<
          AsyncValue<V2BoardApiService>,
          V2BoardApiService,
          FutureOr<V2BoardApiService>
        >
    with
        $FutureModifier<V2BoardApiService>,
        $FutureProvider<V2BoardApiService> {
  /// V2Board API Service Provider
  ///
  /// 替代原有的 XBoardSDK Provider
  /// - 等待 InitializationProvider 完成域名检查
  /// - 使用已缓存的域名竞速结果
  /// - 创建 V2BoardApiService 实例
  /// - 加载已存储的 token
  const XboardSdkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'xboardSdkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$xboardSdkHash();

  @$internal
  @override
  $FutureProviderElement<V2BoardApiService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<V2BoardApiService> create(Ref ref) {
    return xboardSdk(ref);
  }
}

String _$xboardSdkHash() => r'9f5fe8bb626772bdd6c07725c452de2541fbe21c';
