import 'package:fl_clash/xboard/features/ticket/providers/ticket_provider.dart';
import 'package:fl_clash/xboard/features/ticket/widgets/ticket_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_clash/l10n/l10n.dart';

class TicketListPage extends ConsumerStatefulWidget {
  const TicketListPage({super.key});

  @override
  ConsumerState<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends ConsumerState<TicketListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ticketProvider.notifier).loadTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final state = ref.watch(ticketProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).xboardTickets),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: AppLocalizations.of(context).xboardCreateTicket,
            onPressed: () => context.push('/support/create'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(ticketProvider.notifier).refresh(),
        child: _buildBody(theme, state),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, TicketState state) {
    final colorScheme = theme.colorScheme;

    if (state.isLoading && state.tickets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.tickets.isEmpty) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).xboardLoadFailed,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).checkNetwork,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () =>
                          ref.read(ticketProvider.notifier).refresh(),
                      child: Text(AppLocalizations.of(context).xboardRetry),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.tickets.isEmpty) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).xboardNoTickets,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).xboardNoTicketsDesc,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.push('/support/create'),
                      icon: const Icon(Icons.add),
                      label: Text(AppLocalizations.of(context).xboardCreateTicket),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final ticketCount = state.tickets.length;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 768),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: ticketCount * 2 - 1,
          itemBuilder: (context, index) {
            if (index.isOdd) {
              return const SizedBox(height: 12);
            }
            final ticket = state.tickets[index ~/ 2];
            return TicketCard(
              ticket: ticket,
              onTap: () => context.push('/support/detail', extra: ticket.id),
            );
          },
        ),
      ),
    );
  }
}
