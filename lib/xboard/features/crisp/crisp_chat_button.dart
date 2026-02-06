import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/xboard/adapter/state/plan_state.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/crisp/crisp_chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global floating action button that opens Crisp live chat.
///
/// Only renders when [crispWebsiteId] is configured via `--dart-define`.
class CrispChatButton extends ConsumerWidget {
  const CrispChatButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (crispWebsiteId.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.small(
      heroTag: 'crisp_chat_fab',
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      tooltip: 'Support',
      onPressed: () => _openChat(ref),
      child: const Icon(Icons.support_agent),
    );
  }

  Future<void> _openChat(WidgetRef ref) async {
    final user = ref.read(userInfoProvider);
    if (user == null) return;

    // Fetch the user's current plan (best-effort, don't block on failure).
    final plan = user.planId != null
        ? await ref.read(getPlanProvider(user.planId!).future).catchError((_) => null)
        : null;

    await CrispChatService.openChat(user: user, plan: plan);
  }
}
