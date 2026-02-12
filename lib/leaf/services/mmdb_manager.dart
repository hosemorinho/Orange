import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fl_clash/xboard/core/logger/file_logger.dart';
import 'package:flutter/services.dart';

final _logger = FileLogger('mmdb_manager.dart');

/// Manages the Country.mmdb GeoIP database for leaf rule-mode routing.
///
/// The MMDB file is bundled as a Flutter asset (downloaded at build time by
/// setup.dart) and copied to the leaf home directory on first use.
/// Users can re-download from GitHub via [download] for manual updates.
class MmdbManager {
  MmdbManager._();

  static const String fileName = 'Country.mmdb';
  static const String _assetPath = 'assets/data/$fileName';

  /// Maximum age before the file is considered stale (7 days).
  static const Duration _maxAge = Duration(days: 7);

  /// Ensure the MMDB file is available in [leafHomeDir].
  ///
  /// 1. Returns immediately if the file already exists on disk.
  /// 2. Tries to copy from bundled Flutter asset.
  /// 3. Falls back to downloading from GitHub if the asset is missing.
  static Future<String> ensureAvailable(String leafHomeDir) async {
    final path = '$leafHomeDir${Platform.pathSeparator}$fileName';
    final file = File(path);

    if (await file.exists() && (await file.stat()).size > 100 * 1024) {
      return path;
    }

    // Try copying from bundled asset first
    try {
      _logger.info('Copying bundled $fileName to $leafHomeDir');
      final data = await rootBundle.load(_assetPath);
      if (data.lengthInBytes > 100 * 1024) {
        await file.parent.create(recursive: true);
        await file.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          flush: true,
        );
        _logger.info('Copied $fileName (${await file.length()} bytes)');
        return path;
      } else {
        _logger.warning('Bundled $fileName too small (${data.lengthInBytes} bytes), likely placeholder');
      }
    } catch (e) {
      _logger.warning('Bundled $fileName not available: $e');
    }

    // Bundled asset missing or invalid — download from GitHub
    _logger.info('Downloading $fileName from GitHub as fallback...');
    try {
      return await download(leafHomeDir);
    } catch (e) {
      _logger.error('Failed to download $fileName', e);
      rethrow;
    }
  }

  /// Download URLs — primary GitHub releases + raw fallback.
  static const List<String> _downloadUrls = [
    'https://github.com/Loyalsoldier/geoip/releases/latest/download/Country.mmdb',
    'https://raw.githubusercontent.com/Loyalsoldier/geoip/release/Country.mmdb',
  ];

  /// Download a fresh copy from GitHub, replacing any existing file.
  ///
  /// Uses DIRECT connection (no proxy) since the proxy may not be running.
  /// Tries multiple URLs with redirect handling.
  /// [onProgress] reports download progress as (received, total) bytes.
  static Future<String> download(
    String leafHomeDir, {
    void Function(int received, int total)? onProgress,
  }) async {
    final path = '$leafHomeDir${Platform.pathSeparator}$fileName';
    final tmpPath = '$path.tmp';

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
      followRedirects: true,
      maxRedirects: 5,
    ));
    // Force DIRECT — don't route through our own proxy
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        return HttpClient()..findProxy = (_) => 'DIRECT';
      },
    );

    Object? lastError;
    for (final url in _downloadUrls) {
      try {
        _logger.info('Downloading $fileName from $url');
        await dio.download(
          url,
          tmpPath,
          onReceiveProgress: onProgress,
        );

        // Validate minimum file size (Country.mmdb is ~5MB)
        final tmpFile = File(tmpPath);
        final size = await tmpFile.length();
        if (size < 100 * 1024) {
          await tmpFile.delete();
          throw StateError('Downloaded file too small ($size bytes), likely an error page');
        }

        // Atomically replace the old file
        final destFile = File(path);
        if (await destFile.exists()) {
          await destFile.delete();
        }
        await tmpFile.rename(path);
        _logger.info('Downloaded $fileName ($size bytes) from $url');
        return path;
      } catch (e) {
        _logger.warning('Failed to download from $url: $e');
        lastError = e;
        // Clean up temp file
        try {
          await File(tmpPath).delete();
        } catch (_) {}
        // Try next URL
      }
    }

    dio.close();
    throw StateError('All download URLs failed for $fileName: $lastError');
  }

  /// Check if the MMDB file exists and return its info.
  static Future<({bool exists, int size, DateTime? lastModified, bool stale})>
      getFileInfo(String leafHomeDir) async {
    final path = '$leafHomeDir${Platform.pathSeparator}$fileName';
    final file = File(path);
    if (!await file.exists()) {
      return (exists: false, size: 0, lastModified: null, stale: true);
    }
    final stat = await file.stat();
    final age = DateTime.now().difference(stat.modified);
    return (
      exists: true,
      size: stat.size,
      lastModified: stat.modified,
      stale: age > _maxAge,
    );
  }
}
