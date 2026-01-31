/// V2Board JSON → Domain Model 映射函数
///
/// 纯函数，将 V2Board v1.7.2 API 响应 JSON 映射为已有的领域模型
/// V2Board 金额单位为分（cents），需除以 100 转换为元
import 'package:fl_clash/xboard/domain/domain.dart';

// ================================================================
// User
// ================================================================

/// V2Board /api/v1/user/info → DomainUser
DomainUser mapUserInfo(Map<String, dynamic> json) {
  return DomainUser(
    email: json['email'] as String? ?? '',
    uuid: json['uuid'] as String? ?? '',
    avatarUrl: json['avatar_url'] as String? ?? '',
    planId: json['plan_id'] as int?,
    transferLimit: json['transfer_enable'] as int? ?? 0,
    uploadedBytes: json['u'] as int? ?? 0,
    downloadedBytes: json['d'] as int? ?? 0,
    balanceInCents: json['balance'] as int? ?? 0,
    commissionBalanceInCents: json['commission_balance'] as int? ?? 0,
    expiredAt: _parseTimestamp(json['expired_at']),
    lastLoginAt: _parseTimestamp(json['last_login_at']),
    createdAt: _parseTimestamp(json['created_at']),
    banned: (json['banned'] as int? ?? 0) == 1,
    remindExpire: (json['remind_expire'] as int? ?? 1) == 1,
    remindTraffic: (json['remind_traffic'] as int? ?? 1) == 1,
    discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
    commissionRate: json['commission_rate'] != null
        ? (json['commission_rate'] as num).toDouble() / 100.0
        : null,
    telegramId: json['telegram_id']?.toString(),
  );
}

// ================================================================
// Subscription
// ================================================================

/// V2Board /api/v1/user/getSubscribe → DomainSubscription
///
/// 需要额外传入 baseUrl 以构建订阅 URL
DomainSubscription mapSubscription(
  Map<String, dynamic> json, {
  required String baseUrl,
}) {
  final token = json['token'] as String? ?? '';
  final subscribeUrl = token.isNotEmpty
      ? '$baseUrl/api/v1/client/subscribe?token=$token'
      : '';

  return DomainSubscription(
    subscribeUrl: json['subscribe_url'] as String? ?? subscribeUrl,
    email: json['email'] as String? ?? '',
    uuid: json['uuid'] as String? ?? '',
    planId: json['plan_id'] as int? ?? 0,
    planName: json['plan']?['name'] as String?,
    token: token,
    transferLimit: json['transfer_enable'] as int? ?? 0,
    uploadedBytes: json['u'] as int? ?? 0,
    downloadedBytes: json['d'] as int? ?? 0,
    speedLimit: json['speed_limit'] as int?,
    deviceLimit: json['device_limit'] as int?,
    expiredAt: _parseTimestamp(json['expired_at']),
    nextResetAt: _parseTimestamp(json['reset_day']),
  );
}

// ================================================================
// Plan
// ================================================================

/// V2Board /api/v1/user/plan/fetch → DomainPlan
///
/// V2Board 价格以分（cents）为单位，需除以 100
DomainPlan mapPlan(Map<String, dynamic> json) {
  return DomainPlan(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    groupId: json['group_id'] as int? ?? 0,
    transferQuota: json['transfer_enable'] as int? ?? 0,
    description: json['content'] as String?,
    speedLimit: json['speed_limit'] as int?,
    deviceLimit: json['device_limit'] as int?,
    isVisible: (json['show'] as int? ?? 1) == 1,
    renewable: (json['renew'] as int? ?? 1) == 1,
    sort: json['sort'] as int?,
    onetimePrice: _centsToYuan(json['onetime_price']),
    monthlyPrice: _centsToYuan(json['month_price']),
    quarterlyPrice: _centsToYuan(json['quarter_price']),
    halfYearlyPrice: _centsToYuan(json['half_year_price']),
    yearlyPrice: _centsToYuan(json['year_price']),
    twoYearPrice: _centsToYuan(json['two_year_price']),
    threeYearPrice: _centsToYuan(json['three_year_price']),
    resetPrice: _centsToYuan(json['reset_price']),
    createdAt: _parseTimestamp(json['created_at']),
    updatedAt: _parseTimestamp(json['updated_at']),
  );
}

// ================================================================
// Order
// ================================================================

/// V2Board /api/v1/user/order/fetch → DomainOrder
///
/// V2Board total_amount 以分为单位
DomainOrder mapOrder(Map<String, dynamic> json) {
  return DomainOrder(
    tradeNo: json['trade_no'] as String? ?? '',
    planId: json['plan_id'] as int? ?? 0,
    period: json['period'] as String? ?? '',
    totalAmount: _centsToYuan(json['total_amount']) ?? 0.0,
    status: OrderStatus.fromCode(json['status'] as int? ?? 0),
    planName: json['plan']?['name'] as String?,
    createdAt: _parseTimestamp(json['created_at']) ?? DateTime.now(),
    paidAt: _parseTimestamp(json['paid_at']),
  );
}

// ================================================================
// Payment Method
// ================================================================

/// V2Board /api/v1/user/order/getPaymentMethod → DomainPaymentMethod
DomainPaymentMethod mapPaymentMethod(Map<String, dynamic> json) {
  return DomainPaymentMethod(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    iconUrl: json['icon'] as String?,
    feePercentage: (json['handling_fee_percent'] as num?)?.toDouble() ?? 0.0,
    isAvailable: true,
  );
}

// ================================================================
// Notice
// ================================================================

/// V2Board /api/v1/user/notice/fetch → DomainNotice
DomainNotice mapNotice(Map<String, dynamic> json) {
  return DomainNotice(
    id: json['id'] as int? ?? 0,
    title: json['title'] as String? ?? '',
    content: json['content'] as String? ?? '',
    imageUrls: _parseStringList(json['img_url']),
    tags: _parseStringList(json['tags']),
    createdAt: _parseTimestamp(json['created_at']) ?? DateTime.now(),
    updatedAt: _parseTimestamp(json['updated_at']),
  );
}

// ================================================================
// Ticket
// ================================================================

/// V2Board /api/v1/user/ticket/fetch → DomainTicket
DomainTicket mapTicket(Map<String, dynamic> json) {
  final messagesList = json['message'] as List<dynamic>? ?? [];
  return DomainTicket(
    id: json['id'] as int? ?? 0,
    subject: json['subject'] as String? ?? '',
    priority: json['level'] as int? ?? 1,
    status: TicketStatus.fromCode(json['status'] as int? ?? 0),
    messages: messagesList.map((m) {
      if (m is Map<String, dynamic>) {
        return TicketMessage(
          id: m['id'] as int? ?? 0,
          content: m['message'] as String? ?? '',
          isFromUser: (m['is_me'] as int? ?? 0) == 1,
          createdAt: _parseTimestamp(m['created_at']) ?? DateTime.now(),
        );
      }
      return TicketMessage(
        id: 0,
        content: m.toString(),
        createdAt: DateTime.now(),
      );
    }).toList(),
    createdAt: _parseTimestamp(json['created_at']) ?? DateTime.now(),
    updatedAt: _parseTimestamp(json['updated_at']),
  );
}

// ================================================================
// Invite
// ================================================================

/// V2Board /api/v1/user/invite/fetch → DomainInvite
///
/// V2Board 返回 {"data": {"codes": [...], "stat": [...]}}
DomainInvite mapInvite(Map<String, dynamic> json) {
  // codes 数组
  final codesList = json['codes'] as List<dynamic>? ?? [];
  final codes = codesList.map((c) {
    if (c is Map<String, dynamic>) {
      return DomainInviteCode(
        code: c['code'] as String? ?? '',
        status: c['status'] as int? ?? 0,
        createdAt: _parseTimestamp(c['created_at']),
      );
    }
    return DomainInviteCode(code: c.toString());
  }).toList();

  // stat 数组（佣金明细）
  final statList = json['stat'] as List<dynamic>? ?? [];
  int invitedCount = statList.length;
  double totalCommission = 0;
  double pendingCommission = 0;
  for (final s in statList) {
    if (s is Map<String, dynamic>) {
      final amount = (s['commission_balance'] as num?)?.toDouble() ?? 0;
      final status = s['commission_status'] as int? ?? 0;
      totalCommission += amount;
      if (status == 0) pendingCommission += amount;
    }
  }

  return DomainInvite(
    codes: codes,
    stats: InviteStats(
      invitedCount: invitedCount,
      totalCommission: totalCommission / 100.0,
      pendingCommission: pendingCommission / 100.0,
      availableCommission: (totalCommission - pendingCommission) / 100.0,
    ),
  );
}

/// V2Board 佣金明细 → DomainCommission
DomainCommission mapCommission(Map<String, dynamic> json) {
  return DomainCommission(
    id: json['id'] as int? ?? 0,
    tradeNo: json['trade_no'] as String? ?? '',
    amount: _centsToYuan(json['commission_balance']) ?? 0.0,
    createdAt: _parseTimestamp(json['created_at']) ?? DateTime.now(),
  );
}

// ================================================================
// Guest Config
// ================================================================

/// V2Board /api/v1/guest/comm/config → Map
/// 直接返回原始 Map，由 config_state 使用
Map<String, dynamic> mapGuestConfig(Map<String, dynamic> json) {
  return json;
}

// ================================================================
// 工具函数
// ================================================================

/// 分（int）→ 元（double?）
double? _centsToYuan(dynamic cents) {
  if (cents == null) return null;
  if (cents is int) return cents / 100.0;
  if (cents is double) return cents / 100.0;
  if (cents is String) {
    final parsed = double.tryParse(cents);
    return parsed != null ? parsed / 100.0 : null;
  }
  return null;
}

/// 解析时间戳（支持 int 秒级时间戳和 ISO 字符串）
DateTime? _parseTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    if (value == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

/// 解析字符串列表
List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  if (value is String && value.isNotEmpty) {
    return [value];
  }
  return [];
}

// ================================================================
// V2Board Order Cycle 映射
// ================================================================

/// Domain PlanPeriod → V2Board cycle 参数
String planPeriodToV2BoardCycle(PlanPeriod period) {
  return switch (period) {
    PlanPeriod.monthly => 'month_price',
    PlanPeriod.quarterly => 'quarter_price',
    PlanPeriod.halfYearly => 'half_year_price',
    PlanPeriod.yearly => 'year_price',
    PlanPeriod.twoYear => 'two_year_price',
    PlanPeriod.threeYear => 'three_year_price',
    PlanPeriod.onetime => 'onetime_price',
    PlanPeriod.reset => 'reset_price',
  };
}

/// V2Board cycle 参数 → Domain PlanPeriod
PlanPeriod v2BoardCycleToPlanPeriod(String cycle) {
  return switch (cycle) {
    'month_price' => PlanPeriod.monthly,
    'quarter_price' => PlanPeriod.quarterly,
    'half_year_price' => PlanPeriod.halfYearly,
    'year_price' => PlanPeriod.yearly,
    'two_year_price' => PlanPeriod.twoYear,
    'three_year_price' => PlanPeriod.threeYear,
    'onetime_price' => PlanPeriod.onetime,
    'reset_price' => PlanPeriod.reset,
    _ => PlanPeriod.monthly,
  };
}
