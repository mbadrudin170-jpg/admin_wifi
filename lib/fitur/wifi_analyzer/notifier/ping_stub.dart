// path: lib/fitur/wifi_analyzer/notifier/ping_stub.dart

/// Stub untuk target Web, tempat `dart_ping` tidak tersedia.
class Ping {
  Ping(dynamic host, {int count = 1, int timeout = 2});

  Stream<dynamic> get stream => const Stream.empty();
}

class PingResponse {
  Duration? time;
}
