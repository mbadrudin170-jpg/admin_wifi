// path: lib/db/operasi_sqlite.dart

import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:sqflite/sqflite.dart';

/// Operasi generik langsung ke SQLite (tanpa transaksi/status unggah).
/// Menyediakan fungsi dasar: ambil, tambah, ubah, hapus, dan tambahBatch.
class OperasiSqlite {
  final _dbHelper = DatabaseHelper.instance;

  /// Mengambil baris dari tabel.
  /// - [where]/[whereArgs]: filter opsional.
  /// - [orderBy]/[limit]/[offset]: pengurutan dan paginasi opsional.
  Future<List<Map<String, dynamic>>> ambil(
    String tabel, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    L.i('Memulai ambil data dari tabel: $tabel');
    try {
      final db = await _dbHelper.database;
      final hasil = await db.query(
        tabel,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      L.i('Berhasil mengambil ${hasil.length} data dari tabel: $tabel');
      return hasil;
    } catch (e, st) {
      L.e('Gagal ambil data dari tabel: $tabel Error: $e $st');
      rethrow;
    }
  }

  /// Menambahkan satu baris data ke tabel.
  /// Mengembalikan rowId hasil insert.
  Future<int> tambah(String tabel, Map<String, dynamic> data) async {
    L.i('Memulai tambah data ke tabel: $tabel Data: $data');
    try {
      final db = await _dbHelper.database;
      final id = await db.insert(
        tabel,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      L.i('Berhasil tambah data ke tabel: $tabel id: $id');
      return id;
    } catch (e, st) {
      L.e('Gagal tambah data ke tabel: $tabel Error: $e $st');
      rethrow;
    }
  }

  /// Mengubah baris data di tabel.
  /// - [id]: bila diberikan, filter otomatis `id = ?`.
  /// - [where]/[whereArgs]: filter manual (diabaikan bila [id] diberikan).
  /// Mengembalikan jumlah baris yang terpengaruh.
  Future<int> ubah(
    String tabel,
    Map<String, dynamic> data, {
    Object? id,
    String? where,
    List<Object?>? whereArgs,
  }) async {
    L.i('Memulai ubah data di tabel: $tabel Data: $data');
    try {
      final db = await _dbHelper.database;
      final filterWhere = id != null ? 'id = ?' : where;
      final filterArgs = id != null ? <Object?>[id] : whereArgs;
      final rows = await db.update(
        tabel,
        data,
        where: filterWhere,
        whereArgs: filterArgs,
      );
      L.i('Berhasil ubah $rows baris di tabel: $tabel');
      return rows;
    } catch (e, st) {
      L.e('Gagal ubah data di tabel: $tabel Error: $e $st');
      rethrow;
    }
  }

  /// Menghapus baris data dari tabel.
  /// - [id]: bila diberikan, filter otomatis `id = ?`.
  /// - [where]/[whereArgs]: filter manual (diabaikan bila [id] diberikan).
  /// Mengembalikan jumlah baris yang terhapus.
  Future<int> hapus(
    String tabel, {
    Object? id,
    String? where,
    List<Object?>? whereArgs,
  }) async {
    L.i('Memulai hapus data dari tabel: $tabel');
    try {
      final db = await _dbHelper.database;
      final filterWhere = id != null ? 'id = ?' : where;
      final filterArgs = id != null ? <Object?>[id] : whereArgs;
      final rows = await db.delete(
        tabel,
        where: filterWhere,
        whereArgs: filterArgs,
      );
      L.i('Berhasil hapus $rows baris dari tabel: $tabel');
      return rows;
    } catch (e, st) {
      L.e('Gagal hapus data di tabel: $tabel Error: $e $st');
      rethrow;
    }
  }

  /// Menambahkan banyak baris data sekaligus (batch) ke tabel.
  Future<void> tambahBatch(
    String tabel,
    List<Map<String, dynamic>> daftarData,
  ) async {
    if (daftarData.isEmpty) {
      L.w('Daftar data batch kosong, operasi dibatalkan: $tabel');
      return;
    }
    L.i('Memulai tambahBatch ke tabel: $tabel total: ${daftarData.length}');
    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        final batch = txn.batch();
        for (final data in daftarData) {
          if (data.isNotEmpty) {
            batch.insert(
              tabel,
              data,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
        await batch.commit(noResult: true);
      });
      L.i('Berhasil tambahBatch ke tabel: $tabel');
    } catch (e, st) {
      L.e('Gagal tambahBatch ke tabel: $tabel Error: $e $st');
      rethrow;
    }
  }
}

/// Provider Riverpod untuk instance [OperasiSqlite].
final operasiSqliteProvider = Provider<OperasiSqlite>((ref) {
  return OperasiSqlite();
});
