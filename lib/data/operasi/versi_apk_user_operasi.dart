// path: lib/data/operasi/versi_apk_user_operasi.dart

import 'dart:developer' as developer;
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:sqflite/sqflite.dart';

class VersiApkUserOperasi {
  final DatabaseHelper dbHelper;

  VersiApkUserOperasi({DatabaseHelper? dbHelper})
      : dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<void> tambahVersiApkUser(VersiApkUserModel data) async {
    final db = await dbHelper.database;
    try {
      final dataToSave = data.copyWith(diperbarui: DateTime.now());
      await db.insert(
        'versi_apk_user',
        dataToSave.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, s) {
      developer.log(
        'Gagal menambah data versi apk user',
        name: 'tambahVersiApkUser',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<void> perbaruiVersiApkUser(VersiApkUserModel data) async {
    final db = await dbHelper.database;
    try {
      final dataToUpdate = data.copyWith(diperbarui: DateTime.now());
      await db.update(
        'versi_apk_user',
        dataToUpdate.toMap(),
        where: 'id = ?',
        whereArgs: [data.id],
      );
    } catch (e, s) {
      developer.log(
        'Gagal memperbarui versi apk user',
        name: 'perbaruiVersiApkUser',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<void> arsipkanVersiApkUser(String id) async {
    final db = await dbHelper.database;
    try {
      final now = DateTime.now();
      await db.update(
        'versi_apk_user',
        {
          'isDeleted': 1,
          'diarsipkan': now.toIso8601String(),
          'diperbarui': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, s) {
      developer.log(
        'Gagal mengarsipkan versi apk user',
        name: 'arsipkanVersiApkUser',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<List<VersiApkUserModel>> ambilSemuaVersiApk() async {
    final db = await dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('versi_apk_user');
      return List.generate(maps.length, (i) {
        return VersiApkUserModel.fromMap(maps[i]);
      });
    } catch (e, s) {
      developer.log(
        'Gagal mengambil semua versi apk',
        name: 'ambilSemuaVersiApk',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
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
      return List.generate(maps.length, (i) {
        return VersiApkUserModel.fromMap(maps[i]);
      });
    } catch (e, s) {
      developer.log(
        'Gagal mengambil semua versi apk aktif',
        name: 'ambilSemuaVersiApkAktif',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<VersiApkUserModel?> ambilVersiApkById(String id) async {
    final db = await dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'versi_apk_user',
        where: 'id = ? AND IFNULL(isDeleted, 0) = ?',
        whereArgs: [id, 0],
      );

      if (maps.isNotEmpty) {
        return VersiApkUserModel.fromMap(maps.first);
      }
      return null;
    } catch (e, s) {
      developer.log(
        'Gagal mengambil versi apk by id',
        name: 'ambilVersiApkById',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  // diubah: mengambil versi APK dengan build tertinggi.
  Future<VersiApkUserModel?> ambilVersiApkTerbaru() async {
    try {
      // 1. Ambil semua versi yang aktif
      final List<VersiApkUserModel> semuaVersiAktif = await ambilSemuaVersiApkAktif();

      if (semuaVersiAktif.isEmpty) {
        return null;
      }

      // 2. Urutkan berdasarkan nomor build 'universal'
      semuaVersiAktif.sort((a, b) {
        final buildA = a.nomorBuildTerbaru['universal'] ?? 0;
        final buildB = b.nomorBuildTerbaru['universal'] ?? 0;
        return buildA.compareTo(buildB); // Langsung bandingkan nomor build
      });

      // 3. Kembalikan versi terakhir dari daftar (build tertinggi)
      return semuaVersiAktif.last;
    } catch (e, s) {
      developer.log(
        'Gagal mengambil dan memproses versi APK terbaru',
        name: 'VersiApkUserOperasi.Error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
      List<VersiApkUserModel> daftarVersi) async {
    final db = await dbHelper.database;
    try {
      final batch = db.batch();
      for (var versi in daftarVersi) {
        final dataToSave = versi.copyWith(diperbarui: DateTime.now());
        batch.insert(
          'versi_apk_user',
          dataToSave.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e, s) {
      developer.log(
        'Gagal melakukan sisip atau perbarui batch',
        name: 'sisipkanAtauPerbaruiBatch',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}
