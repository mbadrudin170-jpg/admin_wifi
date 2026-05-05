// lib/data/operasi/riwayat_langganan_operasi.dart
// diubah: Menggunakan toMap() yang sudah diperbaiki
import 'package:sqflite/sqflite.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/riwayat_langganan_model.dart';

class RiwayatLanggananOperasi {
  final dbHelper = DatabaseHelper.instance;

  // Tambah riwayat langganan baru
  Future<void> tambahRiwayatLangganan(RiwayatLanggananModel riwayat) async {
    final db = await dbHelper.database;
    await db.insert(
      'riwayat_langganan',
      riwayat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update riwayat langganan
  Future<void> updateRiwayat(RiwayatLanggananModel riwayat) async {
    final db = await dbHelper.database;
    await db.update(
      'riwayat_langganan',
      riwayat.toMap(),
      where: 'id = ?',
      whereArgs: [riwayat.id],
    );
  }

  // ditambah: Fungsi untuk melakukan soft delete pada riwayat langganan
  Future<void> arsipkanRiwayatLangganan(String id) async {
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'riwayat_langganan',
      {'isDeleted': 1, 'diperbarui': now, 'diarsipkan': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Ambil semua riwayat langganan (termasuk yang diarsipkan)
  Future<List<RiwayatLanggananModel>> ambilSemuaRiwayat() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('riwayat_langganan');
    return maps.map((map) => RiwayatLanggananModel.fromMap(map)).toList();
  }

  // ditambah: Fungsi baru untuk mengambil riwayat yang aktif (belum diarsipkan)
  Future<List<RiwayatLanggananModel>> ambilSemuaRiwayatAktif() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'riwayat_langganan',
      where: 'isDeleted = ? OR isDeleted IS NULL',
      whereArgs: [0],
    );
    return maps.map((map) => RiwayatLanggananModel.fromMap(map)).toList();
  }

  // Hapus riwayat langganan berdasarkan ID
  Future<void> hapusPermanenRiwayat(String id) async {
    final db = await dbHelper.database;
    await db.delete('riwayat_langganan', where: 'id = ?', whereArgs: [id]);
  }

  // Hapus semua riwayat langganan
  Future<void> hapusPermanenSemuaRiwayat() async {
    final db = await dbHelper.database;
    await db.delete('riwayat_langganan');
  }

  // Mengambil data perubahan berdasarkan timestamp
  Future<List<RiwayatLanggananModel>> getPerubahan(DateTime timestamp) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'riwayat_langganan',
      where: 'diperbarui > ?',
      whereArgs: [timestamp.toIso8601String()],
    );
    return result.map((json) => RiwayatLanggananModel.fromMap(json)).toList();
  }

  // Menyisipkan atau memperbarui data secara batch
  Future<void> sisipkanAtauPerbaruiBatch(
    List<RiwayatLanggananModel> items,
  ) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (var item in items) {
      batch.insert(
        'riwayat_langganan',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
