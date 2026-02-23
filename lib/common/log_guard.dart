import 'dart:async';

import 'package:fl_clash/xboard/core/logger/log_sanitizer.dart';
import 'package:flutter/foundation.dart';

bool _logMaskInstalled = false;

/// Installs a global debugPrint interceptor so all debugPrint output
/// is sanitized before it reaches console/logcat.
void installGlobalLogMasking() {
  if (_logMaskInstalled) return;
  _logMaskInstalled = true;
  final originalDebugPrint = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    final safeMessage = LogSanitizer.sanitize(message ?? '');
    originalDebugPrint(safeMessage, wrapWidth: wrapWidth);
  };
}

/// Runs [body] in a zone that sanitizes all `print(...)` output.
Future<void> runWithSanitizedPrintZone(Future<void> Function() body) async {
  await runZonedGuarded(
    body,
    (error, stackTrace) {
      final safeError = LogSanitizer.sanitize(error.toString());
      final safeStack = LogSanitizer.sanitize(stackTrace.toString());
      debugPrintSynchronously('[LogGuard] uncaught: $safeError');
      debugPrintSynchronously('[LogGuard] stack:\n$safeStack');
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        parent.print(zone, LogSanitizer.sanitize(line));
      },
    ),
  );
}
