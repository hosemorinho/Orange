import 'package:flutter/material.dart';

class XBCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isSelected;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  const XBCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.isSelected = false,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final defaultBorderRadius = BorderRadius.circular(20);
    return Container(
      margin: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? defaultBorderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          elevation: 0,
          borderRadius: borderRadius ?? defaultBorderRadius,
          color:
              backgroundColor ??
              (isSelected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.65)
                  : colorScheme.surface.withValues(
                      alpha: isDark ? 0.86 : 0.96,
                    )),
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius ?? defaultBorderRadius,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: borderRadius ?? defaultBorderRadius,
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.6)
                      : colorScheme.outlineVariant.withValues(alpha: 0.35),
                  width: isSelected ? 1.4 : 1.0,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
