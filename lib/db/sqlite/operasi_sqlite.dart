// path: lib/db/sqlite/operasi_sqlite.dart

import 'package:admin_wifi/db/sqlite/oncreate_sqflite.dart';
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:sqflite/sqflite.dart';

/// Operasi generik langsung ke SQLite (tanpa transaksi/status unggah).
/// Menyediakan fungsi dasar: ambil, tambah, ubah, hapus, dan tambahBatch.
class OperasiSqlite {
  final _dbHelper = DatabaseHelper.instance;

  /// Mengambil baris dari tabel.
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
      L.e('Gagal hapus data dari tabel: $tabel Error: $e $st');
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

  /// Menjalankan blok operasi kustom yang kompleks di dalam transaksi.
  Future<T> jalankanOperasiKompleks<T>(
    Future<T> Function(Transaction txn) aksiKustom,
  ) async {
    L.i('Mendelegasikan eksekusi transaksi kompleks');
    return await _jalankanDalamTransaksi(aksiKustom);
  }

  /// Menyisipkan satu baris data ke dalam tabel (di dalam transaksi).
  Future<void> sisipkan(String tabel, Map<String, dynamic> data) async {
    L.i('Memulai penyisipan data ke tabel: $tabel Data: $data');

    try {
      await _jalankanDalamTransaksi((txn) async {
        final result = await txn.insert(
          tabel,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        L.i("INSERT berhasil Data: ${{'rowId': result, 'tabel': tabel}}");
        return result;
      });
    } catch (e, s) {
      L.e('Gagal menyisipkan data ke tabel: $tabel Error: $e $s Data: $data');
      rethrow;
    }
  }

  // Fungsi generik untuk menjalankan operasi tulis di dalam transaksi.
  Future<T> _jalankanDalamTransaksi<T>(
    Future<T> Function(Transaction) aksi,
  ) async {
    L.i('[TRANSAKSI DIMULAI] Memulai proses eksekusi dalam wrapper transaksi.');

    try {
      L.i('[TRANSAKSI] Mengambil instance database dari DatabaseHelper.');
      final db = await _dbHelper.database;
      L.i(
        '[TRANSAKSI] Instance database berhasil didapatkan. Tipe: ${db.runtimeType}',
      );

      L.i(
        '[TRANSAKSI] Memanggil db.transaction() untuk memulai blok transaksi.',
      );
      return await db.transaction((txn) async {
        L.i(
          '[TRANSAKSI AKTIF] Blok transaksi telah dimulai. Instance Transaction: ${txn.runtimeType}',
        );

        try {
          L.i('[TRANSAKSI AKTIF] Menandai status `perlu_unggah` menjadi TRUE.');
          await txn.insert(StatusAplikasiSkema.tabel, {
            StatusAplikasiSkema.id: 'perlu_unggah',
            StatusAplikasiSkema.value: '1',
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          L.i('[TRANSAKSI AKTIF] Status `perlu_unggah` berhasil ditandai.');

          L.i(
            '[TRANSAKSI AKTIF] Mengeksekusi aksi utama (callback) yang diberikan.',
          );
          final result = await aksi(txn);
          L.i(
            '[TRANSAKSI AKTIF] Aksi utama berhasil dieksekusi. Hasil: ${result.runtimeType}',
          );

          L.i(
            '[TRANSAKSI COMMIT] Transaksi akan di-commit karena semua langkah berhasil.',
          );
          return result;
        } catch (e, stackTrace) {
          L.e(
            '[TRANSAKSI GAGAL DI DALAM] Terjadi error saat menjalankan aksi di dalam blok transaksi. Error: $e $stackTrace',
          );
          rethrow;
        }
      });
    } catch (e, stackTrace) {
      L.e(
        '[TRANSAKSI GAGAL DI LUAR] Gagal saat memulai atau menyelesaikan transaksi. Error: $e $stackTrace',
      );
      rethrow;
    }
  }
}

/// Provider Riverpod untuk instance [OperasiSqlite].
final operasiSqliteProvider = Provider<OperasiSqlite>((ref) {
  return OperasiSqlite();
});
