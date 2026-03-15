/// User-Agent 配置管理
///
/// 说明：不同的 User-Agent 是有意设计的，服务端会根据 UA 返回不同格式的数据
///
/// 使用场景：
/// 1. 订阅下载：使用 sing-box UA 获取 sing-box JSON 配置格式
/// 2. API/域名竞速：使用标准 UA
/// 3. 其他服务：使用特定版本号标识
library;

import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';

/// User-Agent 配置类
///
/// 订阅下载使用动态 UA（包含 sing-box 标识），其他场景使用固定 UA
///
/// 使用方式:
/// ```dart
/// final ua = UserAgentConfig.get(UserAgentScenario.subscription);
/// request.headers.set(HttpHeaders.userAgentHeader, ua);
/// ```
class UserAgentConfig {
  /// 获取订阅下载 UA（动态生成）
  /// 格式: appName/vVersion sing-box/1.13.3 Platform/xxx
  static String get _subscription {
    try {
      final info = globalState.packageInfo;
      return '$appNameEn/v${info.version} sing-box/1.13.3 Platform/${Platform.operatingSystem}';
    } catch (_) {
      return '$appNameEn sing-box/1.13.3 Platform/${Platform.operatingSystem}';
    }
  }

  static String get _subscriptionRacing {
    try {
      final info = globalState.packageInfo;
      return '$appNameEn/v${info.version} sing-box/1.13.3 Platform/${Platform.operatingSystem}';
    } catch (_) {
      return '$appNameEn sing-box/1.13.3 Platform/${Platform.operatingSystem}';
    }
  }

  static const String _attachment = 'sing-box/1.13.3';
  static const String _api = '$appNameEn/1.0 (V2Board API Client)';
  static const String _domainRacing = '$appNameEn/1.0 (Domain Racing Test)';

  /// 获取指定场景的 User-Agent
  ///
  /// [scenario] 使用场景
  /// 返回对应的 UA 字符串
  static String get(UserAgentScenario scenario) {
    return switch (scenario) {
      UserAgentScenario.subscription => _subscription,
      UserAgentScenario.api => _api,
      UserAgentScenario.subscriptionRacing => _subscriptionRacing,
      UserAgentScenario.domainRacingTest => _domainRacing,
      UserAgentScenario.attachment => _attachment,
    };
  }

  /// 批量获取所有 User-Agent
  static Map<String, String> getAll() {
    return {
      'subscription': _subscription,
      'api': _api,
      'subscription_racing': _subscriptionRacing,
      'domain_racing_test': _domainRacing,
      'attachment': _attachment,
    };
  }
}

/// User-Agent 使用场景枚举
enum UserAgentScenario {
  /// 订阅下载（sing-box JSON 格式）
  subscription,

  /// API 请求
  api,

  /// 并发订阅竞速
  subscriptionRacing,

  /// 域名竞速测试
  domainRacingTest,

  /// 消息附件下载
  attachment,
}
