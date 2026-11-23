// path: lib/fitur/wifi_analyzer/state/wifi_analyzer_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'wifi_analyzer_state.freezed.dart';

@freezed
abstract class WifiAnalyzerState with _$WifiAnalyzerState {
  const WifiAnalyzerState._();

  const factory WifiAnalyzerState({
    @Default(false) bool isLoading,
    String? connectionError,
    String? ssidTerhubung,
    String? bssidTerhubung,
    String? ipTerhubung,
    DateTime? lastInfoAt,
    DateTime? lastInfoAttemptAt,
  }) = _WifiAnalyzerState;
}
