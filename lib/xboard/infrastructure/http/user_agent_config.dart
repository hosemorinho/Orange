/// User-Agent 配置管理
///
/// 所有 UA 基于 globalState.packageInfo.ua 动态生成：
///   "{appName}/v{version} clash-verge Platform/{os}"
/// 例如: "Orange/v1.0.0 clash-verge Platform/android"
///
/// V2Board 识别 UA 中的 "clash-verge" 关键字，返回 Clash YAML 格式配置。
/// appName 由 --dart-define=APP_NAME 指定，自定义后 UA 自动更新。
library;

import 'package:fl_clash/state.dart';

/// User-Agent 配置类
///
/// 使用方式:
/// ```dart
/// final ua = UserAgentConfig.get(UserAgentScenario.subscription);
/// request.headers.set(HttpHeaders.userAgentHeader, ua);
/// ```
class UserAgentConfig {
  /// 基础 UA: "{appName}/v{version} clash-verge Platform/{os}"
  /// 来自 globalState.packageInfo.ua (在 main() 的 globalState.init() 中初始化)
  static String get _baseUa => globalState.packageInfo.ua;

  /// 获取指定场景的 User-Agent
  static String get(UserAgentScenario scenario) {
    return switch (scenario) {
      UserAgentScenario.subscription => _baseUa,
      UserAgentScenario.api => '$_baseUa (V2Board API Client)',
      UserAgentScenario.subscriptionRacing => '$_baseUa (V2Board Race Subscription Client)',
      UserAgentScenario.domainRacingTest => '$_baseUa (Domain Racing Test)',
      UserAgentScenario.attachment => _baseUa,
    };
  }

  /// 批量获取所有 User-Agent
  static Map<String, String> getAll() {
    return {
      'subscription': get(UserAgentScenario.subscription),
      'api': get(UserAgentScenario.api),
      'subscription_racing': get(UserAgentScenario.subscriptionRacing),
      'domain_racing_test': get(UserAgentScenario.domainRacingTest),
      'attachment': get(UserAgentScenario.attachment),
    };
  }
}

/// User-Agent 使用场景枚举
enum UserAgentScenario {
  /// 订阅下载
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
