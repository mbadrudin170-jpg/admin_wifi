// path: lib/dummy/dummy_helper.dart

import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/fitur/paket/dummy/paket_dummy.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/pelanggan/dummy/pelanggan_dummy.dart';
import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/dummy/pelanggan_aktif_dummy.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:sqflite/sqflite.dart';

/// Penyusun operasi data dummy untuk kebutuhan pengembangan.
///
/// Data dummy bukan sumber data produksi; seluruh kelompok dummy
/// ditambahkan, dihapus, atau direset lewat berkas ini. Penghapusan hanya
/// menyasar baris dengan ID dummy yang dikenal — data pengguna biasa
/// tidak tersentuh. Penyisipan mengikuti urutan referensi (paket, lalu
/// pelanggan, lalu pelanggan aktif); penghapusan dilakukan kebalikannya
/// dalam satu transaksi.
abstract final class DummyHelper {
  static final PelangganAktifOperasi _pelangganAktifOperasi =
      PelangganAktifOperasi();
  static final PelangganOperasi _pelangganOperasi = PelangganOperasi();
  static final PaketOperasi _paketOperasi = PaketOperasi();
  static final OperasiDasar _operasiDasar = OperasiDasar();

  /// Menyisipkan semua data dummy ke database (upsert berdasarkan ID).
  static Future<void> tambahSemuaDummy() async {
    try {
      L.i('Menambahkan ${PaketDummy.dummyList.length} data dummy paket');
      await _paketOperasi.sisipkanAtauPerbaruiBatch(PaketDummy.dummyList);
      L.i('Semua data dummy paket berhasil ditambahkan');

      L.i(
        'Menambahkan ${PelangganDummy.dummyList.length} data dummy pelanggan',
      );
      await _pelangganOperasi.sisipkanAtauPerbaruiBatch(
        PelangganDummy.dummyList,
      );
      L.i('Semua data dummy pelanggan berhasil ditambahkan');

      L.i(
        'Menambahkan ${PelangganAktifDummy.dummyList.length} data dummy pelanggan aktif',
      );
      await _pelangganAktifOperasi.sisipkanAtauPerbaruiBatch(
        PelangganAktifDummy.dummyList,
      );
      L.i('Semua data dummy berhasil ditambahkan');
    } catch (e, s) {
      L.e('Gagal menambahkan semua data dummy Error: $e $s');
      rethrow;
    }
  }

  /// Menghapus permanen hanya baris dengan ID dummy yang dikenal.
  static Future<void> hapusSemuaDummy() async {
    final idPaket = PaketDummy.dummyList.map((item) => item.id).toList();
    final idPelanggan = PelangganDummy.dummyList
        .map((item) => item.id)
        .toList();
    final idPelangganAktif = PelangganAktifDummy.dummyList
        .map((item) => item.id)
        .toList();

    if (idPaket.isEmpty && idPelanggan.isEmpty && idPelangganAktif.isEmpty) {
      L.i('Tidak ada ID dummy yang dikenal; penghapusan dibatalkan');
      return;
    }

    try {
      L.i(
        'Menghapus permanen data dummy paket, pelanggan, dan pelanggan aktif',
      );
      final count = await _operasiDasar.jalankanOperasiKompleks((txn) async {
        var total = 0;
        // Hapus pelanggan aktif terlebih dahulu karena merujuk pelanggan
        // dan paket.
        total += await _hapusDummyBerdasarkanId(
          txn,
          PelangganAktifSkema.tabel,
          idPelangganAktif,
          'pelanggan aktif',
        );
        total += await _hapusDummyBerdasarkanId(
          txn,
          PelangganSkema.tabel,
          idPelanggan,
          'pelanggan',
        );
        total += await _hapusDummyBerdasarkanId(
          txn,
          PaketSkema.tabel,
          idPaket,
          'paket',
        );
        return total;
      });
      L.i('$count data dummy berhasil dihapus');
    } catch (e, s) {
      L.e('Gagal menghapus semua data dummy Error: $e $s');
      rethrow;
    }
  }

  /// Menghapus lalu menambahkan kembali seluruh data dummy.
  static Future<void> risetSemuaDummy() async {
    try {
      L.i('Mereset semua data dummy');
      await hapusSemuaDummy();
      await tambahSemuaDummy();
      L.i('Semua data dummy berhasil direset');
    } catch (e, s) {
      L.e('Gagal mereset semua data dummy Error: $e $s');
      rethrow;
    }
  }

  static Future<int> _hapusDummyBerdasarkanId(
    Transaction txn,
    String tabel,
    List<String> ids,
    String label,
  ) async {
    if (ids.isEmpty) {
      return 0;
    }
    final count = await txn.delete(
      tabel,
      where: 'id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );
    L.i('$count data dummy $label terhapus');
    return count;
  }
}
