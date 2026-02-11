import 'dart:io';

import 'package:dio/dio.dart';
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
  static const String _downloadUrl =
      'https://github.com/Loyalsoldier/geoip/releases/latest/download/Country.mmdb';

  /// Maximum age before the file is considered stale (7 days).
  static const Duration _maxAge = Duration(days: 7);

  /// Ensure the MMDB file is available in [leafHomeDir].
  ///
  /// Copies from bundled asset if not present. Returns the absolute path.
  static Future<String> ensureAvailable(String leafHomeDir) async {
    final path = '$leafHomeDir${Platform.pathSeparator}$fileName';
    final file = File(path);

    if (await file.exists()) {
      return path;
    }

    // Copy from bundled asset
    _logger.info('Copying bundled $fileName to $leafHomeDir');
    try {
      final data = await rootBundle.load(_assetPath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
      _logger.info('Copied $fileName (${await file.length()} bytes)');
      return path;
    } catch (e) {
      _logger.error('Failed to copy bundled $fileName', e);
      rethrow;
    }
  }

  /// Download a fresh copy from GitHub, replacing any existing file.
  ///
  /// Uses DIRECT connection (no proxy) since the proxy may not be running.
  /// [onProgress] reports download progress as (received, total) bytes.
  static Future<String> download(
    String leafHomeDir, {
    void Function(int received, int total)? onProgress,
  }) async {
    final path = '$leafHomeDir${Platform.pathSeparator}$fileName';
    final tmpPath = '$path.tmp';

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
    ));
    // Force DIRECT — don't route through our own proxy
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        return HttpClient()..findProxy = (_) => 'DIRECT';
      },
    );

    try {
      _logger.info('Downloading $fileName from $_downloadUrl');
      await dio.download(
        _downloadUrl,
        tmpPath,
        onReceiveProgress: onProgress,
      );

      // Validate minimum file size (Country.mmdb is ~5MB)
      final tmpFile = File(tmpPath);
      final size = await tmpFile.length();
      if (size < 100 * 1024) {
        await tmpFile.delete();
        throw StateError('Downloaded file too small ($size bytes), likely corrupted');
      }

      // Atomically replace the old file
      await tmpFile.rename(path);
      _logger.info('Downloaded $fileName ($size bytes)');
      return path;
    } catch (e) {
      _logger.error('Failed to download $fileName', e);
      // Clean up temp file
      try {
        await File(tmpPath).delete();
      } catch (_) {}
      rethrow;
    } finally {
      dio.close();
    }
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
