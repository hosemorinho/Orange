import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/xboard/features/subscription/widgets/flat_node_list.dart';
import 'package:fl_clash/xboard/features/latency/services/auto_latency_service.dart';
import 'package:fl_clash/xboard/features/latency/widgets/latency_indicator.dart';
import 'package:fl_clash/xboard/features/shared/utils/node_resolver.dart';
import 'package:fl_clash/xboard/features/shared/widgets/tun_introduction_dialog.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/services/services.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final _logger = FileLogger('vpn_hero_card.dart');

class VpnHeroCard extends ConsumerStatefulWidget {
  const VpnHeroCard({super.key});

  @override
  ConsumerState<VpnHeroCard> createState() => _VpnHeroCardState();
}

class _VpnHeroCardState extends ConsumerState<VpnHeroCard>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconAnimation;
  late AnimationController _ringController;
  late Animation<double> _ringAnimation;
  bool _isStart = false;

  @override
  void initState() {
    super.initState();
    _isStart = ref.read(isStartProvider);

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
    if (_isStart) {
      _ringController.repeat(reverse: true);
    }

    ref.listenManual(
      runTimeProvider.select((state) => state != null),
      (prev, next) {
        if (next != _isStart) {
          setState(() {
            _isStart = next;
          });
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

  void _handleSwitchStart() {
    setState(() {
      _isStart = !_isStart;
    });
    _updateController();
    debouncer.call(
      FunctionTag.updateStatus,
      () {
        appController.updateStatus(_isStart);
      },
      duration: commonDuration,
    );
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

  void _navigateToProxies() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FlatNodeListView(),
      ),
    );
  }

  // --- Mode change logic (ported from XBoardOutboundMode) ---

  void _handleModeChange(Mode modeOption) {
    _logger.debug('[VpnHeroCard] Mode change to: $modeOption');
    final currentMode =
        ref.read(patchClashConfigProvider.select((state) => state.mode));
    if (currentMode != modeOption) {
      _syncNodeSelectionOnModeChange(from: currentMode, to: modeOption);
    }
    appController.changeMode(modeOption);
    if (modeOption == Mode.global) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _ensureValidProxyForGlobalMode();
      });
    }
  }

  Future<void> _handleTunToggle(bool selected) async {
    if (selected) {
      final storageService = ref.read(storageServiceProvider);
      final hasShownResult = await storageService.hasTunFirstUseShown();
      final hasShown = hasShownResult.dataOrNull ?? false;
      if (!hasShown) {
        if (mounted) {
          final shouldEnable = await TunIntroductionDialog.show(context);
          if (shouldEnable == true) {
            await storageService.markTunFirstUseShown();
            ref.read(patchClashConfigProvider.notifier).update(
                  (state) => state.copyWith.tun(enable: true),
                );
          }
        }
      } else {
        ref.read(patchClashConfigProvider.notifier).update(
              (state) => state.copyWith.tun(enable: true),
            );
      }
    } else {
      ref.read(patchClashConfigProvider.notifier).update(
            (state) => state.copyWith.tun(enable: false),
          );
    }
  }

  void _syncNodeSelectionOnModeChange({
    required Mode from,
    required Mode to,
  }) {
    final groups = ref.read(groupsProvider);
    final selectedMap = ref.read(selectedMapProvider);
    if (groups.isEmpty) return;

    if (from == Mode.rule && to == Mode.global) {
      final resolved = resolveCurrentNode(
        groups: groups,
        selectedMap: selectedMap,
        mode: Mode.rule,
      );
      if (resolved.proxy != null &&
          resolved.proxy!.name.toUpperCase() != 'DIRECT' &&
          resolved.proxy!.name.toUpperCase() != 'REJECT') {
        appController.updateCurrentSelectedMap(
          GroupName.GLOBAL.name,
          resolved.proxy!.name,
        );
      }
    } else if (from == Mode.global && to == Mode.rule) {
      final globalGroup = groups.firstWhere(
        (g) => g.name == GroupName.GLOBAL.name,
        orElse: () => groups.first,
      );
      final globalSelected = selectedMap[globalGroup.name];
      if (globalSelected != null &&
          globalSelected.isNotEmpty &&
          globalSelected.toUpperCase() != 'DIRECT' &&
          globalSelected.toUpperCase() != 'REJECT') {
        final ruleGroup = groups.firstWhere(
          (g) =>
              g.name != GroupName.GLOBAL.name &&
              g.hidden != true &&
              g.type == GroupType.Selector,
          orElse: () => globalGroup,
        );
        if (ruleGroup.name != globalGroup.name) {
          final nodeExists =
              ruleGroup.all.any((p) => p.name == globalSelected);
          if (nodeExists) {
            appController.updateCurrentSelectedMap(
              ruleGroup.name,
              globalSelected,
            );
          }
        }
      }
    }
  }

  void _ensureValidProxyForGlobalMode() {
    final groups = ref.read(groupsProvider);
    if (groups.isEmpty) return;
    final globalGroup = groups.firstWhere(
      (group) => group.name == GroupName.GLOBAL.name,
      orElse: () => groups.first,
    );
    if (globalGroup.all.isEmpty) return;
    final selectedMap = ref.read(selectedMapProvider);
    final currentSelected = selectedMap[globalGroup.name];
    if (currentSelected != null && currentSelected.isNotEmpty) {
      final selectedProxy = globalGroup.all.firstWhere(
        (proxy) => proxy.name == currentSelected,
        orElse: () => globalGroup.all.first,
      );
      if (selectedProxy.name == currentSelected &&
          selectedProxy.name.toUpperCase() != 'DIRECT' &&
          selectedProxy.name.toUpperCase() != 'REJECT') {
        return;
      }
    }
    Proxy? validProxy;
    for (final proxy in globalGroup.all) {
      if (proxy.name.toUpperCase() != 'DIRECT' &&
          proxy.name.toLowerCase() != 'direct' &&
          proxy.name.toUpperCase() != 'REJECT') {
        validProxy = proxy;
        break;
      }
    }
    if (validProxy != null) {
      appController.updateCurrentSelectedMap(
        globalGroup.name,
        validProxy.name,
      );
    }
  }

  // --- Subscription helpers (ported from SubscriptionUsageCard) ---

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
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes;
    int unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    if (size >= 100) {
      return '${size.toStringAsFixed(0)} ${units[unitIndex]}';
    } else if (size >= 10) {
      return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
    } else {
      return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
    }
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

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    final hasProfile = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    if (!hasProfile) {
      return const SizedBox.shrink();
    }

    final groups = ref.watch(groupsProvider);
    final selectedMap = ref.watch(selectedMapProvider);
    final mode =
        ref.watch(patchClashConfigProvider.select((state) => state.mode));
    final tunEnabled = ref.watch(
        patchClashConfigProvider.select((state) => state.tun.enable));

    if (groups.isEmpty) {
      return _buildEmptyState(context);
    }

    final (:group, :proxy) = resolveCurrentNode(
      groups: groups,
      selectedMap: selectedMap,
      mode: mode,
    );

    if (group == null || proxy == null) {
      return _buildEmptyState(context);
    }

    return _buildCard(context, proxy, mode, tunEnabled);
  }

  Widget _buildCard(
      BuildContext context, Proxy proxy, Mode mode, bool tunEnabled) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final bgColor =
        _isStart ? colorScheme.tertiaryContainer : colorScheme.primaryContainer;
    final statusColor =
        _isStart ? colorScheme.tertiary : colorScheme.primary;
    final onStatusColor =
        _isStart ? colorScheme.onTertiary : colorScheme.onPrimary;

    const buttonSize = 64.0;
    const ringSize = 80.0;

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
        child: Column(
          children: [
            // Row 1: Status + Node (left) | Start Button (right)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isStart
                            ? AppLocalizations.of(context).xboardConnected
                            : AppLocalizations.of(context).xboardDisconnected,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              proxy.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildLatency(proxy),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Start button with ring
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
                            painter: _RingPainter(
                              color: statusColor,
                              isActive: _isStart,
                              pulseProgress: _ringAnimation.value,
                              buttonRadius: buttonSize / 2,
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
                              size: 32,
                              color: onStatusColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Row 2: Compact subscription info
            _buildSubscriptionRow(
              theme,
              colorScheme,
              progress,
              usedTraffic,
              totalTraffic,
              remainingDays,
            ),

            const SizedBox(height: 16),

            // Row 3: Mode + TUN + Switch Node
            _buildControlsRow(theme, colorScheme, mode, tunEnabled),
          ],
        ),
      ),
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
                    ? AppLocalizations.of(context).xboardUnlimitedTime
                    : AppLocalizations.of(context).xboardDays,
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

  Widget _buildControlsRow(
    ThemeData theme,
    ColorScheme colorScheme,
    Mode mode,
    bool tunEnabled,
  ) {
    return Row(
      children: [
        Flexible(
          child: SegmentedButton<Mode>(
            segments: [
              ButtonSegment(
                value: Mode.rule,
                label: Text(
                  Intl.message(Mode.rule.name),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              ButtonSegment(
                value: Mode.global,
                label: Text(
                  Intl.message(Mode.global.name),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
            selected: {mode == Mode.direct ? Mode.rule : mode},
            onSelectionChanged: (selected) {
              _handleModeChange(selected.first);
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('TUN', style: TextStyle(fontSize: 12)),
          selected: tunEnabled,
          onSelected: (selected) {
            _handleTunToggle(selected);
          },
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          selectedColor: colorScheme.tertiaryContainer,
          checkmarkColor: colorScheme.onTertiaryContainer,
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: _navigateToProxies,
          icon: const Icon(Icons.swap_horiz, size: 16),
          label: Text(
            AppLocalizations.of(context).xboardSwitchNode,
            style: const TextStyle(fontSize: 12),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildLatency(Proxy proxy) {
    final delayState = ref.watch(getDelayProvider(
      proxyName: proxy.name,
      testUrl: ref.read(appSettingProvider).testUrl,
    ));
    return LatencyIndicator(
      delayValue: delayState,
      onTap: () => autoLatencyService.testProxy(proxy, forceTest: true),
      isCompact: true,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  AppLocalizations.of(context).xboardNoAvailableNodes,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).xboardClickToSetupNodes,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: _navigateToProxies,
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
              AppLocalizations.of(context).xboardSetup,
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
}

class _RingPainter extends CustomPainter {
  final Color color;
  final bool isActive;
  final double pulseProgress;
  final double buttonRadius;

  _RingPainter({
    required this.color,
    required this.isActive,
    required this.pulseProgress,
    required this.buttonRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = buttonRadius + 6;

    if (isActive) {
      final scale = 1.0 + 0.08 * pulseProgress;
      final opacity = 0.3 + 0.5 * pulseProgress;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = color.withValues(alpha: opacity);
      canvas.drawCircle(center, baseRadius * scale, paint);
    } else {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = color.withValues(alpha: 0.3);
      canvas.drawCircle(center, baseRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.isActive != isActive ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.color != color;
  }
}
