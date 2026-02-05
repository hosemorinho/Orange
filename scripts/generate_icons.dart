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

  IconGenerator(this.projectRoot)
      : tempDir = path.join(projectRoot, '.icon_temp');

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
    final result = await Process.run('which', ['convert']);
    if (result.exitCode != 0) {
      throw 'ImageMagick is not installed. Please install it first:\n'
          '  Ubuntu/Debian: sudo apt install imagemagick\n'
          '  macOS: brew install imagemagick\n'
          '  Windows: choco install imagemagick';
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
    await _generateIco(sourcePath, windowsIconPath, 256);

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

  Future<void> _resizePng(String input, String output, int size) async {
    await _exec('convert', [
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
    await _exec('convert', [
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
    await _exec('convert', [
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
    await _exec('convert', [
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

    await _exec('convert', [...tempPngs, output]);
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
