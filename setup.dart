// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';

enum Target { windows, linux, android, macos }

extension TargetExt on Target {
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
    return switch (this) {
      Target.android || Target.linux => '.so',
      Target.windows => '.dll',
      Target.macos => '.dylib',
    };
  }

  String get executableExtensionName {
    return switch (this) {
      Target.windows => '.exe',
      _ => '',
    };
  }

  /// The shared library filename for this platform.
  String get leafLibName {
    return switch (this) {
      Target.android || Target.linux => 'libleaf.so',
      Target.windows => 'leaf.dll',
      Target.macos => 'libleaf.dylib',
    };
  }
}

enum Arch { amd64, arm64, arm }

extension ArchExt on Arch {
  /// Returns the Rust target triple for the given platform + arch.
  String rustTarget(Target target) {
    return switch ((target, this)) {
      (Target.android, Arch.arm64) => 'aarch64-linux-android',
      (Target.android, Arch.arm) => 'armv7-linux-androideabi',
      (Target.android, Arch.amd64) => 'x86_64-linux-android',
      (Target.linux, Arch.amd64) => 'x86_64-unknown-linux-musl',
      (Target.linux, Arch.arm64) => 'aarch64-unknown-linux-musl',
      (Target.macos, Arch.arm64) => 'aarch64-apple-darwin',
      (Target.macos, Arch.amd64) => 'x86_64-apple-darwin',
      (Target.windows, Arch.amd64) => 'x86_64-pc-windows-msvc',
      (Target.windows, Arch.arm64) => 'aarch64-pc-windows-msvc',
      _ => throw 'Unsupported target/arch combination: $target/$this',
    };
  }
}

class BuildItem {
  Target target;
  Arch? arch;
  String? archName;

  BuildItem({required this.target, this.arch, this.archName});

  @override
  String toString() {
    return 'BuildItem{target: $target, arch: $arch, archName: $archName}';
  }
}

class Build {
  static List<BuildItem> get buildItems => [
    BuildItem(target: Target.macos, arch: Arch.arm64),
    BuildItem(target: Target.macos, arch: Arch.amd64),
    BuildItem(target: Target.linux, arch: Arch.arm64),
    BuildItem(target: Target.linux, arch: Arch.amd64),
    BuildItem(target: Target.windows, arch: Arch.amd64),
    BuildItem(target: Target.windows, arch: Arch.arm64),
    BuildItem(target: Target.android, arch: Arch.arm, archName: 'armeabi-v7a'),
    BuildItem(target: Target.android, arch: Arch.arm64, archName: 'arm64-v8a'),
    BuildItem(target: Target.android, arch: Arch.amd64, archName: 'x86_64'),
  ];

  static String get appName {
    final envName = (Platform.environment['APP_NAME'] ?? '').trim();
    return envName.isNotEmpty ? envName : 'Orange';
  }

  static String get outDir => join(current, 'libleaf');

  static String get _leafFfiDir => join(current, 'leaf');

  static String get _servicesDir => join(current, 'services', 'helper');

  static String get distPath => join(current, 'dist');

  static const int _ndkApiLevel = 21;

  static Future<void> exec(
    List<String> executable, {
    String? name,
    Map<String, String>? environment,
    String? workingDirectory,
    bool runInShell = true,
  }) async {
    if (name != null) print('run $name');
    print('exec: ${executable.join(' ')}');
    print('env: ${environment.toString()}');
    final process = await Process.start(
      executable[0],
      executable.sublist(1),
      environment: environment,
      workingDirectory: workingDirectory,
      runInShell: runInShell,
    );
    process.stdout.listen((data) {
      print(utf8.decode(data));
    });
    process.stderr.listen((data) {
      print(utf8.decode(data));
    });
    final exitCode = await process.exitCode;
    if (exitCode != 0 && name != null) throw '$name error';
  }

  static Future<String> calcSha256(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw 'File not exists';
    }
    final stream = file.openRead();
    return sha256.convert(await stream.reduce((a, b) => a + b)).toString();
  }

  /// Build the leaf-ffi Rust shared library for the given platform.
  static Future<List<String>> buildCore({
    required Target target,
    Arch? arch,
  }) async {
    final items = buildItems.where((element) {
      return element.target == target &&
          (arch == null ? true : element.arch == arch);
    }).toList();

    final List<String> corePaths = [];

    final targetOutFilePath = join(outDir, target.name);
    final dir = Directory(targetOutFilePath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    await dir.create(recursive: true);

    for (final item in items) {
      final rustTarget = item.arch!.rustTarget(item.target);

      // Ensure Rust target is installed
      await exec(
        ['rustup', 'target', 'add', rustTarget],
        name: 'add rust target $rustTarget',
      );

      // Set up environment for cross-compilation
      final Map<String, String> env = {};
      if (item.target == Target.android) {
        _setupAndroidNdkEnv(env, rustTarget, item.archName!);
      } else if (item.target == Target.linux) {
        _setupLinuxMuslEnv(env, rustTarget);
      }

      // Build with cargo
      await exec(
        [
          'cargo', 'build',
          '-p', 'leaf-ffi',
          '--release',
          '--target', rustTarget,
        ],
        name: 'build leaf-ffi ($rustTarget)',
        environment: env,
        workingDirectory: _leafFfiDir,
      );

      // Copy the built library to the output directory
      final builtLib = join(
        _leafFfiDir, 'target', rustTarget, 'release', target.leafLibName,
      );

      final String destPath;
      if (item.target == Target.android) {
        // Android: place in arch-specific subdirectory for jniLibs
        final archDir = join(targetOutFilePath, item.archName!);
        await Directory(archDir).create(recursive: true);
        destPath = join(archDir, target.leafLibName);
      } else {
        destPath = join(targetOutFilePath, target.leafLibName);
      }

      await File(builtLib).copy(destPath);
      corePaths.add(destPath);
      print('Copied $builtLib -> $destPath');
    }

    return corePaths;
  }

  /// Set up NDK environment variables for Rust Android cross-compilation.
  static void _setupAndroidNdkEnv(
    Map<String, String> env,
    String rustTarget,
    String archName,
  ) {
    final ndk = Platform.environment['ANDROID_NDK'] ??
        Platform.environment['NDK_HOME'] ??
        Platform.environment['ANDROID_NDK_HOME'];
    if (ndk == null || ndk.isEmpty) {
      throw 'ANDROID_NDK or NDK_HOME environment variable must be set';
    }

    final hostOs = Platform.isLinux ? 'linux' : (Platform.isMacOS ? 'darwin' : 'windows');
    final hostArch = 'x86_64'; // NDK prebuilt is x86_64
    final toolchainBin = join(
      ndk, 'toolchains', 'llvm', 'prebuilt', '$hostOs-$hostArch', 'bin',
    );

    // If the default x86_64 toolchain doesn't exist, try detecting the actual host arch
    if (!Directory(toolchainBin).existsSync()) {
      final altHostArch = Platform.localHostname; // fallback
      final altBin = join(
        ndk, 'toolchains', 'llvm', 'prebuilt',
      );
      final prebuiltDir = Directory(altBin);
      if (prebuiltDir.existsSync()) {
        final dirs = prebuiltDir.listSync()
            .whereType<Directory>()
            .where((d) => !basename(d.path).startsWith('.'))
            .toList();
        if (dirs.isNotEmpty) {
          final actualBin = join(dirs.first.path, 'bin');
          env['PATH'] = '$actualBin:${Platform.environment['PATH'] ?? ''}';
        }
      }
    } else {
      env['PATH'] = '$toolchainBin:${Platform.environment['PATH'] ?? ''}';
    }

    // Map Rust target to NDK clang/linker names
    final clangPrefix = switch (archName) {
      'armeabi-v7a' => 'armv7a-linux-androideabi$_ndkApiLevel',
      'arm64-v8a' => 'aarch64-linux-android$_ndkApiLevel',
      'x86_64' => 'x86_64-linux-android$_ndkApiLevel',
      _ => throw 'Unknown Android arch: $archName',
    };

    final envTarget = rustTarget.toUpperCase().replaceAll('-', '_');
    env['CC_$rustTarget'] = '$toolchainBin/$clangPrefix-clang';
    env['AR_$rustTarget'] = '$toolchainBin/llvm-ar';
    env['CARGO_TARGET_${envTarget}_LINKER'] = '$toolchainBin/$clangPrefix-clang';
    env['ANDROID_NDK_ROOT'] = ndk;
    env['ANDROID_NDK'] = ndk;
    env['ANDROID_NDK_HOME'] = ndk;
  }

  /// Set up environment variables for Rust Linux musl cross-compilation.
  static void _setupLinuxMuslEnv(
    Map<String, String> env,
    String rustTarget,
  ) {
    final envTarget = rustTarget.toUpperCase().replaceAll('-', '_');
    if (rustTarget.contains('aarch64')) {
      env['CC_$rustTarget'] = 'aarch64-linux-gnu-gcc';
      env['AR_$rustTarget'] = 'aarch64-linux-gnu-ar';
      env['CARGO_TARGET_${envTarget}_LINKER'] = 'aarch64-linux-gnu-gcc';
    } else {
      env['CC_$rustTarget'] = 'musl-gcc';
      env['AR_$rustTarget'] = 'ar';
      env['CARGO_TARGET_${envTarget}_LINKER'] = 'musl-gcc';
    }
  }

  static Future<void> buildHelper(Target target, String token) async {
    await exec(
      ['cargo', 'build', '--release', '--features', 'windows-service'],
      environment: {'TOKEN': token},
      name: 'build helper',
      workingDirectory: _servicesDir,
    );
    final outPath = join(
      _servicesDir,
      'target',
      'release',
      'helper${target.executableExtensionName}',
    );
    final targetPath = join(
      outDir,
      target.name,
      '${appName}HelperService${target.executableExtensionName}',
    );
    await File(outPath).copy(targetPath);
  }

  static List<String> getExecutable(String command) {
    return command.split(' ');
  }

  static Future<void> getDistributor() async {
    final distributorDir = join(
      current,
      'plugins',
      'flutter_distributor',
      'packages',
      'flutter_distributor',
    );

    await exec(
      name: 'clean distributor',
      Build.getExecutable('flutter clean'),
      workingDirectory: distributorDir,
    );
    await exec(
      name: 'upgrade distributor',
      Build.getExecutable('flutter pub upgrade'),
      workingDirectory: distributorDir,
    );
    await exec(
      name: 'get distributor',
      Build.getExecutable('dart pub global activate -s path $distributorDir'),
    );
  }

  static Future<void> _replaceInFile(
    String relativePath,
    Map<String, String> replacements,
  ) async {
    final file = File(join(current, relativePath));
    if (!await file.exists()) return;
    var content = await file.readAsString();
    for (final entry in replacements.entries) {
      content = content.replaceAll(entry.key, entry.value);
    }
    await file.writeAsString(content);
  }

  static Future<void> updatePlatformBinaryNames(Target target) async {
    final name = appName;
    if (name == 'Orange') return;

    final helper = '${name}HelperService';
    print('Updating platform binary names: app=$name helper=$helper');

    // distribute_options.yaml
    await _replaceInFile('distribute_options.yaml', {
      "app_name: 'Orange'": "app_name: '$name'",
    });

    switch (target) {
      case Target.windows:
        await _replaceInFile('windows/CMakeLists.txt', {
          'project(Orange ': 'project($name ',
          'set(BINARY_NAME "Orange")': 'set(BINARY_NAME "$name")',
          'OrangeHelperService.exe': '$helper.exe',
        });
        await _replaceInFile('windows/runner/main.cpp', {
          'L"Orange"': 'L"$name"',
        });
        await _replaceInFile('windows/runner/Runner.rc', {
          '"FileDescription", "Orange"': '"FileDescription", "$name"',
          '"InternalName", "Orange"': '"InternalName", "$name"',
          '"OriginalFilename", "Orange.exe"': '"OriginalFilename", "$name.exe"',
          '"ProductName", "Orange"': '"ProductName", "$name"',
        });
        await _replaceInFile('windows/packaging/exe/make_config.yaml', {
          'app_name: Orange': 'app_name: $name',
          'display_name: Orange': 'display_name: $name',
          'executable_name: Orange.exe': 'executable_name: $name.exe',
          'output_base_file_name: Orange.exe': 'output_base_file_name: $name.exe',
        });
        await _replaceInFile('windows/packaging/exe/inno_setup.iss', {
          "'Orange.exe'": "'$name.exe'",
          "'OrangeHelperService.exe'": "'$helper.exe'",
        });
        break;
      case Target.linux:
        await _replaceInFile('linux/CMakeLists.txt', {
          'set(BINARY_NAME "Orange")': 'set(BINARY_NAME "$name")',
        });
        await _replaceInFile('linux/runner/my_application.cc', {
          '"Orange"': '"$name"',
        });
        for (final pkg in ['appimage', 'deb', 'rpm']) {
          await _replaceInFile('linux/packaging/$pkg/make_config.yaml', {
            'display_name: Orange': 'display_name: $name',
            'package_name: Orange': 'package_name: $name',
            'generic_name: Orange': 'generic_name: $name',
            '  - Orange': '  - $name',
          });
        }
        break;
      case Target.macos:
        await _replaceInFile('macos/Runner/Configs/AppInfo.xcconfig', {
          'PRODUCT_NAME = Orange': 'PRODUCT_NAME = $name',
        });
        await _replaceInFile('macos/packaging/dmg/make_config.yaml', {
          'title: Orange': 'title: $name',
          'path: Orange.app': 'path: $name.app',
        });
        await _replaceInFile('macos/Runner.xcodeproj/project.pbxproj', {
          'Orange.app': '$name.app',
          'INFOPLIST_KEY_CFBundleDisplayName = Orange;':
              'INFOPLIST_KEY_CFBundleDisplayName = $name;',
        });
        await _replaceInFile(
          'macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme',
          {'Orange.app': '$name.app'},
        );
        break;
      case Target.android:
        break;
    }
    print('Platform binary names updated successfully');
  }

  static void copyFile(String sourceFilePath, String destinationFilePath) {
    final sourceFile = File(sourceFilePath);
    if (!sourceFile.existsSync()) {
      throw 'SourceFilePath not exists';
    }
    final destinationFile = File(destinationFilePath);
    final destinationDirectory = destinationFile.parent;
    if (!destinationDirectory.existsSync()) {
      destinationDirectory.createSync(recursive: true);
    }
    try {
      sourceFile.copySync(destinationFilePath);
      print('File copied successfully!');
    } catch (e) {
      print('Failed to copy file: $e');
    }
  }
}

class BuildCommand extends Command {
  Target target;

  BuildCommand({required this.target}) {
    if (target == Target.android || target == Target.linux) {
      argParser.addOption(
        'arch',
        valueHelp: arches.map((e) => e.name).join(','),
        help: 'The $name build desc',
      );
    } else {
      argParser.addOption('arch', help: 'The $name build archName');
    }
    argParser.addOption(
      'out',
      valueHelp: [if (target.same) 'app', 'core'].join(','),
      help: 'The $name build arch',
    );
    argParser.addOption(
      'env',
      valueHelp: ['pre', 'stable'].join(','),
      help: 'The $name build env',
    );
  }

  @override
  String get description => 'build $name application';

  @override
  String get name => target.name;

  List<Arch> get arches => Build.buildItems
      .where((element) => element.target == target && element.arch != null)
      .map((e) => e.arch!)
      .toList();

  Future<void> _buildEnvFile(String env, {String? coreSha256}) async {
    final apiBaseUrl = (Platform.environment['API_BASE_URL'] ?? '').trim();
    final apiTextDomain = (Platform.environment['API_TEXT_DOMAIN'] ?? '').trim();
    final appName = (Platform.environment['APP_NAME'] ?? '').trim();
    final appPackageName = (Platform.environment['APP_PACKAGE_NAME'] ?? '').trim();
    final refactorAndroidPackage =
        (Platform.environment['REFACTOR_ANDROID_PACKAGE'] ?? '').trim().toLowerCase();
    final shouldExposePackageNameToDart =
        target == Target.android && refactorAndroidPackage == 'true';
    final themeColor = (Platform.environment['THEME_COLOR'] ?? '').trim();
    final crispWebsiteId = (Platform.environment['CRISP_WEBSITE_ID'] ?? '').trim();

    final data = {
      'APP_ENV': env,
      if (coreSha256 != null) 'CORE_SHA256': coreSha256,
      if (apiBaseUrl.isNotEmpty) 'API_BASE_URL': apiBaseUrl,
      if (apiTextDomain.isNotEmpty) 'API_TEXT_DOMAIN': apiTextDomain,
      if (appName.isNotEmpty) 'APP_NAME': appName,
      if (appPackageName.isNotEmpty && shouldExposePackageNameToDart)
        'APP_PACKAGE_NAME': appPackageName,
      if (themeColor.isNotEmpty) 'THEME_COLOR': themeColor,
      if (crispWebsiteId.isNotEmpty) 'CRISP_WEBSITE_ID': crispWebsiteId,
    };
    final envFile = File(join(current, 'env.json'))..create();
    await envFile.writeAsString(json.encode(data));
  }

  Future<void> _getLinuxDependencies(Arch arch) async {
    await Build.exec(Build.getExecutable('sudo apt update -y'));
    await Build.exec(
      Build.getExecutable('sudo apt install -y ninja-build libgtk-3-dev'),
    );
    await Build.exec(
      Build.getExecutable('sudo apt install -y libayatana-appindicator3-dev'),
    );
    await Build.exec(
      Build.getExecutable('sudo apt-get install -y libkeybinder-3.0-dev'),
    );
    await Build.exec(Build.getExecutable('sudo apt install -y locate'));
    if (arch == Arch.amd64) {
      await Build.exec(Build.getExecutable('sudo apt install -y rpm patchelf'));
      await Build.exec(Build.getExecutable('sudo apt install -y libfuse2'));

      final downloadName = arch == Arch.amd64 ? 'x86_64' : 'aarch64';
      await Build.exec(
        Build.getExecutable(
          'wget -O appimagetool https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$downloadName.AppImage',
        ),
      );
      await Build.exec(Build.getExecutable('chmod +x appimagetool'));
      await Build.exec(
        Build.getExecutable('sudo mv appimagetool /usr/local/bin/'),
      );
    }
  }

  Future<void> _getMacosDependencies() async {
    await Build.exec(Build.getExecutable('npm install -g appdmg'));
  }

  Future<void> _buildDistributor({
    required Target target,
    required String targets,
    String args = '',
    required String env,
  }) async {
    await Build.getDistributor();
    await Build.exec(
      name: name,
      Build.getExecutable(
        'flutter_distributor package --skip-clean --platform ${target.name} --targets $targets --flutter-build-args=verbose,dart-define-from-file=env.json$args',
      ),
    );
  }

  Future<String?> get systemArch async {
    if (Platform.isWindows) {
      return Platform.environment['PROCESSOR_ARCHITECTURE'];
    } else if (Platform.isLinux || Platform.isMacOS) {
      final result = await Process.run('uname', ['-m']);
      return result.stdout.toString().trim();
    }
    return null;
  }

  @override
  Future<void> run() async {
    final String out = argResults?['out'] ?? (target.same ? 'app' : 'core');
    final archName = argResults?['arch'];
    final env = argResults?['env'] ?? 'pre';
    final currentArches = arches
        .where((element) => element.name == archName)
        .toList();
    final arch = currentArches.isEmpty ? null : currentArches.first;

    if (arch == null && target != Target.android) {
      throw 'Invalid arch parameter';
    }

    await Build.updatePlatformBinaryNames(target);

    final corePaths = await Build.buildCore(
      target: target,
      arch: arch,
    );

    String? coreSha256;

    if (Platform.isWindows) {
      coreSha256 = await Build.calcSha256(corePaths.first);
      await Build.buildHelper(target, coreSha256);
    }
    await _buildEnvFile(env, coreSha256: coreSha256);

    // Generate custom icons if APP_ICON_URL is set
    final appIconUrl = (Platform.environment['APP_ICON_URL'] ?? '').trim();
    if (appIconUrl.isNotEmpty) {
      print('APP_ICON_URL detected, generating icons...');
      await Build.exec(
        name: 'generate icons',
        Build.getExecutable('dart scripts/generate_icons.dart $appIconUrl'),
      );
    }

    if (out != 'app') {
      return;
    }

    switch (target) {
      case Target.windows:
        _buildDistributor(
          target: target,
          targets: 'exe,zip',
          args: ' --description $archName',
          env: env,
        );
        return;
      case Target.linux:
        final targetMap = {Arch.arm64: 'linux-arm64', Arch.amd64: 'linux-x64'};
        final targets = [
          'deb',
          if (arch == Arch.amd64) 'appimage',
          if (arch == Arch.amd64) 'rpm',
        ].join(',');
        final defaultTarget = targetMap[arch];
        await _getLinuxDependencies(arch!);
        _buildDistributor(
          target: target,
          targets: targets,
          args:
              ' --description $archName --build-target-platform $defaultTarget',
          env: env,
        );
        return;
      case Target.android:
        final targetMap = {
          Arch.arm: 'android-arm',
          Arch.arm64: 'android-arm64',
          Arch.amd64: 'android-x64',
        };
        final defaultArches = [Arch.arm, Arch.arm64, Arch.amd64];
        final defaultTargets = defaultArches
            .where((element) => arch == null ? true : element == arch)
            .map((e) => targetMap[e])
            .toList();
        _buildDistributor(
          target: target,
          targets: 'apk',
          args:
              ",split-per-abi --build-target-platform ${defaultTargets.join(",")}",
          env: env,
        );
        return;
      case Target.macos:
        await _getMacosDependencies();
        _buildDistributor(
          target: target,
          targets: 'dmg',
          args: ' --description $archName',
          env: env,
        );
        return;
    }
  }
}

Future<void> main(Iterable<String> args) async {
  final runner = CommandRunner('setup', 'build Application');
  runner.addCommand(BuildCommand(target: Target.android));
  runner.addCommand(BuildCommand(target: Target.linux));
  runner.addCommand(BuildCommand(target: Target.windows));
  runner.addCommand(BuildCommand(target: Target.macos));
  runner.run(args);
}
