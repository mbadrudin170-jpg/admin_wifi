// path: lib/fitur/kategori/state/kategori_state.dart

import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'kategori_state.freezed.dart';

@freezed
abstract class KategoriState with _$KategoriState {
  const KategoriState._();

  const factory KategoriState({
    @Default(<KategoriModel>[]) List<KategoriModel> listKategori,
    @Default(0) int jumlahKategori,
  }) = _KategoriState;

  /// Mengambil satu kategori berdasarkan [id].
  ///
  /// Mengembalikan `null` bila tidak ditemukan.
  KategoriModel? getById(String id) =>
      listKategori.firstWhereOrNull((item) => item.id == id);
}
