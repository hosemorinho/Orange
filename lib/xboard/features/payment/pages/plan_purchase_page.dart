import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/payment/providers/xboard_payment_provider.dart';
import 'package:fl_clash/xboard/adapter/state/payment_state.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import '../widgets/payment_waiting_overlay.dart';
import '../widgets/payment_method_selector_dialog.dart';
import '../widgets/coupon_input_section.dart';
import '../widgets/plan_header_card.dart';
import '../widgets/period_selector.dart';
import '../widgets/price_summary_card.dart';
import '../widgets/plan_conflict_dialog.dart';
import '../widgets/order_confirm_dialog.dart';
import '../utils/price_calculator.dart';
import '../models/payment_step.dart';
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

  // 用户余额
  double? _userBalance;
  bool _isLoadingBalance = false;

  // 优惠券状态
  final TextEditingController _couponController = TextEditingController();
  bool _isCouponValidating = false;
  bool? _isCouponValid;          // null=未验证, true=有效, false=无效
  String? _couponErrorMessage;
  int? _couponType;              // 1=固定金额(分), 2=百分比
  int? _couponValue;
  String? _validatedCouponCode;  // 验证通过的代码（传给下单接口）

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
    setState(() => _isLoadingBalance = true);
    try {
      // 使用 xboardUserProvider 获取用户信息
      final userInfo = ref.read(xboardUserProvider).userInfo;

      if (mounted) {
        setState(() => _userBalance = userInfo?.balanceInYuan);
      }
    } catch (e) {
      _logger.debug('[购买] 加载用户余额失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingBalance = false);
      }
    }
  }

  Future<void> _checkPlanConflict() async {
    final subscriptionAsync = ref.read(getSubscriptionProvider);
    final subscription = subscriptionAsync.valueOrNull;
    if (subscription == null) return;

    final isSamePlan = subscription.planId == widget.plan.id;
    if (isSamePlan) return;

    final hasActive = _isSubscriptionActive(subscription);
    if (!hasActive) return;

    if (!mounted) return;
    final shouldContinue = await PlanConflictDialog.show(context);
    if (!shouldContinue && mounted) {
      Navigator.of(context).pop();
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
            _couponErrorMessage = AppLocalizations.of(context).xboardUnsupportedCouponType;
          });
        }
      } else {
        setState(() {
          _isCouponValid = false;
          _couponErrorMessage = AppLocalizations.of(context).xboardInvalidOrExpiredCoupon;
        });
      }
    } catch (e) {
      setState(() {
        _isCouponValid = false;
        _couponErrorMessage = e.toString();
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
      XBoardNotification.showError(AppLocalizations.of(context).xboardPleaseSelectPaymentPeriod);
      return;
    }

    try {
      String? tradeNo;
      _logger.debug('[购买] 开始购买流程，套餐ID: ${widget.plan.id}, 周期: $_selectedPeriod');

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
        final errorMessage = ref.read(userUIStateProvider).errorMessage;
        throw Exception('${AppLocalizations.of(context).xboardOrderCreationFailed}: $errorMessage');
      }

      _logger.debug('[购买] 订单创建成功: $tradeNo');
      PaymentWaitingManager.updateTradeNo(tradeNo);

      // 计算实付金额（使用优惠后的价格）
      final displayFinalPrice = _couponType != null
          ? PriceCalculator.calculateFinalPrice(_getCurrentPrice(), _couponType, _couponValue)
          : _getCurrentPrice();
      final balanceToUse = _userBalance != null && _userBalance! > 0
          ? (_userBalance! > displayFinalPrice ? displayFinalPrice : _userBalance!)
          : 0.0;
      final actualPayAmount = displayFinalPrice - balanceToUse;

      _logger.debug('[购买] 实付金额: $actualPayAmount (价格: $displayFinalPrice, 余额抵扣: $balanceToUse)');

      // 使用 xboardAvailablePaymentMethodsProvider 获取支付方式
      var paymentMethods = ref.read(xboardAvailablePaymentMethodsProvider);

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
        throw Exception(AppLocalizations.of(context).xboardNoPaymentMethodsAvailable);
      }

      DomainPaymentMethod? selectedMethod;

      // 如果实付金额为0（余额完全抵扣），自动选择第一个支付方式，跳过用户选择
      if (actualPayAmount <= 0) {
        _logger.debug('[购买] 实付金额为0，自动选择第一个支付方式');
        selectedMethod = paymentMethods.first;
        // 显示支付等待页面
        if (mounted) {
          _showPaymentWaiting(tradeNo);
        }
      } else {
        // 需要实际支付，让用户选择支付方式
        selectedMethod = await _selectPaymentMethod(paymentMethods, tradeNo);
        if (selectedMethod == null) return;
      }

      // Show order confirmation dialog
      final basePrice = _getCurrentPrice();
      final couponDiscount = _couponType != null
          ? PriceCalculator.calculateDiscountAmount(basePrice, _couponType, _couponValue)
          : null;
      final priceAfterCoupon = _couponType != null
          ? PriceCalculator.calculateFinalPrice(basePrice, _couponType, _couponValue)
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
        XBoardNotification.showError(AppLocalizations.of(context).xboardOperationFailedError(e.toString()));
      }
    }
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
      XBoardNotification.showSuccess(AppLocalizations.of(context).xboardPaymentSuccess);
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

  Future<DomainPaymentMethod?> _selectPaymentMethod(
    List<DomainPaymentMethod> methods,
    String tradeNo,
  ) async {
    if (methods.length == 1) {
      // 单一支付方式，直接显示等待页面并返回
      if (mounted) {
        _showPaymentWaiting(tradeNo);
      }
      return methods.first;
    }

    PaymentWaitingManager.hide();
    if (!mounted) return null;

    final selected = await showPaymentMethodSelector(
      context,
      paymentMethods: methods,
    );

    if (selected == null) {
      _logger.debug('[支付] 用户取消选择支付方式');
      return null;
    }

    if (mounted) {
      _showPaymentWaiting(tradeNo);
    }

    return selected;
  }

  Future<void> _submitPayment(String tradeNo, DomainPaymentMethod method) async {
    _logger.debug('[支付] 提交支付: $tradeNo, 方式: ${method.id}');
      PaymentWaitingManager.updateStep(PaymentStep.loadingPayment);
      PaymentWaitingManager.updateStep(PaymentStep.verifyPayment);

    final paymentNotifier = ref.read(xboardPaymentProvider.notifier);
      final paymentResult = await paymentNotifier.submitPayment(
        tradeNo: tradeNo,
      method: method.id.toString(),
      );

    if (paymentResult == null) {
      throw Exception(AppLocalizations.of(context).xboardPaymentFailedEmptyResult);
    }

    if (!mounted) return;

    final paymentType = paymentResult['type'] as int? ?? 0;
    final paymentData = paymentResult['data'];

    _logger.debug('[支付] type=$paymentType, data=$paymentData (${paymentData.runtimeType})');

    // type: -1 余额支付成功（data 是 bool）
    // type: 0 跳转支付（data 是 String）
    // type: 1 二维码支付（data 是 String）
    if (paymentType == -1) {
      // 免费订单/余额支付，data 是 bool
      if (paymentData == true) {
        await _handleBalancePaymentSuccess();
      } else {
        throw Exception(AppLocalizations.of(context).xboardPaymentFailedBalanceError);
      }
    } else if (paymentData != null && paymentData is String && paymentData.isNotEmpty) {
      // 付费订单，data 是支付URL（String）
      PaymentWaitingManager.updateStep(PaymentStep.waitingPayment);
      await _launchPaymentUrl(paymentData, tradeNo);
    } else {
      throw Exception(AppLocalizations.of(context).xboardPaymentFailedInvalidData);
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
            XBoardNotification.showSuccess(AppLocalizations.of(context).xboardPaymentSuccess);

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
          throw Exception(AppLocalizations.of(context).xboardCannotOpenPaymentUrl);
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
        XBoardNotification.showError(AppLocalizations.of(context).xboardOpenPaymentPageError(e.toString()));
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
    // 用于判断平台类型
    final isPlatformDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;

    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1200,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isDesktopLayout
              ? _buildTwoColumnLayout(context, periods, currentPrice, colorScheme)
              : _buildSingleColumnLayout(context, periods, currentPrice, colorScheme),
        ),
      ),
    );

    // 桌面端嵌入模式：只返回内容（外层已有 Scaffold）
    if (widget.embedded) {
      return content;
    }

    // 移动端全屏或独立页面：带 AppBar 的 Scaffold
    return Scaffold(
      appBar: isPlatformDesktop ? null : AppBar(
        title: Text(AppLocalizations.of(context).xboardPurchaseSubscription),
      ),
      body: content,
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
              const SizedBox(height: 16),
              _buildPeriodSelectorCard(context, periods, colorScheme),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Right column: Payment details
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildCouponCard(context, colorScheme),
              const SizedBox(height: 16),
              _buildPaymentDetailsCard(context, currentPrice, colorScheme),
              const SizedBox(height: 16),
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
        _buildPlanSummaryCard(context, colorScheme),
        const SizedBox(height: 16),
        _buildPeriodSelectorCard(context, periods, colorScheme),
        const SizedBox(height: 16),
        _buildCouponCard(context, colorScheme),
        const SizedBox(height: 16),
        _buildPaymentDetailsCard(context, currentPrice, colorScheme),
        const SizedBox(height: 16),
        _buildActionButtons(context, colorScheme),
      ],
    );
  }

  // Coupon card
  Widget _buildCouponCard(BuildContext context, ColorScheme colorScheme) {
    final currentPrice = _getCurrentPrice();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: CouponInputSection(
        controller: _couponController,
        isValidating: _isCouponValidating,
        isValid: _isCouponValid,
        errorMessage: _couponErrorMessage,
        discountAmount: _couponType != null
            ? PriceCalculator.calculateDiscountAmount(currentPrice, _couponType, _couponValue)
            : null,
        onValidate: _validateCoupon,
        onChanged: _onCouponChanged,
      ),
    );
  }

  // Plan summary card
  Widget _buildPlanSummaryCard(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).xboardPlanSummary,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          PlanHeaderCard(plan: widget.plan),
        ],
      ),
    );
  }

  // Period selector card
  Widget _buildPeriodSelectorCard(
    BuildContext context,
    List<Map<String, dynamic>> periods,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: PeriodSelector(
        periods: periods,
        selectedPeriod: _selectedPeriod,
        couponType: _couponType,
        couponValue: _couponValue,
        onPeriodSelected: (period) {
          setState(() {
            _selectedPeriod = period;
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).xboardPaymentDetails,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          // Price summary
          if (_selectedPeriod != null)
            PriceSummaryCard(
              originalPrice: currentPrice,
              finalPrice: _couponType != null
                  ? PriceCalculator.calculateFinalPrice(currentPrice, _couponType, _couponValue)
                  : null,
              discountAmount: _couponType != null
                  ? PriceCalculator.calculateDiscountAmount(currentPrice, _couponType, _couponValue)
                  : null,
              userBalance: _userBalance,
            ),
        ],
      ),
    );
  }

  // Action buttons
  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Consumer(
        builder: (context, ref, child) {
          final paymentState = ref.watch(userUIStateProvider);
          return FilledButton.tonal(
            onPressed: paymentState.isLoading ? null : _proceedToPurchase,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: paymentState.isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context).xboardProcessing,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  )
                : Text(
                    AppLocalizations.of(context).xboardContinueToPayment,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
