// path: lib/fitur/wifi_analyzer/notifier/io_stub.dart

/// Stub untuk target Web, tempat `dart:io` tidak tersedia.
class Socket {
  static Future<Socket> connect(
    dynamic host,
    int port, {
    Duration? timeout,
  }) async =>
      Socket();

  Future<void> close() async {}
}

class SocketException implements Exception {
  final dynamic osError;
  SocketException([this.osError]);
}

class OSError {
  final int? errorCode;
  const OSError([this.errorCode]);
}
