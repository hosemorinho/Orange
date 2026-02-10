/// Error codes returned by leaf FFI functions.
/// These map 1:1 to the C constants in leaf-ffi/src/lib.rs.
class LeafError {
  LeafError._();

  static const int ok = 0;
  static const int configPath = 1;
  static const int config = 2;
  static const int io = 3;
  static const int watcher = 4;
  static const int asyncChannelSend = 5;
  static const int syncChannelRecv = 6;
  static const int runtimeManager = 7;
  static const int noConfigFile = 8;
  static const int noData = 9;

  static String message(int code) {
    return switch (code) {
      0 => 'OK',
      1 => 'Invalid config path',
      2 => 'Config parsing error',
      3 => 'IO error',
      4 => 'Config watcher error',
      5 => 'Async channel send error',
      6 => 'Sync channel receive error',
      7 => 'Runtime manager not found',
      8 => 'No config file associated',
      9 => 'No data found',
      _ => 'Unknown error ($code)',
    };
  }

  static bool isOk(int code) => code == ok;

  /// For buffer-returning functions, negative means "buffer too small,
  /// need -returnValue bytes".
  static bool isBufferTooSmall(int code) => code < 0;
}
