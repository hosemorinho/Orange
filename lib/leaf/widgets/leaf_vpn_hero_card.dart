import 'dart:io';
import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/leaf/leaf_controller.dart';
import 'package:fl_clash/leaf/providers/leaf_providers.dart';
import 'package:fl_clash/leaf/widgets/leaf_node_list.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/text.dart';
import 'package:fl_clash/xboard/domain/models/models.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/subscription/services/subscription_status_service.dart';
import 'package:fl_clash/xboard/services/services.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Leaf VPN hero card — replaces the Clash-based VpnHeroCard.
///
/// Shows connection state, selected node, subscription usage, and controls.
/// No mode selector (leaf has no Rule/Global/Direct modes).
class LeafVpnHeroCard extends ConsumerStatefulWidget {
  const LeafVpnHeroCard({super.key});

  @override
  ConsumerState<LeafVpnHeroCard> createState() => _LeafVpnHeroCardState();
}

class _LeafVpnHeroCardState extends ConsumerState<LeafVpnHeroCard>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconAnimation;
  late AnimationController _ringController;
  late Animation<double> _ringAnimation;
  bool _isStart = false;
  bool _isSwitching = false;

  bool get _isDesktop =>
      Platform.isLinux || Platform.isWindows || Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    _isStart = ref.read(isLeafRunningProvider);

    _iconController = AnimationController(
      vsync: this,
      value: _isStart ? 1 : 0,
      duration: const Duration(milliseconds: 200),
    );
    _iconAnimation = CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeOutBack,
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _ringAnimation = CurvedAnimation(
      parent: _ringController,
      curve: Curves.easeInOut,
    );
    if (_isStart) _ringController.repeat(reverse: true);

    ref.listenManual(
      isLeafRunningProvider,
      (prev, next) {
        if (next != _isStart) {
          setState(() => _isStart = next);
          _updateController();
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  Future<void> _handleSwitchStart() async {
    if (_isSwitching) return;
    _isSwitching = true;
    try {
      setState(() => _isStart = !_isStart);
      _updateController();
      if (_isStart) {
        await startLeaf(ref);
      } else {
        await stopLeaf(ref);
      }
    } finally {
      _isSwitching = false;
    }
  }

  void _updateController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isStart) {
        _iconController.forward();
        _ringController.repeat(reverse: true);
      } else {
        _iconController.reverse();
        _ringController.stop();
        _ringController.reset();
      }
    });
  }

  void _navigateToNodes() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LeafNodeListView(),
      ),
    );
  }

  // --- Subscription helpers ---

  double _getProgressValue(SubscriptionInfo? profileSubInfo) {
    if (profileSubInfo != null && profileSubInfo.total > 0) {
      final used = profileSubInfo.upload + profileSubInfo.download;
      return (used / profileSubInfo.total).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  double _getUsedTraffic(SubscriptionInfo? profileSubInfo) {
    if (profileSubInfo != null) {
      return (profileSubInfo.upload + profileSubInfo.download).toDouble();
    }
    return 0;
  }

  double _getTotalTraffic(
      SubscriptionInfo? profileSubInfo, DomainUser? userInfo) {
    if (profileSubInfo != null && profileSubInfo.total > 0) {
      return profileSubInfo.total.toDouble();
    }
    return userInfo?.transferLimit?.toDouble() ?? 0;
  }

  int? _calculateRemainingDays(
      SubscriptionInfo? profileSubInfo, DomainSubscription? subscriptionInfo) {
    DateTime? expiredAt;
    if (profileSubInfo?.expire != null && profileSubInfo!.expire != 0) {
      expiredAt =
          DateTime.fromMillisecondsSinceEpoch(profileSubInfo.expire * 1000);
    } else if (subscriptionInfo?.expiredAt != null) {
      expiredAt = subscriptionInfo!.expiredAt;
    }
    if (expiredAt == null) return null;
    final now = DateTime.now();
    final difference = expiredAt.difference(now);
    return difference.inDays.clamp(0, double.infinity).toInt();
  }

  String _formatBytes(double bytes) {
    if (bytes < 0) return '0 B';
    final trafficShow = bytes.toInt().traffic;
    return '${trafficShow.value} ${trafficShow.unit}';
  }

  Color _getProgressColor(double progress, ThemeData theme) {
    if (progress >= 0.9) {
      return theme.colorScheme.error;
    } else if (progress >= 0.7) {
      return theme.colorScheme.error.withValues(alpha: 0.7);
    } else {
      return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nodes = ref.watch(leafNodesProvider);
    final selectedTag = ref.watch(selectedNodeTagProvider);
    final delays = ref.watch(nodeDelaysProvider);

    if (nodes.isEmpty) {
      final userState = ref.watch(xboardUserProvider);
      if (userState.isAuthenticated) {
        return _buildLoadingState(context);
      }
      return const SizedBox.shrink();
    }

    final selectedNode = nodes.where((n) => n.tag == selectedTag).firstOrNull;
    final nodeName = selectedNode?.tag ?? nodes.first.tag;
    final delayMs = delays[nodeName];

    return _buildCard(context, nodeName, delayMs);
  }

  Widget _buildCard(BuildContext context, String nodeName, int? delayMs) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final bgColor = _isStart
        ? colorScheme.tertiaryContainer
        : colorScheme.primaryContainer;
    final statusColor =
        _isStart ? colorScheme.tertiary : colorScheme.primary;
    final onStatusColor =
        _isStart ? colorScheme.onTertiary : colorScheme.onPrimary;

    // Subscription data
    final currentProfile = ref.watch(currentProfileProvider);
    final profileSubInfo = currentProfile?.subscriptionInfo;
    final userInfo = ref.userInfo;
    final subscriptionInfo = ref.subscriptionInfo;

    final progress = _getProgressValue(profileSubInfo);
    final usedTraffic = _getUsedTraffic(profileSubInfo);
    final totalTraffic = _getTotalTraffic(profileSubInfo, userInfo);
    final remainingDays =
        _calculateRemainingDays(profileSubInfo, subscriptionInfo);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor.withValues(alpha: 0.3),
            bgColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: _isDesktop
            ? _buildDesktopLayout(context, theme, colorScheme, nodeName,
                delayMs, statusColor, onStatusColor, bgColor, progress,
                usedTraffic, totalTraffic, remainingDays)
            : _buildMobileLayout(context, theme, colorScheme, nodeName,
                delayMs, statusColor, onStatusColor, progress, usedTraffic,
                totalTraffic, remainingDays),
      ),
    );
  }

  // --- Mobile Layout ---

  Widget _buildMobileLayout(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String nodeName,
    int? delayMs,
    Color statusColor,
    Color onStatusColor,
    double progress,
    double usedTraffic,
    double totalTraffic,
    int? remainingDays,
  ) {
    const buttonSize = 88.0;
    const ringSize = 108.0;
    final appLocalizations = AppLocalizations.of(context);

    final userState = ref.watch(xboardUserProvider);
    final currentProfile = ref.watch(currentProfileProvider);
    final profileSubInfo = currentProfile?.subscriptionInfo;

    SubscriptionStatusResult? subscriptionStatus;
    if (userState.isAuthenticated && profileSubInfo != null) {
      subscriptionStatus = subscriptionStatusService.checkSubscriptionStatus(
        userState: userState,
        profileSubscriptionInfo: profileSubInfo,
      );
    }

    return Column(
      children: [
        // Status text
        Text(
          _isStart
              ? appLocalizations.xboardConnected
              : appLocalizations.xboardDisconnected,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
        const SizedBox(height: 8),

        // Node pill
        _buildNodePill(nodeName, delayMs, colorScheme, theme),
        const SizedBox(height: 16),

        // Circular button with progress ring
        SizedBox(
          width: ringSize,
          height: ringSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _ringAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(ringSize, ringSize),
                    painter: _ProgressRingPainter(
                      color: statusColor,
                      isActive: _isStart,
                      pulseProgress: _ringAnimation.value,
                      progress: progress,
                      ringRadius: ringSize / 2 - 4,
                    ),
                  );
                },
              ),
              GestureDetector(
                onTap: _handleSwitchStart,
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: _iconAnimation,
                      size: 40,
                      color: onStatusColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Subscription status warning
        if (subscriptionStatus != null &&
            _shouldShowWarning(subscriptionStatus))
          _buildSubscriptionWarning(context, theme, subscriptionStatus),

        // Traffic text
        _buildCompactTrafficText(
            theme, colorScheme, progress, usedTraffic, totalTraffic,
            remainingDays),
        const SizedBox(height: 16),

        // Switch node button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _navigateToNodes,
            icon: const Icon(Icons.swap_horiz, size: 16),
            label: Text(
              appLocalizations.xboardSwitchNode,
              style: const TextStyle(fontSize: 12),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }

  // --- Desktop Layout ---

  Widget _buildDesktopLayout(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String nodeName,
    int? delayMs,
    Color statusColor,
    Color onStatusColor,
    Color bgColor,
    double progress,
    double usedTraffic,
    double totalTraffic,
    int? remainingDays,
  ) {
    const buttonSize = 80.0;
    const ringSize = 100.0;
    final appLocalizations = AppLocalizations.of(context);

    final userState = ref.watch(xboardUserProvider);
    final currentProfile = ref.watch(currentProfileProvider);
    final profileSubInfo = currentProfile?.subscriptionInfo;

    SubscriptionStatusResult? subscriptionStatus;
    if (userState.isAuthenticated && profileSubInfo != null) {
      subscriptionStatus = subscriptionStatusService.checkSubscriptionStatus(
        userState: userState,
        profileSubscriptionInfo: profileSubInfo,
      );
    }

    return Column(
      children: [
        if (subscriptionStatus != null &&
            _shouldShowWarning(subscriptionStatus)) ...[
          _buildSubscriptionWarning(context, theme, subscriptionStatus),
          const SizedBox(height: 12),
        ],

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left section
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isStart
                            ? appLocalizations.xboardConnected
                            : appLocalizations.xboardDisconnected,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  EmojiText(
                    nodeName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _buildLatencyChip(context, nodeName, delayMs),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Right section
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  SizedBox(
                    width: ringSize,
                    height: ringSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _ringAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(ringSize, ringSize),
                              painter: _ProgressRingPainter(
                                color: statusColor,
                                isActive: _isStart,
                                pulseProgress: _ringAnimation.value,
                                progress: progress,
                                ringRadius: ringSize / 2 - 4,
                              ),
                            );
                          },
                        ),
                        GestureDetector(
                          onTap: _handleSwitchStart,
                          child: Container(
                            width: buttonSize,
                            height: buttonSize,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: AnimatedIcon(
                                icon: AnimatedIcons.play_pause,
                                progress: _iconAnimation,
                                size: 36,
                                color: onStatusColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _navigateToNodes,
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: Text(
                      appLocalizations.xboardSwitchNode,
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Full-width subscription row
        _buildSubscriptionRow(
          theme, colorScheme, progress, usedTraffic, totalTraffic,
          remainingDays,
        ),
      ],
    );
  }

  // --- Shared sub-widgets ---

  Widget _buildNodePill(
      String nodeName, int? delayMs, ColorScheme colorScheme, ThemeData theme) {
    return GestureDetector(
      onTap: _navigateToNodes,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.dns_outlined,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: EmojiText(
                nodeName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            _buildLatencyChip(context, nodeName, delayMs),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatencyChip(BuildContext context, String nodeTag, int? delayMs) {
    final colorScheme = Theme.of(context).colorScheme;

    if (delayMs == null) {
      return Icon(
        Icons.speed,
        size: 14,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      );
    }

    final Color chipColor;
    if (delayMs <= 200) {
      chipColor = Colors.green;
    } else if (delayMs <= 500) {
      chipColor = Colors.orange;
    } else {
      chipColor = colorScheme.error;
    }

    return Text(
      '${delayMs}ms',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: chipColor,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildCompactTrafficText(
    ThemeData theme,
    ColorScheme colorScheme,
    double progress,
    double usedTraffic,
    double totalTraffic,
    int? remainingDays,
  ) {
    final progressColor = _getProgressColor(progress, theme);
    final appLocalizations = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${_formatBytes(usedTraffic)} / ${_formatBytes(totalTraffic)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: progressColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            remainingDays != null
                ? appLocalizations.xboardRemainingDaysCount(remainingDays)
                : '${(progress * 100).toInt()}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: progressColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionRow(
    ThemeData theme,
    ColorScheme colorScheme,
    double progress,
    double usedTraffic,
    double totalTraffic,
    int? remainingDays,
  ) {
    final progressColor = _getProgressColor(progress, theme);
    final appLocalizations = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.cloud_download,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${_formatBytes(usedTraffic)} / ${_formatBytes(totalTraffic)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor:
                        colorScheme.primary.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Text(
                remainingDays == null ? '--' : '$remainingDays',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                remainingDays == null
                    ? appLocalizations.xboardUnlimitedTime
                    : appLocalizations.xboardDays,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).xboardImportingSubscription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appLocalizations = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLocalizations.xboardNoAvailableNodes,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appLocalizations.xboardClickToSetupNodes,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: _navigateToNodes,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size(64, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              appLocalizations.xboardSetup,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowWarning(SubscriptionStatusResult status) {
    return status.type == SubscriptionStatusType.expired ||
        status.type == SubscriptionStatusType.exhausted ||
        status.type == SubscriptionStatusType.noSubscription;
  }

  Widget _buildSubscriptionWarning(
    BuildContext context,
    ThemeData theme,
    SubscriptionStatusResult status,
  ) {
    IconData warningIcon;
    Color warningColor;
    String warningText;
    final appLocalizations = AppLocalizations.of(context);

    switch (status.type) {
      case SubscriptionStatusType.noSubscription:
        warningIcon = Icons.info_outline;
        warningColor = theme.colorScheme.primary;
        warningText = appLocalizations.xboardNoAvailableSubscription;
        break;
      case SubscriptionStatusType.expired:
        warningIcon = Icons.warning_amber_rounded;
        warningColor = theme.colorScheme.error;
        warningText = appLocalizations.xboardSubscriptionExpired;
        break;
      case SubscriptionStatusType.exhausted:
        warningIcon = Icons.error_outline;
        warningColor = theme.colorScheme.error;
        warningText = appLocalizations.xboardTrafficExhausted;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: warningColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(warningIcon, size: 16, color: warningColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              warningText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: warningColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final Color color;
  final bool isActive;
  final double pulseProgress;
  final double progress;
  final double ringRadius;

  _ProgressRingPainter({
    required this.color,
    required this.isActive,
    required this.pulseProgress,
    required this.progress,
    required this.ringRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 3.5;
    const startAngle = -pi / 2;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.15);
    canvas.drawCircle(center, ringRadius, bgPaint);

    if (progress > 0) {
      final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
      final scale = isActive ? 1.0 + 0.03 * pulseProgress : 1.0;
      final effectiveRadius = ringRadius * scale;

      final gradientPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: [
            color,
            color.withValues(alpha: 0.7),
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: effectiveRadius),
        );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: effectiveRadius),
        startAngle,
        sweepAngle,
        false,
        gradientPaint,
      );
    } else if (isActive) {
      final scale = 1.0 + 0.03 * pulseProgress;
      final opacity = 0.3 + 0.4 * pulseProgress;
      final pulsePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: opacity);
      canvas.drawCircle(center, ringRadius * scale, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.isActive != isActive ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}
