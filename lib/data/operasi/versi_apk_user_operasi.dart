// path: lib/data/operasi/versi_apk_user_operasi.dart

import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'dart:developer' as developer;
import 'package:admin_wifi/data/sqlite.dart';
import 'package:sqflite/sqflite.dart';

// untuk mengelola operasi data terkait VersiApkUserModel
class VersiApkUserOperasi {
  final dbHelper = DatabaseHelper.instance;
  Future<VersiApkUserModel?> ambilVersiApkById(
    String id, {
    bool termasukDihapus = false,
  }) async {
    final db = await dbHelper.database;

    final where = termasukDihapus ? 'id = ?' : 'id = ? AND isDeleted = 0';

    final maps = await db.query(
      'versi_apk_user',
      where: where,
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return VersiApkUserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<VersiApkUserModel>> ambilSemuaVersiApkAktif() async {
    final db = await dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'versi_apk_user',
        where: 'IFNULL(isDeleted, 0) = ?',
        whereArgs: [0],
        orderBy: 'diperbarui DESC',
      );

      return maps.map((map) => VersiApkUserModel.fromMap(map)).toList();
    } catch (e, s) {
      developer.log(
        'Gagal mengambil semua versi APK aktif',
        name: 'VersiApkUserOperasi.Error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  // diubah: mengambil SEMUA data versi apk, termasuk yang diarsip.
  Future<List<VersiApkUserModel>> ambilSemuaVersiApk() async {
    final db = await dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'versi_apk_user',
        orderBy: 'diperbarui DESC',
      );

      if (maps.isNotEmpty) {
        return maps.map((map) => VersiApkUserModel.fromMap(map)).toList();
      } else {
        return [];
      }
    } catch (e, s) {
      developer.log(
        'Gagal mengambil semua versi APK (termasuk yang diarsip)',
        name: 'VersiApkUserOperasi.Error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  // ditambah: fungsi untuk MENAMBAH data versi apk baru ke database
  Future<void> tambahVersiApkUser(VersiApkUserModel data) async {
    final db = await dbHelper.database;
    try {
      final dataToSave = data.copyWith(diperbarui: DateTime.now());

      await db.insert(
        'versi_apk_user',
        dataToSave.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      developer.log(
        'Berhasil MENAMBAH versi apk dengan ID: ${data.id}',
        name: 'VersiApkUserOperasi',
      );
    } catch (e, s) {
      developer.log(
        'Gagal MENAMBAH versi apk dengan ID: ${data.id}',
        name: 'VersiApkUserOperasi.Error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  // ditambah: fungsi untuk MEMPERBARUI data versi apk yang ada di database
  Future<void> perbaruiVersiApkUser(VersiApkUserModel data) async {
    final db = await dbHelper.database;
    try {
      final dataToSave = data.copyWith(diperbarui: DateTime.now());

      await db.update(
        'versi_apk_user',
        dataToSave.toMap(),
        where: 'id = ?',
        whereArgs: [data.id],
      );
      developer.log(
        'Berhasil MEMPERBARUI versi apk dengan ID: ${data.id}',
        name: 'VersiApkUserOperasi',
      );
    } catch (e, s) {
      developer.log(
        'Gagal MEMPERBARUI versi apk dengan ID: ${data.id}',
        name: 'VersiApkUserOperasi.Error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  // ditambah: fungsi untuk operasi batch insert/update dari server
  Future<void> sisipkanAtauPerbaruiBatch(
    List<VersiApkUserModel> daftarVersi,
  ) async {
    final db = await dbHelper.database;
    final batch = db.batch();

    for (var versi in daftarVersi) {
      batch.insert(
        'versi_apk_user',
        versi.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    try {
      await batch.commit(noResult: true);
      developer.log(
        'Batch insert/update berhasil untuk ${daftarVersi.length} item di tabel versi_apk_user.',
        name: 'VersiApkUserOperasi',
      );
    } catch (e, s) {
      developer.log(
        'Gagal melakukan batch insert/update di tabel versi_apk_user.',
        name: 'VersiApkUserOperasi.Error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  // ditambah: fungsi untuk mengarsipkan data versi apk
  Future<void> arsipkanVersiApkUser(String id) async {
    final db = await dbHelper.database;
    try {
      final now = DateTime.now().toIso8601String();
      final count = await db.update(
        'versi_apk_user',
        {'diarsipkan': now, 'isDeleted': 1, 'diperbarui': now},
        where: 'id = ?',
        whereArgs: [id],
      );
      developer.log(
        'Berhasil mengarsipkan versi apk dengan ID: $id. Jumlah baris terpengaruh: $count',
        name: 'VersiApkUserOperasi',
      );
    } catch (e, s) {
      developer.log(
        'Gagal mengarsipkan versi apk dengan ID: $id',
        name: 'VersiApkUserOperasi.Error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}
