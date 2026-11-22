// path: lib/fitur/wifi_analyzer/notifier/wifi_analyzer_notifier.dart

import 'package:admin_wifi/fitur/wifi_analyzer/dummy/wifi_analyzer_dummy.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/state/wifi_analyzer_state.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/core_shared.dart';
import 'package:wifi_scan/wifi_scan.dart';

part 'wifi_analyzer_notifier.g.dart';

@riverpod
class WifiAnalyzerNotifier extends _$WifiAnalyzerNotifier {
  final _networkInfo = NetworkInfo();

  @override
  Stream<WifiAnalyzerState> build() async* {
    yield await _ambilData();
    await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
      yield await _ambilData();
    }
  }

  Future<WifiAnalyzerState> _ambilData() async {
    if (kDebugMode) {
      return WifiAnalyzerDummy.dummyState;
    }

    if (kIsWeb) {
      return const WifiAnalyzerState(
        isLoading: false,
        errorMessage:
            'WiFi Analyzer tidak didukung di Web. Gunakan perangkat Android.',
      );
    }

    String? ssid;
    String? bssid;
    String? ip;
    List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
    String? errorMessage;
    int? pingMs;
    String? pingError;

    try {
      ssid = await _networkInfo.getWifiName();
      bssid = await _networkInfo.getWifiBSSID();
      ip = await _networkInfo.getWifiIP();

      final canScan = await WiFiScan.instance.canStartScan();
      if (canScan == CanStartScan.yes) {
        await WiFiScan.instance.startScan();
      }
      final canGet = await WiFiScan.instance.canGetScannedResults();
      if (canGet == CanGetScannedResults.yes) {
        accessPoints = await WiFiScan.instance.getScannedResults();
      } else {
        errorMessage = 'Tidak dapat membaca hasil pemindaian: $canGet';
      }
    } catch (e, s) {
      L.e('Gagal memuat data WiFi analyzer: $e $s');
      errorMessage = 'Gagal memuat data: $e';
    }

    // Ping ke gateway/router.
    try {
      final gateway = await _networkInfo.getWifiGatewayIP();
      if (gateway != null && gateway.trim().isNotEmpty) {
        final ms = await _pingGateway(gateway.trim());
        if (ms != null) {
          pingMs = ms;
        } else {
          pingError = 'Gagal ping gateway';
        }
      } else {
        pingError = 'Gateway tidak ditemukan';
      }
    } catch (e, s) {
      L.e('Gagal ping gateway: $e $s');
      pingError = 'Gagal ping: $e';
    }

    return WifiAnalyzerState(
      isLoading: false,
      errorMessage: errorMessage,
      ssidTerhubung: ssid,
      bssidTerhubung: bssid,
      ipTerhubung: ip,
      accessPoints: accessPoints,
      pingMs: pingMs,
      pingError: pingError,
    );
  }

  Future<int?> _pingGateway(String host) async {
    for (final port in <int>[80, 443]) {
      try {
        final sw = Stopwatch()..start();
        final socket = await Socket.connect(
          host,
          port,
          timeout: const Duration(seconds: 2),
        );
        sw.stop();
        socket.destroy();
        return sw.elapsedMilliseconds;
      } catch (_) {
        continue;
      }
    }
    return null;
  }
}
