import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/features/shared/widgets/xb_dashboard_card.dart';
import 'package:flutter/material.dart';
import '../utils/price_calculator.dart';
import 'plan_description_widget.dart';

/// Modern plan card component matching frontend design
///
/// Features:
/// - Header with plan name and optional badge
/// - Large price display with gradient background
/// - Feature list with checkmarks
/// - Purchase button
/// - Hover effects on desktop
/// - Equal height cards in grid
class PlanCard extends StatefulWidget {
  final DomainPlan plan;
  final bool isHighlighted;
  final VoidCallback onPurchase;

  const PlanCard({
    super.key,
    required this.plan,
    this.isHighlighted = false,
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
    final isHighlighted = widget.isHighlighted;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: XBDashboardCard(
          padding: EdgeInsets.zero,
          borderColor: isHighlighted
              ? colorScheme.primary
              : (_isHovered
                  ? colorScheme.outline.withValues(alpha: 0.4)
                  : colorScheme.outline.withValues(alpha: 0.2)),
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
              // Header section with plan name and badge
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            plan.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        if (isHighlighted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.tertiary,
                                  colorScheme.tertiary.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '推荐',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onTertiary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price section
              if (plan.hasPrice)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '最低价格',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getLowestPrice(plan),
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
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
