import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/features/shared/widgets/xb_dashboard_card.dart';
import 'package:flutter/material.dart';
import '../utils/price_calculator.dart';
import 'plan_description_widget.dart';

/// Plan card component
///
/// Features:
/// - Header with plan name
/// - Feature list with checkmarks
/// - Purchase button
/// - Hover effects on desktop
class PlanCard extends StatefulWidget {
  final DomainPlan plan;
  final VoidCallback onPurchase;

  const PlanCard({
    super.key,
    required this.plan,
    required this.onPurchase,
  });

  @override
  State<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
  bool _isHovered = false;

  String _formatTraffic(double transferEnable) {
    return PriceCalculator.formatTraffic(transferEnable);
  }

  String _getLowestPrice(DomainPlan plan) {
    List<double> prices = [];
    if (plan.monthlyPrice != null) prices.add(plan.monthlyPrice!);
    if (plan.quarterlyPrice != null) prices.add(plan.quarterlyPrice!);
    if (plan.halfYearlyPrice != null) prices.add(plan.halfYearlyPrice!);
    if (plan.yearlyPrice != null) prices.add(plan.yearlyPrice!);
    if (plan.twoYearPrice != null) prices.add(plan.twoYearPrice!);
    if (plan.threeYearPrice != null) prices.add(plan.threeYearPrice!);
    if (plan.onetimePrice != null) prices.add(plan.onetimePrice!);
    if (prices.isEmpty) return '-';
    final lowestPrice = prices.reduce((a, b) => a < b ? a : b);
    return PriceCalculator.formatPrice(lowestPrice);
  }

  String _getSpeedLimitText(BuildContext context) {
    if (widget.plan.speedLimit == null) {
      return AppLocalizations.of(context).xboardUnlimited;
    }
    return '${widget.plan.speedLimit} Mbps';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final plan = widget.plan;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: XBDashboardCard(
          padding: EdgeInsets.zero,
          borderColor: _isHovered
              ? colorScheme.outline.withValues(alpha: 0.4)
              : colorScheme.outline.withValues(alpha: 0.2),
          shadows: _isHovered
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with plan name and price
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        plan.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (plan.hasPrice)
                      Text(
                        _getLowestPrice(plan),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),

              // Features section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Traffic
                    _buildFeatureItem(
                      context,
                      Icons.cloud_download_outlined,
                      '${AppLocalizations.of(context).xboardTraffic}: ${_formatTraffic(plan.transferQuota.toDouble())}',
                    ),
                    const SizedBox(height: 12),

                    // Speed limit
                    _buildFeatureItem(
                      context,
                      Icons.speed,
                      '${AppLocalizations.of(context).xboardSpeedLimit}: ${_getSpeedLimitText(context)}',
                    ),
                    const SizedBox(height: 12),

                    // Unlimited devices
                    _buildFeatureItem(
                      context,
                      Icons.devices,
                      '不限设备数量',
                    ),

                    // Description (if exists)
                    if (plan.description != null) ...[
                      const SizedBox(height: 16),
                      Divider(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: 16),
                      PlanDescriptionWidget(content: plan.description!),
                    ],
                  ],
                ),
              ),

              const Spacer(),

              // Purchase button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: widget.onPurchase,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context).xboardBuyNow,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle,
          size: 20,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
          ),
        ),
      ],
    );
  }
}
