// path: lib/fitur/paket/state/paket_state.dart

import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'paket_state.freezed.dart';

@freezed
abstract class PaketState with _$PaketState {
  const PaketState._();

  const factory PaketState({
    @Default(<PaketModel>[]) List<PaketModel> listPaket,
    @Default(0) int jumlahPaket,
  }) = _PaketState;

  /// Mengambil satu paket berdasarkan [id].
  ///
  /// Mengembalikan `null` bila tidak ditemukan.
  PaketModel? getById(String id) =>
      listPaket.firstWhereOrNull((item) => item.id == id);
}
