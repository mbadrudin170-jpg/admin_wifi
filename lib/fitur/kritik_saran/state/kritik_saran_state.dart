// path: lib/fitur/kritik_saran/state/kritik_saran_state.dart

import 'package:admin_wifi/fitur/kritik_saran/model/kritik_saran_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'kritik_saran_state.freezed.dart';

@freezed
abstract class KritikSaranState with _$KritikSaranState {
  const KritikSaranState._();

  const factory KritikSaranState({
    @Default([]) List<KritikSaranModel> listKritikSaran,
    @Default(0) int jumlahKritikSaran,
  }) = _KritikSaranState;
}
