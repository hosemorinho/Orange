import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

Future<T> decodeJSONTask<T>(String data) async {
  return await compute<String, T>(_decodeJSON, data);
}

Future<T> _decodeJSON<T>(String content) async {
  return json.decode(content);
}

Future<String> encodeJSONTask<T>(T data) async {
  return await compute<T, String>(_encodeJSON, data);
}

Future<String> _encodeJSON<T>(T content) async {
  return json.encode(content);
}

Future<String> encodeYamlTask<T>(T data) async {
  return await compute<T, String>(_encodeYaml, data);
}

Future<String> _encodeYaml<T>(T content) async {
  return yaml.encode(content);
}

Future<List<Group>> toGroupsTask(ComputeGroupsState data) async {
  return await compute<ComputeGroupsState, List<Group>>(_toGroupsTask, data);
}

Future<List<Group>> _toGroupsTask(ComputeGroupsState state) async {
  final proxiesData = state.proxiesData;
  final all = proxiesData.all;
  final sortType = state.sortType;
  final delayMap = state.delayMap;
  final selectedMap = state.selectedMap;
  final defaultTestUrl = state.defaultTestUrl;
  final proxies = proxiesData.proxies;
  if (proxies.isEmpty) return [];
  final groupsRaw = all
      .where((name) {
        final proxy = proxies[name] ?? {};
        return GroupTypeExtension.valueList.contains(proxy['type']);
      })
      .map((groupName) {
        final group = proxies[groupName];
        group['all'] = ((group['all'] ?? []) as List)
            .map((name) => proxies[name])
            .where((proxy) => proxy != null)
            .toList();
        return group;
      })
      .toList();
  final groups = groupsRaw.map((e) => Group.fromJson(e)).toList();
  return computeSort(
    groups: groups,
    sortType: sortType,
    delayMap: delayMap,
    selectedMap: selectedMap,
    defaultTestUrl: defaultTestUrl,
  );
}

Future<Map<String, dynamic>> makeRealProfileTask(
  MakeRealProfileState data,
) async {
  return await compute<MakeRealProfileState, Map<String, dynamic>>(
    _makeRealProfileTask,
    data,
  );
}

Future<Map<String, dynamic>> _makeRealProfileTask(
  MakeRealProfileState data,
) async {
  final rawConfig = Map<String, dynamic>.from(data.rawConfig);
  final realPatchConfig = data.realPatchConfig;

  // --- Log ---
  if (rawConfig['log'] == null) {
    rawConfig['log'] = <String, dynamic>{};
  }
  (rawConfig['log'] as Map)['level'] = realPatchConfig.logLevel.name;

  // --- Experimental / Clash API ---
  final experimental =
      Map<String, dynamic>.from(rawConfig['experimental'] as Map? ?? {});
  final clashApi =
      Map<String, dynamic>.from(experimental['clash_api'] as Map? ?? {});
  if (realPatchConfig.externalController.value.isNotEmpty) {
    clashApi['external_controller'] = realPatchConfig.externalController.value;
  }
  clashApi['default_mode'] = realPatchConfig.mode.name;
  experimental['clash_api'] = clashApi;
  rawConfig['experimental'] = experimental;

  // --- Inbounds: mixed-port and allow-lan ---
  final listenAddr = realPatchConfig.allowLan ? '0.0.0.0' : '127.0.0.1';
  List<dynamic> inbounds = List.from(rawConfig['inbounds'] as List? ?? []);

  // Find or create the mixed inbound
  bool hasMixed = false;
  for (int i = 0; i < inbounds.length; i++) {
    final inbound = Map<String, dynamic>.from(inbounds[i] as Map);
    if (inbound['type'] == 'mixed') {
      inbound['listen'] = listenAddr;
      inbound['listen_port'] = realPatchConfig.mixedPort;
      inbounds[i] = inbound;
      hasMixed = true;
    } else {
      // Update listen address for all inbounds
      inbound['listen'] = listenAddr;
      inbounds[i] = inbound;
    }
  }
  if (!hasMixed && realPatchConfig.mixedPort > 0) {
    inbounds.add(<String, dynamic>{
      'type': 'mixed',
      'tag': 'mixed-in',
      'listen': listenAddr,
      'listen_port': realPatchConfig.mixedPort,
    });
  }

  // --- TUN inbound ---
  final tunConfig = realPatchConfig.tun;
  // Remove existing tun inbound if any
  inbounds.removeWhere((ib) => (ib as Map)['type'] == 'tun');
  if (tunConfig.enable) {
    final tunInbound = <String, dynamic>{
      'type': 'tun',
      'tag': 'tun-in',
      'auto_route': tunConfig.autoRoute,
      'stack': tunConfig.stack.name,
      'sniff': true,
      'sniff_override_destination': false,
    };
    if (tunConfig.routeAddress.isNotEmpty) {
      tunInbound['address'] = tunConfig.routeAddress;
    }
    inbounds.add(tunInbound);
  }

  rawConfig['inbounds'] = inbounds;

  // --- Route: find_process ---
  if (rawConfig['route'] != null) {
    final route = Map<String, dynamic>.from(rawConfig['route'] as Map);
    route['find_process'] =
        realPatchConfig.findProcessMode.name == 'always' ? true : false;
    rawConfig['route'] = route;
  }

  return rawConfig;
}

Future<List<String>> shakingProfileTask(
  VM2<Iterable<int>, Iterable<int>> data,
) async {
  return await compute<
    VM3<Iterable<int>, Iterable<int>, RootIsolateToken>,
    List<String>
  >(_shakingProfileTask, VM3(data.a, data.b, RootIsolateToken.instance!));
}

Future<List<String>> _shakingProfileTask(
  VM3<Iterable<int>, Iterable<int>, RootIsolateToken> data,
) async {
  final profileIds = data.a;
  final scriptIds = data.b;
  final token = data.c;
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  final profilesDir = Directory(await appPath.profilesPath);
  final scriptsDir = Directory(await appPath.scriptsDirPath);
  final providersDir = Directory(await appPath.getProvidersRootPath());
  final List<String> targets = [];
  void scanDirectory(
    Directory dir,
    Iterable<int> baseNames, {
    bool skipProvidersFolder = false,
  }) {
    if (!dir.existsSync()) return;
    final entities = dir.listSync(recursive: false, followLinks: false);

    for (final entity in entities) {
      if (entity is File) {
        final id = basenameWithoutExtension(entity.path);
        if (!baseNames.contains(int.tryParse(id))) {
          targets.add(entity.path);
        }
      } else if (skipProvidersFolder && entity is Directory) {
        if (basename(entity.path) == 'providers') {
          continue;
        }
      }
    }
  }

  scanDirectory(profilesDir, profileIds, skipProvidersFolder: true);
  scanDirectory(providersDir, profileIds);
  scanDirectory(scriptsDir, scriptIds);
  return targets;
}

Future<String> encodeLogsTask(List<Log> data) async {
  return await compute<List<Log>, String>(_encodeLogsTask, data);
}

Future<String> _encodeLogsTask(List<Log> data) async {
  final logsRaw = data.map((item) => item.toString());
  final logsRawString = logsRaw.join('\n');
  return logsRawString;
}

Future<MigrationData> oldToNowTask(Map<String, Object?> data) async {
  final homeDir = await appPath.homeDirPath;
  return await compute<
    VM3<Map<String, Object?>, String, String>,
    MigrationData
  >(_oldToNowTask, VM3(data, homeDir, homeDir));
}

Future<MigrationData> _oldToNowTask(
  VM3<Map<String, Object?>, String, String> data,
) async {
  final configMap = data.a;
  final sourcePath = data.b;
  final targetPath = data.c;

  final accessControlMap = configMap['accessControl'];
  final isAccessControl = configMap['isAccessControl'];
  if (accessControlMap != null) {
    (accessControlMap as Map)['enable'] = isAccessControl;
    if (configMap['vpnProps'] != null) {
      final vpnPropsRaw = configMap['vpnProps'] as Map;
      vpnPropsRaw['accessControl'] = accessControlMap;
    }
  }
  if (configMap['vpnProps'] != null) {
    final vpnPropsRaw = configMap['vpnProps'] as Map;
    vpnPropsRaw['accessControlProps'] = vpnPropsRaw['accessControl'];
  }
  configMap['davProps'] = configMap['dav'];
  final appSettingProps = configMap['appSetting'] as Map? ?? {};
  appSettingProps['restoreStrategy'] = appSettingProps['recoveryStrategy'];
  configMap['appSettingProps'] = appSettingProps;
  configMap['proxiesStyleProps'] = configMap['proxiesStyle'];
  configMap['proxiesStyleProps'] = configMap['proxiesStyle'];
  // final overwriteMap = configMap['overwrite'] as Map? ?? {};
  // configMap['overwriteType'] = overwriteMap['type'];
  // configMap['scriptId'] = overwriteMap['scriptOverwrite'];
  List rawScripts = configMap['scripts'] as List<dynamic>? ?? [];
  if (rawScripts.isEmpty) {
    final scriptPropsJson = configMap['scriptProps'] as Map<String, dynamic>?;
    if (scriptPropsJson != null) {
      rawScripts = scriptPropsJson['scripts'] as List<dynamic>? ?? [];
    }
  }
  final Map<String, int> idMap = {};
  final List<Script> scripts = [];
  for (final rawScript in rawScripts) {
    final id = rawScript['id'] as String?;
    final content = rawScript['content'] as String?;
    final label = rawScript['label'] as String?;
    if (id == null || content == null || label == null) {
      continue;
    }
    final newId = idMap.updateCacheValue(rawScript['id'], () => snowflake.id);
    final path = _getScriptPath(targetPath, newId.toString());
    final file = File(path);
    await file.safeWriteAsString(content);
    scripts.add(
      Script(id: newId, label: label, lastUpdateTime: DateTime.now()),
    );
  }
  List rawRules = configMap['rules'] as List<dynamic>? ?? [];
  final List<Rule> rules = [];
  final List<ProfileRuleLink> links = [];
  for (final rawRule in rawRules) {
    final id = idMap.updateCacheValue(rawRule['id'], () => snowflake.id);
    rawRule['id'] = id;
    rules.add(Rule.fromJson(rawRule));
    links.add(ProfileRuleLink(ruleId: id));
  }
  List rawProfiles = configMap['profiles'] as List<dynamic>? ?? [];
  final List<Profile> profiles = [];
  for (final rawProfile in rawProfiles) {
    final rawId = rawProfile['id'] as String?;
    if (rawId == null) {
      continue;
    }
    final profileId = idMap.updateCacheValue(rawId, () => snowflake.id);
    rawProfile['id'] = profileId;
    final overwrite = rawProfile['overwrite'] as Map?;
    if (overwrite != null) {
      final standardOverwrite = overwrite['standardOverwrite'] as Map?;
      if (standardOverwrite != null) {
        final addedRules = standardOverwrite['addedRules'] as List? ?? [];
        for (final addRule in addedRules) {
          final id = idMap.updateCacheValue(addRule['id'], () => snowflake.id);
          addRule['id'] = id;
          rules.add(Rule.fromJson(addRule));
          links.add(
            ProfileRuleLink(
              profileId: profileId,
              ruleId: id,
              scene: RuleScene.added,
            ),
          );
        }
        final disabledRuleIds = standardOverwrite['disabledRuleIds'] as List?;
        if (disabledRuleIds != null) {
          for (final disabledRuleId in disabledRuleIds) {
            final newDisabledRuleId = idMap[disabledRuleId];
            if (newDisabledRuleId != null) {
              links.add(
                ProfileRuleLink(
                  profileId: profileId,
                  ruleId: newDisabledRuleId,
                  scene: RuleScene.disabled,
                ),
              );
            }
          }
        }
      }
      final scriptOverwrite = overwrite['scriptOverwrite'] as Map?;
      if (scriptOverwrite != null) {
        final scriptId = scriptOverwrite['scriptId'] as String?;
        rawProfile['scriptId'] = scriptId != null ? idMap[scriptId] : null;
      }
      rawProfile['overwriteType'] = overwrite['type'];
    }

    final sourceFile = File(_getProfilePath(sourcePath, rawId));
    final targetFilePath = _getProfilePath(targetPath, profileId.toString());
    await sourceFile.safeCopy(targetFilePath);
    profiles.add(Profile.fromJson(rawProfile));
  }
  final currentProfileId = configMap['currentProfileId'];
  configMap['currentProfileId'] = currentProfileId != null
      ? idMap[currentProfileId]
      : null;
  return MigrationData(
    configMap: configMap,
    profiles: profiles,
    rules: rules,
    scripts: scripts,
    links: links,
  );
}

Future<String> backupTask(
  Map<String, dynamic> configMap,
  Iterable<String> fileNames,
) async {
  return await compute<
    VM3<Map<String, dynamic>, Iterable<String>, RootIsolateToken>,
    String
  >(_backupTask, VM3(configMap, fileNames, RootIsolateToken.instance!));
}

Future<String> _backupTask<T>(
  VM3<Map<String, dynamic>, Iterable<String>, RootIsolateToken> args,
) async {
  final configMap = args.a;
  final fileNames = args.b;
  final token = args.c;
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  final dbPath = await appPath.databasePath;
  final configStr = json.encode(configMap);
  final profilesDir = Directory(await appPath.profilesPath);
  final scriptsDir = Directory(await appPath.scriptsDirPath);
  final tempZipFilePath = await appPath.tempFilePath;
  final tempDBFile = File(await appPath.tempFilePath);
  final tempConfigFile = File(await appPath.tempFilePath);
  final dbFile = File(dbPath);
  if (await dbFile.exists()) {
    await dbFile.copy(tempDBFile.path);
  }
  final encoder = ZipFileEncoder();
  encoder.create(tempZipFilePath);
  await tempConfigFile.writeAsString(configStr);
  await encoder.addFile(tempDBFile, backupDatabaseName);
  await encoder.addFile(tempConfigFile, configJsonName);
  if (await profilesDir.exists()) {
    await encoder.addDirectory(
      profilesDir,
      filter: (file, _) {
        if (!fileNames.contains(basename(file.path))) {
          return ZipFileOperation.skip;
        }
        return ZipFileOperation.include;
      },
    );
  }
  if (await scriptsDir.exists()) {
    await encoder.addDirectory(
      scriptsDir,
      filter: (file, _) {
        if (!fileNames.contains(basename(file.path))) {
          return ZipFileOperation.skip;
        }
        return ZipFileOperation.include;
      },
    );
  }
  encoder.close();
  await tempConfigFile.safeDelete();
  await tempDBFile.safeDelete();
  return tempZipFilePath;
}

Future<MigrationData> restoreTask() async {
  return await compute<RootIsolateToken, MigrationData>(
    _restoreTask,
    RootIsolateToken.instance!,
  );
}

Future<MigrationData> _restoreTask(RootIsolateToken token) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  final backupFilePath = await appPath.backupFilePath;
  final restoreDirPath = await appPath.restoreDirPath;
  final homeDirPath = await appPath.homeDirPath;
  final zipDecoder = ZipDecoder();
  final input = InputFileStream(backupFilePath);
  final archive = zipDecoder.decodeStream(input);
  final dir = Directory(restoreDirPath);
  await dir.create(recursive: true);
  for (final file in archive.files) {
    final outPath = join(restoreDirPath, posix.normalize(file.name));
    final outputStream = OutputFileStream(outPath);
    file.writeContent(outputStream);
    await outputStream.close();
  }
  await input.close();
  final restoreConfigFile = File(join(restoreDirPath, configJsonName));
  if (!await restoreConfigFile.exists()) {
    throw appLocalizations.invalidBackupFile;
  }
  final restoreConfigMap =
      json.decode(await restoreConfigFile.readAsString())
          as Map<String, Object?>?;
  final version = restoreConfigMap?['version'] ?? 0;
  MigrationData migrationData = MigrationData(configMap: restoreConfigMap);
  if (version == 0 && restoreConfigMap != null) {
    migrationData = await _oldToNowTask(
      VM3(restoreConfigMap, restoreDirPath, homeDirPath),
    );
    return migrationData;
  }
  final backupDatabaseFile = File(join(restoreDirPath, backupDatabaseName));
  if (!await backupDatabaseFile.exists()) {
    return migrationData;
  }
  final database = Database(
    driftDatabase(
      name: 'database',
      native: DriftNativeOptions(
        databaseDirectory: () async => Directory(restoreDirPath),
      ),
    ),
  );
  final results = await Future.wait([
    database.profilesDao.all().get(),
    database.scriptsDao.all().get(),
    database.rules.all().map((item) => item.toRule()).get(),
    database.profileRuleLinks.all().map((item) => item.toLink()).get(),
  ]);
  final profiles = results[0].cast<Profile>();
  final scripts = results[1].cast<Script>();
  final profilesMigration = profiles.map(
    (item) => VM2(
      _getProfilePath(restoreDirPath, item.id.toString()),
      _getProfilePath(homeDirPath, item.id.toString()),
    ),
  );
  final scriptsMigration = scripts.map(
    (item) => VM2(
      _getScriptPath(restoreDirPath, item.id.toString()),
      _getScriptPath(homeDirPath, item.id.toString()),
    ),
  );
  await _copyWithMapList([...profilesMigration, ...scriptsMigration]);
  migrationData = migrationData.copyWith(
    profiles: profiles,
    scripts: scripts,
    rules: results[2].cast<Rule>(),
    links: results[3].cast<ProfileRuleLink>(),
  );
  await database.close();
  return migrationData;
}

Future<void> _copyWithMapList(List<VM2<String, String>> copyMapList) async {
  await Future.wait(
    copyMapList.map((item) => File(item.a).safeCopy(item.b)).toList(),
  );
}

String _getScriptPath(String root, String fileName) {
  return join(root, 'scripts', '$fileName.js');
}

String _getProfilePath(String root, String fileName) {
  return join(root, 'profiles', '$fileName.yaml');
}
