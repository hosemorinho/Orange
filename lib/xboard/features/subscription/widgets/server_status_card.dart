import 'package:flutter/material.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/xboard/features/shared/widgets/xb_dashboard_card.dart';

/// Server node data model matching frontend ServerNode interface
class ServerNode {
  final int? id;
  final String? host;
  final String? name;
  final bool online;
  final String? type;
  final List<String>? tags;
  final String? rate;

  const ServerNode({
    this.id,
    this.host,
    this.name,
    this.online = false,
    this.type,
    this.tags,
    this.rate,
  });
}

/// Server Status Card Widget
///
/// Displays server status information with collapsible design
/// Design reference: /home/auth/src/components/dashboard/ServerStatus.tsx
class ServerStatusCard extends StatefulWidget {
  final List<ServerNode>? servers;
  final bool loading;
  final bool initiallyExpanded;

  const ServerStatusCard({
    super.key,
    this.servers,
    this.loading = false,
    this.initiallyExpanded = false,
  });

  @override
  State<ServerStatusCard> createState() => _ServerStatusCardState();
}

class _ServerStatusCardState extends State<ServerStatusCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Loading state
    if (widget.loading) {
      return _buildLoadingState(theme);
    }

    // Ensure servers is a list
    final safeServers = widget.servers ?? [];

    // Empty state
    if (safeServers.isEmpty) {
      return _buildEmptyState(appLocalizations, theme);
    }

    // Calculate online/offline counts
    final onlineCount = safeServers.where((s) => s.online).length;
    final totalCount = safeServers.length;

    return XBDashboardCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header with summary badge (always visible)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: XBSectionTitle(
                      title: appLocalizations.xboardServerStatus,
                      icon: Icons.dns_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryBadge(
                    appLocalizations,
                    theme,
                    onlineCount,
                    totalCount,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Server list (collapsible)
          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
            _buildServerList(appLocalizations, theme, safeServers),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return XBDashboardCard(
      child: Column(
        children: [
          _buildSkeletonBar(theme, width: 100),
          const SizedBox(height: 12),
          _buildSkeletonBar(theme, width: double.infinity),
          const SizedBox(height: 8),
          _buildSkeletonBar(theme, width: double.infinity),
          const SizedBox(height: 8),
          _buildSkeletonBar(theme, width: double.infinity),
        ],
      ),
    );
  }

  Widget _buildSkeletonBar(ThemeData theme, {required double width}) {
    return Container(
      height: 16,
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations appLocalizations, ThemeData theme) {
    return XBDashboardCard(
      child: Center(
        child: Text(
          appLocalizations.xboardNoServerData,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBadge(
    AppLocalizations appLocalizations,
    ThemeData theme,
    int onlineCount,
    int totalCount,
  ) {
    final colorScheme = theme.colorScheme;

    // Determine badge color based on server status
    Color badgeColor;
    Color backgroundColor;

    if (onlineCount == totalCount) {
      // All online - green
      badgeColor = const Color(0xFF16A34A); // green-600
      backgroundColor = const Color(0xFF16A34A).withValues(alpha: 0.15);
    } else if (onlineCount > 0) {
      // Partial - yellow/orange
      badgeColor = const Color(0xFFEAB308); // yellow-600
      backgroundColor = const Color(0xFFEAB308).withValues(alpha: 0.15);
    } else {
      // All down - red
      badgeColor = colorScheme.error;
      backgroundColor = colorScheme.error.withValues(alpha: 0.15);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$onlineCount/$totalCount ${appLocalizations.xboardOnline}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildServerList(
    AppLocalizations appLocalizations,
    ThemeData theme,
    List<ServerNode> servers,
  ) {
    return Column(
      children: servers.map((server) {
        return _ServerItem(
          server: server,
          appLocalizations: appLocalizations,
          theme: theme,
        );
      }).toList(),
    );
  }
}

/// Individual server item widget
class _ServerItem extends StatefulWidget {
  final ServerNode server;
  final AppLocalizations appLocalizations;
  final ThemeData theme;

  const _ServerItem({
    required this.server,
    required this.appLocalizations,
    required this.theme,
  });

  @override
  State<_ServerItem> createState() => _ServerItemState();
}

class _ServerItemState extends State<_ServerItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Container(
        decoration: BoxDecoration(
          color: _isHovering
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Status indicator (dot)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: widget.server.online
                    ? const Color(0xFF16A34A) // green-500
                    : colorScheme.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),

            // Server info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and badges
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.server.name ?? widget.server.host ?? 'Unknown',
                          style: widget.theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.server.type != null) ...[
                        const SizedBox(width: 8),
                        _buildBadge(
                          widget.server.type!,
                          colorScheme.primary,
                        ),
                      ],
                      if (widget.server.tags != null &&
                          widget.server.tags!.isNotEmpty)
                        ...widget.server.tags!.map((tag) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _buildBadge(
                              tag,
                              colorScheme.primary,
                            ),
                          );
                        }),
                    ],
                  ),
                  if (widget.server.host != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.server.host!,
                      style: widget.theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Rate and status
            const SizedBox(width: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.server.rate != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${widget.server.rate}x',
                      style: widget.theme.textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                _buildStatusLabel(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: widget.theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildStatusLabel() {
    final isOnline = widget.server.online;
    final color = isOnline
        ? const Color(0xFF16A34A) // green-600
        : widget.theme.colorScheme.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isOnline ? Icons.check : Icons.close,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          isOnline
              ? widget.appLocalizations.xboardServerOnline
              : widget.appLocalizations.xboardServerOffline,
          style: widget.theme.textTheme.bodySmall?.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}
