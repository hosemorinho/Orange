import 'package:flutter/material.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/domain/domain.dart';

/// 套餐信息头部卡片
class PlanHeaderCard extends StatelessWidget {
  final DomainPlan plan;

  const PlanHeaderCard({
    super.key,
    required this.plan,
  });

  String _getTrafficDisplay(BuildContext context) {
    if (plan.transferQuota == 0) {
      return AppLocalizations.of(context).xboardUnlimited;
    }
    return plan.formattedTraffic;
  }

  String _getSpeedLimitDisplay(BuildContext context) {
    if (plan.speedLimit == null) {
      return AppLocalizations.of(context).xboardUnlimited;
    }
    return '${plan.speedLimit}Mbps';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.workspace_premium,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  plan.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCompactInfo(
                context,
                Icons.cloud_download_outlined,
                _getTrafficDisplay(context),
              ),
              _buildCompactInfo(
                context,
                Icons.speed,
                _getSpeedLimitDisplay(context),
              ),
              if (plan.deviceLimit != null)
                _buildCompactInfo(
                  context,
                  Icons.devices,
                  '${plan.deviceLimit} ${AppLocalizations.of(context).xboardDevices}',
                )
              else
                _buildCompactInfo(
                  context,
                  Icons.devices,
                  AppLocalizations.of(context).xboardUnlimited,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfo(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colorScheme.primary, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
