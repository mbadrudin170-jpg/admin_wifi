// path: lib/data/operasi/pelanggan_operasi.dart
// diubah: Disesuaikan dengan PelangganModel yang baru (menghapus status).
import 'package:sqflite/sqflite.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';

class PelangganOperasi {
  final dbHelper = DatabaseHelper.instance;

  // diubah: Menggunakan copyWith untuk mengisi 'diperbarui'.
  Future<void> createPelanggan(PelangganModel pelanggan) async {
    final db = await dbHelper.database;
    // ditambah: Menggunakan copyWith untuk konsistensi.
    final data = pelanggan.copyWith(diperbarui: DateTime.now()).toMapForSqlite();
    await db.insert(
      'pelanggan',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // diubah: Hanya mengambil pelanggan yang aktif (tidak diarsip dan tidak dihapus).
  Future<List<PelangganModel>> getPelanggan() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pelanggan',
      where: 'diarsipkan IS NULL AND isDeleted = ?',
      whereArgs: [0], // 0 untuk false
    );
    return List.generate(maps.length, (i) {
      return PelangganModel.fromMap(maps[i]);
    });
  }

  // Mengambil semua pelanggan, termasuk yang diarsip/dihapus (untuk sinkronisasi/admin)
  Future<List<PelangganModel>> getAllPelanggan() async {
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
    // ditambah: Menggunakan copyWith untuk konsistensi.
    final data = pelanggan.copyWith(diperbarui: DateTime.now()).toMapForSqlite();
    await db.update(
      'pelanggan',
      data,
      where: 'id = ?',
      whereArgs: [pelanggan.id],
    );
  }

  // ditambah: Menghapus pelanggan (soft atau hard delete).
  Future<void> deletePelanggan(String id, {bool softDelete = true}) async {
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

  Future<void> arsipkanPelanggan(String id) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    await db.update(
      'pelanggan',
      {
        'isDeleted': 1, // diubah: Menandai sebagai terhapus (1 untuk true)
        'diarsipkan': now.toIso8601String(), // ditambah: Mencatat waktu arsip
        'diperbarui': now
            .toIso8601String(), // ditambah: Memperbarui waktu update
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Menyisipkan atau memperbarui data secara batch
  Future<void> sisipkanAtauPerbaruiBatch(List<PelangganModel> items) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (var item in items) {
      // Pastikan setiap item memiliki timestamp terbaru sebelum disimpan
      final itemToSave = item.copyWith(diperbarui: DateTime.now());
      batch.insert(
        'pelanggan',
        itemToSave.toMapForSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
