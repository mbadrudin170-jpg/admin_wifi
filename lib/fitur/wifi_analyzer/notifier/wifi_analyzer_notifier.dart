// path: lib/fitur/wifi_analyzer/notifier/wifi_analyzer_notifier.dart

import 'package:admin_wifi/fitur/wifi_analyzer/dummy/wifi_analyzer_dummy.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/state/wifi_analyzer_state.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/core_shared.dart';
import 'package:wifi_scan/wifi_scan.dart';

part 'wifi_analyzer_notifier.g.dart';

@Riverpod(keepAlive: true)
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

    return WifiAnalyzerState(
      isLoading: false,
      errorMessage: errorMessage,
      ssidTerhubung: ssid,
      bssidTerhubung: bssid,
      ipTerhubung: ip,
      accessPoints: accessPoints,
    );
  }
}
