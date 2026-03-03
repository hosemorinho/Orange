import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/text.dart';
import 'package:fl_clash/xboard/features/shared/utils/node_resolver.dart';
import 'package:fl_clash/xboard/features/latency/widgets/latency_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/tv_connect_button.dart';
import '../widgets/tv_design_tokens.dart';
import '../widgets/tv_mode_selector.dart';
import '../widgets/tv_node_grid.dart';
import '../widgets/tv_traffic_bar.dart';

/// TV home page with two-column landscape layout.
class TvHomePage extends ConsumerWidget {
  const TvHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: TvDesignTokens.background(colorScheme),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: TvDesignTokens.pagePadding,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _TvPanel(
                          emphasized: true,
                          child: _ConnectionPanel(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        flex: 3,
                        child: _TvPanel(child: TvNodeGrid()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: const TvTrafficBar(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectionPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appLocalizations = AppLocalizations.of(context);
    final isStart = ref.watch(isStartProvider);
    final groups = ref.watch(groupsProvider);
    final selectedMap = ref.watch(selectedMapProvider);
    final mode = ref.watch(
      patchClashConfigProvider.select((state) => state.mode),
    );

    // Resolve current node
    final resolved = resolveCurrentNode(
      groups: groups,
      selectedMap: selectedMap,
      mode: mode,
    );
    final proxy = resolved.proxy;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isStart ? Icons.verified_rounded : Icons.link_off_rounded,
                size: 22,
                color: isStart
                    ? colorScheme.tertiary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                isStart
                    ? appLocalizations.xboardConnected
                    : appLocalizations.xboardDisconnected,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isStart ? colorScheme.tertiary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.dns_rounded, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appLocalizations.xboardCurrentNode,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (proxy != null)
                        EmojiText(
                          proxy.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text(
                          '--',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (proxy != null) ...[
                  const SizedBox(width: 8),
                  _NodeLatency(proxy: proxy),
                ],
              ],
            ),
          ),
          const Spacer(),

          // Connect button
          const Center(child: TvConnectButton()),
          const SizedBox(height: 28),

          // Mode selector
          const TvModeSelector(),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _TvPanel extends StatelessWidget {
  final Widget child;
  final bool emphasized;

  const _TvPanel({required this.child, this.emphasized = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: TvDesignTokens.panel(colorScheme, emphasized: emphasized),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _NodeLatency extends ConsumerWidget {
  final Proxy proxy;
  const _NodeLatency({required this.proxy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delayState = ref.watch(
      getDelayProvider(
        proxyName: proxy.name,
        testUrl: ref.read(appSettingProvider).testUrl,
      ),
    );
    return LatencyIndicator(delayValue: delayState, isCompact: true);
  }
}
