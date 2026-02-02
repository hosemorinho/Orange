import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:fl_clash/l10n/l10n.dart';

class TicketCard extends StatelessWidget {
  final DomainTicket ticket;
  final VoidCallback onTap;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusInfo = _getStatusInfo(ticket.status, context);
    final priorityInfo = _getPriorityInfo(ticket.priority, context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.subject,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusInfo.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    statusInfo.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusInfo.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (ticket.lastMessage != null)
              Text(
                ticket.lastMessage!.content,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: priorityInfo.color.withValues(alpha: 0.4),
                    ),
                    color: priorityInfo.color.withValues(alpha: 0.08),
                  ),
                  child: Text(
                    priorityInfo.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: priorityInfo.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(ticket.updatedAt ?? ticket.createdAt, context),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (ticket.unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${ticket.unreadCount}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  ({String label, Color color}) _getStatusInfo(TicketStatus status, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case TicketStatus.pending:
        return (label: AppLocalizations.of(context).xboardPending, color: colorScheme.tertiary);
      case TicketStatus.closed:
        return (label: AppLocalizations.of(context).xboardClosed, color: colorScheme.outline);
    }
  }

  ({String label, Color color}) _getPriorityInfo(int priority, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);
    switch (priority) {
      case 0:
        return (label: '${localizations.xboardLowPriority}优先级', color: colorScheme.primary);
      case 2:
        return (label: '${localizations.xboardHighPriority}优先级', color: colorScheme.error);
      default:
        return (label: '${localizations.xboardMediumPriority}优先级', color: colorScheme.secondary);
    }
  }

  String _formatTime(DateTime dateTime, BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    final localizations = AppLocalizations.of(context);

    if (diff.inMinutes < 1) return localizations.xboardJustNow;
    if (diff.inHours < 1) return '${diff.inMinutes} ${localizations.xboardMinutesAgo}';
    if (diff.inDays < 1) return '${diff.inHours} ${localizations.xboardHoursAgo}';
    if (diff.inDays < 30) return '${diff.inDays} ${localizations.xboardDaysAgo}';

    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
