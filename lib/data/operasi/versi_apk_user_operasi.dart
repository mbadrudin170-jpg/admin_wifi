// path: lib/data/operasi/versi_apk_user_operasi.dart

import 'dart:async';
import 'dart:convert'; // ditambahkan: untuk konversi ke JSON
import 'dart:developer' as developer;
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/data/sync/unggah_data.dart';
import 'package:admin_wifi/model/enum/arsitektur_apk_enum.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:admin_wifi/services/cek_koneksi_internet.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:sqflite/sqflite.dart';

class VersiApkUserOperasi {
  final DatabaseHelper dbHelper;
  // ditambah: dependensi untuk koneksi, unggah, dan sync manager
  final KoneksiInternetService koneksiService;
  final LayananUnggahData unggahService;
  final SyncManager syncManager;

  // diubah: konstruktor untuk menerima dependensi (dependency injection)
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
      // 1. Simpan ke database lokal terlebih dahulu
      final dataToSave = data.copyWith(diperbarui: DateTime.now());
      final dataUntukDb = dataToSave.toMapForSqlite();

      await db.insert(
        'versi_apk_user',
        dataUntukDb,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // ditambahkan: konversi map ke string JSON yang rapi
      const jsonEncoder = JsonEncoder.withIndent('  ');
      final dataJson = jsonEncoder.convert(dataUntukDb);

      // diubah: mencetak string JSON
      developer.log(
        'Berhasil menyimpan data ke lokal. Data yang disimpan:\n$dataJson',
        name: 'tambahVersiApkUser',
      );

      // 2. Coba sinkronisasi jika online
      // diubah: menggunakan instance koneksiService yang disuntikkan
      if (await koneksiService.cekKoneksi()) {
        developer.log(
          'Online, mencoba sinkronisasi data.',
          name: 'tambahVersiApkUser',
        );
        try {
          final syncTime = DateTime.now();
          // Memanggil unggah data dengan timeout
          // diubah: menggunakan instance unggahService yang disuntikkan
          await unggahService.unggahDataVersiApkUser().timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw TimeoutException('Batas waktu unggah terlampaui.'),
          );

          // diubah: menggunakan instance syncManager yang disuntikkan
          await syncManager.setLastSyncTimestamp(syncTime);

          developer.log(
            'Sinkronisasi berhasil, timestamp diperbarui.',
            name: 'tambahVersiApkUser',
          );
        } catch (e, s) {
          developer.log(
            'Sinkronisasi gagal, timestamp tidak diperbarui.',
            name: 'tambahVersiApkUser.Warning',
            error: e,
            stackTrace: s,
          );
          // Error tidak dilempar ulang karena penyimpanan lokal sudah sukses
        }
      } else {
        developer.log(
          'Offline, unggah data ditunda.',
          name: 'tambahVersiApkUser',
        );
      }
    } catch (e, s) {
      developer.log(
        'Gagal menyimpan data ke LOKAL.',
        name: 'tambahVersiApkUser.Error',
        error: e,
        stackTrace: s,
      );
      rethrow; // Lempar ulang jika penyimpanan LOKAL itu sendiri gagal
    }
  }

  Future<void> perbaruiVersiApkUser(VersiApkUserModel data) async {
    final db = await dbHelper.database;
    try {
      final dataToUpdate = data.copyWith(diperbarui: DateTime.now());
      // diubah: menggunakan toMapForSqlite() untuk konversi ke format SQLite
      await db.update(
        'versi_apk_user',
        dataToUpdate.toMapForSqlite(),
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

  Future<VersiApkUserModel?> ambilVersiApkTerbaru() async {
    try {
      final List<VersiApkUserModel> semuaVersiAktif =
          await ambilSemuaVersiApkAktif();

      if (semuaVersiAktif.isEmpty) {
        return null;
      }

      semuaVersiAktif.sort((a, b) {
        final buildA = a.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0;
        final buildB = b.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0;
        return buildA.compareTo(buildB);
      });

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
    List<VersiApkUserModel> daftarVersi,
  ) async {
    final db = await dbHelper.database;
    try {
      final batch = db.batch();
      for (var versi in daftarVersi) {
        final dataToSave = versi.copyWith(diperbarui: DateTime.now());
        // diubah: menggunakan toMapForSqlite() untuk konversi ke format SQLite
        batch.insert(
          'versi_apk_user',
          dataToSave.toMapForSqlite(),
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
  Future<List<VersiApkUserModel>> getVersiApkUserByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final db = await dbHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      'versi_apk_user',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return List.generate(maps.length, (i) {
      return VersiApkUserModel.fromMap(maps[i]);
    });
  }
}
