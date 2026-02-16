import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/infrastructure/api/api.dart';
import 'package:fl_clash/l10n/l10n.dart';
class PaymentGatewayPage extends ConsumerStatefulWidget {
  final String paymentUrl;
  final String tradeNo;
  const PaymentGatewayPage({
    super.key,
    required this.paymentUrl,
    required this.tradeNo,
  });
  @override
  ConsumerState<PaymentGatewayPage> createState() => _PaymentGatewayPageState();
}
class _PaymentGatewayPageState extends ConsumerState<PaymentGatewayPage> {
  bool _isLoading = true;
  String? _errorMessage;
  bool _isCheckingPayment = false;
  bool _autoPollingEnabled = false;
  @override
  void initState() {
    super.initState();
    _openPaymentUrl();
    _startPaymentStatusCheck();
  }
  @override
  void dispose() {
    _stopAutoPolling();
    super.dispose();
  }
  Future<void> _openPaymentUrl() async {
    try {
      setState(() {
        _isLoading = false;
      });
      await _launchPaymentUrl(isAutomatic: true);
    } catch (e) {
      setState(() {
        _errorMessage = ErrorSanitizer.sanitize(e.toString());
        _isLoading = false;
      });
    }
  }
  Future<void> _launchPaymentUrl({bool isAutomatic = false}) async {
    try {
      final uri = Uri.parse(widget.paymentUrl);
      if (!await canLaunchUrl(uri)) {
        if (!mounted) return;
        throw Exception('${AppLocalizations.of(context).xboardCannotOpenPaymentLink}: ${widget.paymentUrl}');
      }
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // 强制在外部浏览器打开
      );
      if (!launched) {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context).xboardCannotLaunchBrowser);
      }
      if (mounted) {
        XBoardNotification.showInfo(isAutomatic
            ? AppLocalizations.of(context).xboardAutoOpeningPayment
            : AppLocalizations.of(context).xboardPaymentPageOpenedInBrowserNote);
        _startAutoPolling();
      }
    } catch (e) {
      if (mounted) {
        XBoardNotification.showError(AppLocalizations.of(context).xboardOpenPaymentLinkError(ErrorSanitizer.sanitize(e.toString())));
      }
    }
  }
  Future<void> _copyPaymentUrl() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.paymentUrl));
      if (mounted) {
        XBoardNotification.showSuccess(AppLocalizations.of(context).xboardPaymentLinkCopiedToClipboard);
      }
    } catch (e) {
      if (mounted) {
        XBoardNotification.showError(AppLocalizations.of(context).xboardCopyFailedError(ErrorSanitizer.sanitize(e.toString())));
      }
    }
  }
  Future<void> _startPaymentStatusCheck() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      _checkPaymentStatus();
    }
  }
  void _startAutoPolling() {
    if (_autoPollingEnabled) return;
    setState(() {
      _autoPollingEnabled = true;
    });
    _pollPaymentStatus();
  }
  void _stopAutoPolling() {
    setState(() {
      _autoPollingEnabled = false;
    });
  }
  Future<void> _pollPaymentStatus() async {
    if (!_autoPollingEnabled || !mounted) return;
    await Future.delayed(const Duration(seconds: 5));
    if (!_autoPollingEnabled || !mounted) return;
    await _checkPaymentStatus(silent: true);
    if (_autoPollingEnabled && mounted) {
      _pollPaymentStatus();
    }
  }
  Future<void> _checkPaymentStatus({bool silent = false}) async {
    if (_isCheckingPayment) return;
    setState(() {
      _isCheckingPayment = true;
    });
    try {
      // 使用 V2Board API 查询订单状态
      final api = await ref.read(xboardSdkProvider.future);
      final json = await api.fetchOrders();
      final dataList = json['data'] as List<dynamic>? ?? [];
      final orders = dataList
          .whereType<Map<String, dynamic>>()
          .map(mapOrder)
          .toList();

      DomainOrder? foundOrder;
      try {
        foundOrder = orders.firstWhere((o) => o.tradeNo == widget.tradeNo);
      } catch (_) {
        foundOrder = null;
      }

      if (mounted) {
        setState(() {
          _isCheckingPayment = false;
        });
        if (foundOrder != null) {
          // status: 0=pending, 1=processing, 2=canceled, 3=completed
          if (foundOrder.status == OrderStatus.completed) {
            _stopAutoPolling();
            XBoardNotification.showSuccess(AppLocalizations.of(context).xboardPaymentSuccess);
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            });
          } else if (foundOrder.status == OrderStatus.canceled) {
            _stopAutoPolling();
            if (!silent) {
              XBoardNotification.showInfo(AppLocalizations.of(context).xboardPaymentCancelled);
            }
          } else if (foundOrder.status == OrderStatus.pending || foundOrder.status == OrderStatus.processing) {
            if (!silent) {
              XBoardNotification.showInfo(_autoPollingEnabled
                ? AppLocalizations.of(context).xboardWaitingForPayment
                : AppLocalizations.of(context).xboardOrderStatusPending);
            }
          }
        } else {
          if (!silent) {
            XBoardNotification.showError(AppLocalizations.of(context).xboardOrderInfoNotFound);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingPayment = false;
        });
        if (!silent) {
          XBoardNotification.showError(AppLocalizations.of(context).xboardCheckPaymentStatusError(ErrorSanitizer.sanitize(e.toString())));
        }
      }
    }
  }
  void _completePayment() {
    XBoardNotification.showSuccess(AppLocalizations.of(context).xboardPaymentCompleted);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  void _cancelPayment() {
    Navigator.of(context).pop();
  }
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CommonScaffold(
      title: AppLocalizations.of(context).xboardPaymentGateway,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(AppLocalizations.of(context).xboardGoBack),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).xboardPaymentInfo,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Text('${AppLocalizations.of(context).xboardOrderNumber}: '),
                                  Expanded(
                                    child: Text(
                                      widget.tradeNo,
                                      style: const TextStyle(fontFamily: 'monospace'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: _copyPaymentUrl,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.info, color: colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context).xboardPaymentLink,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: colorScheme.primary,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Icon(
                                                  Icons.copy,
                                                  size: 16,
                                                  color: colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  AppLocalizations.of(context).xboardTapToCopy,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.paymentUrl,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_autoPollingEnabled)
                        Card(
                          color: colorScheme.tertiaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.tertiary),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context).xboardAutoDetectPaymentStatus,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onTertiaryContainer,
                                        ),
                                      ),
                                      Text(
                                        AppLocalizations.of(context).xboardAutoCheckPaymentDesc,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.tertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: _stopAutoPolling,
                                  child: Text(
                                    AppLocalizations.of(context).xboardStop,
                                    style: TextStyle(color: colorScheme.tertiary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_autoPollingEnabled) const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).xboardOperationTips,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(AppLocalizations.of(context).xboardOperationStep1),
                              Text(AppLocalizations.of(context).xboardOperationStep2),
                              Text(AppLocalizations.of(context).xboardOperationStep3),
                              Text(AppLocalizations.of(context).xboardOperationStep4),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 16, color: colorScheme.secondary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context).xboardBrowserNotOpenedNote,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _launchPaymentUrl(isAutomatic: false),
                              icon: const Icon(Icons.open_in_browser),
                              label: Text(AppLocalizations.of(context).xboardReopenPayment),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _copyPaymentUrl,
                              icon: const Icon(Icons.copy),
                              label: Text(AppLocalizations.of(context).xboardCopyLink),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.secondary,
                                foregroundColor: colorScheme.onSecondary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isCheckingPayment ? null : _checkPaymentStatus,
                              icon: _isCheckingPayment
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onSecondary),
                                      ),
                                    )
                                  : const Icon(Icons.refresh),
                              label: Text(_isCheckingPayment ? AppLocalizations.of(context).xboardChecking : AppLocalizations.of(context).xboardCheckStatus),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.secondary,
                                foregroundColor: colorScheme.onSecondary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _completePayment,
                              icon: const Icon(Icons.check_circle),
                              label: Text(AppLocalizations.of(context).xboardPaymentComplete),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.tertiary,
                                foregroundColor: colorScheme.onTertiary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _cancelPayment,
                              icon: const Icon(Icons.cancel),
                              label: Text(AppLocalizations.of(context).xboardCancelPayment),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.outline,
                                foregroundColor: colorScheme.surface,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
