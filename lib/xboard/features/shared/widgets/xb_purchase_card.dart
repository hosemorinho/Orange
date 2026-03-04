/// XBoard 购买卡片组件
///
/// 统一的购买页面卡片组件，提供一致的视觉风格
/// - 统一的圆角
/// - 统一的阴影
/// - 统一的内边距
/// - 统一的边框
library;

import 'package:flutter/material.dart';
import 'package:fl_clash/xboard/features/shared/styles/xboard_design_constants.dart';

/// 购买卡片 - 统一的视觉风格
class XBPurchaseCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool showBorder;
  final bool showShadow;
  final VoidCallback? onTap;

  const XBPurchaseCard({
    super.key,
    required this.child,
    this.title,
    this.leading,
    this.trailing,
    this.padding,
    this.backgroundColor,
    this.showBorder = true,
    this.showShadow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isDark = colorScheme.brightness == Brightness.dark;
    final effectiveBackgroundColor = backgroundColor ??
        colorScheme.surface.withValues(alpha: isDark ? 0.88 : 1.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(XBoardDesignConstants.cardBorderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(
              XBoardDesignConstants.cardBorderRadius,
            ),
            border: showBorder
                ? Border.all(
                    color: colorScheme.outlineVariant.withValues(
                      alpha: XBoardDesignConstants.borderColorAlpha,
                    ),
                    width: XBoardDesignConstants.borderWidth,
                  )
                : null,
            boxShadow: showShadow ? XBoardDesignConstants.cardShadow : null,
          ),
          padding: padding ?? XBoardDesignConstants.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行（可选）
              if (title != null) ...[
                Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        title!,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: TextStyleHelper.fontWeightSemiBold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                const SizedBox(height: 12),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// 购买卡片分隔线
class XBPurchaseCardDivider extends StatelessWidget {
  final double height;

  const XBPurchaseCardDivider({
    super.key,
    this.height = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

/// 购买卡片标题行
class XBPurchaseCardTitleRow extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const XBPurchaseCardTitleRow({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: TextStyleHelper.fontWeightSemiBold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
