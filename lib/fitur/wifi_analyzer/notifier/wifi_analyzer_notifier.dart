// path: lib/fitur/wifi_analyzer/notifier/wifi_analyzer_notifier.dart

import 'dart:async';
import 'dart:io';

import 'package:admin_wifi/fitur/wifi_analyzer/dummy/wifi_analyzer_dummy.dart';
import 'package:admin_wifi/fitur/wifi_analyzer/state/wifi_analyzer_state.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/core_shared.dart';
import 'package:wifi_scan/wifi_scan.dart';

part 'wifi_analyzer_notifier.g.dart';

@riverpod
class WifiAnalyzerNotifier extends _$WifiAnalyzerNotifier {
  final _networkInfo = NetworkInfo();

  // Cache hasil terakhir yang valid.
  String? _lastSsid;
  String? _lastBssid;
  String? _lastIp;
  List<WiFiAccessPoint> _lastScanResults = <WiFiAccessPoint>[];
  int? _lastTcpMs;

  // Error terbaru per sumber data.
  String? _connectionError;
  String? _scanError;
  String? _tcpError;

  // Waktu percobaan dan keberhasilan per sumber data.
  DateTime? _lastInfoAttemptAt;
  DateTime? _lastInfoAt;
  DateTime? _lastScanAttemptAt;
  DateTime? _lastScanAt;
  DateTime? _lastTcpAttemptAt;
  DateTime? _lastTcpAt;

  // Permintaan scan manual dari pengguna.
  bool _scanRequested = false;

  void pindaiUlang() {
    _scanRequested = true;
  }

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
        _lastSsid = info.ssid;
        _lastBssid = info.bssid;
        _lastIp = info.ip;
        _connectionError = null;
        _lastInfoAt = DateTime.now();
      } else {
        _connectionError = info.error;
      }

      final now = DateTime.now();
      final lastScanAttemptAt = _lastScanAttemptAt;
      final scanCooldownPassed =
          lastScanAttemptAt == null ||
          now.difference(lastScanAttemptAt) >= const Duration(seconds: 35);
      final scanDue =
          _scanRequested ||
          _lastScanAt == null ||
          now.difference(_lastScanAt!) >= const Duration(seconds: 35);

      if (scanDue && scanCooldownPassed) {
        _scanRequested = false;
        _lastScanAttemptAt = DateTime.now();
        final scan = await _pindaiSekitar();
        if (scan.error == null) {
          _lastScanResults = scan.accessPoints;
          _scanError = null;
          _lastScanAt = DateTime.now();
        } else {
          _scanError = scan.error;
        }
      }

      final lastTcpAttemptAt = _lastTcpAttemptAt;
      if (lastTcpAttemptAt == null ||
          now.difference(lastTcpAttemptAt) >= const Duration(seconds: 30)) {
        _lastTcpAttemptAt = DateTime.now();
        final tcp = await _ambilTcp();
        if (tcp.tcpError == null) {
          _lastTcpMs = tcp.tcpLatencyMs;
          _tcpError = null;
          _lastTcpAt = DateTime.now();
        } else {
          _tcpError = tcp.tcpError;
        }
      }

      yield WifiAnalyzerState(
        isLoading: false,
        connectionError: _connectionError,
        scanError: _scanError,
        tcpError: _tcpError,
        ssidTerhubung: _lastSsid,
        bssidTerhubung: _lastBssid,
        ipTerhubung: _lastIp,
        accessPoints: _lastScanResults,
        tcpLatencyMs: _lastTcpMs,
        lastInfoAt: _lastInfoAt,
        lastScanAt: _lastScanAt,
        lastTcpAt: _lastTcpAt,
        lastInfoAttemptAt: _lastInfoAttemptAt,
        lastScanAttemptAt: _lastScanAttemptAt,
        lastTcpAttemptAt: _lastTcpAttemptAt,
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

  Future<({List<WiFiAccessPoint> accessPoints, String? error})>
  _pindaiSekitar() async {
    StreamSubscription<List<WiFiAccessPoint>>? subscription;
    final completer = Completer<List<WiFiAccessPoint>>();

    try {
      final canGet = await WiFiScan.instance.canGetScannedResults();
      if (canGet != CanGetScannedResults.yes) {
        return (
          accessPoints: <WiFiAccessPoint>[],
          error: 'Tidak dapat membaca hasil scan: $canGet',
        );
      }

      final canScan = await WiFiScan.instance.canStartScan();
      if (canScan != CanStartScan.yes) {
        return (
          accessPoints: <WiFiAccessPoint>[],
          error: 'Tidak dapat memindai: $canScan',
        );
      }

      subscription = WiFiScan.instance.onScannedResultsAvailable.listen(
        (results) {
          if (!completer.isCompleted) {
            completer.complete(results);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(error, stackTrace);
          }
        },
      );

      final started = await WiFiScan.instance.startScan();
      if (!started) {
        return (
          accessPoints: <WiFiAccessPoint>[],
          error: 'Permintaan scan ditolak Android',
        );
      }

      final hasil = await completer.future.timeout(const Duration(seconds: 10));

      return (accessPoints: hasil, error: null);
    } on TimeoutException {
      return (
        accessPoints: <WiFiAccessPoint>[],
        error: 'Waktu menunggu hasil scan habis',
      );
    } catch (e, s) {
      L.e('Gagal memindai jaringan sekitar: $e $s');
      return (accessPoints: <WiFiAccessPoint>[], error: 'Gagal memindai: $e');
    } finally {
      await subscription?.cancel();
    }
  }

  Future<({int? tcpLatencyMs, String? tcpError})> _ambilTcp() async {
    try {
      final gateway = await _networkInfo.getWifiGatewayIP();
      if (gateway == null || gateway.trim().isEmpty) {
        return (tcpLatencyMs: null, tcpError: 'Gateway tidak ditemukan');
      }
      final ms = await _ujiTcpGateway(gateway.trim());
      if (ms != null) {
        return (tcpLatencyMs: ms, tcpError: null);
      }
      return (tcpLatencyMs: null, tcpError: 'Gagal TCP ke gateway');
    } catch (e, s) {
      L.e('Gagal menguji gateway: $e $s');
      return (tcpLatencyMs: null, tcpError: 'Gagal TCP: $e');
    }
  }

  Future<int?> _ujiTcpGateway(String host) async {
    for (final port in <int>[80, 443]) {
      try {
        final sw = Stopwatch()..start();
        final socket = await Socket.connect(
          host,
          port,
          timeout: const Duration(seconds: 1),
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
