import 'package:flutter/material.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/domain/domain.dart';

/// Order confirmation dialog shown before final payment submission.
/// Displays plan info, price breakdown, and payment method details.
class OrderConfirmDialog extends StatelessWidget {
  final DomainPlan plan;
  final String periodLabel;
  final double basePrice;
  final double? couponDiscount;
  final DomainPaymentMethod? paymentMethod;
  final double totalAmount;

  const OrderConfirmDialog._({
    required this.plan,
    required this.periodLabel,
    required this.basePrice,
    this.couponDiscount,
    this.paymentMethod,
    required this.totalAmount,
  });

  /// Shows the order confirmation dialog.
  /// Returns `true` to confirm, `false` to cancel.
  static Future<bool> show(
    BuildContext context, {
    required DomainPlan plan,
    required String periodLabel,
    required double basePrice,
    double? couponDiscount,
    DomainPaymentMethod? paymentMethod,
    required double totalAmount,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => OrderConfirmDialog._(
        plan: plan,
        periodLabel: periodLabel,
        basePrice: basePrice,
        couponDiscount: couponDiscount,
        paymentMethod: paymentMethod,
        totalAmount: totalAmount,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final fee = paymentMethod != null
        ? paymentMethod!.calculateFee(
            basePrice - (couponDiscount ?? 0),
          )
        : 0.0;

    return AlertDialog(
      title: Text(l10n.xboardConfirmOrder),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan info
            _SectionHeader(label: l10n.xboardPlanSummary, colorScheme: colorScheme),
            const SizedBox(height: 8),
            _InfoRow(label: plan.name, value: periodLabel),
            const SizedBox(height: 16),

            // Payment summary
            _SectionHeader(label: l10n.xboardPaymentSummary, colorScheme: colorScheme),
            const SizedBox(height: 8),
            _PriceRow(
              label: l10n.xboardBasePrice,
              amount: basePrice,
            ),
            if (couponDiscount != null && couponDiscount! > 0)
              _PriceRow(
                label: l10n.xboardCouponDiscount,
                amount: -couponDiscount!,
                color: colorScheme.tertiary,
              ),
            if (fee > 0)
              _PriceRow(
                label: l10n.xboardProcessingFee,
                amount: fee,
              ),
            const Divider(height: 24),
            _PriceRow(
              label: l10n.xboardTotal,
              amount: totalAmount,
              color: colorScheme.primary,
              bold: true,
            ),

            // Payment method
            if (paymentMethod != null) ...[
              const SizedBox(height: 16),
              _SectionHeader(label: l10n.xboardPaymentMethod, colorScheme: colorScheme),
              const SizedBox(height: 8),
              Text(
                paymentMethod!.name,
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.xboardConfirmAndPay),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final ColorScheme colorScheme;

  const _SectionHeader({required this.label, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color? color;
  final bool bold;

  const _PriceRow({
    required this.label,
    required this.amount,
    this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
          Text(
            '${amount < 0 ? '-' : ''}¥${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
