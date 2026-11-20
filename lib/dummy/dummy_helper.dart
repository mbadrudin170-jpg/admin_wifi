// path: lib/dummy/dummy_helper.dart

import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/kritik_saran_operasi.dart';
import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/pengaturan_operasi.dart';
import 'package:admin_wifi/data/operasi/pesanan_operasi.dart';
import 'package:admin_wifi/data/operasi/sub_kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/fitur/dompet/dummy/dompet_dummy.dart';
import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/kategori/dummy/kategori_dummy.dart';
import 'package:admin_wifi/fitur/kategori/dummy/sub_kategori_dummy.dart';
import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:admin_wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:admin_wifi/fitur/kritik_saran/dummy/kritik_saran_dummy.dart';
import 'package:admin_wifi/fitur/kritik_saran/model/kritik_saran_model.dart';
import 'package:admin_wifi/fitur/paket/dummy/paket_dummy.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/pelanggan/dummy/pelanggan_dummy.dart';
import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/dummy/pelanggan_aktif_dummy.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/fitur/pengaturan/dummy/pengaturan_dummy.dart';
import 'package:admin_wifi/fitur/pesanan/dummy/pesanan_dummy.dart';
import 'package:admin_wifi/fitur/pesanan/model/pesanan_model.dart';
import 'package:admin_wifi/fitur/status_unggah/dummy/status_unggah_dummy.dart';
import 'package:admin_wifi/fitur/status_unggah/model/status_unggah_model.dart';
import 'package:admin_wifi/fitur/transaksi/dummy/transaksi_dummy.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/transaksi/notifier/transaksi_notifier.dart';
import 'package:admin_wifi/fitur/versi_apk_user/dummy/versi_apk_user_dummy.dart';
import 'package:admin_wifi/fitur/versi_apk_user/model/versi_apk_user_model.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:sqflite/sqflite.dart';

/// Penyusun operasi data dummy untuk kebutuhan pengembangan.
///
/// Data dummy bukan sumber data produksi; seluruh kelompok dummy
/// ditambahkan, dihapus, atau direset lewat berkas ini. Penghapusan hanya
/// menyasar baris dengan ID dummy yang dikenal — data pengguna biasa
/// tidak tersentuh. Penyisipan mengikuti urutan referensi; penghapusan
/// dilakukan kebalikannya dalam satu transaksi.
abstract final class DummyHelper {
  static final DompetOperasi _dompetOperasi = DompetOperasi();
  static final KategoriOperasi _kategoriOperasi = KategoriOperasi();
  static final KritikSaranOperasi _kritikSaranOperasi = KritikSaranOperasi();
  static final PaketOperasi _paketOperasi = PaketOperasi();
  static final PelangganAktifOperasi _pelangganAktifOperasi =
      PelangganAktifOperasi();
  static final PelangganOperasi _pelangganOperasi = PelangganOperasi();
  static final PengaturanOperasi _pengaturanOperasi = PengaturanOperasi();
  static final PesananOperasi _pesananOperasi = PesananOperasi();
  static final SubKategoriOperasi _subKategoriOperasi = SubKategoriOperasi();
  static final VersiApkUserOperasi _versiApkUserOperasi = VersiApkUserOperasi();
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

      L.i('Menambahkan ${DompetDummy.dummyList.length} data dummy dompet');
      await _dompetOperasi.sisipkanAtauPerbaruiBatch(DompetDummy.dummyList);
      L.i('Semua data dummy dompet berhasil ditambahkan');

      L.i('Menambahkan ${KategoriDummy.dummyList.length} data dummy kategori');
      await _kategoriOperasi.sisipkanAtauPerbaruiBatch(KategoriDummy.dummyList);
      L.i('Semua data dummy kategori berhasil ditambahkan');

      L.i(
        'Menambahkan ${SubKategoriDummy.dummyList.length} data dummy sub kategori',
      );
      await _subKategoriOperasi.sisipkanAtauPerbaruiBatch(
        SubKategoriDummy.dummyList,
      );
      L.i('Semua data dummy sub kategori berhasil ditambahkan');

      L.i(
        'Menambahkan ${PengaturanDummy.dummyList.length} data dummy pengaturan',
      );
      for (final pengaturan in PengaturanDummy.dummyList) {
        await _pengaturanOperasi.simpanAtauPerbaruiPengaturan(pengaturan);
      }
      L.i('Semua data dummy pengaturan berhasil ditambahkan');

      L.i(
        'Menambahkan ${StatusUnggahDummy.dummyList.length} data dummy status unggah',
      );
      await _operasiDasar.sisipkanAtauPerbaruiBatch(
        StatusUnggahSkema.tabel,
        StatusUnggahDummy.dummyList.map((item) => item.toSqlite()).toList(),
      );
      L.i('Semua data dummy status unggah berhasil ditambahkan');

      L.i(
        'Menambahkan ${VersiApkUserDummy.dummyList.length} data dummy versi apk user',
      );
      await _versiApkUserOperasi.sisipkanAtauPerbaruiBatch(
        VersiApkUserDummy.dummyList,
      );
      L.i('Semua data dummy versi apk user berhasil ditambahkan');

      L.i('Menambahkan ${PesananDummy.dummyList.length} data dummy pesanan');
      await _pesananOperasi.sisipkanAtauPerbaruiBatch(PesananDummy.dummyList);
      L.i('Semua data dummy pesanan berhasil ditambahkan');

      L.i(
        'Menambahkan ${KritikSaranDummy.dummyList.length} data dummy kritik saran',
      );
      await _kritikSaranOperasi.sisipkanAtauPerbaruiBatch(
        KritikSaranDummy.dummyList,
      );
      L.i('Semua data dummy kritik saran berhasil ditambahkan');

      L.i(
        'Menambahkan ${TransaksiDummy.dummyList.length} data dummy transaksi',
      );
      await transaksiNotifierGlobal.sisipkanAtauPerbaruiBatch(
        TransaksiDummy.dummyList,
      );
      L.i('Semua data dummy transaksi berhasil ditambahkan');

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
    final idDompet = DompetDummy.dummyList.map((item) => item.id).toList();
    final idKategori = KategoriDummy.dummyList.map((item) => item.id).toList();
    final idSubKategori = SubKategoriDummy.dummyList
        .map((item) => item.id)
        .toList();
    final idPaket = PaketDummy.dummyList.map((item) => item.id).toList();
    final idPelanggan = PelangganDummy.dummyList
        .map((item) => item.id)
        .toList();
    final idPelangganAktif = PelangganAktifDummy.dummyList
        .map((item) => item.id)
        .toList();
    final idPesanan = PesananDummy.dummyList.map((item) => item.id).toList();
    final idKritikSaran = KritikSaranDummy.dummyList
        .map((item) => item.id)
        .toList();
    final idTransaksi = TransaksiDummy.dummyList
        .map((item) => item.id)
        .toList();
    final namaTabelStatusUnggah = StatusUnggahDummy.dummyList
        .map((item) => item.namaTabel)
        .toList();
    final idVersiApkUser = VersiApkUserDummy.dummyList
        .map((item) => item.id)
        .toList();

    if (idPaket.isEmpty &&
        idPelanggan.isEmpty &&
        idPelangganAktif.isEmpty &&
        idDompet.isEmpty &&
        idKategori.isEmpty &&
        idSubKategori.isEmpty &&
        idPesanan.isEmpty &&
        idKritikSaran.isEmpty &&
        idTransaksi.isEmpty &&
        namaTabelStatusUnggah.isEmpty &&
        idVersiApkUser.isEmpty) {
      L.i('Tidak ada ID dummy yang dikenal; penghapusan dibatalkan');
      return;
    }

    try {
      L.i('Menghapus permanen data dummy');
      final count = await _operasiDasar.jalankanOperasiKompleks((txn) async {
        var total = 0;
        // Hapus tabel yang memiliki foreign key terlebih dahulu.
        total += await _hapusDummyBerdasarkanId(
          txn,
          PelangganAktifSkema.tabel,
          idPelangganAktif,
          'pelanggan aktif',
        );
        total += await _hapusDummyBerdasarkanId(
          txn,
          PesananSkema.tabel,
          idPesanan,
          'pesanan',
        );
        total += await _hapusDummyBerdasarkanId(
          txn,
          KritikSaranSkema.tabel,
          idKritikSaran,
          'kritik saran',
        );
        total += await _hapusDummyBerdasarkanId(
          txn,
          TransaksiSkema.tabel,
          idTransaksi,
          'transaksi',
        );
        total += await _hapusDummyBerdasarkanId(
          txn,
          SubKategoriSkema.tabel,
          idSubKategori,
          'sub kategori',
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
        total += await _hapusDummyBerdasarkanId(
          txn,
          KategoriSkema.tabel,
          idKategori,
          'kategori',
        );
        total += await _hapusDummyBerdasarkanId(
          txn,
          DompetSkema.tabel,
          idDompet,
          'dompet',
        );
        total += await _hapusDummyBerdasarkanId(
          txn,
          StatusUnggahSkema.tabel,
          namaTabelStatusUnggah,
          'status unggah',
          kolomKunci: StatusUnggahSkema.namaTabel,
        );
        total += await _hapusDummyBerdasarkanId(
          txn,
          VersiApkUserSkema.tabel,
          idVersiApkUser,
          'versi apk user',
        );
        return total;
      });
      // Pengaturan tidak memiliki ID; reset dilakukan lewat penyisipan upsert.
      // Status unggah dihapus lewat kolom `tabel` (PRIMARY KEY, bukan `id`).
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
    List<Object> ids,
    String label, {
    String kolomKunci = 'id',
  }) async {
    if (ids.isEmpty) {
      return 0;
    }
    final count = await txn.delete(
      tabel,
      where: '$kolomKunci IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );
    L.i('$count data dummy $label terhapus');
    return count;
  }
}
