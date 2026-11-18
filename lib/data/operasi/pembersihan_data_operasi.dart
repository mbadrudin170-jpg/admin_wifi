// path: lib/data/operasi/pembersihan_data_operasi.dart

import 'package:admin_wifi/db/sqflite.dart';
import 'package:share_global_saya/src/utils/l.dart';

class PembersihanDataOperasi {
  final dbHelper = DatabaseHelper.instance;

  /// Fungsi utama untuk menghapus semua data arsip
  /// yang sudah lebih tua dari [batasHari] di semua tabel yang relevan.
  Future<int> hapusSemuaDataArsipKadaluarsa({required int batasHari}) async {
    L.i(
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
          L.i(
            '[$tabel] Dihapus $hasil baris yang diarsipkan lebih dari $batasHari hari.',
          );
        }

        totalTerhapus += hasil;
      } catch (e, s) {
        L.e('Gagal membersihkan tabel $tabel. Error: $e $s');
        // Lanjutkan ke tabel berikutnya meskipun ada error di satu tabel
        continue;
      }
    }

    L.i(
      'Total $totalTerhapus baris data arsip kadaluarsa berhasil dihapus dari database.',
    );
    return totalTerhapus;
  }
}
