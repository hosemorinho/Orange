import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/xboard/features/invite/providers/invite_provider.dart';
import 'package:fl_clash/xboard/features/invite/widgets/invite_stats_section.dart';
import 'package:fl_clash/xboard/features/invite/widgets/invite_codes_card.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';

/// Invite page - Referral & Commission system
///
/// Features:
/// - Statistics cards (5 stats)
/// - Invite codes management (max 5 codes)
/// - Copy code and copy link functionality
/// - Responsive grid layout
/// - Custom commission rate banner
class InvitePage extends ConsumerStatefulWidget {
  const InvitePage({super.key});

  @override
  ConsumerState<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends ConsumerState<InvitePage> {
  bool _isCreatingCode = false;

  Future<void> _handleCreateCode() async {
    setState(() => _isCreatingCode = true);

    try {
      await ref.read(inviteProviderProvider.notifier).createInviteCode();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations.xboardInviteCodeCreated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${appLocalizations.xboardError}: ${e.toString()}'),
            backgroundColor: Colors.red,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;

    final inviteDataAsync = ref.watch(inviteDataProviderProvider);
    final userAsync = ref.watch(xboardUserProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.xboardInvite),
        centerTitle: false,
        actions: [
          // Refresh button
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
          // Get custom commission rate from user info (if available)
          final customRate = userAsync.valueOrNull?.commissionRate;

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(inviteDataProviderProvider.notifier).refresh();
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
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

                      // Coming soon section (Withdraw & Transfer)
                      _buildComingSoonSection(context),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  appLocalizations.xboardLoadError,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
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

  Widget _buildComingSoonSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.construction_outlined,
            size: 32,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLocalizations.xboardComingSoon,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appLocalizations.xboardWithdrawTransferComingSoon,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
