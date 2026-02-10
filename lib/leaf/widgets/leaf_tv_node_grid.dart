import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/leaf/leaf_controller.dart';
import 'package:fl_clash/leaf/models/leaf_node.dart';
import 'package:fl_clash/leaf/providers/leaf_providers.dart';
import 'package:fl_clash/widgets/text.dart';
import 'package:fl_clash/xboard/features/tv/widgets/tv_focus_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// D-pad navigable node grid for TV — leaf version.
///
/// Uses leaf providers instead of Clash groupsProvider/selectedMapProvider.
/// Flat list, no groups or modes.
class LeafTvNodeGrid extends ConsumerWidget {
  const LeafTvNodeGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodes = ref.watch(leafNodesProvider);
    final selectedTag = ref.watch(selectedNodeTagProvider);
    final delays = ref.watch(nodeDelaysProvider);
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.dns, size: 24, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                appLocalizations.xboardSwitchNode,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${nodes.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Grid
        Expanded(
          child: nodes.isEmpty
              ? Center(
                  child: Text(
                    appLocalizations.noData,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : FocusTraversalGroup(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 3.0,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: nodes.length,
                    itemBuilder: (context, index) {
                      final node = nodes[index];
                      final isSelected = node.tag == selectedTag;
                      final delay = delays[node.tag];
                      return _LeafTvNodeCard(
                        node: node,
                        isSelected: isSelected,
                        delayMs: delay,
                        onTap: () => selectLeafNode(ref, node.tag),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _LeafTvNodeCard extends ConsumerWidget {
  final LeafNode node;
  final bool isSelected;
  final int? delayMs;
  final VoidCallback onTap;

  const _LeafTvNodeCard({
    required this.node,
    required this.isSelected,
    required this.delayMs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TvFocusCard(
      isSelected: isSelected,
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.dns,
            size: 20,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EmojiText(
                  node.tag,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _protocolLabel(node.protocol),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _buildLatency(context),
        ],
      ),
    );
  }

  Widget _buildLatency(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (delayMs == null) {
      return Icon(
        Icons.speed,
        size: 16,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      );
    }

    final Color chipColor;
    if (delayMs! <= 200) {
      chipColor = Colors.green;
    } else if (delayMs! <= 500) {
      chipColor = Colors.orange;
    } else {
      chipColor = colorScheme.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${delayMs}ms',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _protocolLabel(String protocol) {
    return switch (protocol) {
      'ss' => 'Shadowsocks',
      'vmess' => 'VMess',
      'trojan' => 'Trojan',
      _ => protocol.toUpperCase(),
    };
  }
}
