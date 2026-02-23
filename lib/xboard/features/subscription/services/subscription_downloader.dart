import 'dart:async';
import 'dart:io';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/xboard/config/xboard_config.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:socks5_proxy/socks_client.dart';

// 初始化文件级日志器
final _logger = FileLogger('subscription_downloader.dart');

/// XBoard 订阅下载服务
///
/// 并发下载（直连 + 所有代理），第一个成功就获胜
/// 并发竞速只用于测试连通性，最终使用 FlClash 核心的 Profile.update() 下载
class SubscriptionDownloader {
  static const Duration _racingTimeout = Duration(seconds: 10); // 竞速测试超时
  static const Duration _coreWaitTimeout = Duration(seconds: 30); // 等待核心就绪超时

  /// 运行连通性竞速测试（并发测试所有连接方式）
  ///
  /// 返回最快响应的连接方式信息
  static Future<_ConnectivityRacingResult> _runConnectivityRacing(
    String url,
    List<String> proxies,
  ) async {
    _logger.info('开始连通性竞速测试 (${proxies.length + 1}种方式)');

    final cancelTokens = <_CancelToken>[];
    final tasks = <Future<_ConnectivityTestResult>>[];

    try {
      // 任务0: 直连测试
      final directToken = _CancelToken();
      cancelTokens.add(directToken);
      tasks.add(
        _testConnectivity(
          url,
          useProxy: false,
          cancelToken: directToken,
          taskIndex: 0,
        ),
      );

      // 任务1+: 所有代理测试
      for (int i = 0; i < proxies.length; i++) {
        final proxyToken = _CancelToken();
        cancelTokens.add(proxyToken);
        tasks.add(
          _testConnectivity(
            url,
            useProxy: true,
            proxyUrl: proxies[i],
            cancelToken: proxyToken,
            taskIndex: i + 1,
          ),
        );
      }

      // 等待第一个成功的连通性测试（忽略失败的）
      final winner = await _waitForFirstSuccess(tasks);

      // 取消其他所有任务
      _logger.info('🏆 ${winner.connectionType} 获胜！');
      for (final token in cancelTokens) {
        token.cancel();
      }

      return _ConnectivityRacingResult(winner: winner, success: true);
    } catch (e) {
      // 取消所有任务
      for (final token in cancelTokens) {
        token.cancel();
      }

      _logger.warning('所有竞速测试失败', e);
      return _ConnectivityRacingResult(winner: null, success: false);
    }
  }

  /// Public gate for callers that need to ensure the core is available
  /// before invoking profile update/validation flows.
  static Future<void> ensureCoreReady() => _waitForCoreReady();

  /// 等待 Clash 核心服务就绪（Android 特需）
  ///
  /// 在 Android 上，Profile.update() 需要调用 validateConfig()，
  /// 该方法通过 AIDL 与 Clash 核心服务通信。如果服务未就绪，
  /// 调用会超时（10秒）。因此需要等待核心连接完成。
  static Future<void> _waitForCoreReady() async {
    // 非 Android 平台或 appController 未就绪时跳过
    if (!system.isAndroid || !appController.isAttach) {
      return;
    }

    _logger.info('[核心初始化] 等待 Clash 核心服务就绪...');

    final startTime = DateTime.now();
    while (DateTime.now().difference(startTime) < _coreWaitTimeout) {
      // 检查核心是否已连接（通过 coreController.isCompleted）
      if (appController.isAttach) {
        // 使用全局的 coreController 检查初始化状态
        try {
          final isCompleted = coreController.isCompleted;
          if (isCompleted) {
            final elapsed = DateTime.now().difference(startTime).inMilliseconds;
            _logger.info('✅ [核心初始化] Clash 核心服务已就绪 (${elapsed}ms)');
            return;
          }
        } catch (e) {
          _logger.debug('[核心初始化] 状态检查出错: $e');
        }
      }

      // 等待一小段时间后重试
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _logger.warning('⚠️ [核心初始化] 等待核心服务超时，尝试继续下载（可能失败）');
  }

  /// 下载订阅并返回 Profile（并发竞速）
  ///
  /// [url] 订阅URL
  /// [enableRacing] 是否启用竞速（默认 true，false时只使用 FlClash 核心直接下载）
  static Future<Profile> downloadSubscription(
    String url, {
    bool enableRacing = true,
  }) async {
    try {
      _logger.info('开始下载订阅: $url');

      if (!enableRacing) {
        // 禁用竞速：等待核心就绪，直接使用 FlClash 核心的 Profile.update()
        _logger.info('竞速已禁用，等待核心就绪后下载');
        await ensureCoreReady();
        final profile = Profile.normal(
          url: url,
          autoUpdateDuration: const Duration(hours: 1),
        );
        return await profile.update(forceDirect: true);
      }

      // 优化策略：并行执行竞速测试和核心初始化，最大化效率
      // 1. 启动竞速测试（不等待结果）
      // 2. 同时等待核心就绪
      // 3. 两者都完成后，使用核心下载配置

      final proxies = XBoardConfig.allProxyUrls;
      _logger.info('🚀 并行执行：竞速测试 (${proxies.length + 1}种方式) + 核心初始化');

      // 启动竞速测试（立即返回 Future，不等待）
      final racingFuture = _runConnectivityRacing(url, proxies);

      // 同时等待核心就绪（Android 上必需，Desktop 上立即返回）
      final coreReadyFuture = ensureCoreReady();

      // 等待两个任务都完成（并行执行）
      await Future.wait([racingFuture, coreReadyFuture]);

      // 使用 FlClash 核心的 Profile.update() 下载完整配置
      // forceDirect: 绕过 Clash 代理直连下载，避免 Clash 核心已启动
      // 但节点配置过期时导致下载超时
      _logger.info('使用 FlClash 核心下载完整配置（直连）...');
      final profile = Profile.normal(
        url: url,
        autoUpdateDuration: const Duration(hours: 1),
      );
      return await profile.update(forceDirect: true);
    } on TimeoutException catch (e) {
      _logger.error('订阅下载超时', e);
      throw Exception('下载超时: ${e.message}');
    } on SocketException catch (e) {
      _logger.error('网络连接失败', e);
      throw Exception('网络连接失败: ${e.message}');
    } on HttpException catch (e) {
      _logger.error('HTTP请求失败', e);
      throw Exception('HTTP请求失败: ${e.message}');
    } catch (e) {
      _logger.error('订阅下载失败', e);
      rethrow;
    }
  }

  /// 等待第一个成功的连通性测试（忽略失败的）
  static Future<_ConnectivityTestResult> _waitForFirstSuccess(
    List<Future<_ConnectivityTestResult>> tasks,
  ) async {
    final completer = Completer<_ConnectivityTestResult>();
    int failedCount = 0;
    final errors = <Object>[];

    for (final task in tasks) {
      task
          .then((result) {
            if (!completer.isCompleted) {
              completer.complete(result);
            }
          })
          .catchError((e) {
            failedCount++;
            errors.add(e);

            // 如果所有任务都失败了，抛出第一个错误
            if (failedCount == tasks.length && !completer.isCompleted) {
              _logger.error('所有连通性测试都失败了', errors.first);
              completer.completeError(errors.first);
            }
          });
    }

    return completer.future;
  }

  /// 测试连通性（只获取前几个字节验证可用性）
  static Future<_ConnectivityTestResult> _testConnectivity(
    String url, {
    required bool useProxy,
    String? proxyUrl,
    required _CancelToken cancelToken,
    required int taskIndex,
  }) async {
    final connectionType = useProxy ? '代理($proxyUrl)' : '直连';
    _logger.info('[任务$taskIndex] 测试连通性: $connectionType');

    try {
      await _pingUrl(
        url,
        useProxy: useProxy,
        proxyUrl: proxyUrl,
        cancelToken: cancelToken,
      );

      _logger.info('[任务$taskIndex] 连通性测试成功: $connectionType');

      return _ConnectivityTestResult(
        connectionType: connectionType,
        useProxy: useProxy,
        proxyUrl: proxyUrl,
      );
    } catch (e) {
      if (cancelToken.isCancelled) {
        _logger.info('[任务$taskIndex] 已取消: $connectionType');
      } else {
        _logger.warning('[任务$taskIndex] 连通性测试失败: $connectionType - $e');
      }
      rethrow;
    }
  }

  /// 测试 URL 连通性（只发送 HEAD 请求或读取少量数据）
  static Future<void> _pingUrl(
    String url, {
    required bool useProxy,
    String? proxyUrl,
    required _CancelToken cancelToken,
  }) async {
    HttpClient? client;

    try {
      // 检查是否已取消
      if (cancelToken.isCancelled) {
        throw Exception('任务已取消');
      }

      // 创建 HttpClient
      client = HttpClient();
      client.connectionTimeout = _racingTimeout;
      client.badCertificateCallback = (cert, host, port) => true;
      // 绕过 FlClashHttpOverrides 代理，避免 Clash 核心已启动时流量被路由到过期节点
      client.findProxy = (uri) => 'DIRECT';

      // 如果使用代理，配置 SOCKS5 代理
      if (useProxy && proxyUrl != null) {
        final proxyConfig = _parseProxyConfig(proxyUrl);
        final proxySettings = ProxySettings(
          InternetAddress(proxyConfig['host']!),
          int.parse(proxyConfig['port']!),
          username: proxyConfig['username'],
          password: proxyConfig['password'],
        );

        SocksTCPClient.assignToHttpClient(client, [proxySettings]);
      }

      // 发起 HEAD 请求（更快，不下载内容）
      final uri = Uri.parse(url);
      final request = await client.headUrl(uri);

      // 检查是否已取消
      if (cancelToken.isCancelled) {
        client.close(force: true);
        throw Exception('任务已取消');
      }

      // 设置请求头（使用应用的动态 User-Agent）
      request.headers.set(
        HttpHeaders.userAgentHeader,
        globalState.packageInfo.ua,
      );

      // 检查是否已取消
      if (cancelToken.isCancelled) {
        client.close(force: true);
        throw Exception('任务已取消');
      }

      // 获取响应
      final response = await request.close().timeout(
        _racingTimeout,
        onTimeout: () {
          throw TimeoutException('连通性测试超时', _racingTimeout);
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw HttpException('HTTP ${response.statusCode}');
      }

      // 检查是否已取消
      if (cancelToken.isCancelled) {
        client.close(force: true);
        throw Exception('任务已取消');
      }

      // 消耗响应流（HEAD 请求通常没有 body，但为了保险起见）
      await response.drain();
    } finally {
      if (cancelToken.isCancelled) {
        client?.close(force: true);
      } else {
        client?.close();
      }
    }
  }

  /// 解析代理配置
  ///
  /// 输入格式:
  /// - `socks5://user:pass@host:port`
  /// - `socks5://host:port`
  /// - `http://user:pass@host:port`
  ///
  /// 返回: { host, port, username?, password? }
  static Map<String, String?> _parseProxyConfig(String proxyUrl) {
    String url = proxyUrl.trim();

    // 去除协议前缀
    if (url.toLowerCase().startsWith('socks5://')) {
      url = url.substring(9);
    } else if (url.toLowerCase().startsWith('http://')) {
      url = url.substring(7);
    } else if (url.toLowerCase().startsWith('https://')) {
      url = url.substring(8);
    }

    String? username;
    String? password;
    String hostPort = url;

    // 解析认证信息 user:pass@host:port
    if (url.contains('@')) {
      final atIndex = url.lastIndexOf('@');
      final authPart = url.substring(0, atIndex);
      hostPort = url.substring(atIndex + 1);

      if (authPart.contains(':')) {
        final colonIndex = authPart.indexOf(':');
        username = authPart.substring(0, colonIndex);
        password = authPart.substring(colonIndex + 1);
      }
    }

    // 解析 host:port
    final colonIndex = hostPort.lastIndexOf(':');
    if (colonIndex == -1) {
      throw FormatException('代理配置格式错误，缺少端口号: $proxyUrl');
    }

    final host = hostPort.substring(0, colonIndex);
    final port = hostPort.substring(colonIndex + 1);

    if (host.isEmpty || port.isEmpty) {
      throw FormatException('代理配置格式错误: $proxyUrl');
    }

    return {
      'host': host,
      'port': port,
      'username': username,
      'password': password,
    };
  }
}

/// 取消令牌
class _CancelToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }
}

/// 连通性测试结果
class _ConnectivityTestResult {
  final String connectionType;
  final bool useProxy;
  final String? proxyUrl;

  _ConnectivityTestResult({
    required this.connectionType,
    required this.useProxy,
    this.proxyUrl,
  });
}

/// 连通性竞速结果
class _ConnectivityRacingResult {
  final _ConnectivityTestResult? winner;
  final bool success;

  _ConnectivityRacingResult({required this.winner, required this.success});
}
