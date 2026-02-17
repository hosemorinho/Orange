import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'clash_config.dart';
import 'common.dart';
import 'config.dart';
import 'core.dart';
import 'profile.dart';

part 'generated/state.freezed.dart';
part 'generated/state.g.dart';

@freezed
abstract class VM2<A, B> with _$VM2<A, B> {
  const factory VM2(A a, B b) = _VM2;
}

@freezed
abstract class VM3<A, B, C> with _$VM3<A, B, C> {
  const factory VM3(A a, B b, C c) = _VM3;
}

@freezed
abstract class CommonMessage with _$CommonMessage {
  const factory CommonMessage({
    required String id,
    required String text,
    @Default(Duration(seconds: 3)) Duration duration,
    MessageActionState? actionState,
  }) = _CommonMessage;
}

@freezed
abstract class MessageActionState with _$MessageActionState {
  const factory MessageActionState({
    required String actionText,
    required VoidCallback action,
  }) = _MessageActionState;
}

@freezed
abstract class AppBarState with _$AppBarState {
  const factory AppBarState({
    @Default([]) List<Widget> actions,
    AppBarSearchState? searchState,
    AppBarEditState? editState,
  }) = _AppBarState;
}

@freezed
abstract class AppBarSearchState with _$AppBarSearchState {
  const factory AppBarSearchState({
    required Function(String) onSearch,
    @Default(true) bool autoAddSearch,
    @Default(null) String? query,
  }) = _AppBarSearchState;
}

@freezed
abstract class AppBarEditState with _$AppBarEditState {
  const factory AppBarEditState({
    @Default(0) int editCount,
    required Function() onExit,
  }) = _AppBarEditState;
}

@freezed
abstract class NetworkDetectionState with _$NetworkDetectionState {
  const factory NetworkDetectionState({
    required bool isLoading,
    required IpInfo? ipInfo,
  }) = _NetworkDetectionState;
}

@freezed
abstract class TrayState with _$TrayState {
  const factory TrayState({
    required Mode mode,
    required int port,
    required bool autoLaunch,
    required bool systemProxy,
    required bool tunEnable,
    required bool isStart,
    required String? locale,
    required Brightness? brightness,
    required List<Group> groups,
    required Map<String, String> selectedMap,
    required bool showTrayTitle,
  }) = _TrayState;
}

@freezed
abstract class TrayTitleState with _$TrayTitleState {
  const factory TrayTitleState({
    required Traffic traffic,
    required bool showTrayTitle,
  }) = _TrayTitleState;
}

@freezed
abstract class GroupsState with _$GroupsState {
  const factory GroupsState({required List<Group> value}) = _GroupsState;
}

@freezed
abstract class ProxyState with _$ProxyState {
  const factory ProxyState({
    required bool isStart,
    required bool systemProxy,
    required List<String> bassDomain,
    required int port,
  }) = _ProxyState;
}

@freezed
abstract class SelectedProxyState with _$SelectedProxyState {
  const factory SelectedProxyState({
    required String proxyName,
    @Default(false) bool group,
    String? testUrl,
  }) = _SelectedProxyState;
}

@freezed
abstract class VpnState with _$VpnState {
  const factory VpnState({
    required TunStack stack,
    required VpnProps vpnProps,
  }) = _VpnState;
}

@freezed
abstract class SharedState with _$SharedState {
  const factory SharedState({
    SetupParams? setupParams,
    VpnOptions? vpnOptions,
    required String stopTip,
    required String startTip,
    required String currentProfileName,
    required String stopText,
    required bool onlyStatisticsProxy,
  }) = _SharedState;

  factory SharedState.fromJson(Map<String, Object?> json) =>
      _$SharedStateFromJson(json);
}

extension SharedStateExt on SharedState {
  SharedState get needSyncSharedState => copyWith(setupParams: null);
}

@freezed
abstract class MigrationData with _$MigrationData {
  const factory MigrationData({
    Map<String, Object?>? configMap,
    @Default([]) List<Rule> rules,
    @Default([]) List<Script> scripts,
    @Default([]) List<Profile> profiles,
    @Default([]) List<ProfileRuleLink> links,
  }) = _MigrationData;
}

@freezed
abstract class SetupState with _$SetupState {
  const factory SetupState({
    required int? profileId,
    required int? profileLastUpdateDate,
    required OverwriteType overwriteType,
    required List<Rule> addedRules,
    required Script? script,
    required bool overrideDns,
    required Dns dns,
  }) = _SetupState;
}

extension SetupStateExt on SetupState {
  bool needSetup(SetupState? lastSetupState) {
    if (lastSetupState == null) {
      return false;
    }
    if (profileId != lastSetupState.profileId) {
      return true;
    }
    if (profileLastUpdateDate != lastSetupState.profileLastUpdateDate) {
      return true;
    }
    final scriptIsChange = script != lastSetupState.script;
    if (overwriteType != lastSetupState.overwriteType) {
      if (!ruleListEquality.equals(addedRules, lastSetupState.addedRules) ||
          scriptIsChange) {
        return true;
      }
    } else {
      if (overwriteType == OverwriteType.script) {
        if (scriptIsChange) {
          return true;
        }
      }
      if (overwriteType == OverwriteType.standard) {
        if (!ruleListEquality.equals(addedRules, lastSetupState.addedRules)) {
          return true;
        }
      }
    }
    if (overrideDns != lastSetupState.overrideDns) {
      return true;
    }
    if (overrideDns == true && dns != lastSetupState.dns) {
      return true;
    }
    return false;
  }
}
