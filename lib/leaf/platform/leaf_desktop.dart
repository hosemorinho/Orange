import 'dart:io';

import 'package:path/path.dart' as path;

/// Desktop-specific leaf library loading and path resolution.
class LeafDesktop {
  LeafDesktop._();

  /// Get the path to the libleaf shared library for the current platform.
  ///
  /// Searches in order:
  /// 1. Same directory as the running executable
  /// 2. `libleaf/` subdirectory relative to project root
  /// 3. System library path (DynamicLibrary.open will handle this)
  static String get libraryPath {
    final execDir = path.dirname(Platform.resolvedExecutable);

    if (Platform.isLinux) {
      final candidates = [
        path.join(execDir, 'lib', 'libleaf.so'),
        path.join(execDir, 'libleaf.so'),
      ];
      for (final p in candidates) {
        if (File(p).existsSync()) return p;
      }
      return 'libleaf.so'; // Fall back to system search
    }

    if (Platform.isMacOS) {
      final candidates = [
        path.join(execDir, '..', 'Frameworks', 'libleaf.dylib'),
        path.join(execDir, 'libleaf.dylib'),
      ];
      for (final p in candidates) {
        if (File(p).existsSync()) return p;
      }
      return 'libleaf.dylib';
    }

    if (Platform.isWindows) {
      final candidates = [
        path.join(execDir, 'leaf.dll'),
      ];
      for (final p in candidates) {
        if (File(p).existsSync()) return p;
      }
      return 'leaf.dll';
    }

    throw UnsupportedError('Unsupported desktop platform');
  }

  /// Get the default config directory for leaf on desktop.
  static String get configDir {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    return path.join(home, '.config', 'orange', 'leaf');
  }
}
