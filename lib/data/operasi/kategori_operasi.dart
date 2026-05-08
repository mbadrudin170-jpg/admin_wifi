// lib/data/operasi/kategori_operasi.dart
// diubah: Menyesuaikan pemanggilan metode model menjadi fromSqlite dan toSqlite.
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:sqflite/sqflite.dart';

class KategoriOperasi {
  Future<KategoriModel> createKategori(KategoriModel kategori) async {
    final db = await DatabaseHelper.instance.database;
    final kategoriBaru = kategori.copyWith(
      id: kategori.id,
      diperbarui: DateTime.now(),
    );
    // diubah: dari toMapForSqlite ke toSqlite
    final data = kategoriBaru.toSqlite();

    await db.insert(
      'kategori',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return kategoriBaru;
  }

  Future<List<KategoriModel>> getKategori() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kategori',
      where: 'diarsipkan IS NULL',
    );
    return List.generate(maps.length, (i) {
      // diubah: dari fromMap ke fromSqlite
      return KategoriModel.fromSqlite(maps[i]);
    });
  }

  Future<KategoriModel> getKategoriById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kategori',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      // diubah: dari fromMap ke fromSqlite
      return KategoriModel.fromSqlite(maps.first);
    } else {
      throw Exception('Kategori dengan ID $id tidak ditemukan.');
    }
  }

  Future<List<KategoriModel>> getKategoriByTipe(TipeKategori tipe) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kategori',
      where: 'tipe = ? AND diarsipkan IS NULL',
      whereArgs: [tipe.name],
    );
    return List.generate(maps.length, (i) {
      // diubah: dari fromMap ke fromSqlite
      return KategoriModel.fromSqlite(maps[i]);
    });
  }

  Future<void> update(KategoriModel kategori) async {
    final db = await DatabaseHelper.instance.database;
    // diubah: dari toMapForSqlite ke toSqlite
    final data = kategori.copyWith(diperbarui: DateTime.now()).toSqlite();
    await db.update(
      'kategori',
      data,
      where: 'id = ?',
      whereArgs: [kategori.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('kategori', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> bersihkanDanSisipkanSemua(List<KategoriModel> items) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.delete('kategori');
      for (var item in items) {
        // diubah: dari toMapForSqlite ke toSqlite
        await txn.insert('kategori', item.toSqlite());
      }
    });
  }

  Future<List<KategoriModel>> getPerubahan(DateTime since) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kategori',
      where: 'diperbarui > ?',
      whereArgs: [since.toIso8601String()],
    );
    // diubah: dari fromMap ke fromSqlite
    return List.generate(maps.length, (i) => KategoriModel.fromSqlite(maps[i]));
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<KategoriModel> items) async {
    final db = await DatabaseHelper.instance.database;
    final batch = db.batch();
    for (var item in items) {
      batch.insert(
        'kategori',
        // diubah: dari toMapForSqlite ke toSqlite
        item.toSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<KategoriModel>> getKategoriByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final db = await DatabaseHelper.instance.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      'kategori',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return List.generate(maps.length, (i) {
      // diubah: dari fromMap ke fromSqlite
      return KategoriModel.fromSqlite(maps[i]);
    });
  }
}
