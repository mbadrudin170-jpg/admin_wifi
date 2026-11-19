// path: lib/fitur/pesanan/state/pesanan_state.dart

import 'package:admin_wifi/fitur/pesanan/model/pesanan_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pesanan_state.freezed.dart';

@freezed
abstract class PesananState with _$PesananState {
  const PesananState._();

  const factory PesananState({
    @Default([]) List<PesananModel> listPesanan,
    @Default(0) int jumlahPesanan,
  }) = _PesananState;
}
