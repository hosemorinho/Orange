// ignore_for_file: avoid_print
/// Icon generation script for Orange
/// Downloads a PNG icon from URL and generates all platform-specific icons
///
/// Usage: dart scripts/generate_icons.dart <icon_url>
/// Or set APP_ICON_URL environment variable
///
/// Requires: ImageMagick (convert command)

import 'dart:io';
import 'package:path/path.dart' as path;

class IconGenerator {
  final String projectRoot;
  final String tempDir;
  late String _magickCmd;

  IconGenerator(this.projectRoot)
      : tempDir = path.join(projectRoot, '.icon_temp') {
    // On Windows, use 'magick' command; on other platforms, use 'convert'
    _magickCmd = Platform.isWindows ? 'magick' : 'convert';
  }

  /// Find ImageMagick executable on Windows
  Future<String?> _findImageMagickOnWindows() async {
    // Check Chocolatey bin path first (most likely on CI)
    final chocoPath = r'C:\ProgramData\chocolatey\bin\magick.exe';
    if (await File(chocoPath).exists()) {
      return chocoPath;
    }

    // Check common installation paths
    final programFiles = Platform.environment['ProgramFiles'] ?? r'C:\Program Files';
    final programFilesX86 = Platform.environment['ProgramFiles(x86)'] ?? r'C:\Program Files (x86)';

    for (final baseDir in [programFiles, programFilesX86]) {
      final dir = Directory(baseDir);
      if (!await dir.exists()) continue;

      try {
        await for (final entity in dir.list()) {
          if (entity is Directory && entity.path.contains('ImageMagick')) {
            final magickExe = File(path.join(entity.path, 'magick.exe'));
            if (await magickExe.exists()) {
              return magickExe.path;
            }
          }
        }
      } catch (e) {
        // Skip directories we can't access
        continue;
      }
    }

    // Also check Chocolatey lib path
    final chocoLibPath = r'C:\ProgramData\chocolatey\lib\imagemagick\tools';
    final chocoLibDir = Directory(chocoLibPath);
    if (await chocoLibDir.exists()) {
      try {
        await for (final entity in chocoLibDir.list(recursive: true)) {
          if (entity is File && entity.path.endsWith('magick.exe')) {
            return entity.path;
          }
        }
      } catch (_) {}
    }

    return null;
  }

  /// Icon sizes for each platform
  static const Map<String, List<int>> macOSSizes = {
    'app_icon': [16, 32, 64, 128, 256, 512, 1024],
  };

  static const Map<String, int> androidSizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  Future<void> run(String iconUrl) async {
    print('🎨 Starting icon generation...');
    print('📥 Icon URL: $iconUrl');

    // Create temp directory
    final tempDirectory = Directory(tempDir);
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
    await tempDirectory.create(recursive: true);

    try {
      // Download the source icon
      final sourcePath = path.join(tempDir, 'source.png');
      await _downloadIcon(iconUrl, sourcePath);

      // Verify source icon
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw 'Failed to download icon';
      }

      // Check ImageMagick is available
      await _checkImageMagick();

      // Generate icons for each platform
      await _generateWindowsIcons(sourcePath);
      await _generateMacOSIcons(sourcePath);
      await _generateAndroidIcons(sourcePath);
      await _generateAssetIcons(sourcePath);
      await _generateTrayIcons(sourcePath);

      print('✅ Icon generation complete!');
    } finally {
      // Cleanup temp directory
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    }
  }

  Future<void> _downloadIcon(String url, String outputPath) async {
    print('📥 Downloading icon...');
    final result = await Process.run('curl', ['-L', '-o', outputPath, url]);
    if (result.exitCode != 0) {
      throw 'Failed to download icon: ${result.stderr}';
    }
    print('✅ Downloaded source icon');
  }

  Future<void> _checkImageMagick() async {
    final checkCmd = Platform.isWindows ? 'where' : 'which';
    final result = await Process.run(checkCmd, [_magickCmd]);
    if (result.exitCode != 0) {
      // On Windows, try to find ImageMagick in common installation paths
      if (Platform.isWindows) {
        print('⚠️ magick not found in PATH, searching for ImageMagick installation...');
        final magickPath = await _findImageMagickOnWindows();
        if (magickPath != null) {
          print('✅ Found ImageMagick at: $magickPath');
          _magickCmd = magickPath;
          return;
        }
        print('❌ Could not find ImageMagick in common paths');
      }
      throw 'ImageMagick is not installed. Please install it first:\n'
          '  Ubuntu/Debian: sudo apt install imagemagick\n'
          '  macOS: brew install imagemagick\n'
          '  Windows: choco install imagemagick';
    } else {
      print('✅ Found ImageMagick command: $_magickCmd');
    }
  }

  Future<void> _exec(String command, List<String> args,
      {String? workingDirectory}) async {
    final result = await Process.run(
      command,
      args,
      workingDirectory: workingDirectory,
    );
    if (result.exitCode != 0) {
      print('Command failed: $command ${args.join(' ')}');
      print('stderr: ${result.stderr}');
      throw 'Command failed with exit code ${result.exitCode}';
    }
  }

  Future<void> _generateWindowsIcons(String sourcePath) async {
    print('🪟 Generating Windows icons...');

    // Windows app icon (256x256 ICO)
    final windowsIconPath =
        path.join(projectRoot, 'windows', 'runner', 'resources', 'app_icon.ico');

    // Ensure directory exists
    final windowsIconDir = Directory(path.dirname(windowsIconPath));
    if (!await windowsIconDir.exists()) {
      await windowsIconDir.create(recursive: true);
    }

    await _generateIco(sourcePath, windowsIconPath, 256);

    // Verify the icon was created
    final iconFile = File(windowsIconPath);
    if (await iconFile.exists()) {
      final size = await iconFile.length();
      print('✅ Windows icon created: $windowsIconPath ($size bytes)');
    } else {
      print('❌ Failed to create Windows icon at: $windowsIconPath');
    }

    print('✅ Windows icons generated');
  }

  Future<void> _generateMacOSIcons(String sourcePath) async {
    print('🍎 Generating macOS icons...');

    final macosIconDir = path.join(
      projectRoot,
      'macos',
      'Runner',
      'Assets.xcassets',
      'AppIcon.appiconset',
    );

    for (final size in macOSSizes['app_icon']!) {
      final outputPath = path.join(macosIconDir, 'app_icon_$size.png');
      await _resizePng(sourcePath, outputPath, size);
    }

    print('✅ macOS icons generated');
  }

  Future<void> _generateAndroidIcons(String sourcePath) async {
    print('🤖 Generating Android icons...');

    final androidResDir =
        path.join(projectRoot, 'android', 'app', 'src', 'main', 'res');

    // Remove adaptive icon files that override bitmap mipmap icons on API 26+
    // The anydpi-v26 qualifier has higher priority than density-specific mipmaps,
    // so the vector foreground would always be shown instead of the custom icon.
    await _removeAdaptiveIconFiles(androidResDir);

    // Generate Play Store icon (512x512)
    final playStorePath =
        path.join(projectRoot, 'android', 'app', 'src', 'main', 'ic_launcher-playstore.png');
    await _resizePng(sourcePath, playStorePath, 512);

    // Generate mipmap icons
    for (final entry in androidSizes.entries) {
      final density = entry.key;
      final size = entry.value;

      final mipmapDir = path.join(androidResDir, density);

      // Square icon
      final squarePath = path.join(mipmapDir, 'ic_launcher.webp');
      await _resizeWebp(sourcePath, squarePath, size);

      // Round icon (with circular mask)
      final roundPath = path.join(mipmapDir, 'ic_launcher_round.webp');
      await _generateRoundWebp(sourcePath, roundPath, size);
    }

    print('✅ Android icons generated');
  }

  /// Remove adaptive icon XML files and vector foreground so bitmap mipmaps take priority
  Future<void> _removeAdaptiveIconFiles(String androidResDir) async {
    final filesToRemove = [
      path.join(androidResDir, 'mipmap-anydpi-v26', 'ic_launcher.xml'),
      path.join(androidResDir, 'mipmap-anydpi-v26', 'ic_launcher_round.xml'),
      path.join(androidResDir, 'drawable', 'ic_launcher_foreground.xml'),
    ];

    for (final filePath in filesToRemove) {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('  🗑️ Removed $filePath');
      }
    }
  }

  Future<void> _generateAssetIcons(String sourcePath) async {
    print('📦 Generating asset icons...');

    final assetsDir = path.join(projectRoot, 'assets', 'images');

    // Main icon PNG (550x550)
    final mainPngPath = path.join(assetsDir, 'icon.png');
    await _resizePng(sourcePath, mainPngPath, 550);

    // Main icon ICO (256x256)
    final mainIcoPath = path.join(assetsDir, 'icon.ico');
    await _generateIco(sourcePath, mainIcoPath, 256);

    print('✅ Asset icons generated');
  }

  Future<void> _generateTrayIcons(String sourcePath) async {
    print('🔔 Generating tray icons...');

    final trayIconDir = path.join(projectRoot, 'assets', 'images', 'icon');

    // Tray icon size (typically 16-32 for Windows, 22 for macOS)
    const traySize = 32;

    // status_1: Default/stopped state - grayscale version
    final status1Png = path.join(trayIconDir, 'status_1.png');
    final status1Ico = path.join(trayIconDir, 'status_1.ico');
    await _generateGrayscalePng(sourcePath, status1Png, traySize);
    await _generateIco(status1Png, status1Ico, traySize);

    // status_2: Running without TUN - normal colored version
    final status2Png = path.join(trayIconDir, 'status_2.png');
    final status2Ico = path.join(trayIconDir, 'status_2.ico');
    await _resizePng(sourcePath, status2Png, traySize);
    await _generateIco(status2Png, status2Ico, traySize);

    // status_3: Running with TUN - slightly brighter/enhanced version
    final status3Png = path.join(trayIconDir, 'status_3.png');
    final status3Ico = path.join(trayIconDir, 'status_3.ico');
    await _generateEnhancedPng(sourcePath, status3Png, traySize);
    await _generateIco(status3Png, status3Ico, traySize);

    print('✅ Tray icons generated');
  }

  Future<void> _generateGrayscalePng(String input, String output, int size) async {
    await _exec(_magickCmd, [
      input,
      '-resize',
      '${size}x$size',
      '-background',
      'none',
      '-gravity',
      'center',
      '-extent',
      '${size}x$size',
      '-colorspace',
      'Gray',
      output,
    ]);
  }

  Future<void> _generateEnhancedPng(String input, String output, int size) async {
    await _exec(_magickCmd, [
      input,
      '-resize',
      '${size}x$size',
      '-background',
      'none',
      '-gravity',
      'center',
      '-extent',
      '${size}x$size',
      '-modulate',
      '110,120,100', // Slightly brighter and more saturated
      output,
    ]);
  }

  Future<void> _resizePng(String input, String output, int size) async {
    await _exec(_magickCmd, [
      input,
      '-resize',
      '${size}x$size',
      '-background',
      'none',
      '-gravity',
      'center',
      '-extent',
      '${size}x$size',
      output,
    ]);
  }

  Future<void> _resizeWebp(String input, String output, int size) async {
    await _exec(_magickCmd, [
      input,
      '-resize',
      '${size}x$size',
      '-background',
      'none',
      '-gravity',
      'center',
      '-extent',
      '${size}x$size',
      '-define',
      'webp:lossless=true',
      output,
    ]);
  }

  Future<void> _generateRoundWebp(String input, String output, int size) async {
    // Create a circular mask and apply it
    final maskPath = path.join(tempDir, 'mask_$size.png');

    // Create circular mask
    await _exec(_magickCmd, [
      '-size',
      '${size}x$size',
      'xc:none',
      '-fill',
      'white',
      '-draw',
      'circle ${size ~/ 2},${size ~/ 2} ${size ~/ 2},0',
      maskPath,
    ]);

    // Resize source and apply mask
    final resizedPath = path.join(tempDir, 'resized_$size.png');
    await _resizePng(input, resizedPath, size);

    // Apply circular mask
    await _exec(_magickCmd, [
      resizedPath,
      maskPath,
      '-alpha',
      'off',
      '-compose',
      'CopyOpacity',
      '-composite',
      '-define',
      'webp:lossless=true',
      output,
    ]);
  }

  Future<void> _generateIco(String input, String output, int size) async {
    // Generate ICO with multiple sizes embedded
    final sizes = [16, 32, 48, 64, 128, 256].where((s) => s <= size).toList();

    final tempPngs = <String>[];
    for (final s in sizes) {
      final tempPath = path.join(tempDir, 'ico_$s.png');
      await _resizePng(input, tempPath, s);
      tempPngs.add(tempPath);
    }

    await _exec(_magickCmd, [...tempPngs, output]);
  }
}

Future<void> main(List<String> args) async {
  String? iconUrl;

  if (args.isNotEmpty) {
    iconUrl = args[0];
  } else {
    iconUrl = Platform.environment['APP_ICON_URL'];
  }

  if (iconUrl == null || iconUrl.isEmpty) {
    print('Usage: dart scripts/generate_icons.dart <icon_url>');
    print('Or set APP_ICON_URL environment variable');
    exit(1);
  }

  final projectRoot = Directory.current.path;
  final generator = IconGenerator(projectRoot);

  try {
    await generator.run(iconUrl);
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
