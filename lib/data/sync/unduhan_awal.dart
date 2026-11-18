// path: lib/data/sync/unduhan_awal.dart

import 'package:admin_wifi/data/sync/unduh_data.dart';
import 'package:admin_wifi/db/sqflite.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:sqflite/sqflite.dart';

/// [UnduhanAwalService] bertanggung jawab untuk mengisi database lokal dengan
/// data dari server jika tabel-tabel tertentu masih kosong.
class UnduhanAwalService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final LayananUnduhData _layananUnduh = LayananUnduhData();

  /// Menjalankan pengecekan dan pengunduhan data awal untuk seluruh tabel.
  Future<void> jalankanUnduhanAwal() async {
    L.i('Memulai sinkronisasi awal: Mengecek tabel lokal yang kosong...');

    final stopwatch = Stopwatch()..start();

    // List fungsi unduh yang akan dijalankan secara sekuensial
    await _unduhDataPaketJikaKosong();
    await _unduhDataKategoriJikaKosong();
    await _unduhDataSubKategoriJikaKosong();
    await _unduhDataDompetJikaKosong();
    await _unduhDataPelangganJikaKosong();
    await _unduhDataVersiApkJikaKosong();
    await _unduhDataPengaturanJikaKosong();
    await _unduhDataPelangganAktifJikaKosong();
    await _unduhDataTransaksiJikaKosong();
    await _unduhDataKritikSaranJikaKosong();
    await _unduhDataPesananJikaKosong();

    stopwatch.stop();
    L.i(
      'Proses unduhan awal selesai dalam ${stopwatch.elapsed.inSeconds} detik.',
    );
  }

  /// Memeriksa apakah sebuah tabel kosong.
  Future<bool> _apakahTabelKosong(String namaTabel) async {
    try {
      final db = await _dbHelper.database;
      final hasil = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $namaTabel',
      );
      final jumlah = Sqflite.firstIntValue(hasil) ?? 0;

      L.i("Tabel '$namaTabel': $jumlah baris.");
      return jumlah == 0;
    } catch (e) {
      L.e("Gagal mengecek tabel '$namaTabel'. Error: $e");
      return false;
    }
  }

  /// Template fungsi pembungkus untuk proses unduh per tabel agar kode lebih bersih.
  Future<void> _prosesUnduhJikaKosong({
    required String namaTabel,
    required Future<void> Function() fungsiUnduh,
  }) async {
    try {
      if (await _apakahTabelKosong(namaTabel)) {
        L.i("Memulai unduh data untuk '$namaTabel'...");
        await fungsiUnduh();
        L.i("Data '$namaTabel' berhasil disimpan ke lokal.");
      } else {
        L.i("Skip '$namaTabel' (Sudah ada data).");
      }
    } catch (e, s) {
      L.e("ERROR saat mengunduh '$namaTabel' Error: $e $s");
    }
  }

  // --- Implementasi Fungsi Khusus ---

  Future<void> _unduhDataPaketJikaKosong() async => _prosesUnduhJikaKosong(
    namaTabel: 'paket',
    fungsiUnduh: _layananUnduh.unduhDataPaket,
  );

  Future<void> _unduhDataKategoriJikaKosong() async => _prosesUnduhJikaKosong(
    namaTabel: 'kategori',
    fungsiUnduh: _layananUnduh.unduhDataKategori,
  );

  Future<void> _unduhDataSubKategoriJikaKosong() async =>
      _prosesUnduhJikaKosong(
        namaTabel: 'sub_kategori',
        fungsiUnduh: _layananUnduh.unduhDataSubKategori,
      );

  Future<void> _unduhDataDompetJikaKosong() async => _prosesUnduhJikaKosong(
    namaTabel: 'dompet',
    fungsiUnduh: _layananUnduh.unduhDataDompet,
  );

  Future<void> _unduhDataPelangganJikaKosong() async => _prosesUnduhJikaKosong(
    namaTabel: 'pelanggan',
    fungsiUnduh: _layananUnduh.unduhDataPelanggan,
  );

  Future<void> _unduhDataVersiApkJikaKosong() async => _prosesUnduhJikaKosong(
    namaTabel: 'versi_apk_user',
    fungsiUnduh: _layananUnduh.unduhDataVersiApkUser,
  );

  Future<void> _unduhDataPengaturanJikaKosong() async => _prosesUnduhJikaKosong(
    namaTabel: 'pengaturan',
    fungsiUnduh: _layananUnduh.unduhDataPengaturan,
  );

  Future<void> _unduhDataPelangganAktifJikaKosong() async =>
      _prosesUnduhJikaKosong(
        namaTabel: 'pelanggan_aktif',
        fungsiUnduh: _layananUnduh.unduhDataPelangganAktif,
      );

  Future<void> _unduhDataTransaksiJikaKosong() async => _prosesUnduhJikaKosong(
    namaTabel: 'transaksi',
    fungsiUnduh: _layananUnduh.unduhDataTransaksi,
  );

  Future<void> _unduhDataKritikSaranJikaKosong() async =>
      _prosesUnduhJikaKosong(
        namaTabel: 'kritik_saran',
        fungsiUnduh: _layananUnduh.unduhDataKritikSaran,
      );

  Future<void> _unduhDataPesananJikaKosong() async => _prosesUnduhJikaKosong(
    namaTabel: 'pesan',
    fungsiUnduh: _layananUnduh.unduhDataPesanan,
  );
}
