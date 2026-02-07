import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import '../xboard_database.dart';

/// XBoardOrderRow 与 DomainOrder 之间的转换扩展
extension XBoardOrderRowToDomain on XBoardOrderRow {
  /// 转换为领域模型
  DomainOrder toDomain() {
    return DomainOrder(
      tradeNo: tradeNo,
      planId: planId,
      period: period,
      totalAmount: totalAmount,
      status: OrderStatus.fromCode(statusCode),
      planName: planName,
      planContent: planContent,
      createdAt: createdAt,
      paidAt: paidAt,
      handlingAmount: handlingAmount,
      balanceAmount: balanceAmount,
      refundAmount: refundAmount,
      discountAmount: discountAmount,
      surplusAmount: surplusAmount,
      paymentId: paymentId,
      paymentName: paymentName,
      couponId: couponId,
      commissionStatus: commissionStatusCode != null
          ? OrderCommissionStatus.fromCode(commissionStatusCode!)
          : null,
      commissionBalance: commissionBalance,
      metadata: _parseMetadata(metadata),
    );
  }

  Map<String, dynamic> _parseMetadata(String metadataJson) {
    try {
      return Map<String, dynamic>.from(jsonDecode(metadataJson));
    } catch (_) {
      return {};
    }
  }
}

/// DomainOrder 转换为数据库 Companion
extension DomainOrderToCompanion on DomainOrder {
  /// 转换为数据库插入/更新对象
  XBoardOrdersCompanion toCompanion({
    required String email,
    DateTime? lastSyncedAt,
  }) {
    return XBoardOrdersCompanion(
      tradeNo: Value(tradeNo),
      email: Value(email),
      planId: Value(planId),
      period: Value(period),
      totalAmount: Value(totalAmount),
      statusCode: Value(status.code),
      planName: Value(planName),
      planContent: Value(planContent),
      createdAt: Value(createdAt),
      paidAt: Value(paidAt),
      handlingAmount: Value(handlingAmount),
      balanceAmount: Value(balanceAmount),
      refundAmount: Value(refundAmount),
      discountAmount: Value(discountAmount),
      surplusAmount: Value(surplusAmount),
      paymentId: Value(paymentId),
      paymentName: Value(paymentName),
      couponId: Value(couponId),
      commissionStatusCode: Value(commissionStatus?.code),
      commissionBalance: Value(commissionBalance),
      metadata: Value(jsonEncode(metadata)),
      lastSyncedAt: Value(lastSyncedAt ?? DateTime.now()),
    );
  }
}
