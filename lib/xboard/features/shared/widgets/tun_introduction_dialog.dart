import 'package:flutter/material.dart';
import 'package:fl_clash/common/common.dart';

class TunIntroductionDialog extends StatelessWidget {
  const TunIntroductionDialog({super.key});
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // 防止点击外部关闭
      builder: (context) => const TunIntroductionDialog(),
    );
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.shield,
          color: Theme.of(context).colorScheme.tertiary,
          size: 32,
        ),
      ),
      title: Text(
        appLocalizations.xboardTunModeTitle,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalizations.xboardTunModeDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              context,
              Icons.network_check,
              appLocalizations.xboardTunFeatureFullTraffic,
              appLocalizations.xboardTunFeatureFullTrafficDesc,
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              context,
              Icons.security,
              appLocalizations.xboardTunFeatureTransparent,
              appLocalizations.xboardTunFeatureTransparentDesc,
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              context,
              Icons.speed,
              appLocalizations.xboardTunFeaturePerformance,
              appLocalizations.xboardTunFeaturePerformanceDesc,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        appLocalizations.xboardTunRecommendations,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appLocalizations.xboardTunRecommendRule,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appLocalizations.xboardTunRecommendGlobal,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            appLocalizations.xboardTunLater,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            foregroundColor: Theme.of(context).colorScheme.onTertiary,
          ),
          child: Text(appLocalizations.xboardEnableTun),
        ),
      ],
    );
  }
  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}