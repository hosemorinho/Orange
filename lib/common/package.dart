import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import 'common.dart';

extension PackageInfoExtension on PackageInfo {
  String get ua => [
        "$appNameEn/v$version",
        "sing-box/1.13.3",
        "Platform/${Platform.operatingSystem}",
      ].join(" ");
}
