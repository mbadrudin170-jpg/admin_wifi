// path: lib/data/operasi/pembersihan_data_operasi.dart

import 'package:admin_wifi/data/sqlite.dart';
// import 'package:sqflite/sqflite.dart';

class PembersihanDataOperasi {
  final dbHelper = DatabaseHelper.instance;

  /// Fungsi utama untuk menghapus semua data arsip
  /// yang sudah lebih dari 30 hari di SEMUA tabel yang relevan
  Future<int> hapusSemuaDataArsipKadaluarsa() async {
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
      final hasil = await db.rawDelete('''
        DELETE FROM $tabel
        WHERE diarsipkan IS NOT NULL
        AND diarsipkan <= datetime('now', '-30 days')
      ''');

      totalTerhapus += hasil;
    }

    return totalTerhapus;
  }
}
