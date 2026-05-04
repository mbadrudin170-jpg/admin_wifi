// lib/data/operasi/pesan_operasi.dart
// diubah: Mengganti path import pesan_model.dart menjadi pesanan_model.dart dan memperbaiki nama tabel
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/pesanan_model.dart';
import 'package:sqflite/sqflite.dart';

class PesananOperasi {
  final dbHelper = DatabaseHelper.instance;

  // Simpan pesanan baru
  Future<int> simpanPesanan(PesananModel pesanan) async {
    final db = await dbHelper.database;
    return await db.insert('pesanan', pesanan.toMap());
  }

  // Ambil semua pesanan (terbaru di atas)
  Future<List<PesananModel>> ambilSemuaPesanan() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pesanan',
      orderBy: 'id DESC',
    );
    return maps.map((map) => PesananModel.fromMap(map)).toList();
  }

  // Ambil pesanan berdasarkan status
  Future<List<PesananModel>> ambilPesananByStatus(String status) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pesanan',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'id DESC',
    );
    return maps.map((map) => PesananModel.fromMap(map)).toList();
  }

  // Update status pesanan
  Future<int> updateStatusPesanan(String id, String status) async {
    final db = await dbHelper.database;
    return await db.update(
      'pesanan',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Hapus pesanan
  Future<int> hapusPesanan(int id) async {
    final db = await dbHelper.database;
    return await db.delete('pesanan', where: 'id = ?', whereArgs: [id]);
  }

  // Hitung total pesanan hari ini
  Future<int> hitungPesananHariIni() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as total FROM pesanan WHERE date(tanggal) = date('now')",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Hitung total pendapatan hari ini
  Future<int> totalPendapatanHariIni() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      "SELECT SUM(harga) as total FROM pesanan WHERE date(tanggal) = date('now')",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // diubah: Menggunakan tabel 'pesanan' bukan 'pelanggan'
  Future<void> sisipkanAtauPerbaruiBatch(List<PesananModel> items) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (var item in items) {
      batch.insert(
        'pesanan',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
