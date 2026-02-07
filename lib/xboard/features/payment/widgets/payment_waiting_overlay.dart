import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_clash/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/infrastructure/api/api.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import '../models/payment_step.dart';

// 初始化文件级日志器
final _logger = FileLogger('payment_waiting_overlay.dart');
class PaymentWaitingOverlay extends ConsumerStatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onPaymentSuccess;
  final String? tradeNo;
  final String? paymentUrl;
  const PaymentWaitingOverlay({
    super.key,
    this.onClose,
    this.onPaymentSuccess,
    this.tradeNo,
    this.paymentUrl,
  });
  @override
  ConsumerState<PaymentWaitingOverlay> createState() => _PaymentWaitingOverlayState();
}
class _PaymentWaitingOverlayState extends ConsumerState<PaymentWaitingOverlay>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  PaymentStep _currentStep = PaymentStep.cancelingOrders;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _paymentCheckTimer;
  String? _currentTradeNo;
  @override
  void initState() {
    super.initState();
    _currentTradeNo = widget.tradeNo;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _paymentCheckTimer?.cancel();
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  void updateStep(PaymentStep step) {
    if (mounted) {
      setState(() {
        _currentStep = step;
      });
      if (step == PaymentStep.waitingPayment && _currentTradeNo != null) {
        _startPaymentStatusCheck();
      }
    }
  }
  void updateTradeNo(String tradeNo) {
    if (mounted) {
      setState(() {
        _currentTradeNo = tradeNo;
      });
    }
  }
  void updatePaymentUrl(String paymentUrl) {
    if (mounted) {
      setState(() {
      });
    }
  }
  void _startPaymentStatusCheck() {
    _logger.info('[PaymentWaiting] 开始定时检测支付状态，订单号: $_currentTradeNo');
    _paymentCheckTimer?.cancel();

    // 立即执行一次检查
    _checkPaymentStatus();

    _paymentCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (!mounted || _currentTradeNo == null) {
      _paymentCheckTimer?.cancel();
      return;
    }

    try {
      _logger.info('[PaymentWaiting] ===== 开始检测支付状态 =====');
      _logger.info('[PaymentWaiting] 订单号: $_currentTradeNo');

      // 使用 V2Board API 检查订单状态
      final api = await ref.read(xboardSdkProvider.future);
      final json = await api.fetchOrders();
      final dataList = json['data'] as List<dynamic>? ?? [];
      final orders = dataList
          .whereType<Map<String, dynamic>>()
          .map(mapOrder)
          .toList();

      final order = orders.where((o) => o.tradeNo == _currentTradeNo).firstOrNull;

      _logger.info('[PaymentWaiting] API 调用完成，订单状态: ${order?.status.name ?? 'null'}');

      if (order != null) {
        // 检查订单状态
        if (order.status == OrderStatus.completed) {
          // 支付成功，立即执行成功回调
          _logger.info('[PaymentWaiting] ===== 检测到支付成功！状态: ${order.status.name} =====');
          _paymentCheckTimer?.cancel();
          if (mounted) {
            setState(() {
              _currentStep = PaymentStep.paymentSuccess;
            });
            _pulseController.stop();

            // 立即执行成功回调
            if (widget.onPaymentSuccess != null) {
              widget.onPaymentSuccess?.call();
            }
          }
        } else if (order.status == OrderStatus.pending || order.status == OrderStatus.processing) {
          // 仍在等待支付
          _logger.info('[PaymentWaiting] 支付仍在等待中 (状态: ${order.status.name})...');
        } else {
          // 其他状态视为失败
          _logger.info('[PaymentWaiting] 支付视为失败/结束，状态: ${order.status.name}');
          _paymentCheckTimer?.cancel();
          if (mounted) {
            widget.onClose?.call();
          }
        }
      } else {
        _logger.info('[PaymentWaiting] 获取订单状态失败：订单不存在');
      }
    } catch (e) {
      _logger.info('[PaymentWaiting] 检测支付状态异常: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _logger.info('[PaymentWaiting] 应用回到前台，立即检测支付状态');
      if (_currentStep == PaymentStep.waitingPayment && _currentTradeNo != null) {
        _checkPaymentStatus();
      }
    }
  }
  String _getStepTitle(PaymentStep step) {
    switch (step) {
      case PaymentStep.cancelingOrders:
        return AppLocalizations.of(context).xboardClearOldOrders;
      case PaymentStep.createOrder:
        return AppLocalizations.of(context).xboardCreatingOrder;
      case PaymentStep.loadingPayment:
        return AppLocalizations.of(context).xboardLoadingPaymentPage;
      case PaymentStep.verifyPayment:
        return AppLocalizations.of(context).xboardPaymentMethodVerified;
      case PaymentStep.waitingPayment:
        return AppLocalizations.of(context).xboardWaitingPaymentCompletion;
      case PaymentStep.paymentSuccess:
        return AppLocalizations.of(context).xboardPaymentSuccess;
    }
  }
  String _getStepDescription(PaymentStep step) {
    switch (step) {
      case PaymentStep.cancelingOrders:
        return AppLocalizations.of(context).xboardCleaningPendingOrders;
      case PaymentStep.createOrder:
        return AppLocalizations.of(context).xboardCreatingOrderPleaseWait;
      case PaymentStep.loadingPayment:
        return AppLocalizations.of(context).xboardPreparingPaymentPage;
      case PaymentStep.verifyPayment:
        return AppLocalizations.of(context).xboardPaymentMethodVerifiedPreparing;
      case PaymentStep.waitingPayment:
        return AppLocalizations.of(context).xboardPaymentPageOpenedCopyDesc;
      case PaymentStep.paymentSuccess:
        return AppLocalizations.of(context).xboardCongratulationsSubscriptionActivated;
    }
  }
  Color _getStepColor(PaymentStep step, ColorScheme colorScheme) {
    switch (step) {
      case PaymentStep.cancelingOrders:
        return colorScheme.outline;
      case PaymentStep.createOrder:
        return colorScheme.secondary;
      case PaymentStep.loadingPayment:
        return colorScheme.primary;
      case PaymentStep.verifyPayment:
        return colorScheme.tertiary;
      case PaymentStep.waitingPayment:
        return colorScheme.secondary;
      case PaymentStep.paymentSuccess:
        return colorScheme.tertiary;
    }
  }
  IconData _getStepIcon(PaymentStep step) {
    switch (step) {
      case PaymentStep.cancelingOrders:
        return Icons.clear_all;
      case PaymentStep.createOrder:
        return Icons.receipt_long;
      case PaymentStep.loadingPayment:
        return Icons.payment;
      case PaymentStep.verifyPayment:
        return Icons.verified_user;
      case PaymentStep.waitingPayment:
        return Icons.access_time;
      case PaymentStep.paymentSuccess:
        return Icons.check_circle;
    }
  }
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stepColor = _getStepColor(_currentStep, colorScheme);
    return Material(
      color: colorScheme.scrim.withValues(alpha: 0.5),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: stepColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: stepColor,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getStepIcon(_currentStep),
                          size: 40,
                          color: stepColor,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  _getStepTitle(_currentStep),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _getStepDescription(_currentStep),
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_currentStep == PaymentStep.paymentSuccess)
                  Icon(
                    Icons.check_circle,
                    size: 48,
                    color: colorScheme.tertiary,
                  )
                else
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        stepColor,
                      ),
                    ),
                  ),
              ],
            ),
            actions: () {
              if (_currentStep == PaymentStep.paymentSuccess && widget.onPaymentSuccess != null) {
                return [
                  ElevatedButton(
                    onPressed: widget.onPaymentSuccess,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.tertiary,
                      foregroundColor: colorScheme.onTertiary,
                    ),
                    child: Text(AppLocalizations.of(context).xboardConfirm),
                  ),
                ];
              } else if (_currentStep == PaymentStep.waitingPayment && widget.onClose != null) {
                return [
                  TextButton(
                    onPressed: widget.onClose,
                    child: Text(AppLocalizations.of(context).xboardHandleLater),
                  ),
                ];
              }
              return null;
            }(),
          ),
        ),
      ),
    );
  }
}
class PaymentWaitingManager {
  static OverlayEntry? _overlayEntry;
  static GlobalKey<_PaymentWaitingOverlayState>? _overlayKey;
  static VoidCallback? _onClose;
  static VoidCallback? _onPaymentSuccess;
  static void show(
    BuildContext context, {
    VoidCallback? onClose,
    VoidCallback? onPaymentSuccess,
    String? tradeNo,
  }) {
    _logger.debug('[PaymentWaitingManager.show] 准备显示支付等待弹窗');
    _logger.debug('[PaymentWaitingManager.show] onClose 是否为 null: ${onClose == null}');
    _logger.debug('[PaymentWaitingManager.show] onPaymentSuccess 是否为 null: ${onPaymentSuccess == null}');
    hide(); // 确保之前的overlay被清除
    _onClose = onClose;
    _onPaymentSuccess = onPaymentSuccess;
    _logger.debug('[PaymentWaitingManager.show] 静态变量已设置，_onPaymentSuccess 是否为 null: ${_onPaymentSuccess == null}');
    _overlayKey = GlobalKey<_PaymentWaitingOverlayState>();
    _overlayEntry = OverlayEntry(
      builder: (context) => PaymentWaitingOverlay(
        key: _overlayKey,
        onClose: () {
          hide();
          _onClose?.call();
        },
        onPaymentSuccess: () {
          _logger.debug('[PaymentWaitingManager] 收到支付成功通知，准备处理');
          // 先保存回调，再隐藏弹窗（因为hide()会清空回调）
          final callback = _onPaymentSuccess;
          _logger.debug('[PaymentWaitingManager] 保存的回调是否为 null: ${callback == null}');
          hide();
          _logger.debug('[PaymentWaitingManager] 弹窗已隐藏，准备调用外部回调');
          if (callback != null) {
            _logger.debug('[PaymentWaitingManager] 外部回调存在，开始调用');
            callback.call();
            _logger.debug('[PaymentWaitingManager] 外部回调调用完成');
          } else {
            _logger.debug('[PaymentWaitingManager] 警告：外部回调为 null');
          }
        },
        tradeNo: tradeNo,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }
  static void updateStep(PaymentStep step) {
    _overlayKey?.currentState?.updateStep(step);
  }
  static void updateTradeNo(String tradeNo) {
    _overlayKey?.currentState?.updateTradeNo(tradeNo);
  }
  static void updatePaymentUrl(String paymentUrl) {
    _overlayKey?.currentState?.updatePaymentUrl(paymentUrl);
  }
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _overlayKey = null;
    _onClose = null;
    _onPaymentSuccess = null;
  }
}
