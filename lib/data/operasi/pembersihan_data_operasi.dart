// path: lib/data/operasi/pembersihan_data_operasi.dart

import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/debug/log.dart';

class PembersihanDataOperasi {
  final dbHelper = DatabaseHelper.instance;
  final String _fileName = 'pembersihan_data_operasi.dart';

  /// Fungsi utama untuk menghapus semua data arsip
  /// yang sudah lebih tua dari [batasHari] di semua tabel yang relevan.
  Future<int> hapusSemuaDataArsipKadaluarsa({required int batasHari}) async {
    final name = '$_fileName.hapusSemuaDataArsipKadaluarsa';
    Log.info(
      'Memulai proses pembersihan data arsip yang lebih tua dari $batasHari hari.',
    );

    final db = await dbHelper.database;
    int totalTerhapus = 0;

    // diubah: Menghapus 'riwayat_langganan' karena tabel tidak ada.
    final List<String> daftarTabel = [
      'pelanggan',
      'pelanggan_aktif',
      'paket',
      'kategori',
      'sub_kategori',
      'transaksi',
      'dompet',
      'pesanan',
      'versi_apk_user',
    ];

    for (final tabel in daftarTabel) {
      try {
        // diubah: Memperbaiki query SQL. Argumen `batasHari` diinterpolasi langsung
        // ke dalam string karena ? tidak didukung di dalam fungsi datetime() sqflite.
        final query =
            '''
          DELETE FROM $tabel
          WHERE diarsipkan IS NOT NULL
          AND diarsipkan <= datetime('now', '-$batasHari days')
        ''';
        final hasil = await db.rawDelete(query);

        if (hasil > 0) {
          Log.info(
            '[$tabel] Dihapus $hasil baris yang diarsipkan lebih dari $batasHari hari.',
          );
        }

        totalTerhapus += hasil;
      } catch (e, s) {
        Log.error(
          'Gagal membersihkan tabel $tabel.',
          error: e,
          stackTrace: s,
          name: '$name.Error',
        );
        // Lanjutkan ke tabel berikutnya meskipun ada error di satu tabel
        continue;
      }
    }

    Log.info(
      'Total $totalTerhapus baris data arsip kadaluarsa berhasil dihapus dari database.',
    );
    return totalTerhapus;
  }
}
