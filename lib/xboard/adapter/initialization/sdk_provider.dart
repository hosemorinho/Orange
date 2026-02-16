import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/common/constant.dart' show apiBaseUrl;
import 'package:fl_clash/common/http.dart';
import 'package:fl_clash/xboard/config/xboard_config.dart';
import 'package:fl_clash/xboard/infrastructure/api/api.dart';
import 'package:fl_clash/xboard/infrastructure/http/xboard_http_client.dart';
import 'package:fl_clash/xboard/infrastructure/network/domain_pool.dart';
import 'package:fl_clash/xboard/core/core.dart';

part 'generated/sdk_provider.g.dart';

final _logger = FileLogger('sdk_provider');

/// V2Board API Service Provider
///
/// 替代原有的 XBoardSDK Provider
/// - 等待 InitializationProvider 完成域名检查
/// - 使用已缓存的域名竞速结果
/// - 创建 V2BoardApiService 实例
/// - 加载已存储的 token
@Riverpod(keepAlive: true)
Future<V2BoardApiService> xboardSdk(Ref ref) async {
  try {
    _logger.info('[SdkProvider] 开始初始化 V2Board API Service');

    String? fastestUrl;

    // 0. 优先使用环境变量指定的 API 地址
    if (apiBaseUrl.isNotEmpty) {
      _logger.info('[SdkProvider] 使用环境变量 API 地址: $apiBaseUrl');
      fastestUrl = apiBaseUrl;
    } else {
      // 1. 使用已缓存的域名竞速结果
      fastestUrl = XBoardConfig.lastRacingResult?.domain;

      if (fastestUrl != null) {
        _logger.info('[SdkProvider] 使用缓存的竞速结果: $fastestUrl');
      } else {
        _logger.warning('[SdkProvider] 缓存未命中，执行降级方案：自行竞速');
        fastestUrl = await XBoardConfig.getFastestPanelUrl();
      }
    }

    if (fastestUrl == null) {
      throw Exception('域名竞速失败：所有面板域名都无法连接');
    }

    _logger.info('[SdkProvider] 使用域名: $fastestUrl');

    // Register panel domain for proxy bypass so the app can reach
    // the panel even when the proxy core is down.
    FlClashHttpOverrides.addBypassHosts([fastestUrl]);

    // 2. 根据竞速结果决定是否使用代理
    String? proxyUrl;
    final racingResult = XBoardConfig.lastRacingResult;
    if (racingResult != null && racingResult.useProxy) {
      proxyUrl = racingResult.proxyUrl;
      _logger.info('[SdkProvider] 使用代理: $proxyUrl');
    }

    // 3. 创建 HTTP 客户端
    final httpClient = XBoardHttpClient(
      baseUrl: fastestUrl,
    );

    // 4. 创建 V2Board API Service
    final api = V2BoardApiService(
      baseUrl: fastestUrl,
      httpClient: httpClient,
    );

    // 5. 加载已存储的 token
    await api.loadStoredToken();
    if (api.hasAuthToken) {
      _logger.info('[SdkProvider] 已加载存储的 token');
    }

    // 6. 初始化 DomainPool（域名切换支持）
    final candidates = XBoardConfig.lastRacingCandidates;
    DomainPool.instance.initialize(
      fastestUrl,
      candidates.isNotEmpty ? candidates : [fastestUrl],
      onSwitch: (newDomain) {
        _logger.info('[SdkProvider] 域名切换: ${api.baseUrl} → $newDomain');
        api.baseUrl = newDomain;
        FlClashHttpOverrides.addBypassHosts([newDomain]);
      },
    );

    _logger.info('[SdkProvider] V2Board API Service 初始化成功');
    return api;
  } catch (e, stackTrace) {
    _logger.error('[SdkProvider] 初始化失败', e, stackTrace);
    rethrow;
  }
}
