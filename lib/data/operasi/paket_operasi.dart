// path: lib/data/operasi/paket_operasi.dart
// diubah: Logika create dan update disederhanakan dan distandarkan menggunakan copyWith.

import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:sqflite/sqflite.dart';

class PaketOperasi {
  final dbHelper = DatabaseHelper.instance;

  // diubah: Menggunakan copyWith untuk mengisi 'diperbarui' dan menghapus log.
  Future<void> createPaket(PaketModel paket) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    // ditambah: Menggunakan copyWith untuk konsistensi.
    final data = paket.copyWith(diperbarui: now).toMapForSqlite();
    await db.insert(
      'paket',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PaketModel>> getPaket() async {
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
    return List.generate(maps.length, (i) {
      return PaketModel.fromMap(maps[i]);
    });
  }

  Future<PaketModel?> getPaketById(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'paket',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PaketModel.fromMap(maps.first);
    }
    return null;
  }

  // diubah: Menggunakan copyWith untuk mengisi 'diperbarui'.
  Future<void> updatePaket(PaketModel paket) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    // ditambah: Menggunakan copyWith untuk konsistensi.
    final data = paket.copyWith(diperbarui: now).toMapForSqlite();
    await db.update('paket', data, where: 'id = ?', whereArgs: [paket.id]);
  }

  Future<void> hapusPaket(String id) async {
    final db = await dbHelper.database;
    await db.delete('paket', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> hapusSemuaPaket() async {
    final db = await dbHelper.database;
    await db.delete('paket');
  }

  Future<List<PaketModel>> getPerubahan(DateTime since) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'paket',
      where: 'diperbarui > ?',
      whereArgs: [since.toIso8601String()],
    );
    return List.generate(maps.length, (i) => PaketModel.fromMap(maps[i]));
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<PaketModel> items) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (var item in items) {
      batch.insert(
        'paket',
        item.toMapForSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<PaketModel>> getPaketByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final db = await dbHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      'paket',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return List.generate(maps.length, (i) {
      return PaketModel.fromMap(maps[i]);
    });
  }
}
