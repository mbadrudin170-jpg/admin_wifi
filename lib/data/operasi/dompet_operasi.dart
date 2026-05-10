// path: lib/data/operasi/dompet_operasi.dart
import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:sqflite/sqflite.dart';

class DompetOperasi {
  final dbHelper = DatabaseHelper.instance;

  Future<void> createDompet(DompetModel dompet) async {
    Log.info('Memulai createDompet untuk dompet: ${dompet.toSqlite()}');
    try {
      final db = await dbHelper.database;
      final data = dompet.copyWith(diperbarui: DateTime.now()).toSqlite();
      
      int id = await db.insert(
        'dompet',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      Log.info('Berhasil membuat dompet dengan ID baris: $id dan ID data: ${dompet.id}');
    } catch (e, st) {
      Log.error('Gagal saat createDompet', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<DompetModel>> getDompet() async {
    Log.info('Memulai getDompet (mengambil semua dompet yang tidak di-soft delete).');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: 'isDeleted = 0',
      );

      final listDompet = List.generate(maps.length, (i) => DompetModel.fromSqlite(maps[i]));
      Log.info('Berhasil mengambil ${listDompet.length} data dompet.');
      return listDompet;
    } catch (e, st) {
      Log.error('Gagal saat getDompet', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<DompetModel?> getDompetById(String id) async {
    Log.info('Memulai getDompetById untuk ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: 'id = ? AND isDeleted = 0',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final dompet = DompetModel.fromSqlite(maps.first);
        Log.info('Dompet dengan ID: $id ditemukan. Data: ${dompet.toSqlite()}');
        return dompet;
      }
      
      Log.warning('Dompet dengan ID: $id tidak ditemukan di database.');
      return null;
    } catch (e, st) {
      Log.error('Gagal saat getDompetById untuk ID: $id', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> updateDompet(DompetModel dompet) async {
    Log.info('Memulai updateDompet untuk dompet: ${dompet.toSqlite()}');
    try {
      final db = await dbHelper.database;
      final data = dompet.copyWith(diperbarui: DateTime.now()).toSqlite();
      
      int count = await db.update('dompet', data, where: 'id = ?', whereArgs: [dompet.id]);
      
      Log.info('Berhasil updateDompet untuk ID: ${dompet.id}. Jumlah baris terpengaruh: $count');
    } catch (e, st) {
      Log.error('Gagal saat updateDompet untuk ID: ${dompet.id}', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> hapusSemuaDompet() async {
    Log.warning('PERINGATAN: Memulai hapusSemuaDompet. Ini adalah operasi destruktif yang akan menghapus semua dompet secara permanen.');
    try {
      final db = await dbHelper.database;
      int count = await db.delete('dompet');
      Log.info('Berhasil hapusSemuaDompet. Total baris yang dihapus permanen: $count');
    } catch (e, st) {
      Log.error('Gagal saat hapusSemuaDompet', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> arsipkanSatuDompet(String id) async {
    Log.info('Memulai arsipkanSatuDompet (soft delete) untuk ID: $id');
    try {
      final db = await dbHelper.database;
      final now = DateTime.now();
      final Map<String, dynamic> dataToUpdate = {
        'diarsipkan': now.toIso8601String(),
        'diperbarui': now.toIso8601String(),
        'isDeleted': 1,
      };
      
      int count = await db.update('dompet', dataToUpdate, where: 'id = ?', whereArgs: [id]);
      
      Log.info('Berhasil arsipkanSatuDompet untuk ID: $id. Jumlah baris terpengaruh: $count');
    } catch (e, st) {
      Log.error('Gagal saat arsipkanSatuDompet untuk ID: $id', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<double> getTotalSaldo() async {
    Log.info('Memulai getTotalSaldo (menghitung total saldo dari semua dompet aktif).');
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery('SELECT SUM(saldo) as total FROM dompet WHERE isDeleted = 0');
      
      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }
      
      Log.info('Berhasil menghitung total saldo: $total');
      return total;
    } catch (e, st) {
      Log.error('Gagal saat getTotalSaldo', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<double> getTotalSaldoPositif() async {
    Log.info('Memulai getTotalSaldoPositif (menghitung total saldo > 0 dari dompet aktif).');
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery('SELECT SUM(saldo) as total FROM dompet WHERE saldo > 0 AND isDeleted = 0');
      
      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }
      
      Log.info('Berhasil menghitung total saldo positif: $total');
      return total;
    } catch (e, st) {
      Log.error('Gagal saat getTotalSaldoPositif', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<double> getTotalSaldoNegatif() async {
    Log.info('Memulai getTotalSaldoNegatif (menghitung total saldo < 0 dari dompet aktif).');
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery('SELECT SUM(saldo) as total FROM dompet WHERE saldo < 0 AND isDeleted = 0');
      
      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }
      
      Log.info('Berhasil menghitung total saldo negatif: $total');
      return total;
    } catch (e, st) {
      Log.error('Gagal saat getTotalSaldoNegatif', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<DompetModel> items) async {
    Log.info('Memulai sisipkanAtauPerbaruiBatch untuk ${items.length} item dompet.');
    if (items.isEmpty) {
      Log.warning('List item untuk batch kosong, tidak ada operasi yang dilakukan.');
      return;
    }
    try {
      final db = await DatabaseHelper.instance.database;
      final batch = db.batch();
      for (var item in items) {
        batch.insert('dompet', item.toSqlite(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      
      await batch.commit(noResult: true);
      Log.info('Berhasil menyelesaikan sisipkanAtauPerbaruiBatch untuk ${items.length} item.');
    } catch (e, st) {
      Log.error('Gagal saat menjalankan sisipkanAtauPerbaruiBatch', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<DompetModel>> getDompetByIds(List<String> ids) async {
    Log.info('Memulai getDompetByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning('List ID untuk getDompetByIds kosong, mengembalikan list kosong.');
      return [];
    }
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      
      final listDompet = List.generate(maps.length, (i) => DompetModel.fromSqlite(maps[i]));
      Log.info('Berhasil mengambil ${listDompet.length} dompet dari ${ids.length} ID yang diminta.');
      return listDompet;
    } catch (e, st) {
      Log.error('Gagal saat getDompetByIds', error: e, stackTrace: st);
      rethrow;
    }
  }
}
