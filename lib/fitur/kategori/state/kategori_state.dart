// path: lib/fitur/kategori/state/kategori_state.dart

import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:admin_wifi/fitur/kategori/model/sub_kategori_model.dart';
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

  /// Alias untuk [getById].
  KategoriModel? getKategoriById(String id) => getById(id);

  /// Mengambil satu sub kategori berdasarkan [id] dari daftar kategori yang
  /// sudah dimuat.
  ///
  /// Mengembalikan `null` bila tidak ditemukan.
  SubKategoriModel? getSubKategoriById(String id) => listKategori
      .expand((k) => k.subKategori)
      .firstWhereOrNull((sk) => sk.id == id);

  /// Mengambil kategori berdasarkan [tipe] dari daftar yang sudah dimuat.
  ///
  /// Hanya mengembalikan kategori yang belum diarsipkan.
  List<KategoriModel> getKategoriByTipe(TipeKategori tipe) => listKategori
      .where((item) => item.tipe == tipe && item.diarsipkan == null)
      .toList();

  /// Mengambil perubahan kategori sejak timestamp tertentu dari daftar yang
  /// sudah dimuat.
  ///
  /// Hanya memakai field `diperbarui` yang non-null dan sudah lewat sejak [since].
  List<KategoriModel> getPerubahan(DateTime since) => listKategori
      .where(
        (item) => item.diperbarui != null && item.diperbarui!.isAfter(since),
      )
      .toList();

  /// Mengambil kategori berdasarkan daftar ID dari daftar yang sudah dimuat.
  ///
  /// Mengembalikan list kosong jika ID tidak ditemukan.
  List<KategoriModel> getKategoriByIds(List<String> ids) =>
      listKategori.where((item) => ids.contains(item.id)).toList();
}
