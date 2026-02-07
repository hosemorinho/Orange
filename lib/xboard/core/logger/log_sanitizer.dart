/// Log sanitizer for masking sensitive information in log output.
///
/// Automatically masks URLs, emails, IP:port pairs, and bare domains
/// to prevent leaking panel infrastructure details in logs.
library;

/// Regex-based sanitizer that masks sensitive patterns in log strings.
class LogSanitizer {
  /// Toggle to disable sanitization for local debugging.
  static bool enabled = true;

  // Pre-compiled patterns for performance.

  /// Matches http:// or https:// URLs (greedy, stops at whitespace).
  static final _urlPattern = RegExp(r'https?://\S+');

  /// Matches email addresses.
  static final _emailPattern = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');

  /// Matches IPv4:port (e.g. 192.168.1.1:8080).
  static final _ipPortPattern = RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d+\b');

  /// Matches bare IPv4 addresses (without port).
  static final _ipPattern = RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b');

  /// Matches bare domain names with common TLDs.
  static final _domainPattern = RegExp(
    r'\b[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*'
    r'\.(com|net|org|io|dev|cn|cc|me|info|xyz|top|cloud|app|co)\b',
  );

  /// Sanitize a log message by masking sensitive patterns.
  static String sanitize(String message) {
    if (!enabled) return message;

    var result = message;

    // Order matters: URLs first (contain domains), then emails, IP:port, bare IPs, bare domains.
    result = result.replaceAllMapped(_urlPattern, (m) {
      final url = m.group(0)!;
      return url.startsWith('https') ? 'https://***' : 'http://***';
    });

    result = result.replaceAllMapped(_emailPattern, (m) {
      final email = m.group(0)!;
      return '${email[0]}***@***';
    });

    result = result.replaceAll(_ipPortPattern, '*.*.*.*:***');

    result = result.replaceAll(_ipPattern, '*.*.*.*');

    result = result.replaceAll(_domainPattern, '***.***');

    return result;
  }
}
