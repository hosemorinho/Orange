import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';

// 环境变量配置（通过 --dart-define 传入）
const _envPackageName = String.fromEnvironment('APP_PACKAGE_NAME');
const _envApiBaseUrl = String.fromEnvironment('API_BASE_URL');
const _envThemeColor = String.fromEnvironment('THEME_COLOR');
const _envAppName = String.fromEnvironment('APP_NAME');

const appName = _envAppName == '' ? "Flclash" : _envAppName;
const appNameEn = appName; // 用于 HTTP User-Agent 的英文名称
const appHelperService = "FlClashHelperService";
const coreName = "clash.meta";
const browserUa =
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";
const packageName = _envPackageName == '' ? "com.follow.clash" : _envPackageName;
const apiBaseUrl = _envApiBaseUrl; // 空字符串表示使用配置文件域名竞速
const themeColorHex = _envThemeColor == '' ? "66558E" : _envThemeColor;
final unixSocketPath = "/tmp/FlClashSocket_${Random().nextInt(10000)}.sock";
const helperPort = 47890;
const maxTextScale = 1.4;
const minTextScale = 0.8;
final baseInfoEdgeInsets = EdgeInsets.symmetric(
  vertical: 16.ap,
  horizontal: 16.ap,
);

final defaultTextScaleFactor =
    WidgetsBinding.instance.platformDispatcher.textScaleFactor;
const httpTimeoutDuration = Duration(milliseconds: 5000);
const moreDuration = Duration(milliseconds: 100);
const animateDuration = Duration(milliseconds: 100);
const midDuration = Duration(milliseconds: 200);
const commonDuration = Duration(milliseconds: 300);
const defaultUpdateDuration = Duration(days: 1);
const mmdbFileName = "geoip.metadb";
const asnFileName = "ASN.mmdb";
const geoIpFileName = "GeoIP.dat";
const geoSiteFileName = "GeoSite.dat";
final double kHeaderHeight = system.isDesktop
    ? !Platform.isMacOS
        ? 40
        : 28
    : 0;
const profilesDirectoryName = "profiles";
const localhost = "127.0.0.1";
const clashConfigKey = "clash_config";
const configKey = "config";
const double dialogCommonWidth = 300;
const repository = "chen08209/FlClash";
const defaultExternalController = "127.0.0.1:9090";
const maxMobileWidth = 600;
const maxLaptopWidth = 840;
const defaultTestUrl = "https://www.gstatic.com/generate_204";
final commonFilter = ImageFilter.blur(
  sigmaX: 5,
  sigmaY: 5,
  tileMode: TileMode.mirror,
);

const navigationItemListEquality = ListEquality<NavigationItem>();
const connectionListEquality = ListEquality<Connection>();
const stringListEquality = ListEquality<String>();
const intListEquality = ListEquality<int>();
const logListEquality = ListEquality<Log>();
const groupListEquality = ListEquality<Group>();
const externalProviderListEquality = ListEquality<ExternalProvider>();
const packageListEquality = ListEquality<Package>();
const hotKeyActionListEquality = ListEquality<HotKeyAction>();
const stringAndStringMapEquality = MapEquality<String, String>();
const stringAndStringMapEntryIterableEquality =
    IterableEquality<MapEntry<String, String>>();
const delayMapEquality = MapEquality<String, Map<String, int?>>();
const stringSetEquality = SetEquality<String>();
const keyboardModifierListEquality = SetEquality<KeyboardModifier>();

const viewModeColumnsMap = {
  ViewMode.mobile: [2, 1],
  ViewMode.laptop: [3, 2],
  ViewMode.desktop: [4, 3],
};

// const proxiesStoreKey = PageStorageKey<String>('proxies');
// const toolsStoreKey = PageStorageKey<String>('tools');
// const profilesStoreKey = PageStorageKey<String>('profiles');

const defaultPrimaryColor = 0xFF66558E;

double getWidgetHeight(num lines) {
  return max(lines * 84 + (lines - 1) * 16, 0).ap;
}

const maxLength = 150;

final mainIsolate = "FlClashMainIsolate";

final serviceIsolate = "FlClashServiceIsolate";

/// 解析环境变量中的主题色（hex 字符串 → int）
int parseThemeColor() {
  if (themeColorHex.isEmpty) return 0xFF66558E;
  final hex = themeColorHex.replaceFirst('#', '');
  final value = int.tryParse(hex, radix: 16);
  if (value == null) return 0xFF66558E;
  return hex.length <= 6 ? (0xFF000000 | value) : value;
}

const defaultPrimaryColors = [
  0xFF795548,
  0xFF03A9F4,
  0xFFFFFF00,
  0XFFBBC9CC,
  0XFFABD397,
  defaultPrimaryColor,
  0XFF665390,
];

const scriptTemplate = """
const main = (config) => {
  return config;
}""";
