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
                      AppLocalizations.of(context).xboardLoadFailed,
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
                      AppLocalizations.of(context).xboardNoAvailablePlans,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).xboardPleaseTryLaterOrContactSupport,
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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width < 500 ? 1 : (width < 800 ? 2 : 3);
                      const spacing = 16.0;
                      final totalSpacing = spacing * (crossAxisCount - 1);
                      final cardWidth = (width - totalSpacing) / crossAxisCount;

                      // Build rows with IntrinsicHeight for equal card heights
                      final List<Widget> rows = [];
                      for (var i = 0; i < plans.length; i += crossAxisCount) {
                        final rowPlans = plans.sublist(
                          i,
                          (i + crossAxisCount).clamp(0, plans.length),
                        );
                        rows.add(
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var j = 0; j < rowPlans.length; j++) ...[
                                  if (j > 0) const SizedBox(width: spacing),
                                  SizedBox(
                                    width: cardWidth,
                                    child: PlanCard(
                                      plan: rowPlans[j],
                                      onPurchase: () => _navigateToPurchase(rowPlans[j]),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          for (var i = 0; i < rows.length; i++) ...[
                            if (i > 0) const SizedBox(height: spacing),
                            rows[i],
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    
    return scaffold;
  }
}