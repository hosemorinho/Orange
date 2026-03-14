/// Mobile sticky action panel with expandable price details
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/features/shared/styles/xboard_design_constants.dart';

/// Mobile sticky action panel
class MobileStickyActionPanel extends StatefulWidget {
  final double originalPrice;
  final double? discountAmount;
  final double totalAmount;
  final double? handlingFee;
  final double? balanceToUse;
  final bool isProcessing;
  final bool hasPeriodSelected;
  final VoidCallback onPurchase;

  const MobileStickyActionPanel({
    super.key,
    required this.originalPrice,
    required this.totalAmount,
    required this.onPurchase,
    this.discountAmount,
    this.handlingFee,
    this.balanceToUse,
    this.isProcessing = false,
    this.hasPeriodSelected = true,
  });

  @override
  State<MobileStickyActionPanel> createState() => _MobileStickyActionPanelState();
}

class _MobileStickyActionPanelState extends State<MobileStickyActionPanel>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    HapticFeedback.selectionClick();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _onPurchase() {
    if (widget.isProcessing || !widget.hasPeriodSelected) return;
    HapticFeedback.mediumImpact();
    widget.onPurchase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final hasDiscount = (widget.discountAmount ?? 0) > 0;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Price summary row (tap to expand)
            InkWell(
              onTap: _toggleExpanded,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            '¥${widget.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 8),
                            Text(
                              '¥${widget.originalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(width: 4),
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                    _buildPurchaseButton(context, l10n, colorScheme),
                  ],
                ),
              ),
            ),
            // Expandable details
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _buildPriceRow(
                      l10n.xboardBasePrice,
                      '¥${widget.originalPrice.toStringAsFixed(2)}',
                      colorScheme,
                    ),
                    if (hasDiscount)
                      _buildPriceRow(
                        l10n.xboardCouponDiscount,
                        '-¥${widget.discountAmount!.toStringAsFixed(2)}',
                        colorScheme,
                        isDiscount: true,
                      ),
                    if (widget.handlingFee != null && widget.handlingFee! > 0)
                      _buildPriceRow(
                        l10n.xboardHandlingFee,
                        '+¥${widget.handlingFee!.toStringAsFixed(2)}',
                        colorScheme,
                      ),
                    if (widget.balanceToUse != null && widget.balanceToUse! > 0)
                  _buildPriceRow(
                    l10n.xboardCouponDiscount,
                    '-¥${widget.balanceToUse!.toStringAsFixed(2)}',
                    colorScheme,
                    isDiscount: true,
                  ),
                  const Divider(height: 24),
                  _buildPriceRow(
                    l10n.xboardActualPayment,
                    '¥${widget.totalAmount.toStringAsFixed(2)}',
                    colorScheme,
                    isTotal: true,
                  ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final isEnabled = !widget.isProcessing && widget.hasPeriodSelected;

    return SizedBox(
      height: 48,
      width: 140,
      child: FilledButton(
        onPressed: isEnabled ? _onPurchase : null,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(XBoardDesignConstants.buttonBorderRadius),
          ),
        ),
        child: widget.isProcessing
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onPrimary,
                ),
              )
            : Text(
                l10n.xboardBuyNow,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isEnabled
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface.withValues(alpha: 0.38),
                ),
              ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value,
    ColorScheme colorScheme, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isDiscount
                  ? colorScheme.tertiary
                  : isTotal
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
