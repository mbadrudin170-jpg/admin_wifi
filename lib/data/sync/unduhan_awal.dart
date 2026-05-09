// path: lib/data/sync/unduhan_awal.dart

import 'dart:developer' as developer;
import 'package:admin_wifi/data/sync/unduh_data.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:sqflite/sqflite.dart';

/// [UnduhanAwalService] bertanggung jawab untuk mengisi database lokal dengan
/// data dari server jika tabel-tabel tertentu masih kosong.
class UnduhanAwalService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final LayananUnduhData _layananUnduh = LayananUnduhData();

  /// Menjalankan pengecekan dan pengunduhan data awal untuk seluruh tabel.
  Future<void> jalankanUnduhanAwal() async {
    developer.log(
      '🚀 Memulai sinkronisasi awal: Mengecek tabel lokal yang kosong...',
      name: 'APP.SyncInitial',
      level: 800, // INFO
    );

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
    developer.log(
      '✅ Proses unduhan awal selesai dalam ${stopwatch.elapsed.inSeconds} detik.',
      name: 'APP.SyncInitial',
      level: 800,
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

      developer.log(
        "📊 Tabel '$namaTabel': $jumlah baris.",
        name: 'APP.SyncInitial.Check',
      );
      return jumlah == 0;
    } catch (e) {
      developer.log(
        "❌ Gagal mengecek tabel '$namaTabel'.",
        name: 'APP.SyncInitial.Check',
        error: e,
        level: 1000,
      );
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
        developer.log(
          "📡 Memulai unduh data untuk '$namaTabel'...",
          name: 'APP.SyncInitial.Action',
        );
        await fungsiUnduh();
        developer.log(
          "💾 Data '$namaTabel' berhasil disimpan ke lokal.",
          name: 'APP.SyncInitial.Action',
        );
      } else {
        developer.log(
          "⏭️ Skip '$namaTabel' (Sudah ada data).",
          name: 'APP.SyncInitial.Action',
        );
      }
    } catch (e, s) {
      developer.log(
        "🚨 ERROR saat mengunduh '$namaTabel'",
        name: 'APP.SyncInitial.Action',
        error: e,
        stackTrace: s,
        level: 1000,
      );
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
