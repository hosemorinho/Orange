import 'dart:async';
import 'dart:io';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/xboard/config/xboard_config.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/infrastructure/http/user_agent_config.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
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
  static const Duration _downloadTimeout = Duration(seconds: 30);
  static const Duration _racingTimeout = Duration(seconds: 10); // 竞速测试超时
  static const Duration _coreWaitTimeout = Duration(seconds: 30); // 等待核心就绪超时

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

  /// 等待 Clash 核心服务就绪（Android 特需）
  ///
  /// 在 Android 上，Profile.update() 需要调用 validateConfig()，
  /// 该方法通过 AIDL 与 Clash 核心服务通信。如果应用还未初始化完成，
  /// 调用会超时。因此需要等待 appController 初始化。
  ///
  /// 注意: coreController.isCompleted 可能永远不会被设置（核心启动时不会触发），
  /// 所以我们改为等待 appController.isAttach，这表示应用初始化已完成。
  static Future<void> _waitForCoreReady() async {
    // 非 Android 平台直接跳过
    if (!system.isAndroid) {
      _logger.info('[核心初始化] 非 Android 平台，跳过核心初始化等待');
      return;
    }

    _logger.info('[核心初始化] 等待应用初始化完成 (appController.attach)...');

    final startTime = DateTime.now();
    int checkCount = 0;

    // appController.isAttach 表示应用初始化流程已完成
    while (DateTime.now().difference(startTime) < _coreWaitTimeout) {
      checkCount++;

      try {
        if (appController.isAttach) {
          final elapsed = DateTime.now().difference(startTime).inMilliseconds;
          _logger.info('[核心初始化] ✅ 应用初始化已完成 (${elapsed}ms, 共${checkCount}次检查)');
          _logger.info('[核心初始化] 核心可以使用，准备下载配置');
          return;
        }

        if (checkCount <= 3 || checkCount % 10 == 0) {
          _logger.info('[核心初始化-$checkCount] 等待 appController.attach() 完成...');
        }
      } catch (e) {
        _logger.warning('[核心初始化-$checkCount] 状态检查出错: $e');
      }

      await Future.delayed(const Duration(milliseconds: 200));
    }

    _logger.warning('[核心初始化] ⚠️  等待应用初始化超时 (${_coreWaitTimeout.inSeconds}s，共${checkCount}次检查)');
    _logger.info('[核心初始化] 应用初始化状态: appController.isAttach=${appController.isAttach}');
    _logger.info('[核心初始化] 💡 提示: 如果核心状态图标是绿色，说明核心已启动，继续尝试下载配置');
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
      _logger.info('════════════════════════════════════════');
      _logger.info('📥 开始下载订阅');
      _logger.info('   URL: $url');
      _logger.info('   enableRacing: $enableRacing');
      _logger.info('   isAndroid: ${system.isAndroid}');
      _logger.info('════════════════════════════════════════');

      if (!enableRacing) {
        // 禁用竞速：等待核心就绪，直接使用 FlClash 核心的 Profile.update()
        _logger.info('📋 模式: 直接下载（竞速已禁用）');
        _logger.info('⏳ 等待核心就绪...');
        await _waitForCoreReady();

        _logger.info('🔄 创建 Profile 对象...');
        final profile = Profile.normal(url: url);

        _logger.info('📡 调用 Profile.update(forceDirect: true)...');
        final result = await profile.update(forceDirect: true);

        _logger.info('✅ 订阅下载成功');
        _logger.info('   URL: ${result.url}');
        _logger.info('   GroupName: ${result.currentGroupName}');
        _logger.info('════════════════════════════════════════');
        return result;
      }

      // 优化策略：并行执行竞速测试和核心初始化，最大化效率
      // 1. 启动竞速测试（不等待结果）
      // 2. 同时等待核心就绪
      // 3. 两者都完成后，使用核心下载配置

      final proxies = XBoardConfig.allProxyUrls;
      _logger.info('📋 模式: 并行竞速 + 核心初始化');
      _logger.info('🚀 竞速方式: 直连 + ${proxies.length}种代理 = ${proxies.length + 1}种方式');

      // 启动竞速测试（立即返回 Future，不等待）
      final racingFuture = _runConnectivityRacing(url, proxies);

      // 同时等待核心就绪（Android 上必需，Desktop 上立即返回）
      final coreReadyFuture = _waitForCoreReady();

      // 等待两个任务都完成（并行执行）
      _logger.info('⏳ 等待竞速测试和核心初始化完成...');
      final startWait = DateTime.now();
      await Future.wait([racingFuture, coreReadyFuture]);
      final waitElapsed = DateTime.now().difference(startWait).inMilliseconds;
      _logger.info('✅ 竞速和核心初始化完成 (${waitElapsed}ms)');

      // 核心已就绪，使用 FlClash 核心的 Profile.update() 下载完整配置
      // forceDirect: 绕过 Clash 代理直连下载，避免节点配置过期导致超时
      _logger.info('🔄 创建 Profile 对象...');
      final profile = Profile.normal(url: url);

      _logger.info('📡 调用 Profile.update(forceDirect: true)...');
      final startUpdate = DateTime.now();
      final result = await profile.update(forceDirect: true);
      final updateElapsed = DateTime.now().difference(startUpdate).inMilliseconds;

      _logger.info('✅ 订阅下载成功 (${updateElapsed}ms)');
      _logger.info('   URL: ${result.url}');
      _logger.info('   GroupName: ${result.currentGroupName}');
      _logger.info('════════════════════════════════════════');
      return result;

    } on TimeoutException catch (e) {
      _logger.error('❌ 订阅下载超时', e);
      _logger.error('   错误信息: ${e.message}');
      _logger.error('   💡 诊断: 可能是网络延迟、DNS 解析缓慢或服务器响应慢');
      _logger.error('   💡 建议: 检查网络连接、DNS 设置或尝试更换节点');
      throw Exception('下载超时: ${e.message}');
    } on SocketException catch (e) {
      _logger.error('❌ 网络连接异常', e);
      _logger.error('   错误码: ${e.osError?.errorCode}');
      _logger.error('   错误信息: ${e.message}');
      _logger.error('   💡 诊断: 网络不可达或连接被拒绝');
      _logger.error('   💡 建议: 检查网络连接、防火墙或 Clash 配置');
      throw Exception('网络连接失败: ${e.message}');
    } on HttpException catch (e) {
      _logger.error('❌ HTTP 请求异常', e);
      _logger.error('   错误信息: ${e.message}');
      _logger.error('   💡 诊断: HTTP 客户端或请求格式问题');
      throw Exception('HTTP 请求失败: ${e.message}');
    } catch (e, st) {
      _logger.error('❌ 订阅下载失败', e, st);
      _logger.error('   错误类型: ${e.runtimeType}');
      _logger.error('   错误信息: $e');

      // 识别常见错误模式
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('timeout')) {
        _logger.error('   💡 诊断: 这看起来像是超时错误');
      } else if (errorStr.contains('connection') || errorStr.contains('refuse')) {
        _logger.error('   💡 诊断: 这看起来像是连接错误');
      } else if (errorStr.contains('certificate')) {
        _logger.error('   💡 诊断: 这看起来像是 SSL 证书错误');
      } else if (errorStr.contains('validateconfig')) {
        _logger.error('   💡 诊断: 这看起来像是配置格式错误（核心验证失败）');
      }

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

      // 设置请求头
      final userAgent = await UserAgentConfig.get(UserAgentScenario.subscription);
      request.headers.set(HttpHeaders.userAgentHeader, userAgent);

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
