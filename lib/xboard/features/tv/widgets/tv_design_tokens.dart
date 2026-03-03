import 'package:flutter/material.dart';

/// Shared visual tokens for the TV experience.
abstract final class TvDesignTokens {
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(20, 14, 20, 14);
  static const double panelRadius = 22;
  static const double controlRadius = 18;
  static const Duration focusDuration = Duration(milliseconds: 180);

  static BoxDecoration background(ColorScheme colorScheme) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colorScheme.surface.withValues(alpha: 0.98),
          colorScheme.surfaceContainerLowest.withValues(alpha: 0.96),
          colorScheme.surfaceContainerLow.withValues(alpha: 0.92),
        ],
      ),
    );
  }

  static BoxDecoration panel(
    ColorScheme colorScheme, {
    bool emphasized = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(panelRadius),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colorScheme.surface.withValues(alpha: 0.9),
          colorScheme.surfaceContainerLow.withValues(alpha: 0.86),
        ],
      ),
      border: Border.all(
        color: emphasized
            ? colorScheme.primary.withValues(alpha: 0.35)
            : colorScheme.outlineVariant.withValues(alpha: 0.35),
        width: emphasized ? 1.4 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.14),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }
}
