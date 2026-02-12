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
      (Target.linux, Arch.amd64) => 'x86_64-unknown-linux-gnu',
      (Target.linux, Arch.arm64) => 'aarch64-unknown-linux-gnu',
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

  /// Download Country.mmdb from Loyalsoldier GitHub releases for leaf rule mode.
  ///
  /// Saves to assets/data/Country.mmdb to be bundled with the app.
  /// Skips download if file already exists and is less than 7 days old.
  /// Retries up to 3 times with different mirrors on failure.
  static Future<void> downloadCountryMmdb() async {
    final assetsDir = Directory(join(current, 'assets', 'data'));
    await assetsDir.create(recursive: true);

    final mmdbPath = join(assetsDir.path, 'Country.mmdb');
    final mmdbFile = File(mmdbPath);

    // Skip if file exists and is recent (< 7 days old)
    if (await mmdbFile.exists()) {
      final stat = await mmdbFile.stat();
      final size = stat.size;
      final age = DateTime.now().difference(stat.modified);
      if (age.inDays < 7 && size > 100 * 1024) {
        final sizeMb = (size / (1024 * 1024)).toStringAsFixed(2);
        print('Country.mmdb exists ($sizeMb MB, ${age.inDays} days old), skipping download');
        return;
      }
    }

    // Try multiple URLs: GitHub releases use 302 redirects to objects.githubusercontent.com
    // which can fail with basic HttpClient. Use explicit redirect following.
    const urls = [
      'https://github.com/Loyalsoldier/geoip/releases/latest/download/Country.mmdb',
      'https://raw.githubusercontent.com/Loyalsoldier/geoip/release/Country.mmdb',
    ];

    for (final url in urls) {
      print('Downloading Country.mmdb from $url...');
      try {
        final httpClient = HttpClient()
          ..connectionTimeout = const Duration(seconds: 30);
        // Follow redirects explicitly (GitHub releases do 302 → CDN)
        var request = await httpClient.getUrl(Uri.parse(url));
        request.followRedirects = true;
        request.maxRedirects = 5;
        var response = await request.close();

        // Manual redirect following as a fallback
        var redirectCount = 0;
        while ((response.statusCode == 301 ||
                response.statusCode == 302 ||
                response.statusCode == 307 ||
                response.statusCode == 308) &&
            redirectCount < 5) {
          final location = response.headers.value('location');
          if (location == null) break;
          await response.drain<void>();
          final redirectUrl = Uri.parse(location);
          request = await httpClient.getUrl(redirectUrl);
          request.followRedirects = true;
          request.maxRedirects = 5;
          response = await request.close();
          redirectCount++;
        }

        if (response.statusCode != 200) {
          await response.drain<void>();
          httpClient.close();
          throw 'HTTP ${response.statusCode}';
        }

        // Stream response to temp file first, then rename
        final tmpPath = '$mmdbPath.tmp';
        final tmpFile = File(tmpPath);
        final sink = tmpFile.openWrite();
        var totalBytes = 0;
        await for (final chunk in response) {
          sink.add(chunk);
          totalBytes += chunk.length;
        }
        await sink.close();
        httpClient.close();

        // Validate: Country.mmdb should be at least 1 MB
        if (totalBytes < 100 * 1024) {
          await tmpFile.delete();
          throw 'Downloaded file too small ($totalBytes bytes), likely an error page';
        }

        // Atomically replace
        if (await mmdbFile.exists()) {
          await mmdbFile.delete();
        }
        await tmpFile.rename(mmdbPath);

        final sizeMb = (totalBytes / (1024 * 1024)).toStringAsFixed(2);
        print('Downloaded Country.mmdb ($sizeMb MB) to ${assetsDir.path}');
        return; // Success — exit loop
      } catch (e) {
        print('Warning: Failed to download Country.mmdb from $url: $e');
        // Try next URL
      }
    }

    // All URLs failed
    if (await mmdbFile.exists() && (await mmdbFile.stat()).size > 100 * 1024) {
      print('Using existing Country.mmdb (download of fresh copy failed)');
    } else {
      print('ERROR: Country.mmdb is not available. Rule mode will not work!');
      print('Please manually download Country.mmdb to assets/data/');
      print('URL: https://github.com/Loyalsoldier/geoip/releases/latest/download/Country.mmdb');
      // Don't exit — let the build continue but warn loudly
    }
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

    // Write .cargo/config.toml for Android NDK cross-compilation
    if (target == Target.android) {
      await _writeAndroidCargoConfig();
    }

    try {
      for (final item in items) {
        final rustTarget = item.arch!.rustTarget(item.target);

        // Ensure Rust target is installed
        await exec(
          ['rustup', 'target', 'add', rustTarget],
          name: 'add rust target $rustTarget',
        );

        // Build with cargo
        await exec(
          [
            'cargo', 'build',
            '-p', 'leaf-ffi',
            '--release',
            '--target', rustTarget,
          ],
          name: 'build leaf-ffi ($rustTarget)',
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
    } finally {
      // Clean up .cargo/config.toml if we created it
      if (target == Target.android) {
        await _cleanupCargoConfig();
      }
    }

    return corePaths;
  }

  /// Resolve the NDK toolchain bin directory.
  static String _resolveNdkToolchainBin() {
    final ndk = Platform.environment['ANDROID_NDK'] ??
        Platform.environment['ANDROID_NDK_HOME'] ??
        Platform.environment['ANDROID_NDK_LATEST_HOME'] ??
        Platform.environment['NDK_HOME'];
    if (ndk == null || ndk.isEmpty) {
      throw 'ANDROID_NDK or NDK_HOME environment variable must be set';
    }

    final hostOs = Platform.isLinux ? 'linux' : (Platform.isMacOS ? 'darwin' : 'windows');
    final defaultBin = join(
      ndk, 'toolchains', 'llvm', 'prebuilt', '$hostOs-x86_64', 'bin',
    );

    if (Directory(defaultBin).existsSync()) {
      return defaultBin;
    }

    // Auto-detect host prebuilt directory
    final prebuiltDir = Directory(join(ndk, 'toolchains', 'llvm', 'prebuilt'));
    if (prebuiltDir.existsSync()) {
      final dirs = prebuiltDir.listSync()
          .whereType<Directory>()
          .where((d) => !basename(d.path).startsWith('.'))
          .toList();
      if (dirs.isNotEmpty) {
        return join(dirs.first.path, 'bin');
      }
    }

    throw 'Could not find NDK toolchain bin directory in $ndk';
  }

  /// Write .cargo/config.toml with Android NDK linker/compiler settings.
  ///
  /// This is more reliable than env vars for cross-compilation because
  /// Cargo reads it directly without depending on shell env propagation.
  static Future<void> _writeAndroidCargoConfig() async {
    final toolchainBin = _resolveNdkToolchainBin();
    print('NDK toolchain bin: $toolchainBin');

    // Derive sysroot from toolchain bin path (bin is <ndk>/toolchains/llvm/prebuilt/<host>/bin)
    final sysroot = Directory(join(toolchainBin, '..', 'sysroot'))
        .resolveSymbolicLinksSync()
        .replaceAll('\\', '/');
    print('NDK sysroot: $sysroot');

    final configDir = Directory(join(_leafFfiDir, '.cargo'));
    await configDir.create(recursive: true);

    final configPath = join(configDir.path, 'config.toml');

    // Use forward slashes for TOML paths (works on all platforms)
    final bin = toolchainBin.replaceAll('\\', '/');
    final api = _ndkApiLevel;

    final config = '''
# Auto-generated for Android NDK cross-compilation
[target.aarch64-linux-android]
linker = "$bin/aarch64-linux-android$api-clang"

[target.armv7-linux-androideabi]
linker = "$bin/armv7a-linux-androideabi$api-clang"

[target.x86_64-linux-android]
linker = "$bin/x86_64-linux-android$api-clang"

[env]
CC_aarch64-linux-android = "$bin/aarch64-linux-android$api-clang"
AR_aarch64-linux-android = "$bin/llvm-ar"
CC_armv7-linux-androideabi = "$bin/armv7a-linux-androideabi$api-clang"
AR_armv7-linux-androideabi = "$bin/llvm-ar"
CC_x86_64-linux-android = "$bin/x86_64-linux-android$api-clang"
AR_x86_64-linux-android = "$bin/llvm-ar"
BINDGEN_EXTRA_CLANG_ARGS_aarch64_linux_android = "--sysroot=$sysroot"
BINDGEN_EXTRA_CLANG_ARGS_armv7_linux_androideabi = "--sysroot=$sysroot"
BINDGEN_EXTRA_CLANG_ARGS_x86_64_linux_android = "--sysroot=$sysroot"
''';

    await File(configPath).writeAsString(config);
    print('Wrote $configPath');
  }

  /// Remove the auto-generated .cargo/config.toml.
  static Future<void> _cleanupCargoConfig() async {
    final configFile = File(join(_leafFfiDir, '.cargo', 'config.toml'));
    if (await configFile.exists()) {
      await configFile.delete();
      print('Cleaned up .cargo/config.toml');
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

    // Download Country.mmdb for leaf rule mode
    print('Downloading Country.mmdb for leaf rule mode...');
    await Build.downloadCountryMmdb();

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
