import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/features/invite/providers/invite_provider.dart';
import 'package:fl_clash/xboard/features/invite/widgets/invite_stats_section.dart';
import 'package:fl_clash/xboard/features/invite/widgets/invite_codes_card.dart';
import 'package:fl_clash/xboard/features/invite/widgets/commission_transfer_dialog.dart';
import 'package:fl_clash/xboard/features/invite/widgets/commission_withdraw_dialog.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';

/// Invite page - Referral & Commission system
///
/// Features:
/// - Statistics cards (compact rows)
/// - Invite codes management (max 5 codes)
/// - Commission transfer to wallet
/// - Commission withdrawal
/// - Copy code and copy link functionality
class InvitePage extends ConsumerStatefulWidget {
  const InvitePage({super.key});

  @override
  ConsumerState<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends ConsumerState<InvitePage>
    with AutomaticKeepAliveClientMixin {
  bool _isCreatingCode = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> _handleCreateCode() async {
    setState(() => _isCreatingCode = true);

    try {
      await ref.read(createInviteCodeProvider.future);
      if (!mounted) return;

      // Refresh invite data from UI scope to avoid action-provider dispose timing.
      ref.invalidate(inviteDataProviderProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.xboardInviteCodeCreated),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${appLocalizations.xboardError}: ${ErrorSanitizer.sanitize(e.toString())}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingCode = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop =
        Platform.isLinux || Platform.isWindows || Platform.isMacOS;

    final inviteDataAsync = ref.watch(inviteDataProviderProvider);
    final user = ref.watch(userInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.xboardInvite),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(inviteDataProviderProvider.notifier).refresh();
            },
            tooltip: appLocalizations.xboardRefresh,
          ),
        ],
      ),
      body: inviteDataAsync.when(
        data: (inviteData) {
          final customRate = user?.commissionRate;

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(inviteDataProviderProvider.notifier).refresh();
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 768),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page header
                      Text(
                        appLocalizations.xboardInviteTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        appLocalizations.xboardInviteSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Statistics section
                      InviteStatsSection(
                        stats: inviteData.stats,
                        customCommissionRate: customRate,
                      ),
                      const SizedBox(height: 24),

                      // Invite codes card
                      InviteCodesCard(
                        codes: inviteData.codes,
                        onCreateCode: _handleCreateCode,
                        isCreating: _isCreatingCode,
                      ),
                      const SizedBox(height: 24),

                      // Commission actions (Transfer & Withdraw)
                      _buildCommissionActionsSection(context, inviteData.stats),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  appLocalizations.xboardLoadError,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ErrorSanitizer.sanitize(error.toString()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    ref.read(inviteDataProviderProvider.notifier).refresh();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(appLocalizations.xboardRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommissionActionsSection(
    BuildContext context,
    DomainInviteStats stats,
  ) {
    final hasCommission = stats.availableCommission > 0;

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: hasCommission ? () => _showTransferDialog(stats) : null,
            icon: const Icon(Icons.swap_horiz),
            label: Text(appLocalizations.transferToWallet),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: hasCommission ? () => _showWithdrawDialog(stats) : null,
            icon: const Icon(Icons.account_balance_outlined),
            label: Text(appLocalizations.withdraw),
          ),
        ),
      ],
    );
  }

  void _showTransferDialog(DomainInviteStats stats) {
    showDialog(
      context: context,
      builder: (context) => CommissionTransferDialog(
        availableCommission: stats.availableCommission,
      ),
    );
  }

  void _showWithdrawDialog(DomainInviteStats stats) {
    showDialog(
      context: context,
      builder: (context) => CommissionWithdrawDialog(
        availableCommission: stats.availableCommission,
      ),
    );
  }
}
