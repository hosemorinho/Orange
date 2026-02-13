import 'dart:math';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/common.dart' as proxies_common;
import 'package:fl_clash/xboard/features/subscription/widgets/flat_node_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/features/latency/widgets/latency_indicator.dart';
import 'package:fl_clash/xboard/features/shared/utils/node_resolver.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/widgets/text.dart';
import 'package:intl/intl.dart';

class ConnectionStatusCard extends ConsumerStatefulWidget {
  const ConnectionStatusCard({super.key});

  @override
  ConsumerState<ConnectionStatusCard> createState() =>
      _ConnectionStatusCardState();
}

class _ConnectionStatusCardState extends ConsumerState<ConnectionStatusCard>
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
        appController.updateStatus(
          _isStart,
          trigger: 'xboard.connection_status_card',
        );
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

    const buttonSize = 100.0;

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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Status text
            Text(
              _isStart
                  ? AppLocalizations.of(context).xboardConnected
                  : AppLocalizations.of(context).xboardDisconnected,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 20),
            // Hero button with ring
            SizedBox(
              width: buttonSize + 24,
              height: buttonSize + 24,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  AnimatedBuilder(
                    animation: _ringAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(buttonSize + 24, buttonSize + 24),
                        painter: _RingPainter(
                          color: statusColor,
                          isActive: _isStart,
                          pulseProgress: _ringAnimation.value,
                          buttonRadius: buttonSize / 2,
                        ),
                      );
                    },
                  ),
                  // Button
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
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedIcon(
                          icon: AnimatedIcons.play_pause,
                          progress: _iconAnimation,
                          size: 44,
                          color: onStatusColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Node info row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: EmojiText(
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
            const SizedBox(height: 8),
            // Mode labels
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 16),
            // Switch node button
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
      onTap: () => proxies_common.proxyDelayTest(proxy, ref.read(appSettingProvider).testUrl),
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
    final baseRadius = buttonRadius + 8;

    if (isActive) {
      // Pulsing ring when connected
      final scale = 1.0 + 0.08 * pulseProgress;
      final opacity = 0.3 + 0.5 * pulseProgress;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = color.withValues(alpha: opacity);
      canvas.drawCircle(center, baseRadius * scale, paint);
    } else {
      // Static ring when disconnected
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
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
