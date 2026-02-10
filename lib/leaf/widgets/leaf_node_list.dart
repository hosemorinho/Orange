import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/leaf/leaf_controller.dart';
import 'package:fl_clash/leaf/models/leaf_node.dart';
import 'package:fl_clash/leaf/providers/leaf_providers.dart';
import 'package:fl_clash/widgets/text.dart';
import 'package:fl_clash/xboard/features/shared/utils/node_tag_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Flat node list for leaf — replaces the Clash-based FlatNodeListView.
///
/// Shows all proxy nodes from the leaf select outbound as a flat list.
/// No groups, no modes — just nodes.
class LeafNodeListView extends ConsumerStatefulWidget {
  const LeafNodeListView({super.key});

  @override
  ConsumerState<LeafNodeListView> createState() => _LeafNodeListViewState();
}

class _LeafNodeListViewState extends ConsumerState<LeafNodeListView> {
  String _searchQuery = '';
  bool _isTesting = false;

  Future<void> _testAllNodesDelay() async {
    if (_isTesting) return;
    setState(() => _isTesting = true);
    try {
      await runHealthChecks(ref);
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final nodes = ref.watch(leafNodesProvider);
    final selectedTag = ref.watch(selectedNodeTagProvider);
    final delays = ref.watch(nodeDelaysProvider);

    final filtered = _searchQuery.isEmpty
        ? nodes
        : nodes.where((n) {
            final q = _searchQuery.toLowerCase();
            return n.tag.toLowerCase().contains(q) ||
                n.protocol.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.xboardSwitchNode),
        actions: [
          if (_isTesting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.speed),
              tooltip: appLocalizations.xboardTestAllNodes,
              onPressed: _testAllNodesDelay,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: appLocalizations.xboardSearchNode,
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      appLocalizations.noData,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final node = filtered[index];
                      final isSelected = node.tag == selectedTag;
                      final delay = delays[node.tag];
                      return _LeafNodeCard(
                        node: node,
                        isSelected: isSelected,
                        delayMs: delay,
                        onTap: () => _selectNode(node),
                        onTestDelay: () => _testNodeDelay(node),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectNode(LeafNode node) async {
    await selectLeafNode(ref, node.tag);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _testNodeDelay(LeafNode node) async {
    final controller = ref.read(leafControllerProvider);
    final result = await controller.healthCheck(node.tag);
    if (result != null) {
      final delays = Map<String, int?>.from(ref.read(nodeDelaysProvider));
      delays[node.tag] = result.tcpMs > 0 ? result.tcpMs : null;
      ref.read(nodeDelaysProvider.notifier).state = delays;
    }
  }
}

class _LeafNodeCard extends StatelessWidget {
  final LeafNode node;
  final bool isSelected;
  final int? delayMs;
  final VoidCallback onTap;
  final VoidCallback onTestDelay;

  const _LeafNodeCard({
    required this.node,
    required this.isSelected,
    required this.delayMs,
    required this.onTap,
    required this.onTestDelay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tags = extractNodeTags(node.tag);

    return Card(
      elevation: 0,
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: colorScheme.primary.withValues(alpha: 0.3))
            : BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: Icon(
          Icons.dns,
          color:
              isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        title: EmojiText(
          node.tag,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _protocolLabel(node.protocol),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: tags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        trailing: _buildLatencyChip(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLatencyChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (delayMs == null) {
      return InkWell(
        onTap: onTestDelay,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.speed,
            size: 20,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
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

    return InkWell(
      onTap: onTestDelay,
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

  String _protocolLabel(String protocol) {
    return switch (protocol) {
      'ss' => 'Shadowsocks',
      'vmess' => 'VMess',
      'trojan' => 'Trojan',
      _ => protocol.toUpperCase(),
    };
  }
}
