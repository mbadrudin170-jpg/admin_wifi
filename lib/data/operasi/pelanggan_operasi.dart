// lib/data/operasi/pelanggan_operasi.dart
// diubah: Mengganti Pelanggan menjadi PelangganModel di seluruh file
import 'package:sqflite/sqflite.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';

class PelangganOperasi {
  final dbHelper = DatabaseHelper.instance;

  // diubah: Menggunakan PelangganModel
  Future<void> createPelanggan(PelangganModel pelanggan) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final data = pelanggan.toMap()..['diperbarui'] = now.toIso8601String();

    await db.insert(
      'pelanggan',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // diubah: Menggunakan PelangganModel
  Future<List<PelangganModel>> getPelanggan() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('pelanggan');
    // diubah: Menggunakan PelangganModel.fromMap
    return List.generate(maps.length, (i) {
      return PelangganModel.fromMap(maps[i]);
    });
  }

  // diubah: Menggunakan PelangganModel
  Future<PelangganModel?> getPelangganById(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pelanggan',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      // diubah: Menggunakan PelangganModel.fromMap
      return PelangganModel.fromMap(maps.first);
    }
    return null;
  }

  // diubah: Menggunakan PelangganModel
  Future<void> updatePelanggan(PelangganModel pelanggan) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final data = pelanggan.toMap()..['diperbarui'] = now.toIso8601String();
    await db.update(
      'pelanggan',
      data,
      where: 'id = ?',
      whereArgs: [pelanggan.id],
    );
  }


  // diubah: Menggunakan PelangganModel
  Future<List<PelangganModel>> getPerubahan(DateTime since) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pelanggan',
      where: 'diperbarui > ?',
      whereArgs: [since.toIso8601String()],
    );
    // diubah: Menggunakan PelangganModel.fromMap
    return List.generate(maps.length, (i) => PelangganModel.fromMap(maps[i]));
  }

  // diubah: Menggunakan PelangganModel
  Future<void> sisipkanAtauPerbaruiBatch(List<PelangganModel> items) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (var item in items) {
      batch.insert(
        'pelanggan',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
