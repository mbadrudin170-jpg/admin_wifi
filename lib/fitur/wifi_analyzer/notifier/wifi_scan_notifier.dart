// path: lib/fitur/wifi_analyzer/notifier/wifi_scan_notifier.dart

import 'dart:async';

import 'package:admin_wifi/fitur/wifi_analyzer/state/wifi_scan_state.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  void pindaiUlang() {
    _scanRequested = true;
  }

  @override
  Stream<WifiScanState> build() async* {
    while (true) {
      if (kIsWeb) {
        yield const WifiScanState(
          isLoading: false,
          scanError:
              'Scan WiFi sekitar tidak didukung di Web. Gunakan perangkat Android.',
        );
        await Future.delayed(const Duration(seconds: 5));
        continue;
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
}
