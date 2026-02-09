/// Sanitizes error messages to remove sensitive network details (IPs, ports, hostnames, URLs).
///
/// Prevents infrastructure information leakage in user-facing error messages.
class ErrorSanitizer {
  // IPv4 address pattern (e.g., 192.168.1.1)
  static final _ipv4 = RegExp(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');

  // IPv6 address in brackets (e.g., [::1], [2001:db8::1])
  static final _ipv6Bracket = RegExp(r'\[[0-9a-fA-F:]+\]');

  // Full URL with scheme (e.g., https://api.example.com:443/path?query)
  static final _url = RegExp(r'https?://[^\s,\)]+');

  // address=... pattern from SocketException
  static final _addressParam = RegExp(r',?\s*address\s*=\s*[^\s,\)]+');

  // port=... pattern from SocketException
  static final _portParam = RegExp(r',?\s*port\s*=\s*\d+');

  // host:port pattern (e.g., example.com:443)
  static final _hostPort = RegExp(r'[a-zA-Z0-9][-a-zA-Z0-9.]*\.[a-zA-Z]{2,}:\d+');

  // Parenthesized network details left empty after stripping
  static final _emptyParens = RegExp(r'\s*\(\s*\)');

  // DioException prefix with type info
  static final _dioPrefix = RegExp(r'DioException\s*\[[^\]]*\]\s*:?\s*');

  // "Connection ... to <url>" pattern
  static final _connectionTo = RegExp(r'\s+to\s+https?://[^\s,\)]+');

  /// Strips sensitive network details from an error message.
  ///
  /// Examples:
  /// - `"SocketException: Connection refused (address=1.2.3.4, port=443)"` → `"Connection refused"`
  /// - `"DioException [connection timeout]: ... https://api.example.com:443/..."` → `"Connection timeout"`
  /// - `"Connection failed: https://secret.com:443/api/v1"` → `"Connection failed"`
  static String sanitize(String message) {
    var result = message;

    // Strip DioException prefix and simplify
    result = result.replaceAll(_dioPrefix, '');

    // Strip "to <url>" patterns (e.g., "Connection timed out to https://...")
    result = result.replaceAll(_connectionTo, '');

    // Strip full URLs
    result = result.replaceAll(_url, '***');

    // Strip address= and port= params
    result = result.replaceAll(_addressParam, '');
    result = result.replaceAll(_portParam, '');

    // Strip host:port
    result = result.replaceAll(_hostPort, '***');

    // Strip IPv4 and IPv6
    result = result.replaceAll(_ipv4, '***');
    result = result.replaceAll(_ipv6Bracket, '***');

    // Clean up empty parentheses left behind
    result = result.replaceAll(_emptyParens, '');

    // Clean up multiple consecutive *** or whitespace
    result = result.replaceAll(RegExp(r'(\*{3}\s*){2,}'), '*** ');

    // Clean up leading/trailing whitespace and colons
    result = result.trim();
    if (result.endsWith(':')) {
      result = result.substring(0, result.length - 1).trim();
    }

    // If the result is empty or only ***, return a generic message
    if (result.isEmpty || result == '***') {
      return 'Network error';
    }

    // Capitalize first letter
    if (result.isNotEmpty && result[0].toLowerCase() == result[0]) {
      result = result[0].toUpperCase() + result.substring(1);
    }

    return result;
  }
}
