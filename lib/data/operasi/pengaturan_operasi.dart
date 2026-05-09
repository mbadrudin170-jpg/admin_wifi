// path: lib/data/operasi/pengaturan_operasi.dart
import 'dart:developer' as developer;
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/pengaturan_model.dart';

// Kelas untuk operasi database terkait tabel `pengaturan`.
class PengaturanOperasi {
  final _namaTabel = 'pengaturan';
  final String fileName = 'pengaturan_operasi.dart';

  // Mengambil data pengaturan dari database.
  Future<PengaturanModel> getPengaturan() async {
    try {
      developer.log('Memulai pengambilan data pengaturan (getPengaturan)', name: fileName);
      final db = await DatabaseHelper.instance.database;
      
      // diubah: Mengambil baris pertama karena hanya ada satu baris konfigurasi.
      final hasil = await db.query(_namaTabel, limit: 1);

      if (hasil.isNotEmpty) {
        developer.log('Data pengaturan ditemukan di database', name: fileName);
        return PengaturanModel.fromSqlite(hasil.first);
      } else {
        developer.log('Data pengaturan kosong, membuat pengaturan default', name: fileName);
        // Jika belum ada, buat pengaturan default
        final pengaturanDefault = PengaturanModel();
        await simpanAtauPerbaruiPengaturan(pengaturanDefault);
        return pengaturanDefault;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error saat mengambil pengaturan: $e',
        name: fileName,
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
      developer.log('Memulai simpanAtauPerbaruiPengaturan', name: fileName);
      final db = await DatabaseHelper.instance.database;
      final data = pengaturan.toSqlite();

      // diubah: Hapus data lama, lalu masukkan data baru untuk memastikan hanya ada 1 baris.
      await db.transaction((txn) async {
        developer.log('Menjalankan transaksi: Hapus dan Sisipkan data pengaturan baru', name: fileName);
        await txn.delete(_namaTabel);
        await txn.insert(_namaTabel, data);
      });

      developer.log(
        'Pengaturan berhasil disimpan/diperbarui.',
        name: fileName,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error saat menyimpan pengaturan: $e',
        name: fileName,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}