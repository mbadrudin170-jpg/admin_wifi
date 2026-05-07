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
      final hasil = await db.query(_namaTabel, limit: 1);

      if (hasil.isNotEmpty) {
        return PengaturanModel.fromMap(hasil.first);
      } else {
        // diubah: Mengembalikan model dengan nilai default eksplisit
        return PengaturanModel(
          intervalSinkronisasiOtomatis: 24,
          hapusOtomatisDataArsip: 30,
          modePemeliharaan: false,
          infoPemeliharaan: '',
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error saat mengambil pengaturan: $e',
        name: 'PengaturanOperasi.get',
        error: e,
        stackTrace: stackTrace,
      );
      // diubah: Mengembalikan model default jika terjadi error
      return PengaturanModel(
        intervalSinkronisasiOtomatis: 24,
        hapusOtomatisDataArsip: 30,
        modePemeliharaan: false,
        infoPemeliharaan: '',
      );
    }
  }

  // Menyimpan atau memperbarui data pengaturan.
  Future<void> simpanAtauPerbaruiPengaturan(PengaturanModel pengaturan) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final hasil = await db.query(_namaTabel, limit: 1);

      if (hasil.isNotEmpty) {
        await db.update(
          _namaTabel,
          pengaturan.toMapForSqlite(),
        );
      } else {
        await db.insert(
          _namaTabel,
          pengaturan.toMapForSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      developer.log('Pengaturan berhasil disimpan.', name: 'PengaturanOperasi.save');
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
