import 'package:fl_clash/common/constant.dart' show apiBaseUrl, apiTextDomain, appName;
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/config/xboard_config.dart';
import 'package:fl_clash/xboard/infrastructure/infrastructure.dart';
// SDK通过Provider自动初始化

// 初始化文件级日志器
final _logger = FileLogger('domain_status_service.dart');


/// 域名状态服务
/// 
/// 负责域名检测、状态管理和XBoard服务初始化
class DomainStatusService {
  // 使用V2配置模块
  bool _isInitialized = false;

  /// 初始化服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _logger.info('开始初始化');
      
      // 确保V2配置模块已初始化
      if (!XBoardConfig.isInitialized) {
        await XBoardConfig.initialize();
      }

      _logger.info('V2配置模块初始化成功');

      _isInitialized = true;
      _logger.info('初始化完成');
    } catch (e) {
      _logger.error('初始化失败', e);
      rethrow;
    }
  }

  /// 检查域名状态
  Future<Map<String, dynamic>> checkDomainStatus() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // PATH 1: apiTextDomain 已配置 - 解析 TXT 记录并竞速
      if (apiTextDomain.isNotEmpty) {
        _logger.info('检测到 API_TEXT_DOMAIN: $apiTextDomain');
        return await _checkWithTxtResolution();
      }

      // PATH 2: 仅 apiBaseUrl 配置 - 直接使用
      if (apiBaseUrl.isNotEmpty) {
        _logger.info('使用环境变量 API 地址，跳过域名竞速: $apiBaseUrl');
        await _initializeXBoardService(apiBaseUrl);
        return {
          'success': true,
          'domain': apiBaseUrl,
          'latency': 0,
          'availableDomains': [apiBaseUrl],
          'message': null,
        };
      }

      // PATH 3: 都没配置 - 使用配置文件中的域名竞速
      _logger.info('开始检查域名状态（配置文件）');

      final startTime = DateTime.now();
      final bestDomain = await XBoardConfig.getFastestPanelUrl();
      final availableDomains = XBoardConfig.allPanelUrls;
      final endTime = DateTime.now();
      final latency = endTime.difference(startTime).inMilliseconds;

      if (bestDomain != null && bestDomain.isNotEmpty) {
        // 保存候选列表供 DomainPool 使用
        XBoardConfig.setLastRacingCandidates(availableDomains);
        await _initializeXBoardService(bestDomain);
        _logger.info('域名检查成功: $bestDomain (${latency}ms)');

        return {
          'success': true,
          'domain': bestDomain,
          'latency': latency,
          'availableDomains': availableDomains,
          'message': null,
        };
      } else {
        _logger.warning('未找到可用域名');
        return {
          'success': false,
          'domain': null,
          'latency': latency,
          'availableDomains': <String>[],
          'message': '无法获取可用域名',
        };
      }
    } catch (e) {
      _logger.error('域名检查失败', e);
      return {
        'success': false,
        'domain': null,
        'latency': null,
        'availableDomains': <String>[],
        'message': '域名检查失败: $e',
      };
    }
  }

  /// 通过 TXT 解析检查域名（PATH 1）
  Future<Map<String, dynamic>> _checkWithTxtResolution() async {
    _logger.info('[TXT] 开始解析 API_TEXT_DOMAIN: $apiTextDomain');

    try {
      // 1. 解析 TXT 记录
      final config = await ApiTextResolver.resolve(apiTextDomain, appName);

      if (config == null) {
        _logger.warning('[TXT] 解析失败，尝试回退方案');
        return await _fallbackAfterTxtFailure();
      }

      _logger.info('[TXT] 解析成功: ${config.hosts.length} 个主机');

      // 2. 合并 TXT 解析的 hosts 和 API_BASE_URL
      final hostsToRace = <String>[...config.hosts];
      if (apiBaseUrl.isNotEmpty && !hostsToRace.contains(apiBaseUrl)) {
        hostsToRace.add(apiBaseUrl);
        _logger.info('[TXT] 添加 API_BASE_URL 到竞速列表: $apiBaseUrl');
      }

      // 3. 域名竞速
      final startTime = DateTime.now();
      final result = await _raceHosts(hostsToRace);
      final endTime = DateTime.now();
      final latency = endTime.difference(startTime).inMilliseconds;

      if (result != null) {
        // 竞速成功，保存结果和候选列表到 XBoardConfig
        XBoardConfig.setLastRacingResult(result);
        XBoardConfig.setLastRacingCandidates(hostsToRace);

        await _initializeXBoardService(result.domain);
        _logger.info('[TXT] 域名竞速成功: ${result.domain} (${latency}ms)');

        return {
          'success': true,
          'domain': result.domain,
          'latency': latency,
          'availableDomains': hostsToRace,
          'message': null,
        };
      } else {
        _logger.warning('[TXT] 域名竞速失败，尝试回退方案');
        return await _fallbackAfterTxtFailure();
      }
    } catch (e) {
      _logger.error('[TXT] 处理失败', e);
      return await _fallbackAfterTxtFailure();
    }
  }

  /// TXT 解析失败后的回退方案
  Future<Map<String, dynamic>> _fallbackAfterTxtFailure() async {
    // 如果有 API_BASE_URL，直接使用
    if (apiBaseUrl.isNotEmpty) {
      _logger.info('[TXT回退] 使用 API_BASE_URL: $apiBaseUrl');
      await _initializeXBoardService(apiBaseUrl);
      return {
        'success': true,
        'domain': apiBaseUrl,
        'latency': 0,
        'availableDomains': [apiBaseUrl],
        'message': 'TXT 解析失败，使用环境变量',
      };
    }

    // 否则使用配置文件中的域名
    _logger.info('[TXT回退] 使用配置文件域名');
    final bestDomain = await XBoardConfig.getFastestPanelUrl();
    final availableDomains = XBoardConfig.allPanelUrls;

    if (bestDomain != null && bestDomain.isNotEmpty) {
      await _initializeXBoardService(bestDomain);
      return {
        'success': true,
        'domain': bestDomain,
        'latency': 0,
        'availableDomains': availableDomains,
        'message': 'TXT 解析失败，使用配置文件',
      };
    }

    // 所有方案都失败
    _logger.error('[TXT回退] 所有方案都失败');
    return {
      'success': false,
      'domain': null,
      'latency': null,
      'availableDomains': <String>[],
      'message': 'TXT 解析失败且无可用域名',
    };
  }

  /// 竞速多个主机
  Future<DomainRacingResult?> _raceHosts(List<String> hosts) async {
    if (hosts.isEmpty) return null;

    _logger.info('[竞速] 开始测试 ${hosts.length} 个主机');

    // 获取所有代理配置
    final proxyUrls = XBoardConfig.allProxyUrls;

    // 调用 DomainRacingService 进行竞速
    final result = await DomainRacingService.raceSelectFastestDomain(
      hosts,
      forceHttpsResult: true,
      proxyUrls: proxyUrls,
    );

    return result;
  }

  /// 刷新域名缓存
  Future<void> refreshDomainCache() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _logger.info('刷新域名缓存');
      // 使用config_v2刷新配置
      await XBoardConfig.refresh();
    } catch (e) {
      _logger.error('刷新缓存失败', e);
      rethrow;
    }
  }

  /// 验证特定域名
  Future<bool> validateDomain(String domain) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _logger.info('验证域名: $domain');
      // 简化验证：检查域名是否在可用列表中
      final availableDomains = XBoardConfig.allPanelUrls;
      return availableDomains.contains(domain);
    } catch (e) {
      _logger.error('域名验证失败', e);
      return false;
    }
  }

  /// 获取统计信息
  Map<String, dynamic> getStatistics() {
    return XBoardConfig.stats;
  }

  /// 初始化XBoard服务
  Future<void> _initializeXBoardService(String domain) async {
    try {
      _logger.info('初始化XBoard服务: $domain');
      // SDK现在通过Provider自动初始化，无需手动调用
      // 域名竞速结果会被XBoardConfig记录，SDK Provider会自动使用
      _logger.info('XBoard服务将在需要时自动初始化');
    } catch (e) {
      _logger.error('XBoard服务检查失败', e);
      // 不抛出异常，因为域名检查已经成功
    }
  }

  /// 释放资源
  void dispose() {
    _logger.info('释放资源');
    _isInitialized = false;
  }
}