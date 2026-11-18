// path: lib/fitur/state/pelanggan_aktif_state.dart

import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pelanggan_aktif_state.freezed.dart';

@freezed
abstract class PelangganAktifState with _$PelangganAktifState {
  const PelangganAktifState._();

  const factory PelangganAktifState({
    @Default([]) List<PelangganAktifModel> listPelangganAktif,
    @Default(0) int jumlahPelangganAktif,
  }) = _PelangganAktifState;
}
