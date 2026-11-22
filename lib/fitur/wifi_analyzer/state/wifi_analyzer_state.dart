// path: lib/fitur/wifi_analyzer/state/wifi_analyzer_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi_scan/wifi_scan.dart';

part 'wifi_analyzer_state.freezed.dart';

@freezed
abstract class WifiAnalyzerState with _$WifiAnalyzerState {
  const WifiAnalyzerState._();

  const factory WifiAnalyzerState({
    @Default(false) bool isLoading,
    String? errorMessage,
    String? ssidTerhubung,
    String? bssidTerhubung,
    String? ipTerhubung,
    @Default(<WiFiAccessPoint>[]) List<WiFiAccessPoint> accessPoints,
  }) = _WifiAnalyzerState;
}
