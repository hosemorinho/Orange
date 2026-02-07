import 'package:flutter/material.dart';

/// Unified dashboard card component matching frontend design
///
/// Design reference: StatCard, SubscriptionDetailCard from frontend
/// - Consistent rounded corners (16px)
/// - Border with theme colors
/// - Proper padding (20px)
/// - Shadow on hover (web/desktop)
/// - Full dark mode support
class XBDashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool showBorder;
  final List<BoxShadow>? shadows;

  const XBDashboardCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16.0,
    this.onTap,
    this.showBorder = true,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor = backgroundColor ??
      colorScheme.surfaceContainerHighest.withValues(alpha: 0.15);

    final effectiveBorderColor = borderColor ??
      colorScheme.outline.withValues(alpha: 0.2);

    final card = Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
          ? Border.all(
              color: effectiveBorderColor,
              width: 1.0,
            )
          : null,
        boxShadow: shadows,
      ),
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Section title widget matching frontend design
class XBSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;

  const XBSectionTitle({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: iconColor ?? colorScheme.primary,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

/// Info chip widget matching frontend design
class XBInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const XBInfoChip({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: effectiveColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status badge matching frontend design
class XBStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const XBStatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
