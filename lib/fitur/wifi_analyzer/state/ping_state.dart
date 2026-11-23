// path: lib/fitur/wifi_analyzer/state/ping_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ping_state.freezed.dart';

enum JenisPengukuranPing {
  icmp('ICMP ping'),
  tcpProbe('TCP probe');

  const JenisPengukuranPing(this.label);

  final String label;
}

@freezed
abstract class PingState with _$PingState {
  const PingState._();

  const factory PingState({
    @Default(false) bool isLoading,
    String? host,
    int? latencyMs,
    @Default(false) bool success,
    String? error,
    JenisPengukuranPing? jenisPengukuran,
  }) = _PingState;
}
