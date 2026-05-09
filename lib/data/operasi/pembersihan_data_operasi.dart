// path: lib/data/operasi/pembersihan_data_operasi.dart

import 'package:admin_wifi/data/sqlite.dart';
import 'dart:developer' as developer;

class PembersihanDataOperasi {
  final dbHelper = DatabaseHelper.instance;

  /// Fungsi utama untuk menghapus semua data arsip
  /// yang sudah lebih tua dari [batasHari] di semua tabel yang relevan.
  Future<int> hapusSemuaDataArsipKadaluarsa({required int batasHari}) async {
    final db = await dbHelper.database;

    int totalTerhapus = 0;

    // List semua tabel yang punya kolom "diarsipkan"
    final List<String> daftarTabel = [
      'pelanggan',
      'pelanggan_aktif',
      'paket',
      'kategori',
      'sub_kategori',
      'transaksi',
      'dompet',
      'riwayat_langganan',
      'pesanan',
      'versi_apk_user',
    ];

    for (final tabel in daftarTabel) {
      try {
        // diperbaiki: Menghapus backslash yang salah agar interpolasi string 'tabel' berjalan dengan benar.
        final hasil = await db.rawDelete('''
          DELETE FROM $tabel
          WHERE diarsipkan IS NOT NULL
          AND diarsipkan <= datetime('now', '-? days')
        ''', [batasHari]);

        if (hasil > 0) {
          // diperbaiki: Menghapus backslash yang salah untuk logging yang benar.
          developer.log(
            'Menghapus $hasil baris dari tabel $tabel yang diarsipkan lebih dari $batasHari hari.',
            name: 'PembersihanDataOperasi',
          );
        }

        totalTerhapus += hasil;
      } catch (e, s) {
        // diperbaiki: Menghapus backslash yang salah untuk logging error yang benar.
        developer.log(
          'Gagal membersihkan tabel $tabel',
          error: e,
          stackTrace: s,
          name: 'PembersihanDataOperasi.Error',
        );
        // Lanjutkan ke tabel berikutnya meskipun ada error di satu tabel
        continue;
      }
    }

    return totalTerhapus;
  }
}
