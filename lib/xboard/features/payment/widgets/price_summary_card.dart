import 'package:flutter/material.dart';
import 'package:fl_clash/l10n/l10n.dart';
import '../utils/price_calculator.dart';

/// 价格汇总卡片
class PriceSummaryCard extends StatelessWidget {
  final double originalPrice;
  final double? finalPrice;
  final double? discountAmount;
  final double? userBalance;
  final double? handlingFee;

  const PriceSummaryCard({
    super.key,
    required this.originalPrice,
    this.finalPrice,
    this.discountAmount,
    this.userBalance,
    this.handlingFee,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final displayFinalPrice = finalPrice ?? originalPrice;
    final hasDiscount = discountAmount != null && discountAmount! > 0;
    final hasBalance = userBalance != null && userBalance! > 0;
    final hasFee = handlingFee != null && handlingFee! > 0;

    // 计算余额抵扣
    final balanceToUse = hasBalance
        ? (userBalance! > displayFinalPrice ? displayFinalPrice : userBalance!)
        : 0.0;
    final actualPayAmount = displayFinalPrice - balanceToUse + (handlingFee ?? 0.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.xboardOrderSummary,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Subtotal
              _PriceRow(
                label: l10n.xboardSubtotal,
                price: originalPrice,
                colorScheme: colorScheme,
              ),

              // Discount
              if (hasDiscount) ...[
                const SizedBox(height: 8),
                _PriceRow(
                  label: l10n.xboardDiscount,
                  price: discountAmount!,
                  isDiscount: true,
                  colorScheme: colorScheme,
                ),
              ],

              // Handling fee
              if (hasFee) ...[
                const SizedBox(height: 8),
                _PriceRow(
                  label: l10n.xboardHandlingFee,
                  price: handlingFee!,
                  colorScheme: colorScheme,
                ),
              ],

              // Divider before total
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),

              // Total
              _FinalPriceRow(
                label: l10n.xboardTotal,
                price: actualPayAmount,
                balanceDeducted: balanceToUse > 0 ? balanceToUse : null,
                remainingBalance: hasBalance && userBalance! > displayFinalPrice
                    ? userBalance! - displayFinalPrice
                    : null,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double price;
  final bool isDiscount;
  final ColorScheme colorScheme;

  const _PriceRow({
    required this.label,
    required this.price,
    required this.colorScheme,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDiscount
                ? colorScheme.tertiary
                : colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          isDiscount
              ? '-${PriceCalculator.formatPrice(price)}'
              : PriceCalculator.formatPrice(price),
          style: TextStyle(
            fontSize: 13,
            fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
            color: isDiscount
                ? colorScheme.tertiary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _FinalPriceRow extends StatelessWidget {
  final String label;
  final double price;
  final double? balanceDeducted;
  final double? remainingBalance;
  final ColorScheme colorScheme;

  const _FinalPriceRow({
    required this.label,
    required this.price,
    required this.colorScheme,
    this.balanceDeducted,
    this.remainingBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          PriceCalculator.formatPrice(price),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
