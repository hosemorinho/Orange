/// User-Agent 配置管理
///
/// 说明：不同的 User-Agent 是有意设计的，服务端会根据 UA 返回不同格式的数据
///
/// 使用场景：
/// 1. 订阅下载：必须使用 'FlClash' 才能获取 Clash 配置格式（硬编码）
/// 2. API/域名竞速：使用标准 UA（硬编码）
/// 3. 其他服务：使用特定版本号标识（硬编码）
library;

/// User-Agent 配置类
///
/// 所有 UA 使用硬编码，V2Board 不需要特殊认证
///
/// 使用方式:
/// ```dart
/// final ua = UserAgentConfig.get(UserAgentScenario.subscription);
/// request.headers.set(HttpHeaders.userAgentHeader, ua);
/// ```
class UserAgentConfig {
  // 硬编码的 User-Agent
  static const String _subscription = 'FlClash';
  static const String _subscriptionRacing = 'FlClash/1.0 (V2Board Race Subscription Client)';
  static const String _attachment = 'FlClash/1.0';
  static const String _api = 'FlClash/1.0 (V2Board API Client)';
  static const String _domainRacing = 'FlClash/1.0 (Domain Racing Test)';

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
  /// 订阅下载（硬编码：'FlClash'）
  subscription,

  /// API 请求/域名竞速（硬编码：'FlClash/1.0 (V2Board API Client)'）
  api,

  /// 并发订阅竞速（硬编码：'FlClash/1.0 (V2Board Race Subscription Client)'）
  subscriptionRacing,

  /// 域名竞速测试（硬编码：'FlClash/1.0 (Domain Racing Test)'）
  domainRacingTest,

  /// 消息附件下载（硬编码：'FlClash/1.0'）
  attachment,
}
