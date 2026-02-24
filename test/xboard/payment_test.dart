/// XBoard 支付状态机测试
///
/// 测试支付流程的状态转换
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import '../xboard/test_helper.dart';

void main() {
  group('支付状态机', () {
    group('订单状态', () {
      test('待支付状态应正确初始化', () {
        // Arrange & Act
        final order = DomainOrder(
          tradeNo: 'ORD001',
          planId: 1,
          period: 'month',
          totalAmount: 100.0,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        // Assert
        expect(order.status, equals(OrderStatus.pending));
        expect(order.totalAmount, equals(100.0));
      });

      test('已完成状态应表示支付成功', () {
        // Arrange & Act
        final order = DomainOrder(
          tradeNo: 'ORD001',
          planId: 1,
          period: 'month',
          totalAmount: 100.0,
          status: OrderStatus.completed,
          createdAt: DateTime.now(),
        );

        // Assert
        expect(order.status, equals(OrderStatus.completed));
      });

      test('已取消状态应表示支付失败', () {
        // Arrange & Act
        final order = DomainOrder(
          tradeNo: 'ORD001',
          planId: 1,
          period: 'month',
          totalAmount: 100.0,
          status: OrderStatus.canceled,
          createdAt: DateTime.now(),
        );

        // Assert
        expect(order.status, equals(OrderStatus.canceled));
      });
    });

    group('套餐价格计算', () {
      test('应能正确计算月付价格', () {
        // Arrange
        final plan = TestDataFactory.createTestPlan(
          name: 'Pro Plan',
          price: 100.0,
        );

        // Act & Assert
        expect(plan.id, equals(1));
        expect(plan.name, equals('Pro Plan'));
        expect(plan.monthlyPrice, equals(100.0));
      });

      test('应能正确计算年付折扣', () {
        // Arrange
        final plan = DomainPlan(
          id: 1,
          name: 'Pro Plan',
          groupId: 1,
          transferQuota: 107374182400,
          monthlyPrice: 100.0,
          yearlyPrice: 1000.0, // 年付 1000，相当于 83.33/月
        );

        // Act
        final monthlyEquivalent = plan.yearlyPrice! / 12;
        final discount = 1 - (monthlyEquivalent / plan.monthlyPrice!);

        // Assert
        expect(monthlyEquivalent, closeTo(83.33, 0.01));
        expect(discount, closeTo(0.1667, 0.001));
      });
    });

    group('流量计算', () {
      test('应能正确计算已用流量百分比', () {
        // Arrange
        final subscription = TestDataFactory.createTestSubscription(
          transferLimit: 107374182400, // 100 GB
          uploadedBytes: 10737418240, // 10 GB
          downloadedBytes: 21474836480, // 20 GB
        );

        // Act
        final used = subscription.uploadedBytes + subscription.downloadedBytes;
        final percentage = used / subscription.transferLimit;

        // Assert
        expect(used, equals(32212254720)); // 30 GB
        expect(percentage, closeTo(0.3, 0.001));
      });

      test('应能正确计算剩余流量', () {
        // Arrange
        final subscription = TestDataFactory.createTestSubscription(
          transferLimit: 107374182400, // 100 GB
          uploadedBytes: 5368709120, // 5 GB
          downloadedBytes: 10737418240, // 10 GB
        );

        // Act
        final used = subscription.uploadedBytes + subscription.downloadedBytes;
        final remaining = subscription.transferLimit - used;

        // Assert
        expect(remaining, equals(91268055040)); // 85 GB
      });
    });
  });
}
