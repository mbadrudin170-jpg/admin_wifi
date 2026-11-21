// path: lib/fitur/kritik_saran/state/kritik_saran_state.dart

import 'package:admin_wifi/fitur/kritik_saran/model/kritik_saran_model.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'kritik_saran_state.freezed.dart';

@freezed
abstract class KritikSaranState with _$KritikSaranState {
  const KritikSaranState._();

  const factory KritikSaranState({
    @Default([]) List<KritikSaranModel> listKritikSaran,
    @Default(0) int jumlahKritikSaran,
  }) = _KritikSaranState;

  /// Mengambil satu kritik dan saran berdasarkan [id].
  ///
  /// Mengembalikan `null` bila tidak ditemukan.
  KritikSaranModel? getKritikSaranById(String id) =>
      listKritikSaran.firstWhereOrNull((item) => item.id == id);

  /// Alias untuk [getKritikSaranById].
  KritikSaranModel? getById(String id) => getKritikSaranById(id);

  /// Mengambil perubahan kritik dan saran sejak timestamp tertentu dari daftar
  /// yang sudah dimuat.
  ///
  /// Hanya memakai field `diperbarui` yang non-null dan sudah lewat sejak [since].
  List<KritikSaranModel> getPerubahan(DateTime since) => listKritikSaran
      .where((item) {
        final diperbarui = item.diperbarui;
        return diperbarui != null && diperbarui.isAfter(since);
      })
      .toList();

  /// Mengambil kritik dan saran berdasarkan daftar ID dari daftar yang sudah
  /// dimuat.
  ///
  /// Mengembalikan list kosong jika ID tidak ditemukan.
  List<KritikSaranModel> getKritikSaranByIds(List<String> ids) =>
      listKritikSaran.where((item) => ids.contains(item.id)).toList();
}
