// path: lib/fitur/wifi_analyzer/notifier/wifi_analyzer_notifier.dart

import 'package:admin_wifi/fitur/wifi_analyzer/dummy/wifi_analyzer_dummy.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/state/wifi_analyzer_state.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/core_shared.dart';

part 'wifi_analyzer_notifier.g.dart';

@riverpod
class WifiAnalyzerNotifier extends _$WifiAnalyzerNotifier {
  final _networkInfo = NetworkInfo();

  // Cache hasil terakhir yang valid.
  String? _lastSsid;
  String? _lastBssid;
  String? _lastIp;

  // Error terbaru koneksi.
  String? _connectionError;

  // Waktu percobaan dan keberhasilan koneksi.
  DateTime? _lastInfoAttemptAt;
  DateTime? _lastInfoAt;

  @override
  Stream<WifiAnalyzerState> build() async* {
    while (true) {
      if (kIsWeb) {
        yield const WifiAnalyzerState(
          isLoading: false,
          connectionError:
              'WiFi Analyzer tidak didukung di Web. Gunakan perangkat Android.',
        );
        await Future.delayed(const Duration(seconds: 5));
        continue;
      }

      if (kDebugMode) {
        yield WifiAnalyzerDummy.dummyState;
        await Future.delayed(const Duration(seconds: 5));
        continue;
      }

      final infoAttemptAt = DateTime.now();
      _lastInfoAttemptAt = infoAttemptAt;
      final info = await _ambilInfoTerhubung();
      if (info.error == null) {
        if (info.ssid != null) _lastSsid = info.ssid;
        if (info.bssid != null) _lastBssid = info.bssid;
        if (info.ip != null) _lastIp = info.ip;
        _connectionError = null;
        _lastInfoAt = DateTime.now();
      } else {
        _connectionError = info.error;
      }

      yield WifiAnalyzerState(
        isLoading: false,
        connectionError: _connectionError,
        ssidTerhubung: _lastSsid,
        bssidTerhubung: _lastBssid,
        ipTerhubung: _lastIp,
        lastInfoAt: _lastInfoAt,
        lastInfoAttemptAt: _lastInfoAttemptAt,
      );

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<({String? ssid, String? bssid, String? ip, String? error})>
  _ambilInfoTerhubung() async {
    try {
      final ssid = await _networkInfo.getWifiName();
      final bssid = await _networkInfo.getWifiBSSID();
      final ip = await _networkInfo.getWifiIP();
      return (ssid: ssid, bssid: bssid, ip: ip, error: null);
    } catch (e, s) {
      L.e('Gagal mengambil info jaringan terhubung: $e $s');
      return (
        ssid: null,
        bssid: null,
        ip: null,
        error: 'Gagal memuat data: $e',
      );
    }
  }
}
