// path: lib/fitur/wifi_analyzer/state/wifi_scan_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi_scan/wifi_scan.dart';

part 'wifi_scan_state.freezed.dart';

@freezed
abstract class WifiScanState with _$WifiScanState {
  const WifiScanState._();

  const factory WifiScanState({
    @Default(false) bool isLoading,
    String? scanError,
    @Default(<WiFiAccessPoint>[]) List<WiFiAccessPoint> accessPoints,
    DateTime? lastScanAt,
    DateTime? lastScanAttemptAt,
  }) = _WifiScanState;
}
