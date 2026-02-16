import 'package:fl_clash/common/utils.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/material.dart';
class LatencyIndicator extends StatelessWidget {
  final int? delayValue;
  final VoidCallback? onTap;
  final bool isCompact;
  final bool showIcon;
  const LatencyIndicator({
    super.key,
    required this.delayValue,
    this.onTap,
    this.isCompact = false,
    this.showIcon = true,
  });
  @override
  Widget build(BuildContext context) {
    if (delayValue == 0) {
      return _buildTestingState(context);
    }
    if (delayValue == null) {
      return _buildUntestedState(context);
    }
    return _buildTestedState(context);
  }
  Widget _buildTestingState(BuildContext context) {
    if (isCompact) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (!isCompact) ...[
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context).xboardLatencyTesting,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildUntestedState(BuildContext context) {
    if (isCompact) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.refresh,
            size: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.refresh,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            AppLocalizations.of(context).xboardLatencyAutoTesting,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTestedState(BuildContext context) {
    final displayText = delayValue! < 0 ? 'Timeout' : '${delayValue}ms';
    final color = utils.getDelayColor(delayValue!);
    if (isCompact) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: color?.withValues(alpha: 0.1) ?? Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color?.withValues(alpha: 0.3) ?? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
          ),
          child: Text(
            delayValue! < 0 ? AppLocalizations.of(context).xboardLatencyTimeout : '$delayValue',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            displayText,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
class LatencyQuality {
  static const int excellent = 50;
  static const int good = 100;
  static const int fair = 200;
  static const int poor = 500;
  static String getQualityLevel(BuildContext context, int delay) {
    final loc = AppLocalizations.of(context);
    if (delay < 0) return loc.xboardLatencyTimeout;
    if (delay <= excellent) return loc.xboardLatencyExcellent;
    if (delay <= good) return loc.xboardLatencyGood;
    if (delay <= fair) return loc.xboardLatencyFair;
    if (delay <= poor) return loc.xboardLatencyPoor;
    return loc.xboardLatencyVeryPoor;
  }
  static String getQualityDescription(BuildContext context, int delay) {
    final loc = AppLocalizations.of(context);
    if (delay < 0) return loc.xboardLatencyTimeoutDesc;
    if (delay <= excellent) return loc.xboardLatencyExcellentDesc;
    if (delay <= good) return loc.xboardLatencyGoodDesc;
    if (delay <= fair) return loc.xboardLatencyFairDesc;
    if (delay <= poor) return loc.xboardLatencyPoorDesc;
    return loc.xboardLatencyVeryPoorDesc;
  }
  static IconData getQualityIcon(int delay) {
    if (delay < 0) return Icons.signal_wifi_off;
    if (delay <= excellent) return Icons.signal_wifi_4_bar;
    if (delay <= good) return Icons.signal_wifi_4_bar;
    if (delay <= fair) return Icons.signal_wifi_4_bar;
    if (delay <= poor) return Icons.signal_wifi_bad;
    return Icons.signal_wifi_0_bar;
  }
}
