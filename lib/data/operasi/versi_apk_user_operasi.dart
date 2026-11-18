// path: lib/data/operasi/versi_apk_user_operasi.dart

import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/db/sqflite.dart';
import 'package:admin_wifi/enum/enum.dart';
import 'package:admin_wifi/fitur/versi_apk_user/model/versi_apk_user_model.dart';
import 'package:share_global_saya/src/utils/l.dart';

class VersiApkUserOperasi {
  final _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'versi_apk_user';
  final OperasiDasar _operasi;

  VersiApkUserOperasi({OperasiDasar? operasi})
    : _operasi = operasi ?? OperasiDasar() {
    L.i(
      'VersiApkUserOperasi diinisialisasi - Tabel: $_tableName, OperasiDasar: ${operasi != null ? "dari parameter" : "instance baru"}',
    );
  }

  // ==========================
  // OPERASI TULIS (WRITE)
  // ==========================

  Future<void> tambahVersiApkUser(VersiApkUserModel versiApkUser) async {
    L.i(
      'Menambah versi APK user baru - ID: ${versiApkUser.id}, Versi: ${versiApkUser.versiTerbaru}',
    );
    L.i(
      'Detail data - Build Universal: ${versiApkUser.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}, Build ARM64: ${versiApkUser.nomorBuildTerbaru[ArsitekturApkEnum.arm64] ?? 0}, Build X86_64: ${versiApkUser.nomorBuildTerbaru[ArsitekturApkEnum.x86_64] ?? 0}, Catatan: ${versiApkUser.catatanRilis.length > 50 ? "${versiApkUser.catatanRilis.substring(0, 50)}..." : versiApkUser.catatanRilis}',
    );

    try {
      await _operasi.sisipkan(_tableName, versiApkUser.toSqlite());
      L.i(
        'Versi APK user berhasil ditambahkan ke tabel $_tableName - ID: ${versiApkUser.id}',
      );
    } catch (e, stackTrace) {
      L.e(
        'Gagal menambah versi APK user - ID: ${versiApkUser.id}, Versi: ${versiApkUser.versiTerbaru} Error: $e $stackTrace',
      );
      rethrow;
    }
  }

  Future<void> perbaruiVersiApkUser(VersiApkUserModel versiApkUser) async {
    L.i(
      'Memperbarui versi APK user - ID: ${versiApkUser.id}, Versi: ${versiApkUser.versiTerbaru}',
    );
    L.i(
      'Data baru - Build Universal: ${versiApkUser.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}, Build ARM64: ${versiApkUser.nomorBuildTerbaru[ArsitekturApkEnum.arm64] ?? 0}, Build X86_64: ${versiApkUser.nomorBuildTerbaru[ArsitekturApkEnum.x86_64] ?? 0}',
    );

    try {
      await _operasi.perbarui(
        _tableName,
        versiApkUser.toSqlite(),
        versiApkUser.id,
      );
      L.i(
        'Versi APK user berhasil diperbarui di tabel $_tableName - ID: ${versiApkUser.id}',
      );
    } catch (e, stackTrace) {
      L.e(
        'Gagal memperbarui versi APK user - ID: ${versiApkUser.id}, Versi: ${versiApkUser.versiTerbaru} Error: $e $stackTrace',
      );
      rethrow;
    }
  }

  Future<void> arsipkanVersiApkUser(String id) async {
    L.i('Mengarsipkan versi APK user - ID: $id');

    try {
      final db = await _dbHelper.database;
      L.i('Mencari data versi APK user ID: $id di tabel $_tableName');

      final data = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);

      if (data.isNotEmpty) {
        final model = VersiApkUserModel.fromSqlite(data.first);
        L.i(
          'Data ditemukan - Versi: ${model.versiTerbaru}, Build Universal: ${model.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}, isDeleted: ${model.isDeleted}',
        );

        final modelDiarsipkan = model.copyWith(
          isDeleted: true,
          diarsipkan: DateTime.now(),
        );

        L.i(
          'Menandai isDeleted=true, diarsipkan=${modelDiarsipkan.diarsipkan?.toIso8601String()}',
        );
        await _operasi.perbarui(_tableName, modelDiarsipkan.toSqlite(), id);

        L.i(
          'Versi APK user berhasil diarsipkan - ID: $id, Waktu arsip: ${modelDiarsipkan.diarsipkan?.toIso8601String()}',
        );
      } else {
        L.i(
          'Data versi APK user ID: $id tidak ditemukan di tabel $_tableName, tidak dapat mengarsipkan',
        );
      }
    } catch (e, stackTrace) {
      L.e('Gagal mengarsipkan versi APK user - ID: $id Error: $e $stackTrace');
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    List<VersiApkUserModel> daftarModel,
  ) async {
    L.i(
      'Memulai operasi batch sisipkan/perbarui - Jumlah data: ${daftarModel.length}, Tabel: $_tableName',
    );

    if (daftarModel.isEmpty) {
      L.i('Daftar model kosong, tidak ada data yang diproses dalam batch');
      return;
    }

    try {
      final daftarMap = daftarModel.map((model) => model.toSqlite()).toList();
      L.i('${daftarModel.length} model berhasil dikonversi ke Map SQLite');

      await _operasi.sisipkanAtauPerbaruiBatch(_tableName, daftarMap);
      L.i(
        'Operasi batch berhasil - ${daftarMap.length} data diproses di tabel $_tableName',
      );
    } catch (e, stackTrace) {
      L.e(
        'Gagal melakukan operasi batch - Jumlah data: ${daftarModel.length}, Tabel: $_tableName Error: $e $stackTrace',
      );
      rethrow;
    }
  }

  // ==========================
  // OPERASI BACA (READ)
  // ==========================

  Future<List<VersiApkUserModel>> ambilSemuaVersiApk() async {
    L.i(
      'Mengambil semua data versi APK dari tabel $_tableName (termasuk yang diarsipkan)',
    );

    try {
      final db = await _dbHelper.database;
      L.i('Query: SELECT * FROM $_tableName ORDER BY diperbarui DESC');

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'diperbarui DESC',
      );

      final result = List.generate(
        maps.length,
        (i) => VersiApkUserModel.fromSqlite(maps[i]),
      );

      // Log ringkasan
      int jumlahAktif = 0;
      int jumlahDiarsipkan = 0;
      for (var model in result) {
        if (model.isDeleted) {
          jumlahDiarsipkan++;
        } else {
          jumlahAktif++;
        }
      }

      L.i(
        'Berhasil mengambil ${result.length} data versi APK - Aktif: $jumlahAktif, Diarsipkan: $jumlahDiarsipkan',
      );
      return result;
    } catch (e, stackTrace) {
      L.e(
        'Gagal mengambil semua data versi APK dari tabel $_tableName, mengembalikan list kosong Error: $e $stackTrace',
      );
      return [];
    }
  }

  Future<List<VersiApkUserModel>> ambilSemuaVersiApkAktif() async {
    L.i(
      'Mengambil semua versi APK aktif (isDeleted = 0) dari tabel $_tableName',
    );

    try {
      final db = await _dbHelper.database;
      L.i(
        'Query: SELECT * FROM $_tableName WHERE isDeleted = 0 ORDER BY diperbarui DESC',
      );

      final maps = await db.query(
        _tableName,
        where: 'isDeleted = 0',
        orderBy: 'diperbarui DESC',
      );

      final result = List.generate(
        maps.length,
        (i) => VersiApkUserModel.fromSqlite(maps[i]),
      );

      L.i('Berhasil mengambil ${result.length} versi APK aktif');

      // Log 3 data teratas
      for (int i = 0; i < (result.length < 3 ? result.length : 3); i++) {
        final v = result[i];
        L.i(
          '  ${i + 1}. ID: ${v.id}, Versi: ${v.versiTerbaru}, Build Universal: ${v.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}',
        );
      }

      return result;
    } catch (e, stackTrace) {
      L.e(
        'Gagal mengambil versi APK aktif dari tabel $_tableName, mengembalikan list kosong Error: $e $stackTrace',
      );
      return [];
    }
  }

  Future<VersiApkUserModel?> ambilVersiApkTerbaru() async {
    L.i('Mengambil versi APK terbaru (aktif) dari tabel $_tableName');

    try {
      final db = await _dbHelper.database;
      L.i(
        'Query: SELECT * FROM $_tableName WHERE isDeleted = 0 ORDER BY diperbarui DESC LIMIT 1',
      );

      final maps = await db.query(
        _tableName,
        where: 'isDeleted = 0',
        orderBy: 'diperbarui DESC',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        final model = VersiApkUserModel.fromSqlite(maps.first);
        L.i(
          'Versi APK terbaru ditemukan - ID: ${model.id}, Versi: ${model.versiTerbaru}, Build Universal: ${model.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}, Diperbarui: ${model.diperbarui?.toIso8601String()}',
        );
        return model;
      }

      L.i('Tidak ada versi APK aktif yang ditemukan di tabel $_tableName');
      return null;
    } catch (e, stackTrace) {
      L.e(
        'Gagal mengambil versi APK terbaru dari tabel $_tableName, mengembalikan null Error: $e $stackTrace',
      );
      return null;
    }
  }

  Future<VersiApkUserModel?> ambilVersiApkById(String id) async {
    L.i('Mengambil versi APK by ID: $id dari tabel $_tableName');

    try {
      final db = await _dbHelper.database;
      L.i('Query: SELECT * FROM $_tableName WHERE id = $id AND isDeleted = 0');

      final maps = await db.query(
        _tableName,
        where: 'id = ? AND isDeleted = 0',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final model = VersiApkUserModel.fromSqlite(maps.first);
        L.i(
          'Versi APK ditemukan - ID: $id, Versi: ${model.versiTerbaru}, Build Universal: ${model.nomorBuildTerbaru[ArsitekturApkEnum.universal] ?? 0}, Catatan: ${model.catatanRilis.length > 50 ? "${model.catatanRilis.substring(0, 50)}..." : model.catatanRilis}',
        );
        return model;
      }

      L.i(
        'Versi APK dengan ID: $id tidak ditemukan (mungkin sudah diarsipkan atau tidak ada)',
      );
      return null;
    } catch (e, stackTrace) {
      L.e(
        'Gagal mengambil versi APK by ID: $id dari tabel $_tableName, mengembalikan null Error: $e $stackTrace',
      );
      return null;
    }
  }
}
