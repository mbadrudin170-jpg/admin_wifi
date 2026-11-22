// path: lib/fitur/wifi_analyzer/state/wifi_analyzer_state.dart

import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi_scan/wifi_scan.dart';

part 'wifi_analyzer_state.freezed.dart';

@freezed
abstract class WifiAnalyzerState with _$WifiAnalyzerState {
  const WifiAnalyzerState._();

  const factory WifiAnalyzerState({
    @Default(false) bool isLoading,
    String? connectionError,
    String? scanError,
    String? tcpError,
    String? ssidTerhubung,
    String? bssidTerhubung,
    String? ipTerhubung,
    @Default(<WiFiAccessPoint>[]) List<WiFiAccessPoint> accessPoints,
    int? tcpLatencyMs,
    DateTime? lastInfoAt,
    DateTime? lastScanAt,
    DateTime? lastTcpAt,
    DateTime? lastInfoAttemptAt,
    DateTime? lastScanAttemptAt,
    DateTime? lastTcpAttemptAt,
  }) = _WifiAnalyzerState;

  /// Frekuensi (MHz) jaringan yang sedang terhubung, 0 bila tidak ditemukan.
  int get frekuensiTerhubung {
    final bssid = bssidTerhubung;
    if (bssid == null) return 0;
    final ap = accessPoints.firstWhereOrNull(
      (a) => a.bssid.toLowerCase() == bssid.toLowerCase(),
    );
    return ap?.frequency ?? 0;
  }

  /// Sinyal (dBm) jaringan yang sedang terhubung, '-' bila tidak ditemukan.
  String get sinyalTerhubung {
    final bssid = bssidTerhubung;
    if (bssid == null) return '-';
    final ap = accessPoints.firstWhereOrNull(
      (a) => a.bssid.toLowerCase() == bssid.toLowerCase(),
    );
    return ap != null ? '${ap.level} dBm' : '-';
  }

  /// Level sinyal (dBm) jaringan terhubung, null bila tidak ditemukan.
  int? get levelTerhubung {
    final bssid = bssidTerhubung;
    if (bssid == null) return null;
    final ap = accessPoints.firstWhereOrNull(
      (a) => a.bssid.toLowerCase() == bssid.toLowerCase(),
    );
    return ap?.level;
  }
}
