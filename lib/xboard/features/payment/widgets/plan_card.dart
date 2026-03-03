import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/features/shared/widgets/xb_dashboard_card.dart';
import 'package:flutter/material.dart';
import '../utils/price_calculator.dart';
import 'plan_description_widget.dart';

/// Plan card component - Compact version
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
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        plan.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (plan.hasPrice)
                      Text(
                        _getLowestPrice(plan),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),

              // Features section with tags
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Feature tags - more compact
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildFeatureTag(
                          context,
                          Icons.cloud_download_outlined,
                          plan.formattedTraffic,
                        ),
                        _buildFeatureTag(
                          context,
                          Icons.speed,
                          _getSpeedLimitText(context),
                        ),
                        if (plan.deviceLimit != null)
                          _buildFeatureTag(
                            context,
                            Icons.devices,
                            '${plan.deviceLimit} ${AppLocalizations.of(context).xboardDevices}',
                          )
                        else
                          _buildFeatureTag(
                            context,
                            Icons.devices,
                            AppLocalizations.of(context).xboardUnlimitedDevices,
                          ),
                      ],
                    ),

                    // Description (if exists)
                    if (plan.description != null) ...[
                      const SizedBox(height: 8),
                      Divider(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: 6),
                      PlanDescriptionWidget(content: plan.description!),
                    ],
                  ],
                ),
              ),

              const Spacer(),

              // Purchase button - compact height
              Padding(
                padding: const EdgeInsets.all(14),
                child: SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: FilledButton(
                    onPressed: widget.onPurchase,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context).xboardBuyNow,
                      style: const TextStyle(
                        fontSize: 14,
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

  Widget _buildFeatureTag(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
