// path: lib/fitur/pelanggan/state/pelanggan_state.dart

import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pelanggan_state.freezed.dart';

@freezed
abstract class PelangganState with _$PelangganState {
  const PelangganState._();

  const factory PelangganState({
    @Default(<PelangganModel>[]) List<PelangganModel> listPelanggan,
    @Default(0) int jumlahPelanggan,
  }) = _PelangganState;

  /// Mengambil satu pelanggan berdasarkan [id].
  ///
  /// Mengembalikan `null` bila tidak ditemukan.
  PelangganModel? getById(String id) =>
      listPelanggan.firstWhereOrNull((item) => item.id == id);
}
