// path: lib/fitur/dompet/state/dompet_state.dart

import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dompet_state.freezed.dart';

@freezed
abstract class DompetState with _$DompetState {
  const DompetState._();

  const factory DompetState({
    @Default(<DompetModel>[]) List<DompetModel> listDompet,
    @Default(0) int jumlahDompet,
  }) = _DompetState;
}
