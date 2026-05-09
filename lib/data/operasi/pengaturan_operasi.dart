// path: lib/data/operasi/pengaturan_operasi.dart
// diubah: Memperbaiki logika pengambilan dan penyimpanan data karena tabel pengaturan tidak memiliki ID.

import 'dart:developer' as developer;
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/pengaturan_model.dart';

// Kelas untuk operasi database terkait tabel `pengaturan`.
class PengaturanOperasi {
  final _namaTabel = 'pengaturan';

  // Mengambil data pengaturan dari database.
  Future<PengaturanModel> getPengaturan() async {
    try {
      final db = await DatabaseHelper.instance.database;
      // diubah: Mengambil baris pertama karena hanya ada satu baris konfigurasi.
      final hasil = await db.query(_namaTabel, limit: 1);

      if (hasil.isNotEmpty) {
        return PengaturanModel.fromSqlite(hasil.first);
      } else {
        // Jika belum ada, buat pengaturan default
        final pengaturanDefault = PengaturanModel();
        await simpanAtauPerbaruiPengaturan(pengaturanDefault);
        return pengaturanDefault;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error saat mengambil pengaturan: $e',
        name: 'PengaturanOperasi.get',
        error: e,
        stackTrace: stackTrace,
      );
      // Mengembalikan model default jika terjadi error
      return PengaturanModel();
    }
  }

  // Menyimpan atau memperbarui data pengaturan.
  Future<void> simpanAtauPerbaruiPengaturan(PengaturanModel pengaturan) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final data = pengaturan.toSqlite();

      // diubah: Hapus data lama, lalu masukkan data baru untuk memastikan hanya ada 1 baris.
      await db.transaction((txn) async {
        await txn.delete(_namaTabel);
        await txn.insert(_namaTabel, data);
      });

      developer.log(
        'Pengaturan berhasil disimpan/diperbarui.',
        name: 'PengaturanOperasi.save',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error saat menyimpan pengaturan: $e',
        name: 'PengaturanOperasi.save',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
