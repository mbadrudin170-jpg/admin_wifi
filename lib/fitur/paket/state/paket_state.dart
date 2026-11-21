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

  /// Mengambil semua paket publik (is_public = 1 dan is_deleted = 0).
  ///
  /// Hanya mengembalikan paket dari daftar yang belum dihapus (is_deleted = 0)
  /// dan memiliki is_public = 1.
  List<PaketModel> getPaketByIsPublic() =>
      listPaket.where((item) => item.isPublic == true).toList();

  /// Mengambil paket berdasarkan ID dari daftar paket yang sudah dimuat.
  ///
  /// Mengembalikan `null` bila tidak ditemukan.
  PaketModel? getPaketById(String id) =>
      listPaket.firstWhereOrNull((item) => item.id == id);

  /// Mengambil perubahan paket sejak timestamp tertentu dari daftar paket yang sudah dimuat.
  ///
  /// Hanya memakai field `diperbarui` yang non-null dan sudah lewat sejak [since].
  List<PaketModel> getPerubahan(DateTime since) => listPaket
      .where(
        (item) => item.diperbarui != null && item.diperbarui!.isAfter(since),
      )
      .toList();

  /// Mengambil paket berdasarkan daftar ID dari daftar paket yang sudah dimuat.
  ///
  /// Mengembalikan list kosong jika ID tidak ditemukan.
  List<PaketModel> getPaketByIds(List<String> ids) =>
      listPaket.where((item) => ids.contains(item.id)).toList();
}
