import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/features/shared/shared.dart';

/// Order card component matching frontend OrdersList design
///
/// Displays order summary with:
/// - Trade number
/// - Status badge
/// - Period and amount
/// - Action buttons (Detail, Pay, Cancel)
class OrderCard extends StatelessWidget {
  final DomainOrder order;
  final VoidCallback onTap;
  final VoidCallback? onPay;
  final VoidCallback? onCancel;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.onPay,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return XBDashboardCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Trade No + Status Badge
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: order.tradeNo));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(appLocalizations.xboardCopied),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Text(
                    '#${order.tradeNo}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(theme, order.status),
            ],
          ),
          const SizedBox(height: 4),

          // Created date
          Text(
            _formatDateTime(order.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),

          // Order info rows
          _buildInfoRow(
            theme,
            appLocalizations.xboardPeriod,
            _formatPeriod(order.period),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            theme,
            appLocalizations.xboardTotalAmount,
            _formatPrice(order.totalAmount),
            valueStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),

          // Handling fee if present
          if (order.handlingAmount > 0) ...[
            const SizedBox(height: 4),
            _buildInfoRow(
              theme,
              appLocalizations.xboardHandlingFee,
              _formatPrice(order.handlingAmount),
              valueStyle: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              // Detail button
              Expanded(
                child: _ActionButton(
                  label: appLocalizations.xboardDetail,
                  icon: Icons.info_outline,
                  backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  foregroundColor: colorScheme.primary,
                  onTap: onTap,
                ),
              ),

              // Pay button (only for pending orders)
              if (order.canPay && onPay != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    label: appLocalizations.xboardPay,
                    icon: Icons.payment,
                    backgroundColor: colorScheme.tertiary.withValues(alpha: 0.15),
                    foregroundColor: colorScheme.tertiary,
                    onTap: onPay,
                  ),
                ),
              ],

              // Cancel button (only for cancellable orders)
              if (order.canCancel && onCancel != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    label: appLocalizations.xboardCancel,
                    icon: Icons.cancel_outlined,
                    backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.3),
                    foregroundColor: colorScheme.error,
                    onTap: onCancel,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String value, {
    TextStyle? valueStyle,
  }) {
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: valueStyle ?? theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ThemeData theme, OrderStatus status) {
    final statusConfig = _getStatusConfig(theme, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusConfig.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusConfig.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusLabel(context, status),
            style: theme.textTheme.labelSmall?.copyWith(
              color: statusConfig.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  ({Color backgroundColor, Color textColor, Color dotColor}) _getStatusConfig(
    ThemeData theme,
    OrderStatus status,
  ) {
    final colorScheme = theme.colorScheme;

    switch (status) {
      case OrderStatus.pending:
        // Warning colors (yellow/orange)
        return (
          backgroundColor: colorScheme.error.withValues(alpha: 0.7).withValues(alpha: 0.15),
          textColor: colorScheme.error.withValues(alpha: 0.7),
          dotColor: colorScheme.error.withValues(alpha: 0.7),
        );

      case OrderStatus.processing:
        // Purple colors
        final purpleColor = Color(0xFF9333EA);
        return (
          backgroundColor: purpleColor.withValues(alpha: 0.15),
          textColor: purpleColor,
          dotColor: purpleColor,
        );

      case OrderStatus.completed:
        // Success colors (green)
        return (
          backgroundColor: colorScheme.tertiary.withValues(alpha: 0.15),
          textColor: colorScheme.tertiary,
          dotColor: colorScheme.tertiary,
        );

      case OrderStatus.canceled:
        // Error colors (red)
        return (
          backgroundColor: colorScheme.error.withValues(alpha: 0.15),
          textColor: colorScheme.error,
          dotColor: colorScheme.error,
        );

      case OrderStatus.discounted:
        // Neutral colors (slate/grey)
        return (
          backgroundColor: colorScheme.surfaceContainerHighest,
          textColor: colorScheme.onSurface.withValues(alpha: 0.6),
          dotColor: colorScheme.onSurface.withValues(alpha: 0.4),
        );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatPeriod(String period) {
    // Map period codes to readable names
    final periodMap = {
      'month_price': appLocalizations.xboardMonthlyPayment,
      'quarter_price': appLocalizations.xboardQuarterlyPayment,
      'half_year_price': appLocalizations.xboardHalfYearPayment,
      'year_price': appLocalizations.xboardYearlyPayment,
      'two_year_price': appLocalizations.xboardTwoYearPayment,
      'three_year_price': appLocalizations.xboardThreeYearPayment,
      'onetime_price': appLocalizations.xboardOnetimePayment,
      'reset_price': appLocalizations.xboardResetTraffic,
    };
    return periodMap[period] ?? period;
  }

  String _formatPrice(double amount) {
    return '¥${amount.toStringAsFixed(2)}';
  }

  String _getStatusLabel(BuildContext context, OrderStatus status) {
    final localizations = appLocalizations;
    switch (status) {
      case OrderStatus.pending:
        return localizations.xboardOrderStatusPending;
      case OrderStatus.processing:
        return localizations.xboardOrderStatusProcessing;
      case OrderStatus.canceled:
        return localizations.xboardOrderStatusCanceled;
      case OrderStatus.completed:
        return localizations.xboardOrderStatusCompleted;
      case OrderStatus.discounted:
        return localizations.xboardOrderStatusDiscounted;
    }
  }
}

/// Action button widget for order cards
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: foregroundColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
