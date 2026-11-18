// path: lib/dummy/dummy_helper.dart

import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/dummy/pelanggan_aktif_dummy.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:share_global_saya/src/utils/l.dart';

/// Penyusun operasi data dummy untuk kebutuhan pengembangan.
///
/// Data dummy bukan sumber data produksi; seluruh kelompok dummy
/// ditambahkan, dihapus, atau direset lewat berkas ini. Penghapusan hanya
/// menyasar baris dengan ID dummy yang dikenal — data pengguna biasa
/// tidak tersentuh.
abstract final class DummyHelper {
  static final PelangganAktifOperasi _pelangganAktifOperasi =
      PelangganAktifOperasi();
  static final OperasiDasar _operasiDasar = OperasiDasar();

  /// Menyisipkan semua data dummy ke database (upsert berdasarkan ID).
  static Future<void> tambahSemuaDummy() async {
    try {
      L.i(
        'Menambahkan ${PelangganAktifDummy.dummyList.length} data dummy pelanggan aktif',
      );
      await _pelangganAktifOperasi.sisipkanAtauPerbaruiBatch(
        PelangganAktifDummy.dummyList,
      );
      L.i('Semua data dummy pelanggan aktif berhasil ditambahkan');
    } catch (e, s) {
      L.e('Gagal menambahkan semua data dummy pelanggan aktif Error: $e $s');
      rethrow;
    }
  }

  /// Menghapus permanen hanya baris dengan ID dummy yang dikenal.
  static Future<void> hapusSemuaDummy() async {
    final ids = PelangganAktifDummy.dummyList.map((item) => item.id).toList();
    if (ids.isEmpty) {
      L.i('Tidak ada ID dummy yang dikenal; penghapusan dibatalkan');
      return;
    }

    try {
      L.i('Menghapus permanen ${ids.length} data dummy pelanggan aktif');
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final count = await txn.delete(
          PelangganAktifSkema.tabel,
          where: 'id IN (${List.filled(ids.length, '?').join(',')})',
          whereArgs: ids,
        );
        L.i('$count data dummy pelanggan aktif terhapus');
        return count;
      });
    } catch (e, s) {
      L.e('Gagal menghapus semua data dummy pelanggan aktif Error: $e $s');
      rethrow;
    }
  }

  /// Menghapus lalu menambahkan kembali seluruh data dummy.
  static Future<void> risetSemuaDummy() async {
    try {
      L.i('Mereset semua data dummy pelanggan aktif');
      await hapusSemuaDummy();
      await tambahSemuaDummy();
      L.i('Semua data dummy pelanggan aktif berhasil direset');
    } catch (e, s) {
      L.e('Gagal mereset semua data dummy pelanggan aktif Error: $e $s');
      rethrow;
    }
  }
}
