// path: lib/fitur/wifi_analyzer/state/perangkat_wifi_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:network_tools/network_tools.dart';

part 'perangkat_wifi_state.freezed.dart';

@freezed
abstract class PerangkatWifiState with _$PerangkatWifiState {
  const PerangkatWifiState._();

  const factory PerangkatWifiState({
    @Default(false) bool isLoading,
    @Default(<ActiveHost>[]) List<ActiveHost> perangkat,
    int? progress,
    String? error,
  }) = _PerangkatWifiState;
}
