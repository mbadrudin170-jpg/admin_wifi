// path: lib/fitur/wifi_analyzer/model/perangkat_wifi_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'perangkat_wifi_model.freezed.dart';

@freezed
abstract class PerangkatWifiModel with _$PerangkatWifiModel {
  const factory PerangkatWifiModel({
    required String ip,
    String? nama,
    String? vendor,
    String? macAddress,
    String? tipePerangkat,
    String? layanan,
    DateTime? terakhirDilihat,
    int? latencyMs,
    String? sumberDiscovery,
  }) = _PerangkatWifiModel;
}
