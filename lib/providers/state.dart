import 'package:dynamic_color/dynamic_color.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fl_clash/leaf/providers/leaf_providers.dart';

import 'app.dart';
import 'config.dart';
import 'database.dart';

part 'generated/state.g.dart';

@riverpod
GroupsState currentGroupsState(Ref ref) {
  final mode = ref.watch(
    patchClashConfigProvider.select((state) => state.mode),
  );
  final groups = ref.watch(
    groupsProvider.select(
      (state) => state.map((item) {
        return item.copyWith(
          now: '',
          all: item.all.map((proxy) => proxy.copyWith(now: '')).toList(),
        );
      }),
    ),
  );
  return GroupsState(
    value: switch (mode) {
      Mode.direct => [],
      Mode.global =>
        groups
            .where((element) => element.name == GroupName.GLOBAL.name)
            .toList(),
      Mode.rule =>
        groups
            .where((item) => item.hidden == false)
            .where((element) => element.name != GroupName.GLOBAL.name)
            .toList(),
    },
  );
}

@riverpod
UpdateParams updateParams(Ref ref) {
  final routeMode = ref.watch(
    networkSettingProvider.select((state) => state.routeMode),
  );
  return ref.watch(
    patchClashConfigProvider.select(
      (state) => UpdateParams(
        tun: state.tun.getRealTun(routeMode),
        allowLan: state.allowLan,
        findProcessMode: state.findProcessMode,
        mode: state.mode,
        logLevel: state.logLevel,
        ipv6: state.ipv6,
        tcpConcurrent: state.tcpConcurrent,
        externalController: state.externalController,
        unifiedDelay: state.unifiedDelay,
        mixedPort: state.mixedPort,
      ),
    ),
  );
}

@riverpod
ProxyState proxyState(Ref ref) {
  final isStart = ref.watch(isStartProvider);
  final vm2 = ref.watch(
    networkSettingProvider.select(
      (state) => VM2(state.systemProxy, state.bypassDomain),
    ),
  );
  // Use the actual port leaf is listening on (may differ from config if
  // the configured port was occupied and a fallback was used).
  final activePort = ref.watch(activePortProvider);
  final configPort = ref.watch(
    patchClashConfigProvider.select((state) => state.mixedPort),
  );
  return ProxyState(
    isStart: isStart,
    systemProxy: vm2.a,
    bassDomain: vm2.b,
    port: activePort ?? configPort,
  );
}

@riverpod
TrayState trayState(Ref ref) {
  final isStart = ref.watch(isStartProvider);
  final systemProxy = ref.watch(
    networkSettingProvider.select((state) => state.systemProxy),
  );
  final clashConfigVm3 = ref.watch(
    patchClashConfigProvider.select(
      (state) => VM3(state.mode, state.mixedPort, state.tun.enable),
    ),
  );
  final appSettingVm3 = ref.watch(
    appSettingProvider.select(
      (state) => VM3(state.autoLaunch, state.locale, state.showTrayTitle),
    ),
  );
  final groups = ref.watch(currentGroupsStateProvider).value;
  final brightness = ref.watch(systemBrightnessProvider);
  final selectedMap = ref.watch(selectedMapProvider);

  return TrayState(
    mode: clashConfigVm3.a,
    port: clashConfigVm3.b,
    autoLaunch: appSettingVm3.a,
    systemProxy: systemProxy,
    tunEnable: clashConfigVm3.c,
    isStart: isStart,
    locale: appSettingVm3.b,
    brightness: brightness,
    groups: groups,
    selectedMap: selectedMap,
    showTrayTitle: appSettingVm3.c,
  );
}

@riverpod
TrayTitleState trayTitleState(Ref ref) {
  final showTrayTitle = ref.watch(
    appSettingProvider.select((state) => state.showTrayTitle),
  );
  final traffic = ref.watch(
    trafficsProvider.select((state) => state.list.safeLast(Traffic())),
  );
  return TrayTitleState(showTrayTitle: showTrayTitle, traffic: traffic);
}

@riverpod
VpnState vpnState(Ref ref) {
  final vpnProps = ref.watch(vpnSettingProvider);
  final stack = ref.watch(
    patchClashConfigProvider.select((state) => state.tun.stack),
  );
  return VpnState(stack: stack, vpnProps: vpnProps);
}

@riverpod
VM2<bool, TunStack> desktopTunState(Ref ref) {
  final enable = ref.watch(
    patchClashConfigProvider.select((state) => state.tun.enable),
  );
  final stack = ref.watch(
    patchClashConfigProvider.select((state) => state.tun.stack),
  );
  return VM2(enable, stack);
}

@riverpod
bool isStart(Ref ref) {
  final runtimeReady = ref.watch(
    runTimeProvider.select((state) => state != null),
  );
  final leafRunning = ref.watch(isLeafRunningProvider);
  return runtimeReady && leafRunning;
}

@riverpod
String realTestUrl(Ref ref, [String? testUrl]) {
  final currentTestUrl = ref.watch(appSettingProvider).testUrl;
  return testUrl.takeFirstValid([currentTestUrl]);
}

@riverpod
int? getDelay(Ref ref, {required String proxyName, String? testUrl}) {
  final currentTestUrl = ref.watch(realTestUrlProvider(testUrl));
  final proxyState = ref.watch(realSelectedProxyStateProvider(proxyName));
  final delay = ref.watch(
    delayDataSourceProvider.select((state) {
      final delayMap =
          state[proxyState.testUrl.takeFirstValid([currentTestUrl])];
      return delayMap?[proxyState.proxyName];
    }),
  );

  return delay;
}

@riverpod
Map<String, String> selectedMap(Ref ref) {
  final selectedMap = ref.watch(
    currentProfileProvider.select((state) => state?.selectedMap ?? {}),
  );
  return selectedMap;
}

@riverpod
HotKeyAction getHotKeyAction(Ref ref, HotAction hotAction) {
  return ref.watch(
    hotKeyActionsProvider.select((state) {
      final index = state.indexWhere((item) => item.action == hotAction);
      return index != -1 ? state[index] : HotKeyAction(action: hotAction);
    }),
  );
}

@riverpod
Profile? currentProfile(Ref ref) {
  final profileId = ref.watch(currentProfileIdProvider);
  return ref.watch(
    profilesProvider.select((state) => state.getProfile(profileId)),
  );
}

@riverpod
int getProxiesColumns(Ref ref) {
  final viewWidth = ref.watch(viewWidthProvider);
  final sideWidth = ref.watch(sideWidthProvider);
  final contentWidth = viewWidth - sideWidth;
  final proxiesLayout = ref.watch(
    proxiesStyleSettingProvider.select((state) => state.layout),
  );
  return utils.getProxiesColumns(contentWidth, proxiesLayout);
}

@riverpod
SelectedProxyState realSelectedProxyState(Ref ref, String proxyName) {
  final groups = ref.watch(groupsProvider);
  final selectedMap = ref.watch(selectedMapProvider);
  return computeRealSelectedProxyState(
    proxyName,
    groups: groups,
    selectedMap: selectedMap,
  );
}

@riverpod
String? getSelectedProxyName(Ref ref, String groupName) {
  final proxyName = ref.watch(
    selectedMapProvider.select((state) => state[groupName]),
  );
  final group = ref.watch(
    groupsProvider.select((state) => state.getGroup(groupName)),
  );
  return group?.getCurrentSelectedName(proxyName ?? '');
}

@riverpod
VM3<bool, int, bool> checkIp(Ref ref) {
  final isInit = ref.watch(initProvider);
  final checkIpNum = ref.watch(checkIpNumProvider);
  final containsDetection = ref.watch(
    appSettingProvider.select(
      (state) =>
          state.dashboardWidgets.contains(DashboardWidget.networkDetection),
    ),
  );
  return VM3(isInit, checkIpNum, containsDetection);
}

@riverpod
ColorScheme genColorScheme(
  Ref ref,
  Brightness brightness, {
  Color? color,
  bool ignoreConfig = false,
}) {
  final vm2 = ref.watch(
    themeSettingProvider.select(
      (state) => VM2(state.primaryColor, state.schemeVariant),
    ),
  );
  if (color == null && (ignoreConfig == true || vm2.a == null)) {
    // if (globalState.corePalette != null) {
    //   return globalState.corePalette!.toColorScheme(brightness: brightness);
    // }
    return ColorScheme.fromSeed(
      seedColor:
          globalState.corePalette
              ?.toColorScheme(brightness: brightness)
              .primary ??
          globalState.accentColor,
      brightness: brightness,
      dynamicSchemeVariant: vm2.b,
    );
  }
  return ColorScheme.fromSeed(
    seedColor: color ?? Color(vm2.a!),
    brightness: brightness,
    dynamicSchemeVariant: vm2.b,
  );
}

@riverpod
SetupState? currentSetupState(Ref ref) {
  final profileId = ref.watch(currentProfileIdProvider);
  return ref.watch(setupStateProvider(profileId)).value;
}

@riverpod
Brightness currentBrightness(Ref ref) {
  final themeMode = ref.watch(
    themeSettingProvider.select((state) => state.themeMode),
  );
  final systemBrightness = ref.watch(systemBrightnessProvider);
  return switch (themeMode) {
    ThemeMode.system => systemBrightness,
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
  };
}

@riverpod
VM2<bool, bool> autoSetSystemDnsState(Ref ref) {
  final isStart = ref.watch(isStartProvider);
  final realTunEnable = ref.watch(realTunEnableProvider);
  final autoSetSystemDns = ref.watch(
    networkSettingProvider.select((state) => state.autoSetSystemDns),
  );
  return VM2(isStart ? realTunEnable : false, autoSetSystemDns);
}

@riverpod
VM3<bool, int, ProxiesSortType> needUpdateGroups(Ref ref) {
  final sortNum = ref.watch(sortNumProvider);
  final sortType = ref.watch(
    proxiesStyleSettingProvider.select((state) => state.sortType),
  );
  // Legacy page-label gating is removed with old views.
  return VM3(true, sortNum, sortType);
}

@riverpod
SharedState sharedState(Ref ref) {
  ref.watch((appSettingProvider).select((state) => state.locale));
  final currentProfileVM2 = ref.watch(
    currentProfileProvider.select(
      (state) => VM2(state?.label ?? '', state?.selectedMap ?? {}),
    ),
  );
  final appSettingVM2 = ref.watch(
    appSettingProvider.select(
      (state) => VM2(state.onlyStatisticsProxy, state.testUrl),
    ),
  );
  final bypassDomain = ref.watch(
    networkSettingProvider.select((state) => state.bypassDomain),
  );
  final clashConfigVM2 = ref.watch(
    patchClashConfigProvider.select(
      (state) => VM2(state.tun.stack.name, state.mixedPort),
    ),
  );
  final vpnSetting = ref.watch(vpnSettingProvider);
  final currentProfileName = currentProfileVM2.a;
  final selectedMap = currentProfileVM2.b;
  final onlyStatisticsProxy = appSettingVM2.a;
  final testUrl = appSettingVM2.b;
  final stack = clashConfigVM2.a;
  final port = clashConfigVM2.b;
  return SharedState(
    currentProfileName: currentProfileName,
    onlyStatisticsProxy: onlyStatisticsProxy,
    stopText: appLocalizations.stop,
    stopTip: appLocalizations.stopVpn,
    startTip: appLocalizations.startVpn,
    setupParams: SetupParams(selectedMap: selectedMap, testUrl: testUrl),
    vpnOptions: VpnOptions(
      enable: vpnSetting.enable,
      stack: stack,
      systemProxy: vpnSetting.systemProxy,
      port: port,
      ipv6: vpnSetting.ipv6,
      dnsHijacking: vpnSetting.dnsHijacking,
      accessControlProps: vpnSetting.accessControlProps,
      allowBypass: vpnSetting.allowBypass,
      bypassDomain: bypassDomain,
    ),
  );
}

@riverpod
double overlayTopOffset(Ref ref) {
  final isMobileView = ref.watch(isMobileViewProvider);
  final version = ref.watch(versionProvider);
  ref.watch(viewSizeProvider);
  double top = kHeaderHeight;
  if ((version <= 10 || !isMobileView) && system.isMacOS || !system.isDesktop) {
    top = 0;
  }
  return kToolbarHeight + top;
}

@riverpod
Future<SetupState> setupState(Ref ref, int? profileId) async {
  final profile = ref.watch(
    profilesProvider.select((state) => state.getProfile(profileId)),
  );
  final scriptId = profile?.scriptId;
  final profileLastUpdateDate = profile?.lastUpdateDate?.millisecondsSinceEpoch;
  final overwriteType = profile?.overwriteType ?? OverwriteType.standard;
  final dns = ref.watch(patchClashConfigProvider.select((state) => state.dns));
  final script = await ref.watch(
    scriptsProvider.future.select((state) async {
      final scripts = await state;
      return scripts.get(scriptId);
    }),
  );
  final overrideDns = ref.watch(overrideDnsProvider);
  final List<Rule> addedRules = profileId != null
      ? await ref.watch(addedRuleStreamProvider(profileId).future)
      : [];
  return SetupState(
    profileId: profileId,
    profileLastUpdateDate: profileLastUpdateDate,
    overwriteType: overwriteType,
    addedRules: addedRules,
    script: script,
    overrideDns: overrideDns,
    dns: dns,
  );
}

@riverpod
class AccessControlState extends _$AccessControlState
    with AutoDisposeNotifierMixin {
  @override
  AccessControlProps build() => AccessControlProps();
}
