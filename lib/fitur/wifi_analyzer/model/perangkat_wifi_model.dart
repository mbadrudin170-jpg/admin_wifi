// path: lib/fitur/wifi_analyzer/model/perangkat_wifi_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'perangkat_wifi_model.freezed.dart';

@freezed
abstract class PerangkatWifiModel with _$PerangkatWifiModel {
  const factory PerangkatWifiModel({
    required String ip,
    String? nama,
    String? mac,
    String? vendor,
    int? latencyMs,
  }) = _PerangkatWifiModel;
}
