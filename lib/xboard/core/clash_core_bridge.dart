import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
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
    _logger.info('[validateConfig] 路径: $profilePath');
    final result = await coreController.validateConfig(profilePath);
    if (result.isNotEmpty) {
      _logger.error('[validateConfig] ❌ 失败: $result');
      throw XBoardConfigException(
        message: '配置文件验证失败: $result',
        details: {'profileId': profile.id, 'error': result},
      );
    }
    _logger.info('[validateConfig] ✅ 通过');
  }

  /// 复现 AppController._setupConfig 核心逻辑，但不用 safeRun()。
  /// 跳过 _requestAdmin()（导入订阅不改变 TUN 状态）和
  /// checkAndUpdateAndCopy()（xboard 刚下载完，无需再更新）。
  /// 错误直接 throw。
  Future<void> setupConfig() async {
    final sw = Stopwatch()..start();
    _logger.info('[setupConfig] ===> 开始');

    final profile = _ref.read(currentProfileProvider);
    if (profile == null) {
      throw XBoardConfigException(
        message: '当前没有选中的配置',
        code: 'NO_CURRENT_PROFILE',
      );
    }
    _logger.info('[setupConfig] 当前 profile: ${profile.id} (${profile.label})');

    final patchConfig = _ref.read(patchClashConfigProvider);
    final realTunEnable = _ref.read(realTunEnableProvider);
    final realPatchConfig = patchConfig.copyWith.tun(enable: realTunEnable);
    _logger.info('[setupConfig] tunEnable=$realTunEnable, mode=${patchConfig.mode}');

    _logger.info('[setupConfig] 读取 setupState...');
    final setupState = await _ref.read(setupStateProvider(profile.id).future);
    globalState.lastSetupState = setupState;
    _logger.info('[setupConfig] setupState OK (profileId=${setupState.profileId})');

    _logger.info('[setupConfig] 构建合并配置...');
    final config = await appController.getProfile(
      setupState: setupState,
      patchConfig: realPatchConfig,
    );
    _logger.info('[setupConfig] 合并配置 OK, keys=${config.keys.length}');

    final configFilePath = await appPath.configFilePath;
    _logger.info('[setupConfig] 编码 YAML 并写入: $configFilePath');
    final yamlString = await encodeYamlTask(config);
    await File(configFilePath).safeWriteAsString(yamlString);
    _logger.info('[setupConfig] YAML 写入完成 (${yamlString.length} bytes)');

    _logger.info('[setupConfig] 调用 coreController.setupConfig...');
    final message = await coreController.setupConfig(
      setupState: setupState,
      params: appController.setupParams,
    );
    if (message.isNotEmpty) {
      _logger.error('[setupConfig] ❌ core 返回错误: $message');
      throw XBoardConfigException(
        message: 'setupConfig 失败: $message',
        details: {'profileId': profile.id},
      );
    }

    sw.stop();
    _logger.info('[setupConfig] ✅ 完成 (${sw.elapsedMilliseconds}ms)');
  }

  /// 获取代理组列表，带 retry。更新 groupsProvider。
  Future<List<Group>> fetchGroups() async {
    final sw = Stopwatch()..start();
    _logger.info('[fetchGroups] ===> 开始');
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
    sw.stop();
    _logger.info('[fetchGroups] ✅ 完成，数量: ${groups.length} (${sw.elapsedMilliseconds}ms)');
    return groups;
  }

  /// 获取外部 providers 列表。更新 providersProvider。
  Future<List<ExternalProvider>> fetchProviders() async {
    final sw = Stopwatch()..start();
    _logger.info('[fetchProviders] ===> 开始');
    final providers = await coreController.getExternalProviders();
    _ref.read(providersProvider.notifier).value = providers;
    sw.stop();
    _logger.info('[fetchProviders] ✅ 完成，数量: ${providers.length} (${sw.elapsedMilliseconds}ms)');
    return providers;
  }

  /// 完整管线：validate → setup → groups → providers。
  /// 错误自然传播，不被 safeRun 吞掉。
  Future<List<Group>> applyAndFetchGroups(Profile profile) async {
    final sw = Stopwatch()..start();
    _logger.info('════════════════════════════════════════');
    _logger.info('🔧 applyAndFetchGroups 开始');
    _logger.info('   profileId: ${profile.id}');
    _logger.info('   profileLabel: ${profile.label}');
    _logger.info('════════════════════════════════════════');

    _logger.info('[1/4] validateConfig...');
    await validateConfig(profile);

    _logger.info('[2/4] setupConfig...');
    await setupConfig();

    _logger.info('[3/4] fetchGroups...');
    final groups = await fetchGroups();

    _logger.info('[4/4] fetchProviders...');
    await fetchProviders();

    sw.stop();
    _logger.info('════════════════════════════════════════');
    _logger.info('✅ applyAndFetchGroups 全部完成');
    _logger.info('   groups: ${groups.length}');
    _logger.info('   总耗时: ${sw.elapsedMilliseconds}ms');
    _logger.info('════════════════════════════════════════');
    return groups;
  }
}
