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
    @Default(<String>[]) List<String> services,
    DateTime? terakhirDilihat,
    int? latencyMs,
    String? latencyMethod,
    @Default(<String>[]) List<String> discoveryMethods,
    @Default(false) bool isOnline,
    String? identificationStatus,
    String? sumberDiscovery,
  }) = _PerangkatWifiModel;
}
