// path: lib/data/operasi/pengaturan_operasi.dart

import 'dart:developer' as developer;
import 'package:sqflite/sqflite.dart';

import '../sqlite.dart';
import '../../model/pengaturan_model.dart';

// Kelas untuk operasi database terkait tabel `pengaturan`.
class PengaturanOperasi {
  final _namaTabel = 'pengaturan';

  // Mengambil data pengaturan dari database.
  Future<PengaturanModel> getPengaturan() async {
    try {
      final db = await DatabaseHelper.instance.database;
      // diubah: Menambahkan id statis karena hanya ada satu baris
      final hasil = await db.query(_namaTabel, where: 'id = ?', whereArgs: [1]);

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
      
      // Menambahkan ID statis untuk operasi upsert
      data['id'] = 1;

      await db.insert(
        _namaTabel,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

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
