import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fl_clash/common/num.dart';

part 'generated/subscription.freezed.dart';
part 'generated/subscription.g.dart';

/// 领域层：订阅模型
@freezed
abstract class DomainSubscription with _$DomainSubscription {
  const factory DomainSubscription({
    /// 订阅 URL
    required String subscribeUrl,
    
    /// 用户邮箱
    required String email,
    
    /// UUID
    required String uuid,
    
    /// 套餐 ID
    required int planId,
    
    /// 套餐名称
    String? planName,
    
    /// Token
    String? token,
    
    /// 总流量限制（字节）
    required int transferLimit,
    
    /// 已用上传（字节）
    required int uploadedBytes,
    
    /// 已用下载（字节）
    required int downloadedBytes,
    
    /// 速度限制（Mbps）
    int? speedLimit,
    
    /// 设备数量限制
    int? deviceLimit,
    
    /// 过期时间
    DateTime? expiredAt,
    
    /// 下次重置时间
    DateTime? nextResetAt,
    
    /// 元数据
    @Default({}) Map<String, dynamic> metadata,
  }) = _DomainSubscription;

  factory DomainSubscription.fromJson(Map<String, dynamic> json) => 
    _$DomainSubscriptionFromJson(json);
}

/// DomainSubscription 扩展方法
extension DomainSubscriptionX on DomainSubscription {
  // ========== 业务逻辑 ==========

  /// 已用流量总计（字节）
  int get totalUsedBytes => uploadedBytes + downloadedBytes;

  /// 剩余流量（字节）
  int get remainingBytes {
    final remaining = transferLimit - totalUsedBytes;
    return remaining > 0 ? remaining : 0;
  }

  /// 流量使用百分比（0-100）
  double get usagePercentage {
    if (transferLimit == 0) return 0;
    return (totalUsedBytes / transferLimit * 100).clamp(0, 100);
  }

  /// 是否流量耗尽
  bool get isTrafficExhausted => remainingBytes == 0;

  /// 是否已过期
  bool get isExpired {
    if (expiredAt == null) return false;
    return DateTime.now().isAfter(expiredAt!);
  }

  /// 剩余天数
  int? get daysRemaining {
    if (expiredAt == null) return null;
    final remaining = expiredAt!.difference(DateTime.now()).inDays;
    return remaining >= 0 ? remaining : 0;
  }

  /// 是否即将过期（7天内）
  bool get isExpiringSoon {
    final days = daysRemaining;
    return days != null && days <= 7 && days > 0;
  }

  /// 剩余流量（格式化）
  String get formattedRemainingTraffic {
    final trafficShow = remainingBytes.traffic;
    return '${trafficShow.value} ${trafficShow.unit}';
  }

  /// 已用流量（格式化）
  String get formattedUsedTraffic {
    final trafficShow = totalUsedBytes.traffic;
    return '${trafficShow.value} ${trafficShow.unit}';
  }

  /// 总流量（格式化）
  String get formattedTotalTraffic {
    final trafficShow = transferLimit.traffic;
    return '${trafficShow.value} ${trafficShow.unit}';
  }

  /// 上传流量（格式化）
  String get formattedUploadedTraffic {
    final trafficShow = uploadedBytes.traffic;
    return '${trafficShow.value} ${trafficShow.unit}';
  }

  /// 下载流量（格式化）
  String get formattedDownloadedTraffic {
    final trafficShow = downloadedBytes.traffic;
    return '${trafficShow.value} ${trafficShow.unit}';
  }
}
