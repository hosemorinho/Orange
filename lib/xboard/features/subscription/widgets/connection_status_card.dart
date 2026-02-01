import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/xboard/features/subscription/widgets/flat_node_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/features/latency/services/auto_latency_service.dart';
import 'package:fl_clash/xboard/features/latency/widgets/latency_indicator.dart';
import 'package:fl_clash/xboard/features/shared/utils/node_resolver.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:intl/intl.dart';

class ConnectionStatusCard extends ConsumerStatefulWidget {
  const ConnectionStatusCard({super.key});

  @override
  ConsumerState<ConnectionStatusCard> createState() =>
      _ConnectionStatusCardState();
}

class _ConnectionStatusCardState extends ConsumerState<ConnectionStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isStart = false;

  @override
  void initState() {
    super.initState();
    _isStart = globalState.appState.runTime != null;
    _controller = AnimationController(
      vsync: this,
      value: _isStart ? 1 : 0,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    ref.listenManual(
      runTimeProvider.select((state) => state != null),
      (prev, next) {
        if (next != _isStart) {
          _isStart = next;
          _updateController();
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSwitchStart() {
    _isStart = !_isStart;
    _updateController();
    debouncer.call(
      FunctionTag.updateStatus,
      () {
        globalState.appController.updateStatus(_isStart);
      },
      duration: commonDuration,
    );
  }

  void _updateController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isStart) {
        _controller.forward();
      } else {
        _controller.reverse();
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(startButtonSelectorStateProvider);
    if (!state.isInit || !state.hasProfile) {
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Connect/Disconnect button
                GestureDetector(
                  onTap: _handleSwitchStart,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        progress: _animation,
                        size: 36,
                        color: onStatusColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Node info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isStart
                            ? AppLocalizations.of(context).xboardConnected
                            : AppLocalizations.of(context).xboardDisconnected,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _ModeLabel(
                            label: Intl.message(mode.name),
                            color: colorScheme.primary,
                          ),
                          if (tunEnabled) ...[
                            const SizedBox(width: 6),
                            _ModeLabel(
                              label: 'TUN',
                              color: colorScheme.tertiary,
                              icon: Icons.check,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _navigateToProxies,
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: Text(AppLocalizations.of(context).xboardSwitchNode),
                style: OutlinedButton.styleFrom(
                  foregroundColor: statusColor,
                  side: BorderSide(
                    color: statusColor.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
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
        borderRadius: BorderRadius.circular(20),
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

class _ModeLabel extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _ModeLabel({
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 2),
            Icon(icon, size: 11, color: color),
          ],
        ],
      ),
    );
  }
}
