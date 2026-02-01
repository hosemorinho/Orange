import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/subscription/providers/xboard_subscription_provider.dart';
import 'plan_purchase_page.dart';
import '../widgets/plan_description_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
class PlansView extends ConsumerStatefulWidget {
  const PlansView({super.key});
  @override
  ConsumerState<PlansView> createState() => _PlansViewState();
}
class _PlansViewState extends ConsumerState<PlansView> {
  DomainPlan? _selectedPlan; // 桌面端选中的套餐
  bool _hasCheckedUrlParams = false; // 标记是否已检查URL参数
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final subscriptionNotifier = ref.read(xboardSubscriptionProvider.notifier);
      subscriptionNotifier.autoRefreshIfNeeded();
      
      // 检查URL参数中是否有planId
      _checkUrlParams();
    });
  }
  
  void _checkUrlParams() {
    if (_hasCheckedUrlParams) return;
    _hasCheckedUrlParams = true;
    
    // 获取URL参数
    final state = GoRouterState.of(context);
    final planIdStr = state.uri.queryParameters['planId'];
    
    if (planIdStr != null) {
      final planId = int.tryParse(planIdStr);
      if (planId != null) {
        // 查找对应的套餐
        final plans = ref.read(xboardSubscriptionProvider);
        DomainPlan? plan;
        try {
          plan = plans.firstWhere((p) => p.id == planId);
        } catch (e) {
          plan = null;
        }
        
        if (plan != null) {
          // UI层：从URL参数选中套餐
          setState(() {
            _selectedPlan = plan;
          });
        }
      }
    }
  }
  
  Future<void> _refreshPlans() async {
    final subscriptionNotifier = ref.read(xboardSubscriptionProvider.notifier);
    await subscriptionNotifier.refreshPlans();
  }
  
  void _backToPlans() {
    setState(() {
      _selectedPlan = null;
    });
  }
  String _formatPrice(double? price) {
    if (price == null) return '-';
    return '¥${price.toStringAsFixed(2)}';
  }
  String _formatTraffic(double transferEnable) {
    if (transferEnable >= 1024) {
      return '${(transferEnable / 1024).toStringAsFixed(1)}TB';
    }
    return '${transferEnable.toStringAsFixed(0)}GB';
  }
  String _getLowestPrice(DomainPlan plan) {
    List<double> prices = [];
    if (plan.monthlyPrice != null) prices.add(plan.monthlyPrice!);
    if (plan.quarterlyPrice != null) prices.add(plan.quarterlyPrice!);
    if (plan.halfYearlyPrice != null) prices.add(plan.halfYearlyPrice!);
    if (plan.yearlyPrice != null) prices.add(plan.yearlyPrice!);
    if (plan.twoYearPrice != null) prices.add(plan.twoYearPrice!);
    if (plan.threeYearPrice != null) prices.add(plan.threeYearPrice!);
    if (plan.onetimePrice != null) prices.add(plan.onetimePrice!);
    if (prices.isEmpty) return '-';
    final lowestPrice = prices.reduce((a, b) => a < b ? a : b);
    return _formatPrice(lowestPrice);
  }
  String _getSpeedLimitText(DomainPlan plan) {
    if (plan.speedLimit == null) {
      return AppLocalizations.of(context).xboardUnlimited; // 不限速
    }
    return '${plan.speedLimit} Mbps';
  }
  Widget _buildPlanCard(DomainPlan plan) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (plan.hasPrice)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getLowestPrice(plan),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.data_usage, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '${AppLocalizations.of(context).xboardTraffic}: ${_formatTraffic(plan.transferQuota.toDouble())}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 16),
                Icon(Icons.speed, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '${AppLocalizations.of(context).xboardSpeedLimit}: ${_getSpeedLimitText(plan)}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            if (plan.description != null) ...[
              const SizedBox(height: 10),
              // 描述区域自适应高度，不再限制
              PlanDescriptionWidget(content: plan.description!),
            ],
            const SizedBox(height: 16),
            if (plan.hasPrice)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _navigateToPurchase(plan),
                  icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                  label: Text(appLocalizations.xboardBuyNow),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }
  void _navigateToPurchase(DomainPlan plan) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    
    if (isDesktop) {
      // 桌面端：内嵌显示
      setState(() {
        _selectedPlan = plan;
      });
    } else {
      // 移动端：使用 Navigator.push 导航，自动有返回按钮
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PlanPurchasePage(plan: plan),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    
    final scaffold = Scaffold(
      appBar: _selectedPlan != null && isDesktop
          // 桌面端购买页面：显示返回按钮的 AppBar
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _backToPlans,
                tooltip: '返回',
              ),
              title: Text(appLocalizations.xboardPurchaseSubscription),
              elevation: 0,
              scrolledUnderElevation: 1,
            )
          // 套餐列表：移动端才显示 AppBar
          : isDesktop
              ? null
              : AppBar(
                  title: Text(appLocalizations.xboardPlanInfo),
                  // 使用 push 路由后，自动显示返回按钮
                ),
      body: isDesktop && _selectedPlan != null
          // 桌面端：显示购买页面（嵌入模式，无 Scaffold）
          ? PlanPurchasePage(
              plan: _selectedPlan!,
              embedded: true,
              onBack: _backToPlans,
            )
          // 显示套餐列表
          : RefreshIndicator(
              onRefresh: _refreshPlans,
              child: Consumer(
                builder: (context, ref, child) {
            final plans = ref.watch(xboardSubscriptionProvider);
            final uiState = ref.watch(userUIStateProvider);
            if (uiState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (uiState.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '加载失败',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      uiState.errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshPlans,
                      child: Text(appLocalizations.xboardRetry),
                    ),
                  ],
                ),
              );
            }
            if (plans.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '暂无套餐信息',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width < 600 ? 1 : (width < 900 ? 2 : 3);
                  const spacing = 12.0;
                  final totalSpacing = spacing * (crossAxisCount - 1);
                  final cardWidth = (width - totalSpacing) / crossAxisCount;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: plans.map((plan) => SizedBox(
                      width: cardWidth,
                      child: _buildPlanCard(plan),
                    )).toList(),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
    
    return scaffold;
  }
}