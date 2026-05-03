// path : lib/data/operasi/dompet_operasi.dart
// diubah: Menambahkan pengisian timestamp 'diperbarui' pada operasi create dan update.
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:sqflite/sqflite.dart';

class DompetOperasi {
  final dbHelper = DatabaseHelper.instance;

  // diubah: Menambahkan pengisian timestamp 'diperbarui' saat membuat dompet
  Future<void> createDompet(DompetModel dompet) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    // ditambah: Menyisipkan 'diperbarui' dengan waktu saat ini
    final data = dompet.copyWith(diperbarui: now).toMap();
    await db.insert(
      'dompet',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DompetModel>> getDompet() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('dompet');
    return List.generate(maps.length, (i) {
      return DompetModel.fromMap(maps[i]);
    });
  }

  Future<DompetModel?> getDompetById(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dompet',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return DompetModel.fromMap(maps.first);
    }
    return null;
  }

  // diubah: Menambahkan pengisian timestamp 'diperbarui' saat memperbarui dompet
  Future<void> updateDompet(DompetModel dompet) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    // ditambah: Menyisipkan 'diperbarui' dengan waktu saat ini
    final data = dompet.copyWith(diperbarui: now).toMap();
    await db.update(
      'dompet',
      data,
      where: 'id = ?',
      whereArgs: [dompet.id],
    );
  }

  // ditambahkan: Metode untuk menghapus dompet secara permanen
  Future<void> deleteDompet(String id) async {
    final db = await dbHelper.database;
    await db.delete('dompet', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalSaldo() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT SUM(saldo) as total FROM dompet');
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<double> getTotalSaldoPositif() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(saldo) as total FROM dompet WHERE saldo > 0',
    );
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<double> getTotalSaldoNegatif() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(saldo) as total FROM dompet WHERE saldo < 0',
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
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
