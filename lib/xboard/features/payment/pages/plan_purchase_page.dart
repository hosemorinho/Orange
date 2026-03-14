import 'package:flutter/material.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/payment/providers/xboard_payment_provider.dart';
import 'package:fl_clash/xboard/features/payment/providers/payment_ui_state_provider.dart';
import 'package:fl_clash/xboard/adapter/state/payment_state.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/features/shared/widgets/xb_purchase_card.dart';
import '../widgets/payment_waiting_overlay.dart';
import '../widgets/coupon_input_section.dart';
import '../widgets/plan_header_card.dart';
import '../widgets/period_selector.dart';
import '../widgets/price_summary_card.dart';
import '../widgets/plan_conflict_dialog.dart';
import '../widgets/order_confirm_dialog.dart';
import '../utils/price_calculator.dart';
import '../models/payment_step.dart';

import '../utils/purchase_error_handler.dart';
import '../widgets/mobile/mobile_sticky_action_panel.dart';
import '../widgets/mobile/purchase_error_sheet.dart';
import 'package:fl_clash/xboard/adapter/state/subscription_state.dart';

// 初始化文件级日志器
final _logger = FileLogger('plan_purchase_page.dart');

/// 套餐购买页面
class PlanPurchasePage extends ConsumerStatefulWidget {
  final DomainPlan plan;
  final bool embedded; // 是否为嵌入模式（桌面端页面内切换时使用）
  final VoidCallback? onBack; // 返回回调

  const PlanPurchasePage({
    super.key,
    required this.plan,
    this.embedded = false,
    this.onBack,
  });

  @override
  ConsumerState<PlanPurchasePage> createState() => _PlanPurchasePageState();
}

class _PlanPurchasePageState extends ConsumerState<PlanPurchasePage> {
  // 周期选择
  String? _selectedPeriod;
  bool _isMobilePlanSectionExpanded = true;

  // 用户余额
  double? _userBalance;
  int? _selectedPaymentMethodId;

  // 优惠券状态
  final TextEditingController _couponController = TextEditingController();
  bool _isCouponValidating = false;
  bool? _isCouponValid; // null=未验证, true=有效, false=无效
  String? _couponErrorMessage;
  int? _couponType; // 1=固定金额(分), 2=百分比
  int? _couponValue;
  String? _validatedCouponCode; // 验证通过的代码（传给下单接口）

  @override
  void initState() {
    super.initState();
    // 确保 PaymentProvider 被初始化，以便开始加载支付方式
    ref.read(xboardPaymentProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final periods = _getAvailablePeriods(context);
      if (periods.isNotEmpty && _selectedPeriod == null) {
        setState(() {
          _selectedPeriod = periods.first['period'];
        });
      }
      _loadUserBalance();
      await _loadPaymentMethods();

      // Check plan conflict: warn if buying a different plan while active
      await _checkPlanConflict();
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  // ========== 数据加载 ==========

  Future<void> _loadUserBalance() async {
    try {
      // 使用 xboardUserProvider 获取用户信息
      final userInfo = ref.read(xboardUserProvider).userInfo;

      if (mounted) {
        setState(() => _userBalance = userInfo?.balanceInYuan);
      }
    } catch (e) {
      _logger.debug('[购买] 加载用户余额失败: $e');
    }
  }

  Future<List<DomainPaymentMethod>> _loadPaymentMethods({
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      ref.invalidate(getPaymentMethodsProvider);
    }
    await ref.read(xboardPaymentProvider.notifier).loadPaymentMethods();
    final methods = ref.read(xboardAvailablePaymentMethodsProvider);
    if (mounted && methods.isNotEmpty) {
      final hasSelected =
          _selectedPaymentMethodId != null &&
          methods.any((m) => m.id == _selectedPaymentMethodId);
      if (!hasSelected) {
        setState(() {
          _selectedPaymentMethodId = methods.first.id;
        });
      }
    }
    return methods;
  }

  DomainPaymentMethod? _getSelectedPaymentMethod(
    List<DomainPaymentMethod> methods,
  ) {
    if (methods.isEmpty) return null;
    for (final method in methods) {
      if (method.id == _selectedPaymentMethodId) {
        return method;
      }
    }
    return methods.first;
  }

  Future<void> _checkPlanConflict() async {
    // Use cached subscription first (populated during login/quickAuth),
    // fall back to awaiting the async provider if cache is empty.
    var subscription = ref.read(subscriptionInfoProvider);
    if (subscription == null) {
      try {
        subscription = await ref.read(getSubscriptionProvider.future);
      } catch (_) {
        return;
      }
    }
    if (subscription == null) return;

    final isSamePlan = subscription.planId == widget.plan.id;
    if (isSamePlan) return;

    final hasActive = _isSubscriptionActive(subscription);
    if (!hasActive) return;

    if (!mounted) return;
    final shouldContinue = await PlanConflictDialog.show(context);
    if (!shouldContinue && mounted) {
      if (widget.embedded) {
        widget.onBack?.call();
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  bool _isSubscriptionActive(DomainSubscription sub) {
    if (sub.expiredAt == null) {
      // No expiry → check if has remaining traffic
      return sub.transferLimit > sub.totalUsedBytes;
    } else {
      return !sub.isExpired;
    }
  }

  String _getSelectedPeriodLabel() {
    if (_selectedPeriod == null) return '';
    final periods = _getAvailablePeriods(context);
    final selected = periods.firstWhere(
      (p) => p['period'] == _selectedPeriod,
      orElse: () => {},
    );
    return (selected['label'] as String?) ?? '';
  }

  List<Map<String, dynamic>> _getAvailablePeriods(BuildContext context) {
    final List<Map<String, dynamic>> periods = [];
    final plan = widget.plan;
    final l10n = AppLocalizations.of(context);

    // 只添加有效价格的周期（不为 null 且大于 0）
    // 参考 V2Board API: OrderController.php:92-94
    if (plan.monthlyPrice != null && plan.monthlyPrice! > 0) {
      periods.add({
        'period': 'month_price',
        'label': l10n.xboardMonthlyPayment,
        'price': plan.monthlyPrice!,
        'description': l10n.xboardMonthlyRenewal,
      });
    }
    if (plan.quarterlyPrice != null && plan.quarterlyPrice! > 0) {
      periods.add({
        'period': 'quarter_price',
        'label': l10n.xboardQuarterlyPayment,
        'price': plan.quarterlyPrice!,
        'description': l10n.xboardThreeMonthCycle,
      });
    }
    if (plan.halfYearlyPrice != null && plan.halfYearlyPrice! > 0) {
      periods.add({
        'period': 'half_year_price',
        'label': l10n.xboardHalfYearlyPayment,
        'price': plan.halfYearlyPrice!,
        'description': l10n.xboardSixMonthCycle,
      });
    }
    if (plan.yearlyPrice != null && plan.yearlyPrice! > 0) {
      periods.add({
        'period': 'year_price',
        'label': l10n.xboardYearlyPayment,
        'price': plan.yearlyPrice!,
        'description': l10n.xboardTwelveMonthCycle,
      });
    }
    if (plan.twoYearPrice != null && plan.twoYearPrice! > 0) {
      periods.add({
        'period': 'two_year_price',
        'label': l10n.xboardTwoYearPayment,
        'price': plan.twoYearPrice!,
        'description': l10n.xboardTwentyFourMonthCycle,
      });
    }
    if (plan.threeYearPrice != null && plan.threeYearPrice! > 0) {
      periods.add({
        'period': 'three_year_price',
        'label': l10n.xboardThreeYearPayment,
        'price': plan.threeYearPrice!,
        'description': l10n.xboardThirtySixMonthCycle,
      });
    }
    if (plan.onetimePrice != null && plan.onetimePrice! > 0) {
      periods.add({
        'period': 'onetime_price',
        'label': l10n.xboardOneTimePayment,
        'price': plan.onetimePrice!,
        'description': l10n.xboardBuyoutPlan,
      });
    }
    if (plan.resetPrice != null && plan.resetPrice! > 0) {
      periods.add({
        'period': 'reset_price',
        'label': l10n.xboardResetTraffic,
        'price': plan.resetPrice!,
        'description': l10n.xboardResetTrafficDescription,
      });
    }

    return periods;
  }

  double _getCurrentPrice() {
    if (_selectedPeriod == null) return 0.0;
    final periods = _getAvailablePeriods(context);
    final selectedPeriod = periods.firstWhere(
      (period) => period['period'] == _selectedPeriod,
      orElse: () => {},
    );
    return selectedPeriod['price']?.toDouble() ?? 0.0;
  }

  double _getOrderTotalAmount() {
    if (_selectedPeriod == null) return 0.0;

    final currentPrice = _getCurrentPrice();
    final displayFinalPrice = _couponType != null
        ? PriceCalculator.calculateFinalPrice(
            currentPrice,
            _couponType,
            _couponValue,
          )
        : currentPrice;

    final paymentMethods = ref.watch(xboardAvailablePaymentMethodsProvider);
    final selectedMethod = _getSelectedPaymentMethod(paymentMethods);
    final fee = selectedMethod?.calculateFee(displayFinalPrice) ?? 0.0;

    return displayFinalPrice + fee;
  }

  // ========== 优惠券 ==========

  Future<void> _validateCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isCouponValidating = true;
      _isCouponValid = null;
      _couponErrorMessage = null;
    });

    try {
      final api = await ref.read(xboardSdkProvider.future);
      final json = await api.checkCoupon(code, widget.plan.id);
      final data = json['data'];

      if (data is Map<String, dynamic>) {
        final type = data['type'] as int?;
        final value = data['value'] as int?;

        if (type == 1 || type == 2) {
          setState(() {
            _isCouponValid = true;
            _couponType = type;
            _couponValue = value;
            _validatedCouponCode = code;
          });
        } else {
          setState(() {
            _isCouponValid = false;
            _couponErrorMessage = AppLocalizations.of(
              context,
            ).xboardUnsupportedCouponType;
          });
        }
      } else {
        setState(() {
          _isCouponValid = false;
          _couponErrorMessage = AppLocalizations.of(
            context,
          ).xboardInvalidOrExpiredCoupon;
        });
      }
    } catch (e) {
      setState(() {
        _isCouponValid = false;
        _couponErrorMessage = ErrorSanitizer.sanitize(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isCouponValidating = false);
      }
    }
  }

  void _onCouponChanged() {
    if (_isCouponValid != null) {
      setState(() {
        _isCouponValid = null;
        _couponErrorMessage = null;
        _couponType = null;
        _couponValue = null;
        _validatedCouponCode = null;
      });
    }
  }

  // ========== 购买流程 ==========

  Future<void> _proceedToPurchase() async {
    if (_selectedPeriod == null) {
      XBoardNotification.showError(
        AppLocalizations.of(context).xboardPleaseSelectPaymentPeriod,
      );
      return;
    }

    try {
      String? tradeNo;
      _logger.debug(
        '[购买] 开始购买流程，套餐ID: ${widget.plan.id}, 周期: $_selectedPeriod',
      );

      // 显示支付等待页面
      if (mounted) {
        _showPaymentWaiting(null);
        PaymentWaitingManager.updateStep(PaymentStep.cancelingOrders);
      }

      // 创建订单
      _logger.debug('[购买] 创建订单');
      PaymentWaitingManager.updateStep(PaymentStep.createOrder);

      final paymentNotifier = ref.read(xboardPaymentProvider.notifier);
      tradeNo = await paymentNotifier.createOrder(
        planId: widget.plan.id,
        period: _selectedPeriod!,
        couponCode: _validatedCouponCode,
      );

      if (tradeNo == null) {
        final errorMessage = ref
            .read(paymentUIStateNotifierProvider)
            .errorMessage;
        throw Exception(
          '${AppLocalizations.of(context).xboardOrderCreationFailed}: $errorMessage',
        );
      }

      _logger.debug('[购买] 订单创建成功: $tradeNo');
      PaymentWaitingManager.updateTradeNo(tradeNo);

      // 计算实付金额（使用优惠后的价格）
      final displayFinalPrice = _couponType != null
          ? PriceCalculator.calculateFinalPrice(
              _getCurrentPrice(),
              _couponType,
              _couponValue,
            )
          : _getCurrentPrice();
      final balanceToUse = _userBalance != null && _userBalance! > 0
          ? (_userBalance! > displayFinalPrice
                ? displayFinalPrice
                : _userBalance!)
          : 0.0;
      final actualPayAmount = displayFinalPrice - balanceToUse;

      _logger.debug(
        '[购买] 实付金额: $actualPayAmount (价格: $displayFinalPrice, 余额抵扣: $balanceToUse)',
      );

      // 使用 xboardAvailablePaymentMethodsProvider 获取支付方式
      var paymentMethods = await _loadPaymentMethods(forceRefresh: true);

      // 如果支付方式为空，尝试重新加载
      if (paymentMethods.isEmpty) {
        _logger.info('[购买] 支付方式列表为空，尝试重新加载...');
        ref.invalidate(getPaymentMethodsProvider);
        await ref.read(xboardPaymentProvider.notifier).loadPaymentMethods();
        paymentMethods = ref.read(xboardAvailablePaymentMethodsProvider);
      }

      _logger.info('[购买] 获取到的支付方式数量: ${paymentMethods.length}');
      if (paymentMethods.isNotEmpty) {
        _logger.info('[购买] 支付方式列表:');
        for (var method in paymentMethods) {
          _logger.info('  - ${method.name} (id: ${method.id})');
        }
      } else {
        _logger.error('[购买] 支付方式列表为空！');
      }

      if (paymentMethods.isEmpty) {
        throw Exception(
          AppLocalizations.of(context).xboardNoPaymentMethodsAvailable,
        );
      }

      final selectedMethod = _getSelectedPaymentMethod(paymentMethods);
      if (selectedMethod == null) {
        throw Exception(
          AppLocalizations.of(context).xboardNoPaymentMethodsAvailable,
        );
      }

      _logger.debug(
        '[购买] 使用支付方式: ${selectedMethod.name} (id: ${selectedMethod.id})',
      );

      // Show order confirmation dialog
      final basePrice = _getCurrentPrice();
      final couponDiscount = _couponType != null
          ? PriceCalculator.calculateDiscountAmount(
              basePrice,
              _couponType,
              _couponValue,
            )
          : null;
      final priceAfterCoupon = _couponType != null
          ? PriceCalculator.calculateFinalPrice(
              basePrice,
              _couponType,
              _couponValue,
            )
          : basePrice;
      final fee = selectedMethod.calculateFee(priceAfterCoupon);
      final totalBeforeBalance = priceAfterCoupon + fee;

      PaymentWaitingManager.hide();
      if (!mounted) return;
      final confirmed = await OrderConfirmDialog.show(
        context,
        plan: widget.plan,
        periodLabel: _getSelectedPeriodLabel(),
        basePrice: basePrice,
        couponDiscount: couponDiscount,
        paymentMethod: selectedMethod,
        totalAmount: totalBeforeBalance,
      );
      if (!confirmed) return;

      // Resume payment waiting and submit
      if (mounted) _showPaymentWaiting(tradeNo);
      await _submitPayment(tradeNo, selectedMethod);
    } catch (e) {
      _logger.error('购买流程出错: $e');
      if (mounted) {
        PaymentWaitingManager.hide();
        
        // 使用新的错误处理机制
        final recovery = PurchaseErrorHandler.handle(e);
        
        await PurchaseErrorSheet.show(
          context,
          recovery: recovery,
          onRetry: recovery.canRetry ? _handleRetryFromError : null,
        );
      }
    }
  }
  /// 导航到订单列表
  void _navigateToOrderList() {
    Navigator.of(context).pop();
    // 导航到订单页面
    context.push('/xboard/orders');
  }

  void _showPaymentWaiting(String? tradeNo) {
    PaymentWaitingManager.show(
      context,
      onClose: () => Navigator.of(context).pop(),
      onPaymentSuccess: _handlePaymentSuccess,
      tradeNo: tradeNo,
    );
  }

  void _handlePaymentSuccess() {
    _logger.info('[支付成功] 处理支付成功回调');
    try {
      final userProvider = ref.read(xboardUserProvider.notifier);
      userProvider.refreshSubscriptionInfoAfterPayment();
    } catch (e) {
      _logger.info('[支付成功] 刷新订阅信息失败: $e');
    }

    if (mounted) {
      XBoardNotification.showSuccess(
        AppLocalizations.of(context).xboardPaymentSuccess,
      );
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        try {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } catch (e) {
          _logger.info('[支付成功] 导航失败: $e');
        }
      }
    });
  }

  Future<void> _submitPayment(
    String tradeNo,
    DomainPaymentMethod method,
  ) async {
    _logger.debug('[支付] 提交支付: $tradeNo, 方式: ${method.id}');
    PaymentWaitingManager.updateStep(PaymentStep.loadingPayment);
    PaymentWaitingManager.updateStep(PaymentStep.verifyPayment);

    final paymentNotifier = ref.read(xboardPaymentProvider.notifier);
    final paymentResult = await paymentNotifier.submitPayment(
      tradeNo: tradeNo,
      method: method.id.toString(),
    );

    if (paymentResult == null) {
      throw Exception(
        AppLocalizations.of(context).xboardPaymentFailedEmptyResult,
      );
    }

    if (!mounted) return;

    final paymentType = paymentResult['type'] as int? ?? 0;
    final paymentData = paymentResult['data'];

    _logger.debug(
      '[支付] type=$paymentType, data=$paymentData (${paymentData.runtimeType})',
    );

    // type: -1 余额支付成功（data 是 bool）
    // type: 0 跳转支付（data 是 String）
    // type: 1 二维码支付（data 是 String）
    if (paymentType == -1) {
      // 免费订单/余额支付，data 是 bool
      if (paymentData == true) {
        await _handleBalancePaymentSuccess();
      } else {
        throw Exception(
          AppLocalizations.of(context).xboardPaymentFailedBalanceError,
        );
      }
    } else if (paymentData != null &&
        paymentData is String &&
        paymentData.isNotEmpty) {
      // 付费订单，data 是支付URL（String）
      PaymentWaitingManager.updateStep(PaymentStep.waitingPayment);
      await _launchPaymentUrl(paymentData, tradeNo);
    } else {
      throw Exception(
        AppLocalizations.of(context).xboardPaymentFailedInvalidData,
      );
    }
  }

  Future<void> _handleBalancePaymentSuccess() async {
    _logger.debug('[支付] 余额支付成功');
    PaymentWaitingManager.hide();

    try {
      final userProvider = ref.read(xboardUserProvider.notifier);
      userProvider.refreshSubscriptionInfoAfterPayment();
    } catch (e) {
      _logger.debug('[余额支付] 刷新订阅信息失败: $e');
    }

    if (mounted) {
      XBoardNotification.showSuccess(
        AppLocalizations.of(context).xboardPaymentSuccess,
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          try {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } catch (e) {
            _logger.debug('[余额支付] 导航失败: $e');
          }
        }
      });
    }
  }

  Future<void> _launchPaymentUrl(String url, String tradeNo) async {
    try {
      if (!mounted) return;

      await Clipboard.setData(ClipboardData(text: url));
      final uri = Uri.parse(url);

      if (!await canLaunchUrl(uri)) {
        throw Exception(
          AppLocalizations.of(context).xboardCannotOpenPaymentUrl,
        );
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception(AppLocalizations.of(context).xboardCannotLaunchBrowser);
      }

      _logger.debug('[支付] 支付页面已在浏览器中打开: $tradeNo');
    } catch (e) {
      if (mounted) {
        PaymentWaitingManager.hide();
        XBoardNotification.showError(
          AppLocalizations.of(
            context,
          ).xboardOpenPaymentPageError(ErrorSanitizer.sanitize(e.toString())),
        );
      }
    }
  }

  // ========== UI 构建 ==========

  @override
  Widget build(BuildContext context) {
    final periods = _getAvailablePeriods(context);
    final currentPrice = _getCurrentPrice();
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopLayout = screenWidth > 900;
    final bodyBottomPadding = isDesktopLayout ? 14.0 : 92.0;

    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1160),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(12, 12, 12, bodyBottomPadding),
          child: isDesktopLayout
              ? _buildTwoColumnLayout(
                  context,
                  periods,
                  currentPrice,
                  colorScheme,
                )
              : _buildSingleColumnLayout(
                  context,
                  periods,
                  currentPrice,
                  colorScheme,
                ),
        ),
      ),
    );

    // 桌面端嵌入模式：只返回内容（外层已有 Scaffold）
    if (widget.embedded) {
      return content;
    }

    // 全屏或独立页面：带 AppBar 的 Scaffold（包含返回按钮）
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(AppLocalizations.of(context).xboardPurchaseSubscription),
      ),
      body: content,
      bottomNavigationBar: isDesktopLayout
          ? null
          : _buildMobileStickyActionBar(context, colorScheme),
    );
  }

  // Two-column layout for desktop
  Widget _buildTwoColumnLayout(
    BuildContext context,
    List<Map<String, dynamic>> periods,
    double currentPrice,
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: Plan summary
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildPlanSummaryCard(context, colorScheme),
              const SizedBox(height: 12),
              _buildPeriodSelectorCard(context, periods, colorScheme),
            ],
          ),
        ),
        const SizedBox(width: 14),
        // Right column: Payment details
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildCouponCard(context, colorScheme),
              const SizedBox(height: 12),
              _buildPaymentDetailsCard(context, currentPrice, colorScheme),
              const SizedBox(height: 12),
              _buildActionButtons(context, colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  // Single-column layout for mobile
  Widget _buildSingleColumnLayout(
    BuildContext context,
    List<Map<String, dynamic>> periods,
    double currentPrice,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMobilePlanAndPeriodSection(
          context,
          periods,
          currentPrice,
          colorScheme,
        ),
        const SizedBox(height: 12),
        _buildCouponCard(context, colorScheme),
        const SizedBox(height: 12),
        _buildPaymentDetailsCard(context, currentPrice, colorScheme),
        if (widget.embedded) ...[
          const SizedBox(height: 16),
          _buildActionButtons(context, colorScheme),
        ],
      ],
    );
  }

  Widget _buildMobileStickyActionBar(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final totalAmount = _getOrderTotalAmount();
    final hasPeriodSelected = _selectedPeriod != null;
    final basePrice = _getCurrentPrice();
    
    // 计算折扣金额
    final couponDiscount = _couponType != null
        ? PriceCalculator.calculateDiscountAmount(
            basePrice,
            _couponType,
            _couponValue,
          )
        : 0.0;

    // 检查是否正在处理中
    final isProcessing = ref.read(paymentUIStateNotifierProvider).isLoading;

    return MobileStickyActionPanel(
      originalPrice: basePrice,
      discountAmount: couponDiscount > 0 ? couponDiscount : null,
      totalAmount: totalAmount,
      balanceToUse: null,
      isProcessing: isProcessing,
      hasPeriodSelected: hasPeriodSelected,
      onPurchase: _proceedToPurchase,
    );
  }

  /// 从错误弹窗重试
  void _handleRetryFromError() {
    // 清除之前的错误状态
    ref.read(paymentUIStateNotifierProvider.notifier).clearError();
    // 重新尝试购买
    _proceedToPurchase();
  }

  Widget _buildMobilePlanAndPeriodSection(
    BuildContext context,
    List<Map<String, dynamic>> periods,
    double currentPrice,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPlanSummaryCard(context, colorScheme),
        const SizedBox(height: 12),
        _buildPeriodSelectorCard(context, periods, colorScheme),
      ],
    );
  }

  // Coupon card
  Widget _buildCouponCard(BuildContext context, ColorScheme colorScheme) {
    final currentPrice = _getCurrentPrice();
    return XBPurchaseCard(
      showShadow: false,
      showBorder: false,
      backgroundColor: colorScheme.surfaceContainerLow,
      child: CouponInputSection(
        controller: _couponController,
        isValidating: _isCouponValidating,
        isValid: _isCouponValid,
        errorMessage: _couponErrorMessage,
        discountAmount: _couponType != null
            ? PriceCalculator.calculateDiscountAmount(
                currentPrice,
                _couponType,
                _couponValue,
              )
            : null,
        onValidate: _validateCoupon,
        onChanged: _onCouponChanged,
      ),
    );
  }

  // Plan summary card
  Widget _buildPlanSummaryCard(BuildContext context, ColorScheme colorScheme) {
    return PlanHeaderCard(plan: widget.plan);
  }

  // Period selector card
  Widget _buildPeriodSelectorCard(
    BuildContext context,
    List<Map<String, dynamic>> periods,
    ColorScheme colorScheme,
  ) {
    return XBPurchaseCard(
      showShadow: false,
      showBorder: false,
      backgroundColor: colorScheme.surfaceContainerLow,
      child: PeriodSelector(
        periods: periods,
        selectedPeriod: _selectedPeriod,
        couponType: _couponType,
        couponValue: _couponValue,
        onPeriodSelected: (period) {
          setState(() {
            _selectedPeriod = period;
            // Reset coupon validation when period changes,
            // since coupon validity may depend on the selected period/price.
            if (_isCouponValid != null) {
              _isCouponValid = null;
              _couponErrorMessage = null;
              _couponType = null;
              _couponValue = null;
              _validatedCouponCode = null;
              _couponController.clear();
            }
          });
        },
      ),
    );
  }

  // Payment details card
  Widget _buildPaymentDetailsCard(
    BuildContext context,
    double currentPrice,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.of(context);
    final paymentMethods = ref.watch(xboardAvailablePaymentMethodsProvider);
    final selectedMethod = _getSelectedPaymentMethod(paymentMethods);
    final displayFinalPrice = _couponType != null
        ? PriceCalculator.calculateFinalPrice(
            currentPrice,
            _couponType,
            _couponValue,
          )
        : currentPrice;

    return XBPurchaseCard(
      showShadow: false,
      showBorder: false,
      backgroundColor: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment method section
          Row(
            children: [
              Icon(Icons.payment, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.xboardPaymentMethod,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (paymentMethods.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.xboardNoPaymentMethodsAvailable,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _loadPaymentMethods(forceRefresh: true),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(l10n.xboardRefresh),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final method in paymentMethods)
                  ChoiceChip(
                    label: Text(method.name),
                    selected: method.id == (_selectedPaymentMethodId ?? paymentMethods.first.id),
                    onSelected: (selected) {
                      if (!selected) return;
                      setState(() {
                        _selectedPaymentMethodId = method.id;
                      });
                    },
                    labelStyle: TextStyle(
                      color: method.id == (_selectedPaymentMethodId ?? paymentMethods.first.id)
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: method.id == (_selectedPaymentMethodId ?? paymentMethods.first.id)
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    selectedColor: colorScheme.primary,
                    backgroundColor: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: method.id == (_selectedPaymentMethodId ?? paymentMethods.first.id)
                            ? Colors.transparent
                            : colorScheme.outlineVariant,
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          // Price summary
          if (_selectedPeriod != null)
            PriceSummaryCard(
              originalPrice: currentPrice,
              finalPrice: _couponType != null
                  ? PriceCalculator.calculateFinalPrice(
                      currentPrice,
                      _couponType,
                      _couponValue,
                    )
                  : null,
              discountAmount: _couponType != null
                  ? PriceCalculator.calculateDiscountAmount(
                      currentPrice,
                      _couponType,
                      _couponValue,
                    )
                  : null,
              userBalance: _userBalance,
              handlingFee: selectedMethod?.calculateFee(displayFinalPrice),
            ),
        ],
      ),
    );
  }

  // Action buttons
  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Consumer(
        builder: (context, ref, child) {
          final paymentState = ref.watch(paymentUIStateNotifierProvider);
          return FilledButton(
            onPressed: paymentState.isLoading ? null : _proceedToPurchase,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: paymentState.isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context).xboardProcessing,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  )
                : Text(
                    AppLocalizations.of(context).xboardContinueToPayment,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
