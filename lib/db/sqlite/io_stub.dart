// path: lib/db/sqlite/io_stub.dart

/// Stub untuk target Web, tempat `dart:io` tidak tersedia.
class Platform {
  static Map<String, String> get environment => <String, String>{};
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static String get operatingSystem => 'web';
}

class Directory {
  final String path;
  Directory(this.path);
}

class File {
  File(String path);
}

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
