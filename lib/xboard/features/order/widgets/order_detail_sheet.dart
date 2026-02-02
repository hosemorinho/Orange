import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/domain/domain.dart';

/// Order detail bottom sheet matching frontend OrderDetailModal
///
/// Displays comprehensive order information:
/// - Order info section (trade no, period, amounts, dates)
/// - Plan info section (if available)
/// - Pay button (if payable)
class OrderDetailSheet extends StatelessWidget {
  final DomainOrder order;

  const OrderDetailSheet({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final l10n = context.appLocalizations;

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(context, theme, l10n),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Information Section
                  _buildSectionTitle(theme, l10n.xboardOrderInfo),
                  const SizedBox(height: 12),
                  _buildOrderInfoSection(theme, l10n),
                  const SizedBox(height: 24),

                  // Plan Information Section
                  if (order.planName != null) ...[
                    _buildSectionTitle(theme, l10n.xboardPlanInfo),
                    const SizedBox(height: 12),
                    _buildPlanInfoSection(theme, l10n),
                  ],
                ],
              ),
            ),
          ),

          // Footer with Pay button
          if (order.canPay) _buildFooter(context, theme, l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            l10n.xboardOrderDetails,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              foregroundColor: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildOrderInfoSection(ThemeData theme, AppLocalizations l10n) {
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDetailRow(
            theme,
            l10n.xboardTradeNo,
            order.tradeNo,
            monospace: true,
            copyable: true,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            theme,
            l10n.xboardPeriod,
            _formatPeriod(order.period, l10n),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            theme,
            l10n.xboardTotalAmount,
            _formatPrice(order.totalAmount),
            bold: true,
          ),

          // Optional amounts
          if (order.handlingAmount > 0) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              theme,
              l10n.xboardHandlingFee,
              _formatPrice(order.handlingAmount),
            ),
          ],
          if (order.balanceAmount > 0) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              theme,
              l10n.xboardBalanceAmount,
              _formatPrice(order.balanceAmount),
            ),
          ],
          if (order.refundAmount > 0) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              theme,
              l10n.xboardRefundAmount,
              _formatPrice(order.refundAmount),
            ),
          ],
          if (order.discountAmount > 0) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              theme,
              l10n.xboardDiscountAmount,
              _formatPrice(order.discountAmount),
            ),
          ],
          if (order.surplusAmount > 0) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              theme,
              l10n.xboardSurplusAmount,
              _formatPrice(order.surplusAmount),
            ),
          ],

          const SizedBox(height: 12),
          _buildDetailRow(
            theme,
            l10n.xboardCreatedAt,
            _formatDateTime(order.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanInfoSection(ThemeData theme, AppLocalizations l10n) {
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan icon and name
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.flash_on,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  order.planName!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Plan content (HTML)
          if (order.planContent != null) ...[
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: HtmlWidget(
                  order.planContent!,
                  textStyle: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    String label,
    String value, {
    bool bold = false,
    bool monospace = false,
    bool copyable = false,
  }) {
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: GestureDetector(
            onLongPress: copyable
                ? () {
                    Clipboard.setData(ClipboardData(text: value));
                  }
                : null,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                fontFamily: monospace ? 'monospace' : null,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            // TODO: Navigate to checkout
          },
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(l10n.xboardGoToPay),
        ),
      ),
    );
  }

  String _formatPeriod(String period, AppLocalizations l10n) {
    final periodMap = {
      'month_price': l10n.xboardMonthlyPayment,
      'quarter_price': l10n.xboardQuarterlyPayment,
      'half_year_price': l10n.xboardHalfYearPayment,
      'year_price': l10n.xboardYearlyPayment,
      'two_year_price': l10n.xboardTwoYearPayment,
      'three_year_price': l10n.xboardThreeYearPayment,
      'onetime_price': l10n.xboardOnetimePayment,
      'reset_price': l10n.xboardResetTraffic,
    };
    return periodMap[period] ?? period;
  }

  String _formatPrice(double amount) {
    return '¥${amount.toStringAsFixed(2)}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
