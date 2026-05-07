// lib/data/operasi/kategori_operasi.dart
// diubah: Menambahkan filter untuk tidak menampilkan data yang diarsipkan.
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
    final data = kategoriBaru.toMapForSqlite();

    await db.insert(
      'kategori',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return kategoriBaru;
  }

  // diubah: Hanya mengambil kategori yang belum diarsipkan.
  Future<List<KategoriModel>> getKategori() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kategori',
      where: 'diarsipkan IS NULL',
    );
    return List.generate(maps.length, (i) {
      return KategoriModel.fromMap(maps[i]);
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
      return KategoriModel.fromMap(maps.first);
    } else {
      throw Exception('Kategori dengan ID $id tidak ditemukan.');
    }
  }

  Future<List<KategoriModel>> getKategoriByTipe(TipeKategori tipe) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kategori',
      where: 'tipe = ? AND diarsipkan IS NULL', // ditambahkan: filter arsip
      whereArgs: [tipe.name],
    );
    return List.generate(maps.length, (i) {
      return KategoriModel.fromMap(maps[i]);
    });
  }

  Future<void> update(KategoriModel kategori) async {
    final db = await DatabaseHelper.instance.database;
    // diubah: memperbarui timestamp saat update dan juga saat arsip
    final data = kategori.copyWith(diperbarui: DateTime.now()).toMapForSqlite();
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
        await txn.insert('kategori', item.toMapForSqlite());
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
    return List.generate(maps.length, (i) => KategoriModel.fromMap(maps[i]));
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<KategoriModel> items) async {
    final db = await DatabaseHelper.instance.database;
    final batch = db.batch();
    for (var item in items) {
      batch.insert(
        'kategori',
        item.toMapForSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
