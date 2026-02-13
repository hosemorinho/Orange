import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/leaf/config/config_writer.dart';
import 'package:fl_clash/leaf/leaf_controller.dart';
import 'package:fl_clash/leaf/providers/leaf_providers.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:fl_clash/leaf/services/mmdb_manager.dart';
import 'package:fl_clash/xboard/infrastructure/crypto/profile_cipher.dart';
import 'package:fl_clash/xboard/core/logger/file_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaml/yaml.dart';

import 'common/common.dart';
import 'database/database.dart';
import 'models/models.dart';
import 'providers/database.dart';

final _logger = FileLogger('controller.dart');

/// Recursively convert YAML values to plain Dart types.
dynamic _convertYamlValue(dynamic v) {
  if (v is YamlMap) {
    return Map<String, dynamic>.from(
      v.map((k, val) => MapEntry(k.toString(), _convertYamlValue(val))),
    );
  }
  if (v is YamlList) {
    return v.map(_convertYamlValue).toList();
  }
  return v;
}

String _callerStackSummary([int maxFrames = 4]) {
  final lines = StackTrace.current.toString().split('\n');
  final frames = <String>[];
  for (final line in lines.skip(1)) {
    final frame = line.trim();
    if (frame.isEmpty) continue;
    if (frame.contains('dart:async')) continue;
    if (frame.contains('package:flutter/')) continue;
    frames.add(frame);
    if (frames.length >= maxFrames) break;
  }
  return frames.join(' | ');
}

class AppController {
  late final BuildContext _context;
  late final WidgetRef _ref;
  bool isAttach = false;
  bool _isApplyingProfile = false;
  bool _isUpdatingStatus = false;
  Future<void> _modeChangeQueue = Future.value();
  DateTime? _lastSetupTime;
  LeafController? _leafController;
  bool _leafInitialized = false;

  /// The actual port the proxy is listening on (may differ from config after fallback).
  int? _activePort;
  int? get activePort => _activePort;

  static AppController? _instance;

  AppController._internal();

  factory AppController() {
    _instance ??= AppController._internal();
    return _instance!;
  }

  Future<void> attach(BuildContext context, WidgetRef ref) async {
    _context = context;
    _ref = ref;
    try {
      _leafController = ref.read(leafControllerProvider);
    } catch (e) {
      _logger.error(
        'failed to initialize LeafController (native library may be missing)',
        e,
      );
      // Continue without leaf — the app can still show UI, manage subscriptions, etc.
      // Proxy functionality will be unavailable.
    }
    await _init();
    isAttach = true;
  }
}

extension InitControllerExt on AppController {
  Future<void> _init() async {
    FlutterError.onError = (details) {
      commonPrint.log(
        'exception: ${details.exception} stack: ${details.stack}',
        logLevel: LogLevel.warning,
      );
    };
    updateTray();
    autoCheckUpdate();
    autoLaunch?.updateStatus(_ref.read(appSettingProvider).autoLaunch);
    if (!_ref.read(appSettingProvider).silentLaunch) {
      window?.show();
    } else {
      window?.hide();
    }
    await _handleFailedPreference();
    await _connectCore();
    await _initCore();
    await _initStatus();
    _ref.read(initProvider.notifier).value = true;
    autoUpdateProfiles();
  }

  Future<void> _handleFailedPreference() async {
    if (await preferences.isInit) {
      return;
    }
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.cacheCorrupt),
    );
    if (res == true) {
      final file = File(await appPath.sharedPreferencesPath);
      await file.safeDelete();
    }
    await handleExit();
  }

  Future<void> _initStatus() async {
    if (!globalState.needInitStatus) {
      commonPrint.log('init status cancel');
      return;
    }
    commonPrint.log('init status');
    if (system.isAndroid) {
      await globalState.updateStartTime();
    }
    final status = globalState.isStart == true
        ? true
        : _ref.read(appSettingProvider).autoRun;
    if (status == true) {
      await updateStatus(
        true,
        isInit: true,
        trigger: 'initStatus(autoStartOrResume)',
      );
    } else {
      await applyProfile(force: true, reason: 'initStatus(noAutoStart)');
    }
  }

  Future<void> autoCheckUpdate() async {
    if (!_ref.read(appSettingProvider).autoCheckUpdate) return;
    final res = await request.checkForUpdate();
    checkUpdateResultHandle(data: res);
  }

  Future<void> checkUpdateResultHandle({
    Map<String, dynamic>? data,
    bool isUser = false,
  }) async {
    if (data != null) {
      final tagName = data['tag_name'];
      final body = data['body'];
      final submits = utils.parseReleaseBody(body);
      final textTheme = _context.textTheme;
      final res = await globalState.showMessage(
        title: appLocalizations.discoverNewVersion,
        message: TextSpan(
          text: '$tagName \n',
          style: textTheme.headlineSmall,
          children: [
            TextSpan(text: '\n', style: textTheme.bodyMedium),
            for (final submit in submits)
              TextSpan(text: '- $submit \n', style: textTheme.bodyMedium),
          ],
        ),
        confirmText: appLocalizations.goDownload,
        cancelText: isUser ? null : appLocalizations.noLongerRemind,
      );
      if (res == true) {
        launchUrl(Uri.parse('https://github.com/$repository/releases/latest'));
      } else if (!isUser && res == false) {
        _ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(autoCheckUpdate: false));
      }
    } else if (isUser) {
      globalState.showMessage(
        title: appLocalizations.checkUpdate,
        message: TextSpan(text: appLocalizations.checkUpdateError),
      );
    }
  }
}

extension StateControllerExt on AppController {
  Config get config {
    return _ref.read(configProvider);
  }

  bool get isMobile {
    return _ref.read(isMobileViewProvider);
  }

  bool get isStart {
    return _ref.read(isStartProvider);
  }

  List<Group> get groups {
    return _ref.read(groupsProvider);
  }

  String get ua => _ref.read(patchClashConfigProvider).globalUa.takeFirstValid([
    globalState.packageInfo.ua,
  ]);

  Profile? get currentProfile {
    return _ref.read(currentProfileProvider);
  }

  String? getSelectedProxyName(String groupName) {
    return _ref.read(getSelectedProxyNameProvider(groupName));
  }

  Future<SetupState> getSetupState(int profileId) async {
    return await _ref.read(setupStateProvider(profileId).future);
  }

  String getRealTestUrl(String? url) {
    return _ref.read(realTestUrlProvider(url));
  }

  int getProxiesColumns() {
    return _ref.read(getProxiesColumnsProvider);
  }

  SharedState get sharedState {
    return _ref.read(sharedStateProvider);
  }

  SetupParams get setupParams {
    final selectedMap = _ref.read(selectedMapProvider);
    final testUrl = _ref.read(
      appSettingProvider.select((state) => state.testUrl),
    );
    return SetupParams(selectedMap: selectedMap, testUrl: testUrl);
  }

  List<Group> getCurrentGroups() {
    return _ref.read(currentGroupsStateProvider.select((state) => state.value));
  }

  String? getCurrentGroupName() {
    final currentGroupName = _ref.read(
      currentProfileProvider.select((state) => state?.currentGroupName),
    );
    return currentGroupName;
  }
}

extension ProfilesControllerExt on AppController {
  Future<void> deleteProfile(int id) async {
    _ref.read(profilesProvider.notifier).del(id);
    clearEffect(id);
    final currentProfileId = _ref.read(currentProfileIdProvider);
    if (currentProfileId == id) {
      final profiles = _ref.read(profilesProvider);
      if (profiles.isNotEmpty) {
        final updateId = profiles.first.id;
        _ref.read(currentProfileIdProvider.notifier).value = updateId;
      } else {
        _ref.read(currentProfileIdProvider.notifier).value = null;
        updateStatus(
          false,
          trigger: 'profiles.deleteProfile(lastProfileRemoved)',
        );
      }
    }
  }

  Future<void> autoUpdateProfiles() async {
    for (final profile in _ref.read(profilesProvider)) {
      if (!profile.autoUpdate) continue;
      final isNotNeedUpdate = profile.lastUpdateDate
          ?.add(profile.autoUpdateDuration)
          .isBeforeNow;
      if (isNotNeedUpdate == false || profile.type == ProfileType.file) {
        continue;
      }
      try {
        await updateProfile(profile);
      } catch (e) {
        commonPrint.log(e.toString(), logLevel: LogLevel.warning);
      }
    }
  }

  void putProfile(Profile profile) {
    _ref.read(profilesProvider.notifier).put(profile);
    if (_ref.read(currentProfileIdProvider) != null) return;
    _ref.read(currentProfileIdProvider.notifier).value = profile.id;
  }

  Future<void> updateProfiles() async {
    for (final profile in _ref.read(profilesProvider)) {
      if (profile.type == ProfileType.file) {
        continue;
      }
      await updateProfile(profile);
    }
  }

  Future<void> updateProfile(
    Profile profile, {
    bool showLoading = false,
  }) async {
    try {
      if (showLoading) {
        _ref.read(isUpdatingProvider(profile.updatingKey).notifier).value =
            true;
      }
      final newProfile = await profile.update();
      _ref.read(profilesProvider.notifier).put(newProfile);
      if (profile.id == _ref.read(currentProfileIdProvider)) {
        await applyProfile(
          silence: true,
          reason: 'profiles.updateProfile(id=${profile.id})',
        );
      }
    } finally {
      _ref.read(isUpdatingProvider(profile.updatingKey).notifier).value = false;
    }
  }

  Future<void> addProfileFormURL(String url) async {
    if (globalState.navigatorKey.currentState?.canPop() ?? false) {
      globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    toProfiles();
    final profile = await loadingRun(tag: LoadingTag.profiles, () async {
      return await Profile.normal(url: url).update();
    }, title: appLocalizations.addProfile);
    if (profile != null) {
      putProfile(profile);
    }
  }

  void setProfileAndAutoApply(Profile profile) {
    _ref.read(profilesProvider.notifier).put(profile);
    if (profile.id == _ref.read(currentProfileIdProvider)) {
      applyProfileDebounce(reason: 'profiles.setProfileAndAutoApply');
    }
  }

  Future<void> addProfileFormFile() async {
    final platformFile = await safeRun(picker.pickerFile);
    final bytes = platformFile?.bytes;
    if (bytes == null) {
      return;
    }
    if (!_context.mounted) return;
    globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    toProfiles();
    final profile = await loadingRun(tag: LoadingTag.profiles, () async {
      return await Profile.normal(label: platformFile?.name).saveFile(bytes);
    }, title: appLocalizations.addProfile);
    if (profile != null) {
      putProfile(profile);
    }
  }

  Future<void> addProfileFormQrCode() async {
    final url = await safeRun(picker.pickerConfigQRCode);
    if (url == null) return;
    addProfileFormURL(url);
  }

  void reorder(List<Profile> profiles) {
    _ref.read(profilesProvider.notifier).reorder(profiles);
  }

  Future<void> clearEffect(int profileId) async {
    final profilePath = await appPath.getProfilePath(profileId.toString());
    final providersDirPath = await appPath.getProvidersDirPath(
      profileId.toString(),
    );
    final profileFile = File(profilePath);
    final isExists = await profileFile.exists();
    if (isExists) {
      await profileFile.safeDelete(recursive: true);
    }
    final providersDir = Directory(providersDirPath);
    if (await providersDir.exists()) {
      await providersDir.delete(recursive: true);
    }
  }
}

extension LogsControllerExt on AppController {
  void addLog(Log log) {
    _ref.read(logsProvider).add(log);
  }

  Future<bool> exportLogs() async {
    final logString = await encodeLogsTask(_ref.read(logsProvider).list);
    final tempFilePath = await appPath.tempFilePath;
    final file = File(tempFilePath);
    await file.safeWriteAsString(logString);
    bool res = false;
    res = await picker.saveFileWithPath(utils.logFile, tempFilePath) != null;
    return res;
  }
}

extension ProxiesControllerExt on AppController {
  void updateGroupsDebounce([Duration? duration]) {
    debouncer.call(FunctionTag.updateGroups, updateGroups, duration: duration);
  }

  void changeProxyDebounce(
    String groupName,
    String proxyName, {
    Duration? duration,
  }) {
    debouncer.call(
      FunctionTag.changeProxy,
      (String groupName, String proxyName) async {
        await changeProxy(groupName: groupName, proxyName: proxyName);
        updateGroupsDebounce();
      },
      args: [groupName, proxyName],
      duration: duration,
    );
  }

  Future<void> updateGroups() async {
    // Leaf uses a flat node list instead of hierarchical proxy groups.
    // The leaf UI widgets read from leafNodesProvider directly.
    // Keep groupsProvider empty for backward compatibility.
    commonPrint.log('updateGroups (leaf: no-op, using leafNodesProvider)');
    if (_leafController != null && _leafController!.isRunning) {
      _ref.read(leafNodesProvider.notifier).state = _leafController!.nodes;
      _ref.read(selectedNodeTagProvider.notifier).state = _leafController!
          .getSelectedNode();
    }
  }

  void updateCurrentGroupName(String groupName) {
    final profile = _ref.read(currentProfileProvider);
    if (profile == null || profile.currentGroupName == groupName) {
      return;
    }
    _ref
        .read(profilesProvider.notifier)
        .put(profile.copyWith(currentGroupName: groupName));
  }

  void updateCurrentSelectedMap(String groupName, String proxyName) {
    final currentProfile = _ref.read(currentProfileProvider);
    if (currentProfile != null &&
        currentProfile.selectedMap[groupName] != proxyName) {
      final selectedMap = Map<String, String>.from(currentProfile.selectedMap)
        ..[groupName] = proxyName;
      _ref
          .read(profilesProvider.notifier)
          .put(currentProfile.copyWith(selectedMap: selectedMap));
    }
  }

  void updateCurrentUnfoldSet(Set<String> value) {
    final currentProfile = _ref.read(currentProfileProvider);
    if (currentProfile == null) {
      return;
    }
    _ref
        .read(profilesProvider.notifier)
        .put(currentProfile.copyWith(unfoldSet: value));
  }

  void setDelay(Delay delay) {
    _ref.read(delayDataSourceProvider.notifier).setDelay(delay);
  }

  /// Returns the currently selected leaf node tag if available.
  ///
  /// This reads runtime state only and does not depend on profile selectedMap.
  String? getSelectedNodeTag() {
    if (_leafController != null && _leafController!.isRunning) {
      return _leafController!.getSelectedNode();
    }
    return _ref.read(selectedNodeTagProvider);
  }

  /// Selects a node in the running core without mutating profile selectedMap.
  ///
  /// Used by latency probes to avoid persisting temporary probe selections.
  Future<void> selectNodeForLatencyTest(String nodeTag) async {
    if (_leafController != null && _leafController!.isRunning) {
      await _leafController!.selectNode(nodeTag);
      _ref.read(selectedNodeTagProvider.notifier).state = nodeTag;
      return;
    }
    if (Platform.isIOS) {
      await service?.selectNode(nodeTag);
      _ref.read(selectedNodeTagProvider.notifier).state = nodeTag;
    }
  }

  Future<void> changeProxy({
    required String groupName,
    required String proxyName,
  }) async {
    // In leaf, groupName is ignored — we select by node tag (proxyName).
    if (_leafController != null && _leafController!.isRunning) {
      await _leafController!.selectNode(proxyName);
      _ref.read(selectedNodeTagProvider.notifier).state = proxyName;
    } else if (Platform.isIOS) {
      _ref.read(selectedNodeTagProvider.notifier).state = proxyName;
      await service?.selectNode(proxyName);
    }
    // Also persist in the profile's selectedMap
    updateCurrentSelectedMap(groupName, proxyName);
    addCheckIp();
  }

  void setProvider(ExternalProvider? provider) {
    _ref.read(providersProvider.notifier).setProvider(provider);
  }

  Future<void> updateProviders() async {
    // Leaf does not support external providers — no-op.
  }

  Future<String> updateProvider(
    ExternalProvider provider, {
    bool showLoading = false,
  }) async {
    // Leaf does not support external providers.
    return '';
  }

  int addSortNum() {
    return _ref.read(sortNumProvider.notifier).add();
  }
}

extension SetupControllerExt on AppController {
  void fullSetup() {
    if (!_ref.read(initProvider)) {
      return;
    }
    _ref.read(delayDataSourceProvider.notifier).value = {};
    applyProfile(force: true, reason: 'fullSetup');
    _ref.read(logsProvider.notifier).value = FixedList(500);
    _ref.read(requestsProvider.notifier).value = FixedList(500);
  }

  Future<void> updateStatus(
    bool isStart, {
    bool isInit = false,
    String trigger = 'unknown',
  }) async {
    if (_isUpdatingStatus) {
      _logger.info(
        'updateStatus: skipping concurrent call '
        '(isStart=$isStart, isInit=$isInit, trigger=$trigger)',
      );
      return;
    }
    _logger.info(
      'updateStatus: requested isStart=$isStart, isInit=$isInit, '
      'trigger=$trigger, caller=${_callerStackSummary()}',
    );
    _isUpdatingStatus = true;
    try {
      if (isStart) {
        if (!isInit) {
          final res = await tryStartCore(true);
          if (res) {
            return;
          }
          if (!_ref.read(initProvider)) {
            return;
          }
          final started = await globalState.handleStart([
            updateRunTime,
            updateTraffic,
          ]);
          if (!started) {
            _logger.warning(
              'updateStatus: VPN service failed to start '
              '(permission denied?) trigger=$trigger',
            );
            return;
          }
          applyProfileDebounce(
            force: true,
            silence: true,
            reason: 'updateStatus(start,isInit=false,trigger=$trigger)',
          );
        } else {
          globalState.needInitStatus = false;
          await applyProfile(
            force: true,
            reason: 'updateStatus(start,isInit=true,trigger=$trigger)',
            preloadInvoke: () async {
              final started = await globalState.handleStart([
                updateRunTime,
                updateTraffic,
              ]);
              if (!started) {
                _logger.warning(
                  'updateStatus(init): VPN service failed to start '
                  'trigger=$trigger',
                );
              }
            },
          );
        }
      } else {
        if (system.isAndroid) {
          await service?.disableSocketProtection();
        }
        await _leafController?.stop();
        _ref.read(isLeafRunningProvider.notifier).state = false;
        await globalState.handleStop();
        _ref.read(trafficsProvider.notifier).clear();
        _ref.read(totalTrafficProvider.notifier).value = Traffic();
        _ref.read(runTimeProvider.notifier).value = null;
        addCheckIp();
      }
    } finally {
      _isUpdatingStatus = false;
      _logger.info(
        'updateStatus: completed isStart=$isStart, isInit=$isInit, trigger=$trigger',
      );
    }
  }

  Future<bool> needSetup() async {
    final profileId = _ref.read(currentProfileIdProvider);
    if (profileId == null) {
      return false;
    }
    final setupState = await _ref.read(setupStateProvider(profileId).future);
    return setupState.needSetup(globalState.lastSetupState) == true;
  }

  Future<void> updateConfigDebounce() async {
    debouncer.call(FunctionTag.updateConfig, () async {
      await _updateConfigImmediate();
    });
  }

  Future<void> _updateConfigImmediate() async {
    if (Platform.isIOS) {
      await applyProfile(
        force: true,
        silence: true,
        reason: 'updateConfigImmediate(iOS)',
      );
      return;
    }

    // Leaf does not support runtime config hot-reload for most parameters
    // (mode, allowLan, etc.). These are UI-only state changes.
    // However, port changes require a leaf restart because the inbound
    // is bound to a specific port.
    if (_leafController == null || !_leafController!.isRunning) return;

    final configPort = _ref.read(patchClashConfigProvider).mixedPort;
    if (_activePort != null && _activePort != configPort) {
      _logger.info('port changed: $_activePort → $configPort, restarting leaf');
      applyProfile(force: true, reason: 'updateConfigImmediate(portChanged)');
    }
  }

  void addCheckIp() {
    _ref.read(checkIpNumProvider.notifier).add();
  }

  void tryCheckIp() {
    final isTimeout = _ref.read(
      networkDetectionProvider.select(
        (state) => state.ipInfo == null && state.isLoading == false,
      ),
    );
    if (!isTimeout) {
      return;
    }
    _ref.read(checkIpNumProvider.notifier).add();
  }

  void applyProfileDebounce({
    bool silence = false,
    bool force = false,
    String reason = 'unspecified',
  }) {
    debouncer.call(FunctionTag.applyProfile, (
      bool silence,
      bool force,
      String reason,
    ) {
      applyProfile(silence: silence, force: force, reason: reason);
    }, args: [silence, force, reason]);
  }

  Future<void> changeMode(Mode mode) {
    _modeChangeQueue = _modeChangeQueue
        .catchError((e, _) {
          _logger.warning('changeMode: previous queued task failed: $e');
        })
        .then((_) => _changeModeInternal(mode));
    return _modeChangeQueue;
  }

  Future<void> _changeModeInternal(Mode mode) async {
    final currentMode = _ref.read(
      patchClashConfigProvider.select((state) => state.mode),
    );
    if (currentMode == mode) {
      return;
    }

    _ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(mode: mode));

    if (Platform.isIOS) {
      await applyProfile(
        force: true,
        silence: true,
        reason: 'changeMode(iOS)',
      );
      return;
    }

    if (_leafController != null && _leafController!.isRunning) {
      _logger.info(
        'changeMode: ${_leafController!.currentMode.name} → ${mode.name}',
      );
      final mmdbAvailable = await _isMmdbAvailable();
      await _leafController!.updateMode(mode, mmdbAvailable: mmdbAvailable);
    }
  }

  /// Check if geo.mmdb is available in the leaf home directory.
  Future<bool> _isMmdbAvailable() async {
    final homeDir = _leafController?.homeDir;
    if (homeDir == null) return false;
    try {
      final mmdbPath = await MmdbManager.ensureAvailable(homeDir);
      return await File(mmdbPath).exists();
    } catch (_) {
      return false;
    }
  }

  /// Ensure a valid proxy node is selected in the leaf core.
  Future<void> _ensureValidSelection() async {
    if (Platform.isIOS) {
      final nodes = _ref.read(leafNodesProvider);
      if (nodes.isEmpty) return;

      final current = _ref.read(selectedNodeTagProvider);
      final selected = (current != null && nodes.any((n) => n.tag == current))
          ? current
          : nodes.first.tag;

      _ref.read(selectedNodeTagProvider.notifier).state = selected;
      await service?.selectNode(selected);
      return;
    }

    if (_leafController == null || !_leafController!.isRunning) return;

    final currentSelected = _leafController!.getSelectedNode();
    if (currentSelected != null && currentSelected.isNotEmpty) {
      // Already has a valid selection
      _ref.read(selectedNodeTagProvider.notifier).state = currentSelected;
      return;
    }

    // No selection — auto-pick the first node
    final nodes = _leafController!.nodes;
    if (nodes.isNotEmpty) {
      final firstNode = nodes.first.tag;
      await _leafController!.selectNode(firstNode);
      _ref.read(selectedNodeTagProvider.notifier).state = firstNode;
      commonPrint.log('Auto-selected node: $firstNode');
    }
  }

  void autoApplyProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      applyProfile(reason: 'autoApplyProfile');
    });
  }

  Future<void> applyProfile({
    bool silence = false,
    bool force = false,
    String reason = 'unspecified',
    Future<void> Function()? preloadInvoke,
  }) async {
    if (_isApplyingProfile) {
      _logger.info(
        'applyProfile: skipping concurrent call '
        '(force=$force, silence=$silence, reason=$reason)',
      );
      return;
    }
    if (!force && !await needSetup()) {
      _logger.info('applyProfile: skipped (needSetup=false, reason=$reason)');
      return;
    }
    _logger.info(
      'applyProfile: start force=$force, silence=$silence, reason=$reason, '
      'preloadInvoke=${preloadInvoke != null}, caller=${_callerStackSummary()}',
    );
    _isApplyingProfile = true;
    try {
      await loadingRun(
        () async {
          await _setupConfig(preloadInvoke, reason);
          await updateGroups();
          await _ensureValidSelection();
        },
        silence: true,
        tag: !silence ? LoadingTag.proxies : null,
      );
    } finally {
      _isApplyingProfile = false;
      _logger.info('applyProfile: complete reason=$reason');
    }
  }

  Future<void> restoreSelectedProxy() async {
    await _ensureValidSelection();
  }

  /// Read profile YAML from disk, decrypting if encrypted.
  Future<String?> _getProfileYaml(Profile profile) async {
    final profilePath = await appPath.getProfilePath(profile.id.toString());
    final file = File(profilePath);
    if (!await file.exists()) return null;

    final bytes = await file.readAsBytes();
    if (ProfileCipher.isEncryptedFormat(bytes)) {
      final token = ProfileCipher.extractToken(profile.url);
      if (token != null && token.isNotEmpty) {
        final decrypted = ProfileCipher.decrypt(bytes, token);
        return utf8.decode(decrypted);
      }
    }
    return file.readAsString();
  }

  /// Read profile config as a Map (for backward compatibility).
  Future<Map<String, dynamic>> _getConfigDecrypted(int profileId) async {
    final profile = _ref.read(profilesProvider).getProfile(profileId);
    if (profile == null) return {};
    final yaml = await _getProfileYaml(profile);
    if (yaml == null) return {};
    try {
      final doc = loadYaml(yaml);
      if (doc is YamlMap) {
        return Map<String, dynamic>.from(
          doc.map((k, v) => MapEntry(k.toString(), _convertYamlValue(v))),
        );
      }
    } catch (e) {
      commonPrint.log('Failed to parse profile YAML: $e');
    }
    return {};
  }

  Future<Map> getProfileWithId(int profileId) async {
    var res = {};
    try {
      res = await _getConfigDecrypted(profileId);
    } catch (e) {
      globalState.showNotifier(e.toString());
    }
    return res;
  }

  Future<void> _setupConfig(
    [Future<void> Function()? preloadInvoke,
    String reason = 'unspecified']
  ) async {
    // Throttle: skip if setup completed less than 2 seconds ago
    final now = DateTime.now();
    if (_lastSetupTime != null &&
        now.difference(_lastSetupTime!).inSeconds < 2) {
      _logger.info(
        'setup: throttled (last ran '
        '${now.difference(_lastSetupTime!).inMilliseconds}ms ago, reason=$reason)',
      );
      return;
    }

    _logger.info(
      'setup ===> reason=$reason, isStart=${globalState.isStart}, '
      'preloadInvoke=${preloadInvoke != null}, caller=${_callerStackSummary()}',
    );
    var profile = _ref.read(currentProfileProvider);
    if (profile == null) {
      _logger.warning('setup: no current profile');
      return;
    }

    final nextProfile = await profile.checkAndUpdateAndCopy();
    if (nextProfile != null) {
      profile = nextProfile;
      _ref.read(profilesProvider.notifier).put(nextProfile);
    }

    // Read YAML content from profile file
    String? yamlContent;
    try {
      yamlContent = await _getProfileYaml(profile!);
    } catch (e) {
      _logger.error(
        'setup: failed to read/decrypt YAML for profile ${profile.id}',
        e,
      );
      return;
    }
    if (yamlContent == null || yamlContent.isEmpty) {
      _logger.warning('setup: empty YAML for profile ${profile.id}');
      return;
    }

    // Port configuration — single mixed port for HTTP+SOCKS5
    // Do NOT write port changes back to patchClashConfigProvider —
    // that triggers updateParamsProvider → updateConfigDebounce → applyProfile loop.
    var mixedPort = _ref.read(patchClashConfigProvider).mixedPort;
    // Skip port availability check if leaf is already running on this port —
    // the port will be freed when we stop leaf below. Without this check,
    // isPortAvailable returns false (leaf is occupying it), we'd pick a
    // random fallback port, and system proxy would desync.
    final leafOccupyingSamePort =
        _leafController?.isRunning == true && _activePort == mixedPort;
    if (!system.isAndroid &&
        !leafOccupyingSamePort &&
        !await isPortAvailable(mixedPort)) {
      final newPort = await findAvailablePort(mixedPort);
      _logger.warning(
        'Port $mixedPort occupied, using $newPort (local only, not persisted)',
      );
      mixedPort = newPort;
    }

    // Save setup state
    final setupState = await _ref.read(setupStateProvider(profile.id).future);
    globalState.lastSetupState = setupState;
    if (system.isAndroid) {
      globalState.lastVpnState = _ref.read(vpnStateProvider);
      preferences.saveShareState(this.sharedState);
    }

    if (preloadInvoke != null) await preloadInvoke();

    // TUN mode configuration
    // On Android, TUN is required when VPN is active — the VPN service creates
    // a TUN interface that captures all traffic, so leaf must read from it.
    // But only enable TUN if VPN is currently running or about to start
    // (via preloadInvoke). When _setupConfig is called just to load a profile
    // (e.g. on init with autoRun=false), VPN isn't running so TUN is skipped.
    var tunEnabled = system.isAndroid
        ? (globalState.isStart || preloadInvoke != null)
        : _ref.read(patchClashConfigProvider).tun.enable;
    _logger.info(
      'setup: tun decision enabled=$tunEnabled, android=${system.isAndroid}, '
      'isStart=${globalState.isStart}, preloadInvoke=${preloadInvoke != null}, '
      'configTun=${_ref.read(patchClashConfigProvider).tun.enable}, reason=$reason',
    );
    int? tunFd;
    if (system.isAndroid && tunEnabled) {
      await service?.enableSocketProtection();
      // Retry getTunFd — VPN service may still be establishing after
      // permission grant. Poll for up to 5 seconds as a safety net.
      for (var attempt = 0; attempt < 25; attempt++) {
        tunFd = await service?.getTunFd();
        if (tunFd != null) break;
        if (attempt < 24) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
      if (tunFd == null) {
        _logger.warning(
          'setup: Android TUN fd not available — '
          'VPN service failed to establish. Cannot start.',
        );
        await service?.disableSocketProtection();
        await globalState.handleStop();
        _ref.read(runTimeProvider.notifier).value = null;
        globalState.showNotifier('VPN启动失败，无法获取TUN设备');
        return;
      } else {
        _logger.info('setup: got TUN fd=$tunFd from VPN service');
      }
    }
    if (tunEnabled && !system.isAndroid) {
      _logger.info(
        'setup: TUN mode enabled for desktop (${Platform.operatingSystem})',
      );
    }

    // MMDB for rule mode — ensure geo.mmdb is in ASSET_LOCATION
    final mode = _ref.read(patchClashConfigProvider).mode;
    bool mmdbAvailable = false;
    if (mode == Mode.rule && _leafController != null) {
      final homeDir = _leafController!.homeDir;
      if (homeDir != null) {
        try {
          final mmdbPath = await MmdbManager.ensureAvailable(homeDir);
          final mmdbFile = File(mmdbPath);
          if (await mmdbFile.exists()) {
            final stat = await mmdbFile.stat();
            _logger.info(
              'setup: geo.mmdb verified at $mmdbPath (${stat.size} bytes)',
            );
            mmdbAvailable = true;
          } else {
            _logger.warning(
              'setup: geo.mmdb path returned but file missing: $mmdbPath',
            );
          }
        } catch (e) {
          _logger.warning('setup: geo.mmdb unavailable for rule mode: $e');
          _logger.warning(
            'setup: Rule mode will behave like global mode (no GeoIP rules)',
          );
        }
      }
    }

    if (Platform.isIOS) {
      final proxies = LeafController.parseClashProxies(yamlContent);
      final nodes = LeafController.extractNodesFromProxies(proxies);
      final configJson = ConfigWriter.build(
        proxies: proxies,
        mixedPort: mixedPort,
        tunEnabled: false,
        mode: mode,
        mmdbAvailable: mmdbAvailable,
      ).toJsonString();

      await service?.syncLeafConfig(configJson);
      _ref.read(leafNodesProvider.notifier).state = nodes;

      final previousSelected = _ref.read(selectedNodeTagProvider);
      final selectedTag = switch (nodes.any((n) => n.tag == previousSelected)) {
        true => previousSelected,
        false => nodes.isNotEmpty ? nodes.first.tag : null,
      };
      _ref.read(selectedNodeTagProvider.notifier).state = selectedTag;
      if (selectedTag != null) {
        await service?.selectNode(selectedTag);
      }

      _ref.read(isLeafRunningProvider.notifier).state = globalState.isStart;
      _activePort = mixedPort;
      _ref.read(activePortProvider.notifier).state = mixedPort;
      _lastSetupTime = DateTime.now();
      _logger.info(
        'setup: iOS config synced to packet tunnel, '
        'nodes=${nodes.length}, mode=${mode.name}, start=${globalState.isStart}',
      );
      return;
    }

    // Start leaf with the subscription YAML
    if (_leafController == null) {
      _logger.warning(
        'setup: LeafController unavailable on ${Platform.operatingSystem}, '
        'skipping leaf startup',
      );
      _ref.read(isLeafRunningProvider.notifier).state = false;
      _ref.read(leafNodesProvider.notifier).state = const [];
      _ref.read(selectedNodeTagProvider.notifier).state = null;
      _activePort = null;
      _ref.read(activePortProvider.notifier).state = null;
      _lastSetupTime = DateTime.now();
      return;
    }
    if (_leafController!.isRunning) {
      await _leafController!.stop();
    }
    _logger.info(
      'setup: starting leaf on mixed port $mixedPort, mode=${mode.name}, '
      'tun=$tunEnabled, with YAML (${yamlContent.length} bytes)',
    );
    try {
      await _leafController!.startWithClashYaml(
        yamlContent,
        mixedPort: mixedPort,
        tunFd: tunFd,
        tunEnabled: tunEnabled,
        mode: mode,
        mmdbAvailable: mmdbAvailable,
      );
    } catch (e) {
      if (tunEnabled && !system.isAndroid) {
        // Desktop: TUN failures are common (missing admin rights, wintun.dll
        // issues). Retry without TUN — desktop can fall back to system proxy.
        _logger.warning(
          'setup: leaf start failed with TUN ($e), retrying without TUN',
        );
        try {
          await _leafController!.startWithClashYaml(
            yamlContent,
            mixedPort: mixedPort,
            tunEnabled: false,
            mode: mode,
            mmdbAvailable: mmdbAvailable,
          );
          _ref
              .read(patchClashConfigProvider.notifier)
              .update((state) => state.copyWith.tun(enable: false));
          _ref.read(realTunEnableProvider.notifier).value = false;
          globalState.showNotifier('TUN启动失败，已降级为系统代理模式: $e');
        } catch (e2) {
          _logger.error('setup: leaf start failed even without TUN', e2);
          return;
        }
      } else if (system.isAndroid) {
        // Android: VPN captures all traffic via TUN — cannot fall back to
        // non-TUN mode. Stop VPN and reset state.
        _logger.error(
          'setup: leaf TUN start failed on Android, stopping VPN',
          e,
        );
        await service?.disableSocketProtection();
        await globalState.handleStop();
        _ref.read(runTimeProvider.notifier).value = null;
        globalState.showNotifier('VPN启动失败: $e');
        return;
      } else {
        _logger.error('setup: leaf start failed', e);
        return;
      }
    }

    // Update leaf providers
    _ref.read(isLeafRunningProvider.notifier).state = true;
    _ref.read(leafNodesProvider.notifier).state = _leafController!.nodes;
    _ref.read(selectedNodeTagProvider.notifier).state = _leafController!
        .getSelectedNode();

    // Track the actual port the proxy is running on (may differ from config)
    _activePort = mixedPort;
    _ref.read(activePortProvider.notifier).state = mixedPort;

    addCheckIp();
    _lastSetupTime =
        DateTime.now(); // Only throttle after successful completion
    _logger.info('setup complete: ${_leafController!.nodes.length} nodes');
  }
}

extension CoreControllerExt on AppController {
  Future<void> _initCore() async {
    if (_leafInitialized) return;

    String homeDir;
    if (Platform.isAndroid) {
      homeDir = await appPath.homeDirPath;
    } else {
      final home =
          Platform.environment['HOME'] ??
          Platform.environment['USERPROFILE'] ??
          '.';
      homeDir =
          '$home${Platform.pathSeparator}.config${Platform.pathSeparator}orange${Platform.pathSeparator}leaf';
    }

    await _leafController?.init(homeDir);
    _leafInitialized = true;
    commonPrint.log('leaf core initialized: $homeDir');
  }

  Future<void> _connectCore() async {
    _ref.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    try {
      // Leaf FFI library is loaded when LeafController is constructed.
      // No separate connect step needed.
      await Future.delayed(const Duration(milliseconds: 100));
      _ref.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    } catch (e) {
      _ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
      commonPrint.log('leaf connect failed: $e');
    }
  }

  /// Request admin authorization for TUN on desktop.
  ///
  /// Returns a [Result] indicating whether the caller should continue:
  /// - [Result.success(true)]: authorized, caller should proceed with restart
  /// - [Result.success(false)]: authorization failed or TUN disabled, caller
  ///   should NOT proceed (state already rolled back)
  /// - [Result.error]: restartCore() was already called internally (e.g. after
  ///   first-time SUID setup), caller should NOT proceed
  Future<Result<bool>> _requestAdmin(bool enableTun) async {
    final realTunEnable = _ref.read(realTunEnableProvider);
    if (enableTun != realTunEnable && realTunEnable == false) {
      commonPrint.log(
        'TUN: requesting admin authorization',
        logLevel: LogLevel.info,
      );
      final code = await system.authorizeCore();
      commonPrint.log(
        'TUN: authorization result: $code',
        logLevel: LogLevel.info,
      );
      switch (code) {
        case AuthorizeCode.success:
          // Binary permissions changed (SUID set). Must restart the core
          // process to pick up the new privileges. restartCore() triggers
          // applyProfile internally, so caller should NOT restart again.
          await restartCore();
          return Result.error('restart_handled');
        case AuthorizeCode.none:
          // Already authorized — continue normally.
          break;
        case AuthorizeCode.error:
          commonPrint.log(
            'TUN: admin authorization failed, disabling TUN',
            logLevel: LogLevel.warning,
          );
          enableTun = false;
          _ref
              .read(patchClashConfigProvider.notifier)
              .update((state) => state.copyWith.tun(enable: false));
          _ref.read(realTunEnableProvider.notifier).value = false;
          return Result.success(false);
      }
    }
    _ref.read(realTunEnableProvider.notifier).value = enableTun;
    return Result.success(enableTun);
  }

  Future<void> restartCore([bool start = false]) async {
    _ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await _leafController?.stop();
    _ref.read(isLeafRunningProvider.notifier).state = false;
    _leafInitialized = false;
    await _connectCore();
    await _initCore();
    if (start || _ref.read(isStartProvider)) {
      await updateStatus(
        true,
        isInit: true,
        trigger: 'restartCore(start=$start)',
      );
    } else {
      await applyProfile(force: true, reason: 'restartCore(start=$start)');
    }
  }

  Future<bool> tryStartCore([bool start = false]) async {
    if (_leafInitialized) {
      return false;
    }
    await restartCore(start);
    return true;
  }

  void handleCoreDisconnected() {
    _ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
  }
}

extension SystemControllerExt on AppController {
  Future<List<Package>> getPackages() async {
    if (_ref.read(isMobileViewProvider)) {
      await Future.delayed(commonDuration);
    }
    if (_ref.read(packagesProvider).isEmpty) {
      _ref.read(packagesProvider.notifier).value =
          await app?.getPackages() ?? [];
    }
    return _ref.read(packagesProvider);
  }

  Future<void> handleExit([bool needSave = false]) async {
    Future.delayed(Duration(seconds: 3), () {
      system.exit();
    });
    try {
      if (system.isAndroid) {
        await service?.disableSocketProtection();
      }
      await Future.wait([
        if (needSave) preferences.saveConfig(config),
        if (macOS != null) macOS!.updateDns(true),
        if (proxy != null) proxy!.stopProxy(),
        if (tray != null) tray!.destroy(),
      ]);
      await _leafController?.stop();
      _ref.read(isLeafRunningProvider.notifier).state = false;
      commonPrint.log('exit');
    } finally {
      system.exit();
    }
  }

  Future<void> handleBackOrExit() async {
    if (_ref.read(backBlockProvider)) {
      return;
    }
    if (_ref.read(appSettingProvider).minimizeOnExit) {
      if (system.isDesktop) {
        await preferences.saveConfig(config);
      }
      await system.back();
    } else {
      await handleExit();
    }
  }

  Future<void> updateVisible() async {
    final visible = await window?.isVisible;
    if (visible != null && !visible) {
      window?.show();
    } else {
      window?.hide();
    }
  }

  void updateBrightness() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ref.read(systemBrightnessProvider.notifier).value =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
    });
  }

  void updateViewSize(Size size) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ref.read(viewSizeProvider.notifier).value = size;
    });
  }

  Future<void> updateTun() async {
    if (system.isAndroid) {
      _logger.info(
        'updateTun: ignored on Android (TUN is managed by VpnService lifecycle)',
      );
      return;
    }
    final newEnable = !_ref.read(patchClashConfigProvider).tun.enable;
    _ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith.tun(enable: newEnable));

    // TUN config change requires leaf restart to take effect.
    if (!_ref.read(isStartProvider)) return;

    if (newEnable && system.isDesktop) {
      // Desktop needs admin authorization before enabling TUN.
      // _requestAdmin handles the restart when authorization succeeds.
      final result = await _requestAdmin(newEnable);
      if (result.isError) return; // restartCore() already called
    }

    applyProfile(force: true, reason: 'updateTun(newEnable=$newEnable)');
  }

  void updateSystemProxy() {
    _ref
        .read(networkSettingProvider.notifier)
        .update((state) => state.copyWith(systemProxy: !state.systemProxy));
  }

  void updateAutoLaunch() {
    _ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(autoLaunch: !state.autoLaunch));
  }

  Future<void> updateTray() async {
    tray?.update(
      trayState: _ref.read(trayStateProvider),
      traffic: _ref.read(
        trafficsProvider.select((state) => state.list.safeLast(Traffic())),
      ),
    );
  }

  Future<void> updateLocalIp() async {
    _ref.read(localIpProvider.notifier).value = null;
    await Future.delayed(commonDuration);
    _ref.read(localIpProvider.notifier).value = await utils.getLocalIpAddress();
  }
}

extension BackupControllerExt on AppController {
  Future<void> shakingStore() async {
    final profileIds = _ref.read(
      profilesProvider.select((state) => state.map((item) => item.id)),
    );
    final scriptIds = await _ref.read(
      scriptsProvider.future.select(
        (state) async => (await state).map((item) => item.id),
      ),
    );
    final pathsToDelete = await shakingProfileTask(VM2(profileIds, scriptIds));
    if (pathsToDelete.isNotEmpty) {
      final deleteFutures = pathsToDelete.map((path) async {
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete(recursive: true);
          } else {
            final dir = Directory(path);
            if (await dir.exists()) {
              await dir.delete(recursive: true);
            }
          }
        } catch (e) {
          commonPrint.log('Failed to delete $path: $e');
        }
      });

      await Future.wait(deleteFutures);
    }
  }

  Future<String> backup() async {
    final profileFileNames = _ref.read(
      profilesProvider.select((state) => state.map((item) => item.fileName)),
    );
    final scriptFileNames = await _ref.read(
      scriptsProvider.future.select(
        (state) async => (await state).map((item) => item.fileName),
      ),
    );
    final configMap = _ref.read(configProvider).toJson();
    configMap['version'] = await preferences.getVersion();
    return await backupTask(configMap, [
      ...profileFileNames,
      ...scriptFileNames,
    ]);
  }

  Future<void> restore(RestoreOption option) async {
    final restoreDirPath = await appPath.restoreDirPath;
    final restoreDir = Directory(restoreDirPath);
    final restoreStrategy = _ref.read(
      appSettingProvider.select((state) => state.restoreStrategy),
    );
    final isOverride = restoreStrategy == RestoreStrategy.override;
    try {
      final migrationData = await restoreTask();
      if (!await restoreDir.exists()) {
        throw appLocalizations.restoreException;
      }
      await database.restore(
        migrationData.profiles,
        migrationData.scripts,
        migrationData.rules,
        migrationData.links,
        isOverride: isOverride,
      );
      final configMap = migrationData.configMap;
      if (option == RestoreOption.onlyProfiles || configMap == null) {
        return;
      }
      final config = Config.fromJson(configMap);
      _ref.read(patchClashConfigProvider.notifier).value =
          config.patchClashConfig;
      _ref.read(appSettingProvider.notifier).value = config.appSettingProps;
      _ref.read(currentProfileIdProvider.notifier).value =
          config.currentProfileId;
      _ref.read(davSettingProvider.notifier).value = config.davProps;
      _ref.read(themeSettingProvider.notifier).value = config.themeProps;
      _ref.read(windowSettingProvider.notifier).value = config.windowProps;
      _ref.read(vpnSettingProvider.notifier).value = config.vpnProps;
      _ref.read(proxiesStyleSettingProvider.notifier).value =
          config.proxiesStyleProps;
      _ref.read(overrideDnsProvider.notifier).value = config.overrideDns;
      _ref.read(networkSettingProvider.notifier).value = config.networkProps;
      _ref.read(hotKeyActionsProvider.notifier).value = config.hotKeyActions;
      return;
    } finally {
      await restoreDir.safeDelete(recursive: true);
    }
  }
}

extension BackBlockControllExt on AppController {
  void backBlock() {
    _ref.read(backBlockProvider.notifier).value = true;
  }

  void unBackBlock() {
    _ref.read(backBlockProvider.notifier).value = false;
  }
}

extension StoreControllerExt on AppController {
  void savePreferencesDebounce() {
    debouncer.call(FunctionTag.savePreferences, () async {
      await preferences.saveConfig(config);
    });
  }

  Future handleClear() async {
    await preferences.clearPreferences();
    commonPrint.log('clear preferences');
    await database.close();
    await File(await appPath.databasePath).safeDelete(recursive: true);
    final homeDir = Directory(await appPath.profilesPath);
    await for (final file in homeDir.list(recursive: true)) {
      final f = File(file.path);
      if (await f.exists()) {
        await f.delete();
      }
    }
    await preferences.clearPreferences();
    handleExit(false);
  }
}

extension CommonControllerExt on AppController {
  void toPage(PageLabel pageLabel) {
    _ref.read(currentPageLabelProvider.notifier).value = pageLabel;
  }

  void toProfiles() {
    toPage(PageLabel.profiles);
  }

  void updateStart() {
    updateStatus(
      !_ref.read(isStartProvider),
      trigger: 'controller.updateStart',
    );
  }

  void updateSpeedStatistics() {
    _ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(showTrayTitle: !state.showTrayTitle));
  }

  Future<void> updateMode() async {
    // Leaf uses a single select outbound — mode switching is a UI-only concept.
    final currentMode = _ref.read(
      patchClashConfigProvider.select((state) => state.mode),
    );
    final index = Mode.values.indexWhere((item) => item == currentMode);
    if (index == -1) {
      return;
    }
    final nextIndex = index + 1 > Mode.values.length - 1 ? 0 : index + 1;
    final nextMode = Mode.values[nextIndex];
    await changeMode(nextMode);
  }

  void updateRunTime() {
    final startTime = globalState.startTime;
    if (startTime != null) {
      final startTimeStamp = startTime.millisecondsSinceEpoch;
      final nowTimeStamp = DateTime.now().millisecondsSinceEpoch;
      _ref.read(runTimeProvider.notifier).value = nowTimeStamp - startTimeStamp;
    } else {
      _ref.read(runTimeProvider.notifier).value = null;
    }
  }

  Future<void> updateTraffic() async {
    if (_leafController == null || !_leafController!.isRunning) return;
    final totals = _leafController!.getTrafficTotals();
    final traffic = Traffic(up: totals.bytesSent, down: totals.bytesRecvd);
    _ref.read(trafficsProvider.notifier).addTraffic(traffic);
    _ref.read(totalTrafficProvider.notifier).value = traffic;
  }

  Future<T?> loadingRun<T>(
    FutureOr<T> Function() futureFunction, {
    String? title,
    required LoadingTag? tag,
    bool silence = false,
  }) async {
    return safeRun(
      futureFunction,
      silence: silence,
      title: title,
      onStart: () {
        if (tag == null) {
          return;
        }
        _ref.read(loadingProvider(tag).notifier).start();
      },
      onEnd: () {
        if (tag == null) {
          return;
        }
        _ref.read(loadingProvider(tag).notifier).stop();
      },
    );
  }

  Future<T?> safeRun<T>(
    FutureOr<T> Function() futureFunction, {
    String? title,
    VoidCallback? onStart,
    VoidCallback? onEnd,
    bool silence = true,
  }) async {
    try {
      if (onStart != null) {
        onStart();
      }
      final res = await futureFunction();
      return res;
    } catch (e, s) {
      commonPrint.log('$title ===> $e, $s', logLevel: LogLevel.warning);
      if (silence) {
        globalState.showNotifier(e.toString());
      } else {
        globalState.showMessage(
          title: title ?? appLocalizations.tip,
          message: TextSpan(text: e.toString()),
        );
      }
      return null;
    } finally {
      if (onEnd != null) {
        onEnd();
      }
    }
  }
}

final appController = AppController();
