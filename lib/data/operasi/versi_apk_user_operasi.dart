// path: lib/data/operasi/versi_apk_user_operasi.dart

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/data/sync/unggah_data.dart';
import 'package:admin_wifi/enum/arsitektur_apk_enum.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:admin_wifi/services/cek_koneksi_internet.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:sqflite/sqflite.dart';

class VersiApkUserOperasi {
  final DatabaseHelper dbHelper;
  final KoneksiInternetService koneksiService;
  final LayananUnggahData unggahService;
  final SyncManager syncManager;

  VersiApkUserOperasi({
    DatabaseHelper? dbHelper,
    KoneksiInternetService? koneksiService,
    LayananUnggahData? unggahService,
    SyncManager? syncManager,
  }) : dbHelper = dbHelper ?? DatabaseHelper.instance,
       koneksiService = koneksiService ?? KoneksiInternetService(),
       unggahService = unggahService ?? LayananUnggahData(),
       syncManager = syncManager ?? SyncManager();

  Future<void> tambahVersiApkUser(VersiApkUserModel data) async {
    final db = await dbHelper.database;
    try {
      final dataToSave = data.copyWith(diperbarui: DateTime.now());
      final dataUntukDb = dataToSave.toSqlite();

      await db.insert(
        'versi_apk_user',
        dataUntukDb,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      const jsonEncoder = JsonEncoder.withIndent('  ');
      final dataJson = jsonEncoder.convert(dataUntukDb);

      developer.log(
        '✅ [versi_apk_user_operasi.dart] -> [tambahVersiApkUser] -> Berhasil menyimpan data ke lokal. Data:\n$dataJson',
        name: 'tambahVersiApkUser.Success',
      );

      if (await koneksiService.cekKoneksi()) {
        developer.log(
          '🌐 [versi_apk_user_operasi.dart] -> [tambahVersiApkUser] -> Online, mencoba sinkronisasi data.',
          name: 'tambahVersiApkUser.Info',
        );
        try {
          final syncTime = DateTime.now();
          await unggahService.unggahDataVersiApkUser().timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw TimeoutException('Batas waktu unggah terlampaui.'),
          );

          await syncManager.setLastSyncTimestamp(syncTime);

          developer.log(
            '🚀 [versi_apk_user_operasi.dart] -> [tambahVersiApkUser] -> Sinkronisasi berhasil, timestamp diperbarui.',
            name: 'tambahVersiApkUser.SyncSuccess',
          );
        } catch (e, s) {
          developer.log(
            '⚠️ [versi_apk_user_operasi.dart] -> [tambahVersiApkUser] -> Sinkronisasi gagal, timestamp tidak diperbarui.',
            name: 'tambahVersiApkUser.SyncWarning',
            error: e,
            stackTrace: s,
          );
        }
      } else {
        developer.log(
          '📴 [versi_apk_user_operasi.dart] -> [tambahVersiApkUser] -> Offline, unggah data ditunda.',
          name: 'tambahVersiApkUser.Offline',
        );
      }
    } catch (e, s) {
      developer.log(
        '❌ [versi_apk_user_operasi.dart] -> [tambahVersiApkUser] -> Gagal menyimpan data ke LOKAL.',
        name: 'tambahVersiApkUser.Error',
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
        dataToUpdate.toSqlite(),
        where: 'id = ?',
        whereArgs: [data.id],
      );
      developer.log(
        '✅ [versi_apk_user_operasi.dart] -> [perbaruiVersiApkUser] -> Berhasil memperbarui data ID: ${data.id}',
        name: 'perbaruiVersiApkUser.Success',
      );
    } catch (e, s) {
      developer.log(
        '❌ [versi_apk_user_operasi.dart] -> [perbaruiVersiApkUser] -> Gagal memperbarui versi apk user',
        name: 'perbaruiVersiApkUser.Error',
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
      developer.log(
        '📦 [versi_apk_user_operasi.dart] -> [arsipkanVersiApkUser] -> Berhasil mengarsipkan data ID: $id',
        name: 'arsipkanVersiApkUser.Success',
      );
    } catch (e, s) {
      developer.log(
        '❌ [versi_apk_user_operasi.dart] -> [arsipkanVersiApkUser] -> Gagal mengarsipkan versi apk user',
        name: 'arsipkanVersiApkUser.Error',
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
      final hasil = List.generate(maps.length, (i) {
        return VersiApkUserModel.fromSqlite(maps[i]);
      });
      developer.log(
        '📊 [versi_apk_user_operasi.dart] -> [ambilSemuaVersiApk] -> Berhasil mengambil ${hasil.length} data',
        name: 'ambilSemuaVersiApk.Success',
      );
      return hasil;
    } catch (e, s) {
      developer.log(
        '❌ [versi_apk_user_operasi.dart] -> [ambilSemuaVersiApk] -> Gagal mengambil semua versi apk',
        name: 'ambilSemuaVersiApk.Error',
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
      final hasil = List.generate(maps.length, (i) {
        return VersiApkUserModel.fromSqlite(maps[i]);
      });
      developer.log(
        '✅ [versi_apk_user_operasi.dart] -> [ambilSemuaVersiApkAktif] -> Berhasil mengambil ${hasil.length} data aktif',
        name: 'ambilSemuaVersiApkAktif.Success',
      );
      return hasil;
    } catch (e, s) {
      developer.log(
        '❌ [versi_apk_user_operasi.dart] -> [ambilSemuaVersiApkAktif] -> Gagal mengambil semua versi apk aktif',
        name: 'ambilSemuaVersiApkAktif.Error',
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
        developer.log(
          '🔍 [versi_apk_user_operasi.dart] -> [ambilVersiApkById] -> Data ID: $id ditemukan',
          name: 'ambilVersiApkById.Success',
        );
        return VersiApkUserModel.fromSqlite(maps.first);
      }
      developer.log(
        '⚠️ [versi_apk_user_operasi.dart] -> [ambilVersiApkById] -> Data ID: $id tidak ditemukan',
        name: 'ambilVersiApkById.NotFound',
      );
      return null;
    } catch (e, s) {
      developer.log(
        '❌ [versi_apk_user_operasi.dart] -> [ambilVersiApkById] -> Gagal mengambil versi apk by id',
        name: 'ambilVersiApkById.Error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<VersiApkUserModel?> ambilVersiApkTerbaru() async {
    try {
      final List<VersiApkUserModel> semuaVersiAktif =
          await ambilSemuaVersiApkAktif();

      if (semuaVersiAktif.isEmpty) {
        developer.log(
          'ℹ️ [versi_apk_user_operasi.dart] -> [ambilVersiApkTerbaru] -> Tidak ada data versi aktif',
          name: 'ambilVersiApkTerbaru.Info',
        );
        return null;
      }

      semuaVersiAktif.sort((a, b) {
        final buildA = a.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0;
        final buildB = b.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0;
        return buildA.compareTo(buildB);
      });

      developer.log(
        '🔝 [versi_apk_user_operasi.dart] -> [ambilVersiApkTerbaru] -> Berhasil memproses versi terbaru',
        name: 'ambilVersiApkTerbaru.Success',
      );
      return semuaVersiAktif.last;
    } catch (e, s) {
      developer.log(
        '❌ [versi_apk_user_operasi.dart] -> [ambilVersiApkTerbaru] -> Gagal mengambil dan memproses versi APK terbaru',
        name: 'ambilVersiApkTerbaru.Error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    List<VersiApkUserModel> daftarVersi,
  ) async {
    final db = await dbHelper.database;
    try {
      final batch = db.batch();
      for (var versi in daftarVersi) {
        final dataToSave = versi.copyWith(diperbarui: DateTime.now());
        batch.insert(
          'versi_apk_user',
          dataToSave.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      developer.log(
        '📚 [versi_apk_user_operasi.dart] -> [sisipkanAtauPerbaruiBatch] -> Berhasil memproses ${daftarVersi.length} data dalam batch',
        name: 'sisipkanAtauPerbaruiBatch.Success',
      );
    } catch (e, s) {
      developer.log(
        '❌ [versi_apk_user_operasi.dart] -> [sisipkanAtauPerbaruiBatch] -> Gagal melakukan sisip atau perbarui batch',
        name: 'sisipkanAtauPerbaruiBatch.Error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<List<VersiApkUserModel>> getVersiApkUserByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final db = await dbHelper.database;
    try {
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'versi_apk_user',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      final hasil = List.generate(maps.length, (i) {
        return VersiApkUserModel.fromSqlite(maps[i]);
      });
      developer.log(
        '🔗 [versi_apk_user_operasi.dart] -> [getVersiApkUserByIds] -> Berhasil mengambil ${hasil.length} data berdasarkan IDs',
        name: 'getVersiApkUserByIds.Success',
      );
      return hasil;
    } catch (e, s) {
      developer.log(
        '❌ [versi_apk_user_operasi.dart] -> [getVersiApkUserByIds] -> Gagal mengambil data berdasarkan IDs',
        name: 'getVersiApkUserByIds.Error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}
