// lib/data/operasi/pelanggan_operasi.dart
// diubah: Menggunakan copyWith untuk standarisasi pengisian timestamp.
import 'package:sqflite/sqflite.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';

class PelangganOperasi {
  final dbHelper = DatabaseHelper.instance;

  // diubah: Menggunakan copyWith untuk mengisi 'diperbarui'.
  Future<void> createPelanggan(PelangganModel pelanggan) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    // ditambah: Menggunakan copyWith untuk konsistensi.
    final data = pelanggan.copyWith(diperbarui: now).toMap();
    await db.insert(
      'pelanggan',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Mengambil semua pelanggan
  Future<List<PelangganModel>> getPelanggan() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('pelanggan');
    return List.generate(maps.length, (i) {
      return PelangganModel.fromMap(maps[i]);
    });
  }

  // Mengambil pelanggan berdasarkan ID
  Future<PelangganModel?> getPelangganById(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pelanggan',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PelangganModel.fromMap(maps.first);
    }
    return null;
  }

  // diubah: Menggunakan copyWith untuk mengisi 'diperbarui'.
  Future<void> updatePelanggan(PelangganModel pelanggan) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    // ditambah: Menggunakan copyWith untuk konsistensi.
    final data = pelanggan.copyWith(diperbarui: now).toMap();
    await db.update(
      'pelanggan',
      data,
      where: 'id = ?',
      whereArgs: [pelanggan.id],
    );
  }

  // Mengambil perubahan sejak waktu tertentu
  Future<List<PelangganModel>> getPerubahan(DateTime since) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pelanggan',
      where: 'diperbarui > ?',
      whereArgs: [since.toIso8601String()],
    );
    return List.generate(maps.length, (i) => PelangganModel.fromMap(maps[i]));
  }

  // Menyisipkan atau memperbarui data secara batch
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
