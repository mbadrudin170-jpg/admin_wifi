// path: lib/data/operasi/pelanggan_operasi.dart
import 'package:admin_wifi/debug/log.dart';
import 'package:sqflite/sqflite.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';

class PelangganOperasi {
  final dbHelper = DatabaseHelper.instance;

  Future<void> createPelanggan(PelangganModel pelanggan) async {
    Log.info('Memulai pembuatan pelanggan dengan ID: ${pelanggan.id}');
    try {
      final db = await dbHelper.database;
      final pelangganUntukDisimpan = pelanggan.copyWith(
        diperbarui: DateTime.now(),
      );
      final data = pelangganUntukDisimpan.toSqlite();

      await db.insert(
        'pelanggan',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      Log.info('Pelanggan (ID: ${pelangganUntukDisimpan.id}) berhasil dibuat di database lokal.');
    } catch (e, s) {
      Log.error('Gagal membuat pelanggan.', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<List<PelangganModel>> getPelanggan() async {
    Log.info('Mengambil semua pelanggan yang aktif (tidak diarsipkan dan tidak dihapus).');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'diarsipkan IS NULL AND isDeleted = ?',
        whereArgs: [0],
      );

      Log.info('Berhasil mengambil ${maps.length} pelanggan aktif.');
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil pelanggan aktif.', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<List<PelangganModel>> getAllPelanggan() async {
    Log.info('Mengambil SEMUA data pelanggan dari database lokal.');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('pelanggan');

      Log.info('Berhasil mengambil total ${maps.length} pelanggan.');
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil semua data pelanggan.', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<PelangganModel?> getPelangganById(String id) async {
    Log.info('Mencari pelanggan berdasarkan ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info('Pelanggan dengan ID: $id ditemukan.');
        return PelangganModel.fromSqlite(maps.first);
      }
      Log.warning('Pelanggan dengan ID: $id tidak ditemukan.');
      return null;
    } catch (e, s) {
      Log.error('Gagal mencari pelanggan berdasarkan ID.', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> updatePelanggan(PelangganModel pelanggan) async {
    Log.info('Memulai pembaruan untuk pelanggan ID: ${pelanggan.id}');
    try {
      final db = await dbHelper.database;
      final data = pelanggan.copyWith(diperbarui: DateTime.now()).toSqlite();

      int count = await db.update(
        'pelanggan',
        data,
        where: 'id = ?',
        whereArgs: [pelanggan.id],
      );

      Log.info('Berhasil memperbarui pelanggan ID: ${pelanggan.id}. Jumlah baris terpengaruh: $count');
    } catch (e, s) {
      Log.error('Gagal memperbarui pelanggan.', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> deletePelanggan(String id, {bool softDelete = true}) async {
    Log.info('Memulai proses penghapusan untuk pelanggan ID: $id (softDelete: $softDelete)');
    try {
      final db = await dbHelper.database;
      if (softDelete) {
        await db.update(
          'pelanggan',
          {'isDeleted': 1, 'diperbarui': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [id],
        );
        Log.info('Berhasil melakukan soft delete pada pelanggan ID: $id.');
      } else {
        await db.delete('pelanggan', where: 'id = ?', whereArgs: [id]);
        Log.warning('Berhasil melakukan hard delete (penghapusan permanen) pada pelanggan ID: $id.');
      }
    } catch (e, s) {
      Log.error('Gagal menghapus pelanggan.', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<List<PelangganModel>> getPerubahan(DateTime since) async {
    Log.info('Mengambil perubahan pelanggan sejak: ${since.toIso8601String()}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'diperbarui > ?',
        whereArgs: [since.toIso8601String()],
      );
      Log.info('Ditemukan ${maps.length} perubahan pelanggan sejak waktu yang ditentukan.');
      return List.generate(
        maps.length,
        (i) => PelangganModel.fromSqlite(maps[i]),
      );
    } catch (e, s) {
      Log.error('Gagal mengambil perubahan pelanggan.', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> arsipkanPelanggan(String id) async {
    Log.info('Mengarsipkan pelanggan ID: $id');
    try {
      final db = await dbHelper.database;
      final now = DateTime.now();
      await db.update(
        'pelanggan',
        {
          'isDeleted': 1,
          'diarsipkan': now.toIso8601String(),
          'diperbarui': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      Log.info('Berhasil mengarsipkan pelanggan ID: $id.');
    } catch (e, s) {
      Log.error('Gagal mengarsipkan pelanggan.', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<PelangganModel> items) async {
    if (items.isEmpty) {
      Log.info('Tidak ada item untuk diproses dalam batch.');
      return;
    }
    Log.info('Memulai batch insert/update untuk ${items.length} pelanggan.');
    try {
      final db = await dbHelper.database;
      final batch = db.batch();
      for (var item in items) {
        final itemToSave = item.copyWith(diperbarui: DateTime.now());
        batch.insert(
          'pelanggan',
          itemToSave.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      Log.info('Berhasil menyelesaikan operasi batch untuk ${items.length} pelanggan.');
    } catch (e, s) {
      Log.error('Gagal menjalankan operasi batch.', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<List<PelangganModel>> getPelangganByIds(List<String> ids) async {
    if (ids.isEmpty) {
      Log.info('List ID kosong, tidak ada pelanggan yang diambil.');
      return [];
    }
    Log.info('Mengambil data pelanggan untuk ${ids.length} ID.');
    try {
      final db = await dbHelper.database;
      // Untuk menghindari masalah batasan variabel di SQL, kita pecah menjadi beberapa query jika perlu.
      // SQflite umumnya menangani ini dengan baik, jadi kita coba langsung.
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info('Berhasil mengambil ${maps.length} pelanggan berdasarkan list ID yang diberikan.');
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil pelanggan berdasarkan list ID.', error: e, stackTrace: s);
      rethrow;
    }
  }
}