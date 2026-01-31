import 'config_entry.dart';

/// 订阅URL信息
/// V2Board subscription format: {baseUrl}/api/v1/client/subscribe?token={token}
class SubscriptionUrlInfo extends ConfigEntry {
  const SubscriptionUrlInfo({
    required super.url,
    required super.description,
  });

  /// 从JSON创建订阅URL信息
  factory SubscriptionUrlInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionUrlInfo(
      url: json['url'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  /// 构建完整的订阅URL
  /// V2Board format: {baseUrl}/api/v1/client/subscribe?token={token}&flag=flclash
  String buildSubscriptionUrl(String token) {
    final baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    return '$baseUrl/api/v1/client/subscribe?token=$token&flag=flclash';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'SubscriptionUrlInfo(url: $url)';
  }
}

/// 订阅配置信息
class SubscriptionInfo {
  final List<SubscriptionUrlInfo> urls;

  const SubscriptionInfo({
    required this.urls,
  });

  /// 从JSON创建订阅配置
  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    final urlsList = json['urls'] as List<dynamic>? ?? [];

    return SubscriptionInfo(
      urls: urlsList
          .map((item) => SubscriptionUrlInfo.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 获取第一个可用的订阅URL
  String? get firstUrl {
    return urls.isNotEmpty ? urls.first.url : null;
  }

  /// 构建订阅URL (V2Board format)
  String? buildSubscriptionUrl(String token) {
    if (urls.isEmpty) return null;
    return urls.first.buildSubscriptionUrl(token);
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'urls': urls.map((url) => url.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'SubscriptionInfo(urls: ${urls.length})';
  }
}
