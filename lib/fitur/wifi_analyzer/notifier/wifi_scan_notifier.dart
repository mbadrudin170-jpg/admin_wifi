// path: lib/fitur/wifi_analyzer/notifier/wifi_scan_notifier.dart

import 'dart:async';

import 'package:admin_wifi/fitur/wifi_analyzer/state/wifi_scan_state.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/core_shared.dart';
import 'package:wifi_scan/wifi_scan.dart';

part 'wifi_scan_notifier.g.dart';

@riverpod
class WifiScanNotifier extends _$WifiScanNotifier {
  // Cache hasil terakhir yang valid.
  List<WiFiAccessPoint> _lastScanResults = <WiFiAccessPoint>[];

  // Error terbaru scan.
  String? _scanError;

  // Waktu percobaan dan keberhasilan scan.
  DateTime? _lastScanAttemptAt;
  DateTime? _lastScanAt;

  // Permintaan scan manual dari pengguna.
  bool _scanRequested = false;
  Completer<void>? _pendingScanCompleter;

  Future<void> pindaiUlang() {
    _scanRequested = true;
    _pendingScanCompleter ??= Completer<void>();
    return _pendingScanCompleter!.future;
  }

  @override
  Stream<WifiScanState> build() async* {
    while (true) {
      if (kIsWeb) {
        _pendingScanCompleter?.complete();
        _pendingScanCompleter = null;
        yield const WifiScanState(
          isLoading: false,
          scanError: 'Scan WiFi sekitar tidak didukung di Web. Gunakan perangkat Android.',
        );
        await Future.delayed(const Duration(seconds: 5));
        continue;
      }

      final now = DateTime.now();
      final lastScanAttemptAt = _lastScanAttemptAt;
      final scanCooldownPassed =
          lastScanAttemptAt == null ||
          now.difference(lastScanAttemptAt) >= const Duration(seconds: 35);
      final manualRequest = _scanRequested;
      final lastScanAt = _lastScanAt;
      final bool scanDue;
      if (manualRequest || lastScanAt == null) {
        scanDue = true;
      } else {
        scanDue = now.difference(lastScanAt) >= const Duration(seconds: 35);
      }

      if (scanDue && scanCooldownPassed) {
        _scanRequested = false;
        _lastScanAttemptAt = DateTime.now();
        yield WifiScanState(
          isLoading: true,
          scanError: _scanError,
          accessPoints: _lastScanResults,
          lastScanAt: _lastScanAt,
          lastScanAttemptAt: _lastScanAttemptAt,
        );
        final scan = await _pindaiSekitar();
        if (scan.error == null) {
          _lastScanResults = scan.accessPoints;
          _scanError = null;
          _lastScanAt = DateTime.now();
        } else {
          _scanError = scan.error;
        }
        _pendingScanCompleter?.complete();
        _pendingScanCompleter = null;
      } else if (manualRequest) {
        _scanRequested = false;
        _pendingScanCompleter?.complete();
        _pendingScanCompleter = null;
      }

      yield WifiScanState(
        isLoading: false,
        scanError: _scanError,
        accessPoints: _lastScanResults,
        lastScanAt: _lastScanAt,
        lastScanAttemptAt: _lastScanAttemptAt,
      );

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<({List<WiFiAccessPoint> accessPoints, String? error})>
  _pindaiSekitar() async {
    StreamSubscription<List<WiFiAccessPoint>>? subscription;
    final completer = Completer<List<WiFiAccessPoint>>();

    try {
      if (!kIsWeb) {
        final serviceStatus = await Permission.location.serviceStatus;
        if (serviceStatus != ServiceStatus.enabled) {
          return (
            accessPoints: <WiFiAccessPoint>[],
            error: 'Aktifkan layanan lokasi untuk memindai WiFi.',
          );
        }
        final status = await Permission.location.request();
        if (!status.isGranted) {
          return (
            accessPoints: <WiFiAccessPoint>[],
            error: 'Izin lokasi diperlukan untuk memindai WiFi.',
          );
        }
      }

      final canGet = await WiFiScan.instance.canGetScannedResults(
        askPermissions: true,
      );
      if (canGet != CanGetScannedResults.yes) {
        return (
          accessPoints: <WiFiAccessPoint>[],
          error: 'Tidak dapat membaca hasil scan: $canGet',
        );
      }

      final canScan = await WiFiScan.instance.canStartScan(
        askPermissions: true,
      );
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
          error: 'Pemindaian ditolak sistem Android (batas scan). Coba lagi nanti.',
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
}
