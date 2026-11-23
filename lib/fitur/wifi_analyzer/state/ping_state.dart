// path: lib/fitur/wifi_analyzer/state/ping_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ping_state.freezed.dart';

@freezed
abstract class PingState with _$PingState {
  const PingState._();

  const factory PingState({
    @Default(false) bool isLoading,
    String? host,
    int? latencyMs,
    @Default(false) bool success,
    String? error,
    String? jenisPengukuran,
  }) = _PingState;
}
