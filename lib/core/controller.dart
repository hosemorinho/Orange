import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/config_session.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/service.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class CoreController {
  static CoreController? _instance;
  late CoreHandlerInterface _interface;
  static const String _inlineConfigPrefix = 'inline-b64://';
  static const String _sessionConfigPrefix = 'session://';
  static const int _androidInlineSoftLimitBytes = 512 * 1024;

  CoreController._internal() {
    if (system.isAndroid) {
      _interface = coreLib!;
    } else {
      _interface = coreService!;
    }
  }

  factory CoreController() {
    _instance ??= CoreController._internal();
    return _instance!;
  }

  bool get isCompleted => _interface.completer.isCompleted;

  Future<String> preload() {
    return _interface.preload();
  }

  static Future<void> initGeo() async {
    final homePath = await appPath.homeDirPath;
    final homeDir = Directory(homePath);
    final isExists = await homeDir.exists();
    if (!isExists) {
      await homeDir.create(recursive: true);
    }
    const geoFileNameList = [MMDB, GEOIP, GEOSITE, ASN];
    try {
      for (final geoFileName in geoFileNameList) {
        final geoFile = File(join(homePath, geoFileName));
        final isExists = await geoFile.exists();
        if (isExists) {
          continue;
        }
        final data = await rootBundle.load('assets/data/$geoFileName');
        List<int> bytes = data.buffer.asUint8List();
        await geoFile.writeAsBytes(bytes, flush: true);
      }
    } catch (e) {
      exit(0);
    }
  }

  Future<bool> init(int version) async {
    await initGeo();
    final homeDirPath = await appPath.homeDirPath;
    return await _interface.init(
      InitParams(homeDir: homeDirPath, version: version),
    );
  }

  Future<void> shutdown(bool isUser) async {
    await _interface.shutdown(isUser);
  }

  FutureOr<bool> get isInit => _interface.isInit;

  Future<String> validateConfig(String path) async {
    final res = await _interface.validateConfig(path);
    return res;
  }

  Future<String> validateConfigWithData(String data) async {
    return validateConfigWithBytes(Uint8List.fromList(utf8.encode(data)));
  }

  Future<String> validateConfigWithBytes(Uint8List bytes) async {
    if (_shouldPreferSessionTransport(bytes)) {
      final sessionSource = await _buildSessionConfigSource(bytes);
      if (sessionSource != null) {
        return _interface.validateConfig(sessionSource);
      }
    }
    try {
      final payload = _buildInlineConfigPayload(bytes);
      return _interface.validateConfig(payload);
    } on PlatformException catch (e) {
      // On Android, PlatformException can occur for Binder-too-large errors
      // or SERVICE_ERROR/SERVICE_TIMEOUT when the Go core service is not yet
      // available. Try session transport first, then temp file as last resort.
      commonPrint.log(
        'validateConfigWithBytes PlatformException: ${e.code} ${e.message}, '
        'attempting fallback',
        logLevel: LogLevel.warning,
      );
      final sessionSource = await _buildSessionConfigSource(bytes);
      if (sessionSource != null) {
        return _interface.validateConfig(sessionSource);
      }
      return _validateConfigWithTempFile(bytes);
    }
  }

  Future<String> updateConfig(UpdateParams updateParams) async {
    return await _interface.updateConfig(updateParams);
  }

  Future<String> setupConfig({
    required SetupParams params,
    required SetupState setupState,
    VoidCallback? preloadInvoke,
  }) async {
    final res = _interface.setupConfig(params);
    if (preloadInvoke != null) {
      preloadInvoke();
    }
    return res;
  }

  Future<String> setupConfigWithBytes({
    required Uint8List configBytes,
    required SetupParams params,
    required SetupState setupState,
    VoidCallback? preloadInvoke,
  }) async {
    Future<String> fallbackWithConfigFile() async {
      final configFilePath = join(await appPath.homeDirPath, 'config.yaml');
      await File(configFilePath).writeAsBytes(configBytes, flush: true);
      return setupConfig(
        params: params,
        setupState: setupState,
        preloadInvoke: preloadInvoke,
      );
    }

    if (system.isAndroid) {
      final configFilePath = join(await appPath.homeDirPath, 'config.yaml');
      final persisted = await _persistAndroidQuickSetupConfigSnapshot(
        configBytes,
      );
      if (persisted) {
        await File(configFilePath).safeDelete();
      } else {
        commonPrint.log(
          'persistQuickSetupConfig unavailable, fallback to config.yaml snapshot',
          logLevel: LogLevel.warning,
        );
        await File(configFilePath).writeAsBytes(configBytes, flush: true);
      }
    }

    String? sessionId;
    try {
      sessionId = await ConfigSessionUploader(_interface).upload(configBytes);
    } catch (e) {
      commonPrint.log(
        'setupConfigWithBytes session upload failed, fallback to file: $e',
        logLevel: LogLevel.warning,
      );
      sessionId = null;
    }

    if (sessionId == null) {
      if (!system.isAndroid) {
        return fallbackWithConfigFile();
      }
      return setupConfig(
        params: params,
        setupState: setupState,
        preloadInvoke: preloadInvoke,
      );
    }

    final sessionParams = SetupParams(
      selectedMap: params.selectedMap,
      testUrl: params.testUrl,
      configSessionId: sessionId,
    );
    final res = _interface.setupConfig(sessionParams);
    if (preloadInvoke != null) {
      preloadInvoke();
    }
    return res;
  }

  Future<List<Group>> getProxiesGroups({
    required ProxiesSortType sortType,
    required DelayMap delayMap,
    required Map<String, String> selectedMap,
    required String defaultTestUrl,
  }) async {
    final proxiesData = await _interface.getProxies();
    return toGroupsTask(
      ComputeGroupsState(
        proxiesData: proxiesData,
        sortType: sortType,
        delayMap: delayMap,
        selectedMap: selectedMap,
        defaultTestUrl: defaultTestUrl,
      ),
    );
  }

  FutureOr<String> changeProxy(ChangeProxyParams changeProxyParams) async {
    return await _interface.changeProxy(changeProxyParams);
  }

  Future<List<TrackerInfo>> getConnections() async {
    final res = await _interface.getConnections();
    final connectionsData = json.decode(res) as Map;
    final connectionsRaw = connectionsData['connections'] as List? ?? [];
    return connectionsRaw.map((e) => TrackerInfo.fromJson(e)).toList();
  }

  void closeConnection(String id) {
    _interface.closeConnection(id);
  }

  void closeConnections() {
    _interface.closeConnections();
  }

  void resetConnections() {
    _interface.resetConnections();
  }

  Future<List<ExternalProvider>> getExternalProviders() async {
    final externalProvidersRawString = await _interface.getExternalProviders();
    if (externalProvidersRawString.isEmpty) {
      return [];
    }
    final externalProviders =
        (await externalProvidersRawString.commonToJSON<List<dynamic>>())
            .map((item) => ExternalProvider.fromJson(item))
            .toList();
    return externalProviders;
  }

  Future<ExternalProvider?> getExternalProvider(
    String externalProviderName,
  ) async {
    final externalProvidersRawString = await _interface.getExternalProvider(
      externalProviderName,
    );
    if (externalProvidersRawString.isEmpty) {
      return null;
    }
    return ExternalProvider.fromJson(json.decode(externalProvidersRawString));
  }

  Future<String> updateGeoData(UpdateGeoDataParams params) {
    return _interface.updateGeoData(params);
  }

  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  }) {
    return _interface.sideLoadExternalProvider(
      providerName: providerName,
      data: data,
    );
  }

  Future<String> updateExternalProvider({required String providerName}) async {
    return _interface.updateExternalProvider(providerName);
  }

  Future<bool> startListener() async {
    return await _interface.startListener();
  }

  Future<bool> stopListener() async {
    return await _interface.stopListener();
  }

  Future<Delay> getDelay(String url, String proxyName) async {
    final data = await _interface.asyncTestDelay(url, proxyName);
    return Delay.fromJson(json.decode(data));
  }

  Future<Map<String, dynamic>> getConfig(
    int id, {
    String? overridePath,
    Uint8List? overrideBytes,
  }) async {
    final source = await _buildConfigSourceForGet(
      id: id,
      overridePath: overridePath,
      overrideBytes: overrideBytes,
    );
    Result res;
    try {
      res = await _interface.getConfig(source.source);
    } on PlatformException catch (e) {
      if (overrideBytes != null) {
        commonPrint.log(
          'getConfig PlatformException: ${e.code} ${e.message}, '
          'attempting fallback',
          logLevel: LogLevel.warning,
        );
        final sessionSource = await _buildSessionConfigSource(overrideBytes);
        if (sessionSource != null) {
          res = await _interface.getConfig(sessionSource);
        } else {
          final tempPath = await _writeTempConfigFile(overrideBytes);
          try {
            res = await _interface.getConfig(tempPath);
          } finally {
            await File(tempPath).safeDelete();
          }
        }
      } else {
        rethrow;
      }
    } finally {
      if (source.tempPath != null) {
        await File(source.tempPath!).safeDelete();
      }
    }

    if (res.isSuccess) {
      final data = Map<String, dynamic>.from(res.data);
      data['rules'] = data['rule'];
      data.remove('rule');
      return data;
    } else {
      throw res.message;
    }
  }

  Future<Traffic> getTraffic(bool onlyStatisticsProxy) async {
    final trafficString = await _interface.getTraffic(onlyStatisticsProxy);
    if (trafficString.isEmpty) {
      return Traffic();
    }
    return Traffic.fromJson(json.decode(trafficString));
  }

  Future<IpInfo?> getCountryCode(String ip) async {
    final countryCode = await _interface.getCountryCode(ip);
    if (countryCode.isEmpty) {
      return null;
    }
    return IpInfo(ip: ip, countryCode: countryCode);
  }

  Future<Traffic> getTotalTraffic(bool onlyStatisticsProxy) async {
    final totalTrafficString = await _interface.getTotalTraffic(
      onlyStatisticsProxy,
    );
    if (totalTrafficString.isEmpty) {
      return Traffic();
    }
    return Traffic.fromJson(json.decode(totalTrafficString));
  }

  Future<int> getMemory() async {
    final value = await _interface.getMemory();
    if (value.isEmpty) {
      return 0;
    }
    return int.parse(value);
  }

  void resetTraffic() {
    _interface.resetTraffic();
  }

  void startLog() {
    _interface.startLog();
  }

  void stopLog() {
    _interface.stopLog();
  }

  Future<void> requestGc() async {
    await _interface.forceGc();
  }

  Future<void> destroy() async {
    await _interface.destroy();
  }

  Future<void> crash() async {
    await _interface.crash();
  }

  Future<String> deleteFile(String path) async {
    return await _interface.deleteFile(path);
  }

  String _buildInlineConfigPayload(Uint8List bytes) {
    return '$_inlineConfigPrefix${base64.encode(bytes)}';
  }

  bool _shouldPreferSessionTransport(Uint8List bytes) {
    if (!system.isAndroid) return false;
    return bytes.length > _androidInlineSoftLimitBytes;
  }

  Future<bool> _persistAndroidQuickSetupConfigSnapshot(Uint8List bytes) async {
    if (!system.isAndroid) return false;
    try {
      return await service?.persistQuickSetupConfig(bytes) ?? false;
    } on PlatformException catch (e) {
      commonPrint.log(
        'persistQuickSetupConfig PlatformException: ${e.code} ${e.message}',
        logLevel: LogLevel.warning,
      );
      return false;
    } catch (e) {
      commonPrint.log(
        'persistQuickSetupConfig error: $e',
        logLevel: LogLevel.warning,
      );
      return false;
    }
  }

  Future<String> _validateConfigWithTempFile(Uint8List bytes) async {
    final path = await _writeTempConfigFile(bytes);
    try {
      return await _interface.validateConfig(path);
    } finally {
      await File(path).safeDelete();
    }
  }

  Future<String> _writeTempConfigFile(Uint8List bytes) async {
    final path = await appPath.tempFilePath;
    final file = File(path);
    await file.safeWriteAsBytes(bytes);
    return path;
  }

  Future<String?> _buildSessionConfigSource(Uint8List bytes) async {
    try {
      final sessionId = await ConfigSessionUploader(_interface).upload(bytes);
      if (sessionId == null) return null;
      return '$_sessionConfigPrefix$sessionId';
    } catch (e) {
      commonPrint.log(
        'session transport unavailable, fallback to path-based flow: $e',
        logLevel: LogLevel.warning,
      );
      return null;
    }
  }

  Future<_ConfigSource> _buildConfigSourceForGet({
    required int id,
    String? overridePath,
    Uint8List? overrideBytes,
  }) async {
    if (overrideBytes == null) {
      return _ConfigSource(
        source: overridePath ?? await appPath.getProfilePath(id.toString()),
      );
    }

    if (_shouldPreferSessionTransport(overrideBytes)) {
      final sessionSource = await _buildSessionConfigSource(overrideBytes);
      if (sessionSource != null) {
        return _ConfigSource(source: sessionSource);
      }
      final tempPath = await _writeTempConfigFile(overrideBytes);
      return _ConfigSource(source: tempPath, tempPath: tempPath);
    }

    return _ConfigSource(source: _buildInlineConfigPayload(overrideBytes));
  }
}

class _ConfigSource {
  final String source;
  final String? tempPath;

  const _ConfigSource({required this.source, this.tempPath});
}

final coreController = CoreController();
