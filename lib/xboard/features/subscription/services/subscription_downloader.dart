import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/xboard/config/xboard_config.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/state.dart';
import 'package:socks5_proxy/socks_client.dart';

// 初始化文件级日志器
final _logger = FileLogger('subscription_downloader.dart');

/// XBoard 订阅下载服务
///
/// 使用自有 Dio DIRECT 直连下载配置文件，不依赖 appController 或 coreController。
/// 可选的并发连通性竞速测试（直连 + 代理）仅用于后台预热探测。
class SubscriptionDownloader {
  static const Duration _downloadTimeout = Duration(seconds: 30);
  static const Duration _racingTimeout = Duration(seconds: 10); // 竞速测试超时

  /// 专用直连 Dio 实例（懒加载）
  /// 不经过 Clash 代理，不依赖 appController 或 coreController
  static Dio? _directDioInstance;
  static Dio get _directDio {
    _directDioInstance ??= Dio()
      ..httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.findProxy = (uri) => 'DIRECT';
          client.badCertificateCallback = (_, _, _) => true;
          return client;
        },
      );
    return _directDioInstance!;
  }

  /// 运行连通性竞速测试（并发测试所有连接方式）
  ///
  /// 返回最快响应的连接方式信息
  static Future<_ConnectivityRacingResult> _runConnectivityRacing(
    String url,
    List<String> proxies,
  ) async {
    _logger.info('🏁 开始连通性竞速测试');
    _logger.info('   URL: $url');
    _logger.info('   竞速方式: 直连 + ${proxies.length}个代理');

    final cancelTokens = <_CancelToken>[];
    final tasks = <Future<_ConnectivityTestResult>>[];

    try {
      // 任务0: 直连测试
      final directToken = _CancelToken();
      cancelTokens.add(directToken);
      tasks.add(_testConnectivity(
        url,
        useProxy: false,
        cancelToken: directToken,
        taskIndex: 0,
      ));

      // 任务1+: 所有代理测试
      for (int i = 0; i < proxies.length; i++) {
        final proxyToken = _CancelToken();
        cancelTokens.add(proxyToken);
        tasks.add(_testConnectivity(
          url,
          useProxy: true,
          proxyUrl: proxies[i],
          cancelToken: proxyToken,
          taskIndex: i + 1,
        ));
      }

      // 等待第一个成功的连通性测试（忽略失败的）
      _logger.info('⏳ 等待第一个成功响应...');
      final winner = await _waitForFirstSuccess(tasks);

      // 取消其他所有任务
      _logger.info('🏆 竞速获胜: ${winner.connectionType}');
      for (final token in cancelTokens) {
        token.cancel();
      }

      return _ConnectivityRacingResult(
        winner: winner,
        success: true,
      );
    } catch (e, st) {
      // 取消所有任务
      for (final token in cancelTokens) {
        token.cancel();
      }

      _logger.warning('❌ 所有竞速测试失败', e, st);
      return _ConnectivityRacingResult(
        winner: null,
        success: false,
      );
    }
  }

  /// 下载订阅并返回 Profile
  ///
  /// 使用自有 Dio 直接下载配置文件并保存到本地，
  /// 完全不依赖 appController 或 coreController（解决 Android 初始化竞态条件）。
  ///
  /// 与旧方案的区别：
  /// - 旧: Profile.update() → request.getFileResponseForUrl() → saveFile() → coreController.validateConfig()
  ///   问题: validateConfig 需要 Clash 核心已连接，但 quickAuth() 在 attach() 之前就触发了下载
  /// - 新: 自有 Dio DIRECT 下载 → 直接写入 profile 目录 → 返回 Profile 对象
  ///   不需要任何核心服务，配置会在后续 applyProfile() 时被核心加载验证
  static Future<Profile> downloadSubscription(
    String url, {
    bool enableRacing = true,
  }) async {
    try {
      _logger.info('════════════════════════════════════════');
      _logger.info('📥 开始下载订阅（直接下载模式）');
      _logger.info('   URL: $url');
      _logger.info('════════════════════════════════════════');

      // 可选: 并行启动连通性竞速测试（仅用于预热探测，不阻塞下载）
      if (enableRacing) {
        final proxies = XBoardConfig.allProxyUrls;
        if (proxies.isNotEmpty) {
          _logger.info('🏁 启动后台连通性竞速（不阻塞下载）...');
          // ignore: unawaited_futures
          _runConnectivityRacing(url, proxies).catchError((e) {
            _logger.warning('竞速测试失败（不影响下载）: $e');
            return _ConnectivityRacingResult(winner: null, success: false);
          });
        }
      }

      // 使用与 FlClash 一致的 User-Agent: "{appName}/v{version} clash-verge Platform/{os}"
      // V2Board 识别 UA 中的 "clash-verge" 关键字，返回 Clash YAML 格式配置
      final userAgent = globalState.packageInfo.ua;
      _logger.info('   User-Agent: $userAgent');

      // 直接下载配置文件（DIRECT 连接，绕过 Clash 代理，无需核心服务）
      _logger.info('📡 直接下载配置文件 (DIRECT)...');
      final startTime = DateTime.now();
      final response = await _directDio.get<Uint8List>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            HttpHeaders.userAgentHeader: userAgent,
          },
        ),
      ).timeout(
        _downloadTimeout,
        onTimeout: () {
          throw TimeoutException('配置下载超时', _downloadTimeout);
        },
      );
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      _logger.info('✅ 配置文件下载完成 (${elapsed}ms)');

      // 解析响应头
      final disposition = response.headers.value("content-disposition");
      final userinfo = response.headers.value('subscription-userinfo');
      _logger.info('   Content-Disposition: $disposition');
      _logger.info('   Subscription-Userinfo: $userinfo');

      // 检查响应数据
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('下载的配置文件为空');
      }
      _logger.info('   文件大小: ${bytes.length} bytes');

      // 创建 Profile 对象
      final profile = Profile.normal(url: url);
      final labelFromDisposition = utils.getFileNameForDisposition(disposition);
      final updatedProfile = profile.copyWith(
        label: labelFromDisposition?.isNotEmpty == true
            ? labelFromDisposition!
            : profile.id.toString(),
        subscriptionInfo: SubscriptionInfo.formHString(userinfo),
        lastUpdateDate: DateTime.now(),
      );

      // 直接保存到 profile 目录（跳过 validateConfig）
      // validateConfig 需要 Clash 核心已连接，Android 上可能尚未完成初始化
      // 配置来自可信订阅服务器，后续 applyProfile 时核心会加载并验证
      _logger.info('💾 保存配置文件...');
      _logger.info('   Profile ID: ${updatedProfile.id}');
      final profilePath = await appPath.getProfilePath(
        updatedProfile.id.toString(),
      );
      final profileFile = File(profilePath);
      await profileFile.parent.create(recursive: true);
      await profileFile.writeAsBytes(bytes);

      _logger.info('✅ 配置文件已保存');
      _logger.info('   路径: $profilePath');
      _logger.info('   Label: ${updatedProfile.label}');
      _logger.info('   URL: ${updatedProfile.url}');
      _logger.info('════════════════════════════════════════');
      return updatedProfile;

    } on TimeoutException catch (e) {
      _logger.error('❌ 订阅下载超时', e);
      throw Exception('下载超时: ${e.message}');
    } on SocketException catch (e) {
      _logger.error('❌ 网络连接异常', e);
      throw Exception('网络连接失败: ${e.message}');
    } on DioException catch (e) {
      _logger.error('❌ HTTP 请求异常', e);
      _logger.error('   状态码: ${e.response?.statusCode}');
      _logger.error('   类型: ${e.type}');
      throw Exception('HTTP 请求失败: ${e.message}');
    } catch (e, st) {
      _logger.error('❌ 订阅下载失败', e, st);
      _logger.error('   错误类型: ${e.runtimeType}');
      _logger.info('════════════════════════════════════════');
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
      task.then((result) {
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      }).catchError((e) {
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

      // 设置请求头（与下载使用相同的 UA）
      request.headers.set(HttpHeaders.userAgentHeader, globalState.packageInfo.ua);

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

  _ConnectivityRacingResult({
    required this.winner,
    required this.success,
  });
}
