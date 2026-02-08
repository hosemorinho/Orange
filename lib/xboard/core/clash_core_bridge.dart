import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'logger/logger.dart';
import 'exceptions/exceptions.dart';

final _logger = FileLogger('clash_core_bridge.dart');

final clashCoreBridgeProvider = Provider<ClashCoreBridge>((ref) {
  return ClashCoreBridge(ref);
});

/// 直接调用 Clash 核心的桥接服务，绕过 AppController 的 safeRun() 包装，
/// 让错误自然传播到调用方。
class ClashCoreBridge {
  final Ref _ref;

  ClashCoreBridge(this._ref);

  /// 验证配置文件格式，失败抛出 [XBoardConfigException]
  Future<void> validateConfig(Profile profile) async {
    final profilePath = await appPath.getProfilePath(profile.id.toString());
    final result = await coreController.validateConfig(profilePath);
    if (result.isNotEmpty) {
      throw XBoardConfigException(
        message: '配置文件验证失败: $result',
        details: {'profileId': profile.id, 'error': result},
      );
    }
  }

  /// 复现 AppController._setupConfig 核心逻辑，但不用 safeRun()。
  /// 跳过 _requestAdmin()（导入订阅不改变 TUN 状态）和
  /// checkAndUpdateAndCopy()（xboard 刚下载完，无需再更新）。
  /// 错误直接 throw。
  Future<void> setupConfig() async {
    _logger.info('setupConfig ===>');

    final profile = _ref.read(currentProfileProvider);
    if (profile == null) {
      throw XBoardConfigException(
        message: '当前没有选中的配置',
        code: 'NO_CURRENT_PROFILE',
      );
    }

    final patchConfig = _ref.read(patchClashConfigProvider);
    final realTunEnable = _ref.read(realTunEnableProvider);
    final realPatchConfig = patchConfig.copyWith.tun(enable: realTunEnable);

    final setupState = await _ref.read(setupStateProvider(profile.id).future);
    globalState.lastSetupState = setupState;

    final config = await appController.getProfile(
      setupState: setupState,
      patchConfig: realPatchConfig,
    );

    final configFilePath = await appPath.configFilePath;
    final yamlString = await encodeYamlTask(config);
    await File(configFilePath).safeWriteAsString(yamlString);

    final message = await coreController.setupConfig(
      setupState: setupState,
      params: appController.setupParams,
    );
    if (message.isNotEmpty) {
      throw XBoardConfigException(
        message: 'setupConfig 失败: $message',
        details: {'profileId': profile.id},
      );
    }

    _logger.info('setupConfig 完成');
  }

  /// 获取代理组列表，带 retry。更新 groupsProvider。
  Future<List<Group>> fetchGroups() async {
    _logger.info('fetchGroups ===>');
    final groups = await retry(
      task: () async {
        final sortType = _ref.read(
          proxiesStyleSettingProvider.select((state) => state.sortType),
        );
        final delayMap = _ref.read(delayDataSourceProvider);
        final testUrl = _ref.read(
          appSettingProvider.select((state) => state.testUrl),
        );
        final selectedMap = _ref.read(
          currentProfileProvider.select((state) => state?.selectedMap ?? {}),
        );
        return await coreController.getProxiesGroups(
          selectedMap: selectedMap,
          sortType: sortType,
          delayMap: delayMap,
          defaultTestUrl: testUrl,
        );
      },
      retryIf: (res) => res.isEmpty,
    );
    _ref.read(groupsProvider.notifier).value = groups;
    _logger.info('fetchGroups 完成，数量: ${groups.length}');
    return groups;
  }

  /// 获取外部 providers 列表。更新 providersProvider。
  Future<List<ExternalProvider>> fetchProviders() async {
    _logger.info('fetchProviders ===>');
    final providers = await coreController.getExternalProviders();
    _ref.read(providersProvider.notifier).value = providers;
    _logger.info('fetchProviders 完成，数量: ${providers.length}');
    return providers;
  }

  /// 完整管线：validate → setup → groups → providers。
  /// 错误自然传播，不被 safeRun 吞掉。
  Future<List<Group>> applyAndFetchGroups(Profile profile) async {
    _logger.info('applyAndFetchGroups 开始 (profile: ${profile.id})');
    await validateConfig(profile);
    await setupConfig();
    final groups = await fetchGroups();
    await fetchProviders();
    _logger.info('applyAndFetchGroups 完成，groups: ${groups.length}');
    return groups;
  }
}
