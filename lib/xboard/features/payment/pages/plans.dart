import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/subscription/providers/xboard_subscription_provider.dart';
import 'plan_purchase_page.dart';
import '../widgets/plan_card.dart';
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
  /// Determine if a plan should be highlighted (e.g., most popular)
  bool _shouldHighlightPlan(DomainPlan plan, List<DomainPlan> allPlans) {
    // Highlight the middle-priced plan or the one with best value
    // You can customize this logic based on your business needs
    if (allPlans.length < 2) return false;

    // Get plans with prices
    final plansWithPrices = allPlans.where((p) => p.hasPrice).toList();
    if (plansWithPrices.length < 2) return false;

    // Find middle plan by index
    final middleIndex = (plansWithPrices.length / 2).floor();
    return plansWithPrices[middleIndex].id == plan.id;
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
                      Icons.workspace_premium_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '暂无可用套餐',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '请稍后再试或联系客服',
                      style: TextStyle(
                        fontSize: 14,
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
                  // Responsive grid: 1 column on mobile, 2 on tablet, 3 on desktop
                  final crossAxisCount = width < 600 ? 1 : (width < 900 ? 2 : 3);
                  const spacing = 16.0;
                  final totalSpacing = spacing * (crossAxisCount - 1);
                  final cardWidth = (width - totalSpacing) / crossAxisCount;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: plans.map((plan) {
                      final isHighlighted = _shouldHighlightPlan(plan, plans);
                      return SizedBox(
                        width: cardWidth,
                        child: PlanCard(
                          plan: plan,
                          isHighlighted: isHighlighted,
                          onPurchase: () => _navigateToPurchase(plan),
                        ),
                      );
                    }).toList(),
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