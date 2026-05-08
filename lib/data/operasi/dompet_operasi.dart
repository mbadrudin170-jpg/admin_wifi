// path: lib/data/operasi/dompet_operasi.dart
// diubah: Menambahkan pengisian timestamp 'diperbarui' pada operasi create dan update.
// diubah: Mengganti fromSqlite menjadi fromSqlite untuk konsistensi.
import 'package:admin_wifi/data/operasi/status_unggah_operasi.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/enum/nama_tabel_enum.dart';
import 'package:sqflite/sqflite.dart';

class DompetOperasi {
  final dbHelper = DatabaseHelper.instance;
  final statusUnggahOperasi = StatusUnggahOperasi();

  // diubah: Menambahkan pengisian timestamp 'diperbarui' saat membuat dompet
  Future<void> createDompet(DompetModel dompet) async {
    final db = await dbHelper.database;

    // ditambah: Menyisipkan 'diperbarui' dengan waktu saat ini
    final data = dompet.copyWith(diperbarui: DateTime.now()).toSqlite();
    await db.insert(
      'dompet',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await statusUnggahOperasi.tambahIdDanUbahStatus(NamaTabel.dompet, [
      dompet.id,
    ]);
  }

  Future<List<DompetModel>> getDompet() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dompet',
      where: 'isDeleted = 0',
    );
    return List.generate(maps.length, (i) {
      return DompetModel.fromSqlite(maps[i]);
    });
  }

  Future<DompetModel?> getDompetById(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dompet',
      where: 'id = ? AND isDeleted = 0',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return DompetModel.fromSqlite(maps.first);
    }
    return null;
  }

  // diubah: Menambahkan pengisian timestamp 'diperbarui' saat memperbarui dompet
  Future<void> updateDompet(DompetModel dompet) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    // ditambah: Menyisipkan 'diperbarui' dengan waktu saat ini
    final data = dompet.copyWith(diperbarui: now).toSqlite();
    await db.update('dompet', data, where: 'id = ?', whereArgs: [dompet.id]);
    await statusUnggahOperasi.tambahIdDanUbahStatus(NamaTabel.dompet, [
      dompet.id,
    ]);
  }

  // ditambahkan: fungsi untuk menghapus semua dompet
  Future<void> hapusSemuaDompet() async {
    final db = await dbHelper.database;
    await db.delete('dompet');
  }

  Future<void> arsipkanSatuDompet(String id) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    await db.update(
      'dompet',
      {
        'diarsipkan': now.toIso8601String(),
        'diperbarui': now.toIso8601String(),
        'isDeleted': 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await statusUnggahOperasi.tambahIdDanUbahStatus(NamaTabel.dompet, [id]);
  }

  Future<double> getTotalSaldo() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(saldo) as total FROM dompet WHERE isDeleted = 0',
    );
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<double> getTotalSaldoPositif() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(saldo) as total FROM dompet WHERE saldo > 0 AND isDeleted = 0',
    );
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<double> getTotalSaldoNegatif() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(saldo) as total FROM dompet WHERE saldo < 0 AND isDeleted = 0',
    );
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<DompetModel> items) async {
    final db = await DatabaseHelper.instance.database;
    final batch = db.batch();
    for (var item in items) {
      // Pastikan model Anda memiliki ID yang unik untuk proses ini
      batch.insert(
        'dompet',
        item.toSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Mengambil beberapa dompet dari database lokal berdasarkan daftar ID.
  ///
  /// Fungsi ini efisien untuk mengambil data secara massal untuk proses sinkronisasi.
  Future<List<DompetModel>> getDompetByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final db = await dbHelper.database;
    // Membuat placeholder '?' sebanyak jumlah id untuk query yang aman
    final placeholders = List.filled(ids.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      'dompet',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return List.generate(maps.length, (i) {
      return DompetModel.fromSqlite(maps[i]);
    });
  }
}
