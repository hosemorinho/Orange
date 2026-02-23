import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:fl_clash/core/interface.dart';

final _sessionIdRegex = RegExp(r'^[0-9a-f]{32}$');

/// Chunk size in raw bytes (48 KB). After base64 encoding each chunk
/// becomes ~65 KB, well under the Android Binder transaction limit.
const int _chunkSize = 48 * 1024;
const int _maxUploadRetryAttempts = 3;
const Duration _retryBaseDelay = Duration(milliseconds: 200);

/// Orchestrates a chunked config upload to the Go core via the
/// config session protocol.
class ConfigSessionUploader {
  final CoreHandlerInterface _core;

  const ConfigSessionUploader(this._core);

  /// Uploads [configBytes] to the Go core in chunks and returns the
  /// session ID on success.
  ///
  /// Returns `null` when the core does not support this protocol so the
  /// caller can fall back to file-based setup.
  Future<String?> upload(Uint8List configBytes) async {
    String? sessionId;
    try {
      sessionId = await _retry<String?>(
        operation: () => _core.beginConfigSession(),
        operationName: 'beginConfigSession',
      );
    } catch (_) {
      return null;
    }
    if (sessionId == null || !_sessionIdRegex.hasMatch(sessionId)) {
      return null;
    }

    final totalChunks = (configBytes.length + _chunkSize - 1) ~/ _chunkSize;
    for (var i = 0; i < totalChunks; i++) {
      final start = i * _chunkSize;
      final end = start + _chunkSize > configBytes.length
          ? configBytes.length
          : start + _chunkSize;
      final chunk = configBytes.sublist(start, end);
      final chunkBase64 = base64.encode(chunk);

      await _retry<void>(
        operation: () async {
          final ok = await _core.appendConfigChunk(
            sessionId: sessionId!,
            chunkBase64: chunkBase64,
            index: i,
          );
          if (!ok) {
            throw Exception('appendConfigChunk failed at index $i');
          }
        },
        operationName: 'appendConfigChunk#$i',
      );
    }

    final hashHex = sha256.convert(configBytes).toString();
    final committed = await _retry<bool>(
      operation: () =>
          _core.commitConfigSession(sessionId: sessionId!, sha256: hashHex),
      operationName: 'commitConfigSession',
    );
    if (!committed) {
      throw Exception('commitConfigSession failed');
    }

    return sessionId;
  }

  Future<T> _retry<T>({
    required Future<T> Function() operation,
    required String operationName,
  }) async {
    Object? lastError;
    for (var attempt = 1; attempt <= _maxUploadRetryAttempts; attempt++) {
      try {
        return await operation();
      } catch (e) {
        lastError = e;
        if (attempt >= _maxUploadRetryAttempts) {
          rethrow;
        }
        final delayMs = _retryBaseDelay.inMilliseconds * attempt;
        await Future<void>.delayed(Duration(milliseconds: delayMs));
      }
    }
    throw Exception('$operationName failed: $lastError');
  }
}
