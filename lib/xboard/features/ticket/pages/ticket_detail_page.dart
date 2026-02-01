import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/features/ticket/providers/ticket_provider.dart';
import 'package:fl_clash/xboard/features/ticket/widgets/ticket_message_bubble.dart';
import 'package:fl_clash/xboard/utils/xboard_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TicketDetailPage extends ConsumerStatefulWidget {
  final int ticketId;

  const TicketDetailPage({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends ConsumerState<TicketDetailPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

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
    if (message.isEmpty) return;

    final success = await ref.read(ticketProvider.notifier).replyTicket(
          widget.ticketId,
          message,
        );

    if (success) {
      _messageController.clear();
      _scrollToBottom();
    } else {
      final error = ref.read(ticketProvider).errorMessage;
      XBoardNotification.showError(error ?? '发送失败');
    }
  }

  Future<void> _closeTicket() async {
    final confirmed = await XBoardNotification.showConfirm(
      '确定要关闭此工单吗？关闭后将无法继续回复。',
      title: '关闭工单',
    );

    if (confirmed) {
      final success = await ref.read(ticketProvider.notifier).closeTicket(widget.ticketId);
      if (success) {
        XBoardNotification.showSuccess('工单已关闭');
      } else {
        final error = ref.read(ticketProvider).errorMessage;
        XBoardNotification.showError(error ?? '关闭失败');
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
          ticket?.subject ?? '工单详情',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          if (ticket != null && ticket.status != TicketStatus.closed)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: '关闭工单',
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
                      _buildReplyBar(theme, state),
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
            state.errorMessage ?? '加载失败',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => ref.read(ticketProvider.notifier).loadTicketDetail(widget.ticketId),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketHeader(ThemeData theme, DomainTicket ticket) {
    final statusInfo = _getStatusInfo(ticket.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
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
            '优先级: ${ticket.priorityLabel}',
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
          '暂无消息',
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
                hintText: '输入回复内容...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendReply(),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: state.isSending ? null : _sendReply,
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
            tooltip: '发送',
          ),
        ],
      ),
    );
  }

  ({String label, Color color}) _getStatusInfo(TicketStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case TicketStatus.pending:
        return (label: '待处理', color: colorScheme.tertiary);
      case TicketStatus.closed:
        return (label: '已关闭', color: colorScheme.outline);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    if (_isSameDay(dateTime, now)) return '今天';

    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(dateTime, yesterday)) return '昨天';

    return '${dateTime.month}月${dateTime.day}日';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
