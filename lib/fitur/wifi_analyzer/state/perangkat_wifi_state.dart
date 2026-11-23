// path: lib/fitur/wifi_analyzer/state/perangkat_wifi_state.dart

import 'package:admin_wifi/fitur/wifi_analyzer/model/perangkat_wifi_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'perangkat_wifi_state.freezed.dart';

@freezed
abstract class PerangkatWifiState with _$PerangkatWifiState {
  const PerangkatWifiState._();

  const factory PerangkatWifiState({
    @Default(false) bool isLoading,
    @Default(<PerangkatWifiModel>[]) List<PerangkatWifiModel> perangkat,
    int? progress,
    String? error,
  }) = _PerangkatWifiState;
}
