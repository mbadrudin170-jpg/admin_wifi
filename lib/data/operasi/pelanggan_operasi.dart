// path: lib/data/operasi/pelanggan_operasi.dart
import 'dart:developer' as developer;

import 'package:sqflite/sqflite.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';

class PelangganOperasi {
  final dbHelper = DatabaseHelper.instance;
  final String fileName = 'pelanggan_operasi.dart';

  Future<void> createPelanggan(PelangganModel pelanggan) async {
    try {
      developer.log(
        'Memulai createPelanggan untuk ID: ${pelanggan.id}',
        name: fileName,
      );
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

      developer.log(
        '✅ [LOKAL] Pelanggan (ID: ${pelangganUntukDisimpan.id}) berhasil dibuat.',
        name: fileName,
      );
    } catch (e) {
      developer.log('Gagal createPelanggan: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<List<PelangganModel>> getPelanggan() async {
    try {
      developer.log(
        'Mengambil semua pelanggan (diarsipkan IS NULL AND isDeleted = 0)',
        name: fileName,
      );
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'diarsipkan IS NULL AND isDeleted = ?',
        whereArgs: [0],
      );

      developer.log(
        'Berhasil mengambil ${maps.length} pelanggan',
        name: fileName,
      );
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log('Gagal getPelanggan: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<List<PelangganModel>> getAllPelanggan() async {
    try {
      developer.log(
        'Mengambil SEMUA data pelanggan (getAllPelanggan)',
        name: fileName,
      );
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('pelanggan');

      developer.log(
        'Berhasil mengambil total ${maps.length} pelanggan',
        name: fileName,
      );
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log('Gagal getAllPelanggan: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<PelangganModel?> getPelangganById(String id) async {
    try {
      developer.log('Mencari pelanggan berdasarkan ID: $id', name: fileName);
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        developer.log('Pelanggan ditemukan untuk ID: $id', name: fileName);
        return PelangganModel.fromSqlite(maps.first);
      }
      developer.log('Pelanggan tidak ditemukan untuk ID: $id', name: fileName);
      return null;
    } catch (e) {
      developer.log('Gagal getPelangganById: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<void> updatePelanggan(PelangganModel pelanggan) async {
    try {
      developer.log(
        'Memulai updatePelanggan untuk ID: ${pelanggan.id}',
        name: fileName,
      );
      final db = await dbHelper.database;

      final data = pelanggan.copyWith(diperbarui: DateTime.now()).toSqlite();

      int count = await db.update(
        'pelanggan',
        data,
        where: 'id = ?',
        whereArgs: [pelanggan.id],
      );

      developer.log(
        'Berhasil updatePelanggan ID: ${pelanggan.id}. Baris terpengaruh: $count',
        name: fileName,
      );
    } catch (e) {
      developer.log('Gagal updatePelanggan: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<void> deletePelanggan(String id, {bool softDelete = true}) async {
    try {
      developer.log(
        'Menghapus pelanggan ID: $id (softDelete: $softDelete)',
        name: fileName,
      );
      final db = await dbHelper.database;
      if (softDelete) {
        await db.update(
          'pelanggan',
          {'isDeleted': 1, 'diperbarui': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [id],
        );
      } else {
        await db.delete('pelanggan', where: 'id = ?', whereArgs: [id]);
      }
      developer.log('Berhasil hapus pelanggan ID: $id', name: fileName);
    } catch (e) {
      developer.log('Gagal deletePelanggan: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<List<PelangganModel>> getPerubahan(DateTime since) async {
    try {
      developer.log(
        'Mengambil perubahan pelanggan sejak: ${since.toIso8601String()}',
        name: fileName,
      );
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'diperbarui > ?',
        whereArgs: [since.toIso8601String()],
      );
      developer.log(
        'Ditemukan ${maps.length} perubahan pelanggan',
        name: fileName,
      );
      return List.generate(
        maps.length,
        (i) => PelangganModel.fromSqlite(maps[i]),
      );
    } catch (e) {
      developer.log('Gagal getPerubahan: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<void> arsipkanPelanggan(String id) async {
    try {
      developer.log('Mengarsipkan pelanggan ID: $id', name: fileName);
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
      developer.log('Berhasil mengarsipkan pelanggan ID: $id', name: fileName);
    } catch (e) {
      developer.log('Gagal arsipkanPelanggan: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<PelangganModel> items) async {
    try {
      developer.log(
        'Memulai batch insert/update untuk ${items.length} pelanggan',
        name: fileName,
      );
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
      developer.log('Berhasil menyelesaikan batch pelanggan', name: fileName);
    } catch (e) {
      developer.log(
        'Gagal sisipkanAtauPerbaruiBatch: $e',
        name: fileName,
        error: e,
      );
      rethrow;
    }
  }

  Future<List<PelangganModel>> getPelangganByIds(List<String> ids) async {
    try {
      if (ids.isEmpty) {
        developer.log('getPelangganByIds: List ID kosong', name: fileName);
        return [];
      }
      developer.log(
        'Mengambil data pelanggan untuk multiple IDs: $ids',
        name: fileName,
      );
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      developer.log(
        'Berhasil mengambil ${maps.length} pelanggan berdasarkan list ID',
        name: fileName,
      );
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log('Gagal getPelangganByIds: $e', name: fileName, error: e);
      rethrow;
    }
  }
}
