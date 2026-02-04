import 'dart:io';

/// Check if a TCP port is available on localhost.
Future<bool> isPortAvailable(int port) async {
  try {
    final socket = await ServerSocket.bind(
      InternetAddress.loopbackIPv4,
      port,
    );
    await socket.close();
    return true;
  } catch (_) {
    return false;
  }
}

/// Find a free port. Tries [preferredPort] first, then lets the OS assign one.
Future<int> findAvailablePort(int preferredPort) async {
  if (await isPortAvailable(preferredPort)) {
    return preferredPort;
  }
  final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = socket.port;
  await socket.close();
  return port;
}
