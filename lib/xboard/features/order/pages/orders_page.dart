import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/adapter/state/order_state.dart';
import 'package:fl_clash/xboard/adapter/state/payment_state.dart';
import 'package:fl_clash/xboard/features/shared/shared.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/payment/providers/xboard_payment_provider.dart';
import 'package:fl_clash/xboard/features/payment/widgets/payment_waiting_overlay.dart';
import 'package:fl_clash/xboard/features/payment/widgets/payment_method_selector_dialog.dart';
import 'package:fl_clash/xboard/features/payment/models/payment_step.dart';
import '../widgets/order_card.dart';
import '../widgets/order_detail_sheet.dart';
import '../providers/order_provider.dart';

/// Orders page matching frontend Orders.tsx design
///
/// Features:
/// - Status-based filtering (All, Pending, Processing, Completed, Cancelled)
/// - Responsive design (cards on all screens)
/// - Order detail view (bottom sheet)
/// - Cancel order functionality
/// - Pay order navigation
class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  OrderStatusFilter _selectedFilter = OrderStatusFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.xboardMyOrders),
        leading: isDesktop
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(getOrdersProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 768),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page header
                Text(
                  appLocalizations.xboardOrderHistory,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  appLocalizations.xboardOrderHistoryDesc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),

                // Status filter
                _buildFilterButtons(theme),
                const SizedBox(height: 16),

                // Orders list
                _buildOrdersList(),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: OrderStatusFilter.values.map((filter) {
        final isSelected = _selectedFilter == filter;
        return Material(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
              // Invalidate to refetch with new filter
              ref.invalidate(getOrdersProvider);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                filter.getLabel(appLocalizations),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrdersList() {
    final ordersAsync = ref.watch(getOrdersProvider);

    return ordersAsync.when(
      data: (orders) {
        // Filter orders based on selected status
        final filteredOrders = _filterOrders(orders);

        if (filteredOrders.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: filteredOrders.map((order) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OrderCard(
                order: order,
                onTap: () => _showOrderDetail(order),
                onPay: () => _navigateToCheckout(order),
                onCancel: () => _cancelOrder(order.tradeNo),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                appLocalizations.xboardLoadFailed,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              appLocalizations.xboardNoOrders,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              appLocalizations.xboardNoOrdersDesc,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<DomainOrder> _filterOrders(List<DomainOrder> orders) {
    if (_selectedFilter == OrderStatusFilter.all) {
      return orders;
    }

    return orders.where((order) {
      switch (_selectedFilter) {
        case OrderStatusFilter.all:
          return true;
        case OrderStatusFilter.pending:
          return order.status == OrderStatus.pending;
        case OrderStatusFilter.processing:
          return order.status == OrderStatus.processing;
        case OrderStatusFilter.completed:
          return order.status == OrderStatus.completed;
        case OrderStatusFilter.cancelled:
          return order.status == OrderStatus.canceled;
      }
    }).toList();
  }

  void _showOrderDetail(DomainOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailSheet(
        order: order,
        onPay: order.canPay ? () => _navigateToCheckout(order) : null,
      ),
    );
  }

  Future<void> _navigateToCheckout(DomainOrder order) async {
    try {
      // Ensure payment provider is initialized
      ref.read(xboardPaymentProvider);

      // Get available payment methods
      var paymentMethods = ref.read(xboardAvailablePaymentMethodsProvider);

      // If empty, try reloading
      if (paymentMethods.isEmpty) {
        ref.invalidate(getPaymentMethodsProvider);
        await ref.read(xboardPaymentProvider.notifier).loadPaymentMethods();
        paymentMethods = ref.read(xboardAvailablePaymentMethodsProvider);
      }

      if (paymentMethods.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appLocalizations.xboardNoPaymentMethodsAvailable),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      // Select payment method
      DomainPaymentMethod? selectedMethod;
      if (paymentMethods.length == 1) {
        selectedMethod = paymentMethods.first;
      } else {
        if (!mounted) return;
        selectedMethod = await PaymentMethodSelectorDialog.show(
          context,
          paymentMethods: paymentMethods,
        );
        if (selectedMethod == null) return;
      }

      if (!mounted) return;

      // Show payment waiting overlay
      PaymentWaitingManager.show(
        context,
        onClose: () {
          ref.invalidate(getOrdersProvider);
        },
        onPaymentSuccess: _handlePaymentSuccess,
        tradeNo: order.tradeNo,
      );
      PaymentWaitingManager.updateStep(PaymentStep.loadingPayment);
      PaymentWaitingManager.updateStep(PaymentStep.verifyPayment);

      // Submit payment
      final paymentNotifier = ref.read(xboardPaymentProvider.notifier);
      final paymentResult = await paymentNotifier.submitPayment(
        tradeNo: order.tradeNo,
        method: selectedMethod.id.toString(),
      );

      if (paymentResult == null) {
        PaymentWaitingManager.hide();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appLocalizations.xboardPaymentFailedEmptyResult),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      if (!mounted) return;

      final paymentType = paymentResult['type'] as int? ?? 0;
      final paymentData = paymentResult['data'];

      if (paymentType == -1) {
        // Balance payment
        PaymentWaitingManager.hide();
        if (paymentData == true) {
          _handlePaymentSuccess();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(appLocalizations.xboardPaymentFailedBalanceError),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      } else if (paymentData != null && paymentData is String && paymentData.isNotEmpty) {
        // Redirect payment URL
        PaymentWaitingManager.updateStep(PaymentStep.waitingPayment);
        await _launchPaymentUrl(paymentData);
      } else {
        PaymentWaitingManager.hide();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appLocalizations.xboardPaymentFailedInvalidData),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      PaymentWaitingManager.hide();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${appLocalizations.xboardLoadFailed}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _handlePaymentSuccess() {
    try {
      final userProvider = ref.read(xboardUserProvider.notifier);
      userProvider.refreshSubscriptionInfoAfterPayment();
    } catch (_) {}

    ref.invalidate(getOrdersProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.xboardPaymentSuccess),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
    }
  }

  Future<void> _launchPaymentUrl(String url) async {
    try {
      if (!mounted) return;
      await Clipboard.setData(ClipboardData(text: url));
      final uri = Uri.parse(url);
      if (!await canLaunchUrl(uri)) {
        throw Exception(appLocalizations.xboardCannotOpenPaymentUrl);
      }
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception(appLocalizations.xboardCannotLaunchBrowser);
      }
    } catch (e) {
      if (mounted) {
        PaymentWaitingManager.hide();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${appLocalizations.xboardLoadFailed}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _cancelOrder(String tradeNo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLocalizations.xboardCancelOrder),
        content: Text(appLocalizations.xboardCancelOrderConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(appLocalizations.xboardCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(appLocalizations.xboardConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(cancelOrderProvider(tradeNo).future);
        ref.invalidate(getOrdersProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appLocalizations.xboardOrderCancelled),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${appLocalizations.xboardCancelFailed}: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}

/// Order status filter enum
enum OrderStatusFilter {
  all,
  pending,
  processing,
  completed,
  cancelled;

  String getLabel(dynamic localizations) {
    switch (this) {
      case OrderStatusFilter.all:
        return localizations.xboardAllOrders;
      case OrderStatusFilter.pending:
        return localizations.xboardPendingOrders;
      case OrderStatusFilter.processing:
        return localizations.xboardProcessingOrders;
      case OrderStatusFilter.completed:
        return localizations.xboardCompletedOrders;
      case OrderStatusFilter.cancelled:
        return localizations.xboardCancelledOrders;
    }
  }
}
