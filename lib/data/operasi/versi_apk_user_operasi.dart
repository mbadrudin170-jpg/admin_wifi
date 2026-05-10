// path: lib/data/operasi/versi_apk_user_operasi.dart

import 'dart:developer' as developer;
import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';

class VersiApkUserOperasi {
  final _dbHelper = DatabaseHelper.instance;
  final String _tableName = 'versi_apk_user';
  final OperasiDasar _operasi;

  VersiApkUserOperasi({OperasiDasar? operasi})
    : _operasi = operasi ?? OperasiDasar() {
    developer.log(
      'VersiApkUserOperasi berhasil diinisialisasi dengan tabel: $_tableName',
      name: 'VersiApkUserOperasi-Constructor 🚀',
    );
  }

  // ==========================
  // OPERASI TULIS (WRITE)
  // ==========================

  Future<void> tambahVersiApkUser(VersiApkUserModel versiApkUser) async {
    developer.log(
      'Menambah versi APK user baru | ID: ${versiApkUser.id} | Versi: ${versiApkUser.versiTerbaru}',
      name: 'VersiApkUserOperasi-tambahVersiApkUser ℹ️',
    );

    try {
      await _operasi.sisipkan(_tableName, versiApkUser.toSqlite());

      developer.log(
        'Versi APK user berhasil ditambahkan | ID: ${versiApkUser.id}',
        name: 'VersiApkUserOperasi-tambahVersiApkUser ✅',
      );
    } catch (e) {
      developer.log(
        'Gagal menambah versi APK user | ID: ${versiApkUser.id} | Error: $e',
        name: 'VersiApkUserOperasi-tambahVersiApkUser ❌',
        error: e,
      );
      rethrow;
    }
  }

  // ditambah: Fungsionalitas pembaruan dikembalikan
  Future<void> perbaruiVersiApkUser(VersiApkUserModel versiApkUser) async {
    developer.log(
      'Memperbarui versi APK user | ID: ${versiApkUser.id} | Versi: ${versiApkUser.versiTerbaru}',
      name: 'VersiApkUserOperasi-perbaruiVersiApkUser ℹ️',
    );

    try {
      await _operasi.perbarui(
        _tableName,
        versiApkUser.toSqlite(),
        versiApkUser.id,
      );

      developer.log(
        'Versi APK user berhasil diperbarui | ID: ${versiApkUser.id}',
        name: 'VersiApkUserOperasi-perbaruiVersiApkUser ✅',
      );
    } catch (e) {
      developer.log(
        'Gagal memperbarui versi APK user | ID: ${versiApkUser.id} | Error: $e',
        name: 'VersiApkUserOperasi-perbaruiVersiApkUser ❌',
        error: e,
      );
      rethrow;
    }
  }

  // ditambah: Fungsionalitas arsip dikembalikan
  Future<void> arsipkanVersiApkUser(String id) async {
    developer.log(
      'Mengarsipkan versi APK user | ID: $id',
      name: 'VersiApkUserOperasi-arsipkanVersiApkUser ℹ️',
    );

    try {
      final db = await _dbHelper.database;

      developer.log(
        'Mencari data versi APK user untuk diarsipkan | ID: $id',
        name: 'VersiApkUserOperasi-arsipkanVersiApkUser 🔄',
      );

      final data = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);

      if (data.isNotEmpty) {
        developer.log(
          'Data ditemukan, menyiapkan model untuk diarsipkan | ID: $id',
          name: 'VersiApkUserOperasi-arsipkanVersiApkUser 📝',
        );

        final model = VersiApkUserModel.fromSqlite(
          data.first,
        ).copyWith(isDeleted: true, diarsipkan: DateTime.now());

        await _operasi.perbarui(_tableName, model.toSqlite(), id);

        developer.log(
          'Versi APK user berhasil diarsipkan | ID: $id | Waktu arsip: ${model.diarsipkan}',
          name: 'VersiApkUserOperasi-arsipkanVersiApkUser ✅',
        );
      } else {
        developer.log(
          'Data tidak ditemukan untuk diarsipkan | ID: $id',
          name: 'VersiApkUserOperasi-arsipkanVersiApkUser ⚠️',
        );
      }
    } catch (e) {
      developer.log(
        'Gagal mengarsipkan versi APK user | ID: $id | Error: $e',
        name: 'VersiApkUserOperasi-arsipkanVersiApkUser ❌',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    List<VersiApkUserModel> daftarModel,
  ) async {
    developer.log(
      'Memulai operasi batch sisipkan/perbarui | Jumlah data: ${daftarModel.length}',
      name: 'VersiApkUserOperasi-sisipkanAtauPerbaruiBatch ℹ️',
    );

    if (daftarModel.isEmpty) {
      developer.log(
        'Daftar model kosong, tidak ada yang diproses',
        name: 'VersiApkUserOperasi-sisipkanAtauPerbaruiBatch ⚠️',
      );
      return;
    }

    try {
      final daftarMap = daftarModel.map((model) => model.toSqlite()).toList();

      developer.log(
        'Konversi ${daftarModel.length} model ke Map selesai, memulai operasi batch',
        name: 'VersiApkUserOperasi-sisipkanAtauPerbaruiBatch 🔄',
      );

      await _operasi.sisipkanAtauPerbaruiBatch(_tableName, daftarMap);

      developer.log(
        'Operasi batch berhasil | ${daftarMap.length} data diproses di tabel: $_tableName',
        name: 'VersiApkUserOperasi-sisipkanAtauPerbaruiBatch ✅',
      );
    } catch (e) {
      developer.log(
        'Gagal melakukan operasi batch | Jumlah data: ${daftarModel.length} | Error: $e',
        name: 'VersiApkUserOperasi-sisipkanAtauPerbaruiBatch ❌',
        error: e,
      );
      rethrow;
    }
  }

  // ==========================
  // OPERASI BACA (READ)
  // ==========================

  // diubah: Nama generik getVersiApkUser diganti menjadi nama yang lebih spesifik
  Future<List<VersiApkUserModel>> ambilSemuaVersiApk() async {
    developer.log(
      'Mengambil semua data versi APK dari tabel: $_tableName',
      name: 'VersiApkUserOperasi-ambilSemuaVersiApk ℹ️',
    );

    try {
      final db = await _dbHelper.database;

      developer.log(
        'Menjalankan query SELECT * FROM $_tableName ORDER BY diperbarui DESC',
        name: 'VersiApkUserOperasi-ambilSemuaVersiApk 🔄',
      );

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'diperbarui DESC',
      );

      final result = List.generate(
        maps.length,
        (i) => VersiApkUserModel.fromSqlite(maps[i]),
      );

      developer.log(
        'Berhasil mengambil semua data versi APK | Jumlah data: ${result.length}',
        name: 'VersiApkUserOperasi-ambilSemuaVersiApk ✅',
      );

      return result;
    } catch (e) {
      developer.log(
        'Gagal mengambil semua data versi APK | Error: $e | Mengembalikan list kosong',
        name: 'VersiApkUserOperasi-ambilSemuaVersiApk ❌',
        error: e,
      );
      return [];
    }
  }

  // ditambah: Fungsionalitas ambil data aktif dikembalikan
  Future<List<VersiApkUserModel>> ambilSemuaVersiApkAktif() async {
    developer.log(
      'Mengambil semua versi APK aktif (isDeleted = 0) dari tabel: $_tableName',
      name: 'VersiApkUserOperasi-ambilSemuaVersiApkAktif ℹ️',
    );

    try {
      final db = await _dbHelper.database;

      developer.log(
        'Menjalankan query SELECT * FROM $_tableName WHERE isDeleted = 0 ORDER BY diperbarui DESC',
        name: 'VersiApkUserOperasi-ambilSemuaVersiApkAktif 🔄',
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

      developer.log(
        'Berhasil mengambil versi APK aktif | Jumlah data: ${result.length}',
        name: 'VersiApkUserOperasi-ambilSemuaVersiApkAktif ✅',
      );

      return result;
    } catch (e) {
      developer.log(
        'Gagal mengambil versi APK aktif | Error: $e | Mengembalikan list kosong',
        name: 'VersiApkUserOperasi-ambilSemuaVersiApkAktif ❌',
        error: e,
      );
      return [];
    }
  }

  // ditambah: Fungsionalitas ambil data terbaru dikembalikan
  Future<VersiApkUserModel?> ambilVersiApkTerbaru() async {
    developer.log(
      'Mengambil versi APK terbaru (aktif) dari tabel: $_tableName',
      name: 'VersiApkUserOperasi-ambilVersiApkTerbaru ℹ️',
    );

    try {
      final db = await _dbHelper.database;

      developer.log(
        'Menjalankan query SELECT * FROM $_tableName WHERE isDeleted = 0 ORDER BY diperbarui DESC LIMIT 1',
        name: 'VersiApkUserOperasi-ambilVersiApkTerbaru 🔄',
      );

      final maps = await db.query(
        _tableName,
        where: 'isDeleted = 0',
        orderBy:
            'diperbarui DESC', // Asumsi versi terbaru adalah yang terakhir diperbarui
        limit: 1,
      );

      if (maps.isNotEmpty) {
        final model = VersiApkUserModel.fromSqlite(maps.first);

        developer.log(
          'Versi APK terbaru ditemukan | ID: ${model.id} | Versi: ${model.versiTerbaru}',
          name: 'VersiApkUserOperasi-ambilVersiApkTerbaru ✅',
        );

        return model;
      }

      developer.log(
        'Tidak ada versi APK aktif yang ditemukan',
        name: 'VersiApkUserOperasi-ambilVersiApkTerbaru ⚠️',
      );

      return null;
    } catch (e) {
      developer.log(
        'Gagal mengambil versi APK terbaru | Error: $e | Mengembalikan null',
        name: 'VersiApkUserOperasi-ambilVersiApkTerbaru ❌',
        error: e,
      );
      return null;
    }
  }

  // ditambah: Fungsionalitas ambil data by ID dikembalikan
  Future<VersiApkUserModel?> ambilVersiApkById(String id) async {
    developer.log(
      'Mengambil versi APK by ID: $id | Tabel: $_tableName',
      name: 'VersiApkUserOperasi-ambilVersiApkById ℹ️',
    );

    try {
      final db = await _dbHelper.database;

      developer.log(
        'Menjalankan query SELECT * FROM $_tableName WHERE id = $id AND isDeleted = 0',
        name: 'VersiApkUserOperasi-ambilVersiApkById 🔄',
      );

      final maps = await db.query(
        _tableName,
        where: 'id = ? AND isDeleted = 0',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final model = VersiApkUserModel.fromSqlite(maps.first);

        developer.log(
          'Versi APK ditemukan | ID: $id | Versi: ${model.versiTerbaru}',
          name: 'VersiApkUserOperasi-ambilVersiApkById ✅',
        );

        return model;
      }

      developer.log(
        'Versi APK tidak ditemukan untuk ID: $id (mungkin sudah dihapus atau tidak ada)',
        name: 'VersiApkUserOperasi-ambilVersiApkById ⚠️',
      );

      return null;
    } catch (e) {
      developer.log(
        'Gagal mengambil versi APK by ID: $id | Error: $e | Mengembalikan null',
        name: 'VersiApkUserOperasi-ambilVersiApkById ❌',
        error: e,
      );
      return null;
    }
  }
}
