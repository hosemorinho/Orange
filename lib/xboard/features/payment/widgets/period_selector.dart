import 'package:flutter/material.dart';
import 'package:fl_clash/l10n/l10n.dart';
import '../utils/price_calculator.dart';

/// 周期选择器
class PeriodSelector extends StatelessWidget {
  final List<Map<String, dynamic>> periods;
  final String? selectedPeriod;
  final Function(String) onPeriodSelected;
  final int? couponType;
  final int? couponValue;

  const PeriodSelector({
    super.key,
    required this.periods,
    required this.selectedPeriod,
    required this.onPeriodSelected,
    this.couponType,
    this.couponValue,
  });

  @override
  Widget build(BuildContext context) {
    if (periods.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            AppLocalizations.of(context).xboardSelectPaymentPeriod,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (periods.length <= 2)
          _buildRowLayout(context)
        else
          _buildGridLayout(context),
      ],
    );
  }

  Widget _buildRowLayout(BuildContext context) {
    return Row(
      children: periods.map((period) {
        final isSelected = selectedPeriod == period['period'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _PeriodCard(
              period: period,
              isSelected: isSelected,
              onTap: () => onPeriodSelected(period['period']),
              couponType: couponType,
              couponValue: couponValue,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGridLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 3 : (screenWidth > 600 ? 3 : 2);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: periods.length,
      itemBuilder: (context, index) {
        final period = periods[index];
        final isSelected = selectedPeriod == period['period'];
        return _PeriodCard(
          period: period,
          isSelected: isSelected,
          onTap: () => onPeriodSelected(period['period']),
          couponType: couponType,
          couponValue: couponValue,
        );
      },
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final Map<String, dynamic> period;
  final bool isSelected;
  final VoidCallback onTap;
  final int? couponType;
  final int? couponValue;

  const _PeriodCard({
    required this.period,
    required this.isSelected,
    required this.onTap,
    this.couponType,
    this.couponValue,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final periodPrice = period['price']?.toDouble() ?? 0.0;
    final displayPrice = isSelected && couponType != null
        ? PriceCalculator.calculateFinalPrice(
            periodPrice,
            couponType,
            couponValue,
          )
        : periodPrice;

    final hasDiscount = isSelected &&
        couponType != null &&
        displayPrice < periodPrice;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  period['label'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                if (hasDiscount)
                  Column(
                    children: [
                      Text(
                        PriceCalculator.formatPrice(periodPrice),
                        style: TextStyle(
                          fontSize: 10,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: colorScheme.outline,
                          color: colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        PriceCalculator.formatPrice(displayPrice),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    PriceCalculator.formatPrice(periodPrice),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 12,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
