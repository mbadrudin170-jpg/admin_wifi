// path: lib/fitur/pelanggan_aktif/state/pelanggan_aktif_state.dart

import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pelanggan_aktif_state.freezed.dart';

@freezed
abstract class PelangganAktifState with _$PelangganAktifState {
  const PelangganAktifState._();

  const factory PelangganAktifState({
    @Default([]) List<PelangganAktifModel> listPelangganAktif,
    @Default(0) int jumlahPelangganAktif,
  }) = _PelangganAktifState;

  /// Mengambil satu pelanggan aktif berdasarkan [id].
  ///
  /// Mengembalikan `null` bila tidak ditemukan.
  PelangganAktifModel? getById(String id) =>
      listPelangganAktif.firstWhereOrNull((item) => item.id == id);
}
