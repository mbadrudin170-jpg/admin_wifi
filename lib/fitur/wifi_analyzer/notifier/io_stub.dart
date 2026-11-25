import 'dart:async';

/// Stub untuk target Web, tempat `dart:io` tidak tersedia.
class Platform {
  static Map<String, String> get environment => <String, String>{};
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static String get operatingSystem => 'web';
}

class InternetAddress {
  final String host;
  const InternetAddress(this.host);

  static InternetAddress get anyIPv4 => const InternetAddress('0.0.0.0');

  static InternetAddress parse(String address) => InternetAddress(address);
}

class Datagram {
  final List<int> data;
  Datagram(this.data);
}

class RawDatagramSocket {
  static Future<RawDatagramSocket> bind(
    InternetAddress address,
    int port, {
    bool reuseAddress = false,
    bool reusePort = false,
    int ttl = 1,
  }) async =>
      RawDatagramSocket();

  bool broadcastEnabled = false;

  void joinMulticast(InternetAddress address) {}

  int send(List<int> data, InternetAddress address, int port) => 0;

  Datagram? receive() => null;

  Future<void> close() async {}
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

class HttpClient {
  Duration? connectionTimeout;

  Future<HttpClientRequest> getUrl(Uri url) async => HttpClientRequest();

  void close({bool force = false}) {}
}

class HttpClientRequest {
  Future<HttpClientResponse> close() async => HttpClientResponse();

  Future<HttpClientResponse> get done async => HttpClientResponse();
}

class HttpClientResponse extends Stream<List<int>> {
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.empty().listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}