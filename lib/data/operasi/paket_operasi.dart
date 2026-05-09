// path: lib/data/operasi/paket_operasi.dart
import 'dart:developer' as developer;
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:sqflite/sqflite.dart';

class PaketOperasi {
  final dbHelper = DatabaseHelper.instance;
  final String fileName = 'paket_operasi.dart'; // Nama file untuk log

  Future<void> createPaket(PaketModel paket) async {
    try {
      developer.log(
        '🆕 Memulai createPaket untuk ID: ${paket.id}',
        name: fileName,
      );
      final db = await dbHelper.database;
      final now = DateTime.now();

      final data = paket.copyWith(diperbarui: now).toSqlite();
      await db.insert(
        'paket',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      developer.log('✅ Berhasil createPaket ID: ${paket.id}', name: fileName);
    } catch (e) {
      developer.log('❌ Gagal createPaket: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<List<PaketModel>> getPaket() async {
    try {
      developer.log('🔍 Mengambil semua data paket (getPaket)', name: fileName);
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE tipe
            WHEN 'jam' THEN durasi
            WHEN 'hari' THEN durasi * 24
            WHEN 'bulan' THEN durasi * 24 * 30
            ELSE 999999
          END as urutan
        FROM paket
        ORDER BY urutan ASC
      ''');

      developer.log(
        '📦 Berhasil mengambil ${maps.length} data paket',
        name: fileName,
      );
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log('❌ Gagal getPaket: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<PaketModel?> getPaketById(String id) async {
    try {
      developer.log('🔎 Mencari paket berdasarkan ID: $id', name: fileName);
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        developer.log('📍 Paket ditemukan untuk ID: $id', name: fileName);
        return PaketModel.fromSqlite(maps.first);
      }
      developer.log('⚠️ Paket tidak ditemukan untuk ID: $id', name: fileName);
      return null;
    } catch (e) {
      developer.log('❌ Gagal getPaketById: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<void> updatePaket(PaketModel paket) async {
    try {
      developer.log(
        '📝 Memulai updatePaket untuk ID: ${paket.id}',
        name: fileName,
      );
      final db = await dbHelper.database;
      final now = DateTime.now();

      final data = paket.copyWith(diperbarui: now).toSqlite();
      int count = await db.update(
        'paket',
        data,
        where: 'id = ?',
        whereArgs: [paket.id],
      );

      developer.log(
        '✅ Berhasil updatePaket. Baris terpengaruh: $count',
        name: fileName,
      );
    } catch (e) {
      developer.log('❌ Gagal updatePaket: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<void> hapusPaket(String id) async {
    try {
      developer.log('🗑️ Menghapus paket ID: $id', name: fileName);
      final db = await dbHelper.database;
      int count = await db.delete('paket', where: 'id = ?', whereArgs: [id]);
      developer.log(
        '✅ Berhasil hapusPaket. Baris terhapus: $count',
        name: fileName,
      );
    } catch (e) {
      developer.log('❌ Gagal hapusPaket: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<void> hapusSemuaPaket() async {
    try {
      developer.log('🧨 Menghapus SEMUA data paket', name: fileName);
      final db = await dbHelper.database;
      int count = await db.delete('paket');
      developer.log(
        '✅ Berhasil hapusSemuaPaket. Total terhapus: $count',
        name: fileName,
      );
    } catch (e) {
      developer.log('❌ Gagal hapusSemuaPaket: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<List<PaketModel>> getPerubahan(DateTime since) async {
    try {
      developer.log(
        '🔄 Mengambil perubahan paket sejak: ${since.toIso8601String()}',
        name: fileName,
      );
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: 'diperbarui > ?',
        whereArgs: [since.toIso8601String()],
      );
      developer.log(
        '✨ Ditemukan ${maps.length} perubahan paket',
        name: fileName,
      );
      return List.generate(maps.length, (i) => PaketModel.fromSqlite(maps[i]));
    } catch (e) {
      developer.log('❌ Gagal getPerubahan: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<PaketModel> items) async {
    try {
      developer.log(
        '🗂️ Memulai proses batch insert/update ${items.length} item',
        name: fileName,
      );
      final db = await dbHelper.database;
      final batch = db.batch();
      for (var item in items) {
        batch.insert(
          'paket',
          item.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      developer.log(
        '✅ Berhasil menyelesaikan batch insert/update',
        name: fileName,
      );
    } catch (e) {
      developer.log(
        '❌ Gagal sisipkanAtauPerbaruiBatch: $e',
        name: fileName,
        error: e,
      );
      rethrow;
    }
  }

  Future<List<PaketModel>> getPaketByIds(List<String> ids) async {
    try {
      if (ids.isEmpty) {
        developer.log('⚠️ getPaketByIds: List ID kosong', name: fileName);
        return [];
      }
      developer.log(
        '🔗 Mengambil paket untuk multiple IDs: $ids',
        name: fileName,
      );
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      developer.log(
        '📦 Berhasil mengambil ${maps.length} paket berdasarkan multiple IDs',
        name: fileName,
      );
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log('❌ Gagal getPaketByIds: $e', name: fileName, error: e);
      rethrow;
    }
  }
}
