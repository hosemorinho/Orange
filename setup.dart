// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';

enum Target {
  windows,
  linux,
  android,
  macos,
}

extension TargetExt on Target {
  String get os {
    if (this == Target.macos) {
      return "darwin";
    }
    return name;
  }

  bool get same {
    if (this == Target.android) {
      return true;
    }
    if (Platform.isWindows && this == Target.windows) {
      return true;
    }
    if (Platform.isLinux && this == Target.linux) {
      return true;
    }
    if (Platform.isMacOS && this == Target.macos) {
      return true;
    }
    return false;
  }

  String get dynamicLibExtensionName {
    final String extensionName;
    switch (this) {
      case Target.android || Target.linux:
        extensionName = ".so";
        break;
      case Target.windows:
        extensionName = ".dll";
        break;
      case Target.macos:
        extensionName = ".dylib";
        break;
    }
    return extensionName;
  }

  String get executableExtensionName {
    final String extensionName;
    switch (this) {
      case Target.windows:
        extensionName = ".exe";
        break;
      default:
        extensionName = "";
        break;
    }
    return extensionName;
  }
}

enum Mode { core, lib }

enum Arch { amd64, arm64, arm }

class BuildItem {
  Target target;
  Arch? arch;
  String? archName;

  BuildItem({
    required this.target,
    this.arch,
    this.archName,
  });

  @override
  String toString() {
    return 'BuildLibItem{target: $target, arch: $arch, archName: $archName}';
  }
}

class Build {
  static List<BuildItem> get buildItems => [
        BuildItem(
          target: Target.macos,
          arch: Arch.arm64,
        ),
        BuildItem(
          target: Target.macos,
          arch: Arch.amd64,
        ),
        BuildItem(
          target: Target.linux,
          arch: Arch.arm64,
        ),
        BuildItem(
          target: Target.linux,
          arch: Arch.amd64,
        ),
        BuildItem(
          target: Target.windows,
          arch: Arch.amd64,
        ),
        BuildItem(
          target: Target.windows,
          arch: Arch.arm64,
        ),
        BuildItem(
          target: Target.android,
          arch: Arch.arm,
          archName: 'armeabi-v7a',
        ),
        BuildItem(
          target: Target.android,
          arch: Arch.arm64,
          archName: 'arm64-v8a',
        ),
        BuildItem(
          target: Target.android,
          arch: Arch.amd64,
          archName: 'x86_64',
        ),
      ];

  static String get defaultAppName => "Flclash";

  static String coreNameFor(String appName) => "${appName}Core";

  static String helperNameFor(String appName) => "${appName}HelperService";

  static String get libName => "libclash";

  static String get outDir => join(current, libName);

  static String get _coreDir => join(current, "core");

  static String get _servicesDir => join(current, "services", "helper");

  static String get distPath => join(current, "dist");

  static String _getCc(BuildItem buildItem) {
    final environment = Platform.environment;
    if (buildItem.target == Target.android) {
      final ndk = environment["ANDROID_NDK"];
      assert(ndk != null);
      final prebuiltDir =
          Directory(join(ndk!, "toolchains", "llvm", "prebuilt"));
      final prebuiltDirList = prebuiltDir.listSync();
      final map = {
        "armeabi-v7a": "armv7a-linux-androideabi21-clang",
        "arm64-v8a": "aarch64-linux-android21-clang",
        "x86": "i686-linux-android21-clang",
        "x86_64": "x86_64-linux-android21-clang"
      };
      return join(
        prebuiltDirList.first.path,
        "bin",
        map[buildItem.archName],
      );
    }
    return "gcc";
  }

  static get tags => "with_gvisor";

  static Future<void> exec(
    List<String> executable, {
    String? name,
    Map<String, String>? environment,
    String? workingDirectory,
    bool runInShell = true,
  }) async {
    if (name != null) print("run $name");
    final process = await Process.start(
      executable[0],
      executable.sublist(1),
      environment: environment,
      workingDirectory: workingDirectory,
      runInShell: runInShell,
    );
    process.stdout.listen((data) {
      try {
        print(utf8.decode(data));
      } catch (e) {
        // 如果UTF-8解码失败，使用latin1编码或直接输出原始数据
        print(String.fromCharCodes(data));
      }
    });
    process.stderr.listen((data) {
      try {
        print(utf8.decode(data));
      } catch (e) {
        // 如果UTF-8解码失败，使用latin1编码或直接输出原始数据
        print(String.fromCharCodes(data));
      }
    });
    final exitCode = await process.exitCode;
    if (exitCode != 0 && name != null) throw "$name error";
  }

  static Future<String> calcSha256(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw "File not exists";
    }
    final stream = file.openRead();
    return sha256.convert(await stream.reduce((a, b) => a + b)).toString();
  }

  static Future<List<String>> buildCore({
    required Mode mode,
    required Target target,
    Arch? arch,
    String? appName,
  }) async {
    final isLib = mode == Mode.lib;
    final coreName = coreNameFor(appName ?? defaultAppName);

    final items = buildItems.where(
      (element) {
        return element.target == target &&
            (arch == null ? true : element.arch == arch);
      },
    ).toList();

    final List<String> corePaths = [];

    for (final item in items) {
      final outFileDir = join(
        outDir,
        item.target.name,
        item.archName,
      );

      final file = File(outFileDir);
      if (file.existsSync()) {
        file.deleteSync(recursive: true);
      }

      final fileName = isLib
          ? "$libName${item.target.dynamicLibExtensionName}"
          : "$coreName${item.target.executableExtensionName}";
      final outPath = join(
        outFileDir,
        fileName,
      );
      corePaths.add(outPath);

      final Map<String, String> env = {};
      env["GOOS"] = item.target.os;
      if (item.arch != null) {
        env["GOARCH"] = item.arch!.name;
      }
      if (isLib) {
        env["CGO_ENABLED"] = "1";
        env["CC"] = _getCc(item);
        env["CFLAGS"] = "-O3 -Werror";
      } else {
        env["CGO_ENABLED"] = "0";
      }

      final execLines = [
        "go",
        "build",
        "-ldflags=-w -s",
        "-tags=$tags",
        if (isLib) "-buildmode=c-shared",
        "-o",
        outPath,
      ];
      await exec(
        execLines,
        name: "build core",
        environment: env,
        workingDirectory: _coreDir,
      );
    }

    return corePaths;
  }

  static buildHelper(Target target, String token, {String? appName}) async {
    final helperName = helperNameFor(appName ?? defaultAppName);
    await exec(
      [
        "cargo",
        "build",
        "--release",
        "--features",
        "windows-service",
      ],
      environment: {
        "TOKEN": token,
        "SERVICE_NAME": helperName,
      },
      name: "build helper",
      workingDirectory: _servicesDir,
    );
    final outPath = join(
      _servicesDir,
      "target",
      "release",
      "helper${target.executableExtensionName}",
    );
    final targetPath = join(
      outDir,
      target.name,
      "$helperName${target.executableExtensionName}",
    );
    await File(outPath).copy(targetPath);
  }

  static List<String> getExecutable(String command) {
    return command.split(" ");
  }

  static getDistributor() async {
    final distributorDir = join(
      current,
      "plugins",
      "flutter_distributor",
      "packages",
      "flutter_distributor",
    );

    await exec(
      name: "clean distributor",
      Build.getExecutable("flutter clean"),
      workingDirectory: distributorDir,
    );
    await exec(
      name: "upgrade distributor",
      Build.getExecutable("flutter pub upgrade"),
      workingDirectory: distributorDir,
    );
    await exec(
      name: "get distributor",
      Build.getExecutable("dart pub global activate -s path $distributorDir"),
    );
  }

  static copyFile(String sourceFilePath, String destinationFilePath) {
    final sourceFile = File(sourceFilePath);
    if (!sourceFile.existsSync()) {
      throw "SourceFilePath not exists";
    }
    final destinationFile = File(destinationFilePath);
    final destinationDirectory = destinationFile.parent;
    if (!destinationDirectory.existsSync()) {
      destinationDirectory.createSync(recursive: true);
    }
    try {
      sourceFile.copySync(destinationFilePath);
      print("File copied successfully!");
    } catch (e) {
      print("Failed to copy file: $e");
    }
  }
}

class BuildCommand extends Command {
  Target target;

  BuildCommand({
    required this.target,
  }) {
    if (target == Target.android || target == Target.linux) {
      argParser.addOption(
        "arch",
        valueHelp: arches.map((e) => e.name).join(','),
        help: 'The $name build desc',
      );
    } else {
      argParser.addOption(
        "arch",
        help: 'The $name build archName',
      );
    }
    argParser.addOption(
      "out",
      valueHelp: [
        if (target.same) "app",
        "core",
      ].join(','),
      help: 'The $name build arch',
    );
    argParser.addOption(
      "env",
      valueHelp: [
        "pre",
        "stable",
      ].join(','),
      help: 'The $name build env',
    );
    argParser.addOption(
      "app-name",
      help: 'Override application display name (e.g. Orange)',
    );
    argParser.addOption(
      "package-name",
      help: 'Override APP_PACKAGE_NAME via --dart-define',
    );
    argParser.addOption(
      "api-url",
      help: 'Override API_BASE_URL via --dart-define',
    );
    argParser.addOption(
      "theme-color",
      help: 'Override THEME_COLOR via --dart-define',
    );
  }

  @override
  String get description => "build $name application";

  @override
  String get name => target.name;

  List<Arch> get arches => Build.buildItems
      .where((element) => element.target == target && element.arch != null)
      .map((e) => e.arch!)
      .toList();

  _getLinuxDependencies(Arch arch) async {
    await Build.exec(
      Build.getExecutable("sudo apt update -y"),
    );
    await Build.exec(
      Build.getExecutable("sudo apt install -y ninja-build libgtk-3-dev"),
    );
    await Build.exec(
      Build.getExecutable("sudo apt install -y libayatana-appindicator3-dev"),
    );
    await Build.exec(
      Build.getExecutable("sudo apt-get install -y libkeybinder-3.0-dev"),
    );
    await Build.exec(
      Build.getExecutable("sudo apt install -y locate"),
    );
    if (arch == Arch.amd64) {
      await Build.exec(
        Build.getExecutable("sudo apt install -y rpm patchelf"),
      );
      await Build.exec(
        Build.getExecutable("sudo apt install -y libfuse2"),
      );

      final downloadName = arch == Arch.amd64 ? "x86_64" : "aarch64";
      await Build.exec(
        Build.getExecutable(
          "wget -O appimagetool https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$downloadName.AppImage",
        ),
      );
      await Build.exec(
        Build.getExecutable(
          "chmod +x appimagetool",
        ),
      );
      await Build.exec(
        Build.getExecutable(
          "sudo mv appimagetool /usr/local/bin/",
        ),
      );
    }
  }

  _getMacosDependencies() async {
    await Build.exec(
      Build.getExecutable("npm install -g appdmg"),
    );
  }

  _buildDistributor({
    required Target target,
    required String targets,
    String args = '',
    required String env,
    String extraDefines = '',
  }) async {
    await Build.getDistributor();
    await Build.exec(
      name: name,
      Build.getExecutable(
        "flutter_distributor package --skip-clean --platform ${target.name} --targets $targets --flutter-build-args=verbose$args --build-dart-define=APP_ENV=$env$extraDefines",
      ),
    );
  }

  Future<String?> get systemArch async {
    if (Platform.isWindows) {
      return Platform.environment["PROCESSOR_ARCHITECTURE"];
    } else if (Platform.isLinux || Platform.isMacOS) {
      final result = await Process.run('uname', ['-m']);
      return result.stdout.toString().trim();
    }
    return null;
  }

  static void _patchFile(String filePath, String from, String to) {
    final file = File(filePath);
    if (!file.existsSync()) return;
    final content = file.readAsStringSync();
    final patched = content.replaceAll(from, to);
    if (patched != content) {
      file.writeAsStringSync(patched);
      print('Patched app name in $filePath');
    }
  }

  static void _patchAppName(String appName) {
    final coreName = Build.coreNameFor(appName);
    final helperName = Build.helperNameFor(appName);

    // distribute_options.yaml
    _patchFile(join(current, 'distribute_options.yaml'), 'Flclash', appName);

    // Android
    _patchFile(
      join(current, 'android', 'app', 'src', 'main', 'AndroidManifest.xml'),
      'android:label="Flclash"',
      'android:label="$appName"',
    );
    _patchFile(
      join(current, 'android', 'app', 'src', 'main', 'res', 'values', 'strings.xml'),
      '>FlClash<',
      '>$appName<',
    );

    // Windows — main.cpp window title
    _patchFile(
      join(current, 'windows', 'runner', 'main.cpp'),
      'L"FlClash"',
      'L"$appName"',
    );

    // Windows — Runner.rc version info fields
    final runnerRc = join(current, 'windows', 'runner', 'Runner.rc');
    for (final field in ['"FileDescription"', '"InternalName"', '"ProductName"']) {
      _patchFile(runnerRc, '$field, "Flclash"', '$field, "$appName"');
    }
    _patchFile(runnerRc, '"OriginalFilename", "Flclash.exe"', '"OriginalFilename", "$appName.exe"');

    // Windows — CMakeLists.txt project name, binary name, core/helper references
    final winCMake = join(current, 'windows', 'CMakeLists.txt');
    _patchFile(winCMake, 'project(Flclash ', 'project($appName ');
    _patchFile(winCMake, 'BINARY_NAME "Flclash"', 'BINARY_NAME "$appName"');
    _patchFile(winCMake, 'FlClashCore.exe', '$coreName.exe');
    _patchFile(winCMake, 'FlClashHelperService.exe', '$helperName.exe');

    // Windows — packaging exe config
    final winPkgConfig = join(current, 'windows', 'packaging', 'exe', 'make_config.yaml');
    _patchFile(winPkgConfig, 'app_name: Flclash', 'app_name: $appName');
    _patchFile(winPkgConfig, 'display_name: Flclash', 'display_name: $appName');
    _patchFile(winPkgConfig, 'executable_name: Flclash.exe', 'executable_name: $appName.exe');
    _patchFile(winPkgConfig, 'output_base_file_name: Flclash.exe', 'output_base_file_name: $appName.exe');

    // Windows — Inno Setup process killer list
    _patchFile(
      join(current, 'windows', 'packaging', 'exe', 'inno_setup.iss'),
      "Processes := ['Flclash.exe', 'FlClashCore.exe', 'FlClashHelperService.exe']",
      "Processes := ['$appName.exe', '$coreName.exe', '$helperName.exe']",
    );

    // Linux
    _patchFile(
      join(current, 'linux', 'my_application.cc'),
      '"Flclash"',
      '"$appName"',
    );
    _patchFile(
      join(current, 'linux', 'CMakeLists.txt'),
      'FlClashCore',
      coreName,
    );
    for (final pkg in ['deb', 'rpm', 'appimage']) {
      final path = join(current, 'linux', 'packaging', pkg, 'make_config.yaml');
      _patchFile(path, 'display_name: Flclash', 'display_name: $appName');
      _patchFile(path, 'generic_name: Flclash', 'generic_name: $appName');
      if (pkg == 'deb') {
        _patchFile(path, 'package_name: Flclash', 'package_name: $appName');
      }
    }

    // macOS
    _patchFile(
      join(current, 'macos', 'Runner', 'Configs', 'AppInfo.xcconfig'),
      'PRODUCT_NAME = Flclash',
      'PRODUCT_NAME = $appName',
    );
    _patchFile(
      join(current, 'macos', 'Runner.xcodeproj', 'project.pbxproj'),
      'FlClashCore',
      coreName,
    );
    final dmgConfig = join(current, 'macos', 'packaging', 'dmg', 'make_config.yaml');
    _patchFile(dmgConfig, 'title: Flclash', 'title: $appName');
    _patchFile(dmgConfig, 'path: Flclash.app', 'path: $appName.app');
  }

  @override
  Future<void> run() async {
    final mode = target == Target.android ? Mode.lib : Mode.core;
    final String out = argResults?["out"] ?? (target.same ? "app" : "core");
    final archName = argResults?["arch"];
    final env = argResults?["env"] ?? "stable";
    final appNameArg = argResults?["app-name"] as String?;
    final packageNameArg = argResults?["package-name"] as String?;
    final apiUrlArg = argResults?["api-url"] as String?;
    final themeColorArg = argResults?["theme-color"] as String?;

    // 替换平台文件中的应用名称
    if (appNameArg != null && appNameArg.isNotEmpty) {
      _patchAppName(appNameArg);
    }

    // 构建额外的 --dart-define 参数
    final extraDefinesBuf = StringBuffer();
    if (appNameArg != null && appNameArg.isNotEmpty) {
      extraDefinesBuf.write(' --build-dart-define=APP_NAME=$appNameArg');
    }
    if (packageNameArg != null && packageNameArg.isNotEmpty) {
      extraDefinesBuf.write(' --build-dart-define=APP_PACKAGE_NAME=$packageNameArg');
    }
    if (apiUrlArg != null && apiUrlArg.isNotEmpty) {
      extraDefinesBuf.write(' --build-dart-define=API_BASE_URL=$apiUrlArg');
    }
    if (themeColorArg != null && themeColorArg.isNotEmpty) {
      extraDefinesBuf.write(' --build-dart-define=THEME_COLOR=$themeColorArg');
    }
    final extraDefines = extraDefinesBuf.toString();
    final currentArches =
        arches.where((element) => element.name == archName).toList();
    final arch = currentArches.isEmpty ? null : currentArches.first;

    if (arch == null && target != Target.android) {
      throw "Invalid arch parameter";
    }

    final corePaths = await Build.buildCore(
      target: target,
      arch: arch,
      mode: mode,
      appName: appNameArg,
    );

    if (out != "app") {
      return;
    }

    switch (target) {
      case Target.windows:
        final token = target != Target.android
            ? await Build.calcSha256(corePaths.first)
            : null;
        Build.buildHelper(target, token!, appName: appNameArg);
        _buildDistributor(
          target: target,
          targets: "exe,zip",
          args:
              " --description $archName --build-dart-define=CORE_SHA256=$token",
          env: env,
          extraDefines: extraDefines,
        );
        return;
      case Target.linux:
        final targetMap = {
          Arch.arm64: "linux-arm64",
          Arch.amd64: "linux-x64",
        };
        final targets = [
          "deb",
          if (arch == Arch.amd64) "appimage",
          if (arch == Arch.amd64) "rpm",
        ].join(",");
        final defaultTarget = targetMap[arch];
        await _getLinuxDependencies(arch!);
        _buildDistributor(
          target: target,
          targets: targets,
          args:
              " --description $archName --build-target-platform $defaultTarget",
          env: env,
          extraDefines: extraDefines,
        );
        return;
      case Target.android:
        final targetMap = {
          Arch.arm: "android-arm",
          Arch.arm64: "android-arm64",
          Arch.amd64: "android-x64",
        };
        final defaultArches = [Arch.arm, Arch.arm64, Arch.amd64];
        final defaultTargets = defaultArches
            .where((element) => arch == null ? true : element == arch)
            .map((e) => targetMap[e])
            .toList();
        _buildDistributor(
          target: target,
          targets: "apk",
          args:
              ",split-per-abi --build-target-platform ${defaultTargets.join(",")}",
          env: env,
          extraDefines: extraDefines,
        );
        return;
      case Target.macos:
        await _getMacosDependencies();
        _buildDistributor(
          target: target,
          targets: "dmg",
          args: " --description $archName",
          env: env,
          extraDefines: extraDefines,
        );
        return;
    }
  }
}

main(args) async {
  final runner = CommandRunner("setup", "build Application");
  runner.addCommand(BuildCommand(target: Target.android));
  runner.addCommand(BuildCommand(target: Target.linux));
  runner.addCommand(BuildCommand(target: Target.windows));
  runner.addCommand(BuildCommand(target: Target.macos));
  runner.run(args);
}
