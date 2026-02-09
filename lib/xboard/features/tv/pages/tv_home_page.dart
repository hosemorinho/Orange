import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/text.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/shared/utils/node_resolver.dart';
import 'package:fl_clash/xboard/features/latency/widgets/latency_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/tv_connect_button.dart';
import '../widgets/tv_mode_selector.dart';
import '../widgets/tv_node_grid.dart';
import '../widgets/tv_traffic_bar.dart';

/// TV home page with two-column landscape layout.
class TvHomePage extends ConsumerWidget {
  const TvHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // LEFT: Connection control
                Expanded(
                  flex: 2,
                  child: _ConnectionPanel(),
                ),
                VerticalDivider(
                  width: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                // RIGHT: Node selection
                const Expanded(
                  flex: 3,
                  child: TvNodeGrid(),
                ),
              ],
            ),
          ),
          // Bottom traffic bar
          const TvTrafficBar(),
        ],
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
    final mode =
        ref.watch(patchClashConfigProvider.select((state) => state.mode));

    // Resolve current node
    final (:group, :proxy) = resolveCurrentNode(
      groups: groups,
      selectedMap: selectedMap,
      mode: mode,
    );

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status text
          Text(
            isStart
                ? appLocalizations.xboardConnected
                : appLocalizations.xboardDisconnected,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isStart ? colorScheme.tertiary : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Current node info
          if (proxy != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: EmojiText(
                    proxy.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _NodeLatency(proxy: proxy),
              ],
            ),
            const SizedBox(height: 24),
          ] else
            const SizedBox(height: 32),

          // Connect button
          const TvConnectButton(),
          const SizedBox(height: 32),

          // Mode selector
          const TvModeSelector(),
        ],
      ),
    );
  }
}

class _NodeLatency extends ConsumerWidget {
  final Proxy proxy;
  const _NodeLatency({required this.proxy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delayState = ref.watch(getDelayProvider(
      proxyName: proxy.name,
      testUrl: ref.read(appSettingProvider).testUrl,
    ));
    return LatencyIndicator(
      delayValue: delayState,
      isCompact: true,
    );
  }
}
