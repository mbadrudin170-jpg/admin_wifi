// path: lib/fitur/status_unggah/state/status_unggah_state.dart

import 'package:admin_wifi/fitur/status_unggah/model/status_unggah_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'status_unggah_state.freezed.dart';

@freezed
abstract class StatusUnggahState with _$StatusUnggahState {
  const StatusUnggahState._();

  const factory StatusUnggahState({
    @Default([]) List<StatusUnggahModel> listStatusUnggah,
    @Default(0) int jumlahStatusUnggah,
  }) = _StatusUnggahState;
}
