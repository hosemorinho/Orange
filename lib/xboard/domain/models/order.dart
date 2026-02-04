import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/order.freezed.dart';
part 'generated/order.g.dart';

/// 领域层：订单模型
@freezed
abstract class DomainOrder with _$DomainOrder {
  const factory DomainOrder({
    /// 订单号（交易号）
    required String tradeNo,

    /// 套餐 ID
    required int planId,

    /// 周期类型
    required String period,

    /// 订单金额（元）
    required double totalAmount,

    /// 订单状态
    required OrderStatus status,

    /// 套餐名称（可选）
    String? planName,

    /// 套餐内容（HTML，可选）
    String? planContent,

    /// 创建时间
    required DateTime createdAt,

    /// 支付时间
    DateTime? paidAt,

    /// 手续费（元）
    @Default(0) double handlingAmount,

    /// 余额支付金额（元）
    @Default(0) double balanceAmount,

    /// 退款金额（元）
    @Default(0) double refundAmount,

    /// 折扣金额（元）
    @Default(0) double discountAmount,

    /// 剩余金额（元）
    @Default(0) double surplusAmount,

    /// 支付方式 ID
    int? paymentId,

    /// 支付方式名称
    String? paymentName,

    /// 优惠券 ID
    int? couponId,

    /// 佣金状态
    OrderCommissionStatus? commissionStatus,

    /// 佣金余额（元）
    @Default(0) double commissionBalance,

    /// 元数据
    @Default({}) Map<String, dynamic> metadata,
  }) = _DomainOrder;

  factory DomainOrder.fromJson(Map<String, dynamic> json) => 
    _$DomainOrderFromJson(json);

  // ========== 业务逻辑 ==========

  /// 是否待支付
  bool get isPending => status == OrderStatus.pending;

  /// 是否已完成
  bool get isCompleted => status == OrderStatus.completed;

  /// 是否已取消
  bool get isCanceled => status == OrderStatus.canceled;

  /// 是否正在处理
  bool get isProcessing => status == OrderStatus.processing;

  /// 是否可以支付
  bool get canPay => status == OrderStatus.pending;

  /// 是否可以取消（待付款和开通中的订单都可以取消）
  bool get canCancel => status == OrderStatus.pending || status == OrderStatus.processing;

  /// 是否需要在创建新订单前自动取消（后端要求）
  bool get shouldAutoCancelBeforeNewOrder => canCancel;
}

/// 订单状态枚举
enum OrderStatus {
  /// 待支付
  pending(0, 'xboardOrderStatusPending'),

  /// 开通中
  processing(1, 'xboardOrderStatusProcessing'),

  /// 已取消
  canceled(2, 'xboardOrderStatusCanceled'),

  /// 已完成
  completed(3, 'xboardOrderStatusCompleted'),

  /// 已折抵
  discounted(4, 'xboardOrderStatusDiscounted');

  const OrderStatus(this.code, this.labelKey);

  final int code;
  final String labelKey; // Changed from label to labelKey for i18n

  static OrderStatus fromCode(int code) {
    return OrderStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => OrderStatus.pending,
    );
  }
}

/// 佣金状态枚举
enum OrderCommissionStatus {
  /// 待确认
  pending(0, 'xboardCommissionStatusPending'),

  /// 发放中
  processing(1, 'xboardCommissionStatusProcessing'),

  /// 已发放
  completed(2, 'xboardCommissionStatusCompleted'),

  /// 无佣金
  none(3, 'xboardCommissionStatusNone');

  const OrderCommissionStatus(this.code, this.labelKey);

  final int code;
  final String labelKey; // Changed from label to labelKey for i18n

  static OrderCommissionStatus fromCode(int code) {
    return OrderCommissionStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => OrderCommissionStatus.pending,
    );
  }
}
