import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/features/ticket/providers/ticket_provider.dart';
import 'package:fl_clash/xboard/features/ticket/widgets/ticket_message_bubble.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/l10n/l10n.dart';

class TicketDetailPage extends ConsumerStatefulWidget {
  final int ticketId;

  const TicketDetailPage({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends ConsumerState<TicketDetailPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String _draftMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ticketProvider.notifier).loadTicketDetail(widget.ticketId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendReply() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      XBoardNotification.showInfo(AppLocalizations.of(context).xboardEnterMessage);
      return;
    }

    final success = await ref.read(ticketProvider.notifier).replyTicket(
          widget.ticketId,
          message,
        );

    if (success) {
      _messageController.clear();
      setState(() => _draftMessage = '');
      _scrollToBottom();
    } else {
      final error = ref.read(ticketProvider).errorMessage;
      XBoardNotification.showError(error ?? AppLocalizations.of(context).xboardReplyFailed);
    }
  }

  Future<void> _closeTicket() async {
    final confirmed = await XBoardNotification.showConfirm(
      AppLocalizations.of(context).xboardCloseTicketConfirm,
      title: AppLocalizations.of(context).xboardCloseTicket,
    );

    if (confirmed) {
      final success = await ref.read(ticketProvider.notifier).closeTicket(widget.ticketId);
      if (success) {
        await ref.read(ticketProvider.notifier).loadTicketDetail(widget.ticketId);
        XBoardNotification.showSuccess(AppLocalizations.of(context).xboardTicketClosed);
      } else {
        final error = ref.read(ticketProvider).errorMessage;
        XBoardNotification.showError(error ?? AppLocalizations.of(context).xboardCloseFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(ticketProvider);
    final ticket = state.currentTicket;

    // Auto-scroll when messages change
    if (ticket != null && ticket.messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ticket?.subject ?? AppLocalizations.of(context).xboardTicketDetail,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          if (ticket != null && ticket.status != TicketStatus.closed)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: AppLocalizations.of(context).xboardCloseTicket,
              onPressed: _closeTicket,
            ),
        ],
      ),
      body: state.isLoading && ticket == null
          ? const Center(child: CircularProgressIndicator())
          : ticket == null
              ? _buildError(theme, state)
              : Column(
                  children: [
                    _buildTicketHeader(theme, ticket),
                    Expanded(
                      child: _buildMessageList(theme, ticket),
                    ),
                    if (ticket.status != TicketStatus.closed)
                      _isWaitingForAdminReply(ticket)
                          ? _buildWaitingHint(theme)
                          : _buildReplyBar(theme, state),
                  ],
                ),
    );
  }

  Widget _buildError(ThemeData theme, TicketState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            state.errorMessage ?? AppLocalizations.of(context).xboardLoadFailed,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => ref.read(ticketProvider.notifier).loadTicketDetail(widget.ticketId),
            child: Text(AppLocalizations.of(context).xboardRetry),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketHeader(ThemeData theme, DomainTicket ticket) {
    final statusInfo = _getStatusInfo(ticket.status);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusInfo.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusInfo.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: statusInfo.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${AppLocalizations.of(context).xboardPriority}: ${_getPriorityLabel(ticket.priority)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const Spacer(),
          Text(
            _formatDateTime(ticket.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ThemeData theme, DomainTicket ticket) {
    if (ticket.messages.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).xboardNoMessages,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: ticket.messages.length,
      itemBuilder: (context, index) {
        final message = ticket.messages[index];

        // Show date separator if needed
        Widget? dateSeparator;
        if (index == 0 ||
            !_isSameDay(ticket.messages[index - 1].createdAt, message.createdAt)) {
          dateSeparator = Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatDate(message.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            if (dateSeparator != null) dateSeparator,
            TicketMessageBubble(message: message),
          ],
        );
      },
    );
  }

  bool _isWaitingForAdminReply(DomainTicket ticket) {
    if (ticket.messages.isEmpty) return false;
    return ticket.messages.last.isFromUser;
  }

  Widget _buildWaitingHint(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_top_rounded,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context).xboardWaitingForAdminReply,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBar(ThemeData theme, TicketState state) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: 8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).xboardEnterReplyContent,
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onChanged: (value) => setState(() => _draftMessage = value),
              onSubmitted: (_) {
                if (!_canSendReply(state)) return;
                _sendReply();
              },
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: _canSendReply(state) ? _sendReply : null,
            icon: state.isSending
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : Icon(
                    Icons.send,
                    color: theme.colorScheme.primary,
                  ),
            tooltip: AppLocalizations.of(context).xboardSend,
          ),
        ],
      ),
    );
  }

  bool _canSendReply(TicketState state) {
    return !state.isSending && _draftMessage.trim().isNotEmpty;
  }

  String _getPriorityLabel(int priority) {
    final l10n = AppLocalizations.of(context);
    switch (priority) {
      case 0:
        return l10n.xboardLowPriority;
      case 1:
        return l10n.xboardMediumPriority;
      case 2:
        return l10n.xboardHighPriority;
      default:
        return l10n.xboardUnknownPriority;
    }
  }

  ({String label, Color color}) _getStatusInfo(TicketStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case TicketStatus.pending:
        return (label: AppLocalizations.of(context).xboardPending, color: colorScheme.tertiary);
      case TicketStatus.closed:
        return (label: AppLocalizations.of(context).xboardClosed, color: colorScheme.outline);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    if (_isSameDay(dateTime, now)) return AppLocalizations.of(context).xboardToday;

    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(dateTime, yesterday)) return AppLocalizations.of(context).xboardYesterday;

    return MaterialLocalizations.of(context).formatShortDate(dateTime);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
