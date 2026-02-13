import 'dart:math';

import 'package:fl_clash/controller.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/leaf/leaf_controller.dart';
import 'package:fl_clash/leaf/providers/leaf_providers.dart';
import 'package:fl_clash/leaf/widgets/leaf_node_list.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Leaf connection status card — replaces the Clash-based ConnectionStatusCard.
///
/// Shows connection state, selected node, and latency using leaf providers.
/// Uses appController.updateStatus() for full lifecycle management.
class LeafConnectionStatusCard extends ConsumerStatefulWidget {
  const LeafConnectionStatusCard({super.key});

  @override
  ConsumerState<LeafConnectionStatusCard> createState() =>
      _LeafConnectionStatusCardState();
}

class _LeafConnectionStatusCardState
    extends ConsumerState<LeafConnectionStatusCard>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconAnimation;
  late AnimationController _ringController;
  late Animation<double> _ringAnimation;
  bool _isStart = false;
  bool _isSwitching = false;

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
    if (_isStart) _ringController.repeat(reverse: true);

    ref.listenManual(
      isStartProvider,
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
    final targetState = !_isStart;
    setState(() => _isStart = targetState);
    _updateController();
    appController
        .updateStatus(targetState, trigger: 'leaf_connection_status_card.switch')
        .whenComplete(() {
      final actualState = ref.read(isStartProvider);
      if (mounted && actualState != _isStart) {
        setState(() => _isStart = actualState);
        _updateController();
      }
      _isSwitching = false;
    });
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

  @override
  Widget build(BuildContext context) {
    final nodes = ref.watch(leafNodesProvider);
    final selectedTag = ref.watch(selectedNodeTagProvider);
    final delays = ref.watch(nodeDelaysProvider);

    if (nodes.isEmpty) return _buildEmptyState(context);

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

    const buttonSize = 100.0;
    final appLocalizations = AppLocalizations.of(context);

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
                  ? appLocalizations.xboardConnected
                  : appLocalizations.xboardDisconnected,
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
                    nodeName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildLatencyChip(context, nodeName, delayMs),
              ],
            ),
            const SizedBox(height: 16),
            // Switch node button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _navigateToNodes,
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: Text(appLocalizations.xboardSwitchNode),
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

  Widget _buildLatencyChip(BuildContext context, String nodeTag, int? delayMs) {
    final colorScheme = Theme.of(context).colorScheme;

    if (delayMs == null) {
      return InkWell(
        onTap: () => _testNodeDelay(nodeTag),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.speed,
            size: 18,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
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

    return InkWell(
      onTap: () => _testNodeDelay(nodeTag),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: chipColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${delayMs}ms',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: chipColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Future<void> _testNodeDelay(String tag) async {
    final controller = ref.read(leafControllerProvider);
    final node = controller.nodes.where((n) => n.tag == tag).firstOrNull;
    if (node == null) return;
    final result = await controller.tcpPing(node);
    final delays = Map<String, int?>.from(ref.read(nodeDelaysProvider));
    delays[tag] = result;
    ref.read(nodeDelaysProvider.notifier).state = delays;
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
      final scale = 1.0 + 0.08 * pulseProgress;
      final opacity = 0.3 + 0.5 * pulseProgress;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = color.withValues(alpha: opacity);
      canvas.drawCircle(center, baseRadius * scale, paint);
    } else {
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
