// path: lib/data/operasi/dompet_operasi.dart
import 'dart:developer' as developer;
import 'package:admin_wifi/data/operasi/status_unggah_operasi.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/enum/nama_tabel_enum.dart';
import 'package:sqflite/sqflite.dart';

class DompetOperasi {
  final dbHelper = DatabaseHelper.instance;
  final statusUnggahOperasi = StatusUnggahOperasi();
  final String fileName = 'dompet_operasi.dart';

  Future<void> createDompet(DompetModel dompet) async {
    try {
      developer.log('Memulai createDompet untuk ID: ${dompet.id}', name: fileName);
      final db = await dbHelper.database;

      final data = dompet.copyWith(diperbarui: DateTime.now()).toSqlite();
      await db.insert(
        'dompet',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      await statusUnggahOperasi.tambahIdDanUbahStatus(NamaTabel.dompet, [
        dompet.id,
      ]);
      developer.log('Berhasil createDompet dan perbarui status unggah ID: ${dompet.id}', name: fileName);
    } catch (e) {
      developer.log('Gagal createDompet: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<List<DompetModel>> getDompet() async {
    try {
      developer.log('Mengambil semua data dompet (isDeleted = 0)', name: fileName);
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: 'isDeleted = 0',
      );
      
      developer.log('Berhasil mengambil ${maps.length} data dompet', name: fileName);
      return List.generate(maps.length, (i) {
        return DompetModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log('Gagal getDompet: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<DompetModel?> getDompetById(String id) async {
    try {
      developer.log('Mencari dompet berdasarkan ID: $id', name: fileName);
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: 'id = ? AND isDeleted = 0',
        whereArgs: [id],
      );
      
      if (maps.isNotEmpty) {
        developer.log('Dompet ditemukan untuk ID: $id', name: fileName);
        return DompetModel.fromSqlite(maps.first);
      }
      developer.log('Dompet tidak ditemukan untuk ID: $id', name: fileName);
      return null;
    } catch (e) {
      developer.log('Gagal getDompetById: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<void> updateDompet(DompetModel dompet) async {
    try {
      developer.log('Memulai updateDompet untuk ID: ${dompet.id}', name: fileName);
      final db = await dbHelper.database;
      final now = DateTime.now();
      
      final data = dompet.copyWith(diperbarui: now).toSqlite();
      await db.update('dompet', data, where: 'id = ?', whereArgs: [dompet.id]);
      
      await statusUnggahOperasi.tambahIdDanUbahStatus(NamaTabel.dompet, [
        dompet.id,
      ]);
      developer.log('Berhasil updateDompet dan perbarui status unggah ID: ${dompet.id}', name: fileName);
    } catch (e) {
      developer.log('Gagal updateDompet: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<void> hapusSemuaDompet() async {
    try {
      developer.log('Menghapus SEMUA data dompet dari tabel', name: fileName);
      final db = await dbHelper.database;
      int count = await db.delete('dompet');
      developer.log('Berhasil hapusSemuaDompet. Total baris dihapus: $count', name: fileName);
    } catch (e) {
      developer.log('Gagal hapusSemuaDompet: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<void> arsipkanSatuDompet(String id) async {
    try {
      developer.log('Mengarsipkan dompet (soft delete) ID: $id', name: fileName);
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
      developer.log('Berhasil mengarsipkan dompet ID: $id', name: fileName);
    } catch (e) {
      developer.log('Gagal arsipkanSatuDompet: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<double> getTotalSaldo() async {
    try {
      developer.log('Menghitung total saldo seluruh dompet', name: fileName);
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(saldo) as total FROM dompet WHERE isDeleted = 0',
      );
      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }
      developer.log('Total saldo: $total', name: fileName);
      return total;
    } catch (e) {
      developer.log('Gagal getTotalSaldo: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<double> getTotalSaldoPositif() async {
    try {
      developer.log('Menghitung total saldo positif', name: fileName);
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(saldo) as total FROM dompet WHERE saldo > 0 AND isDeleted = 0',
      );
      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }
      developer.log('Total saldo positif: $total', name: fileName);
      return total;
    } catch (e) {
      developer.log('Gagal getTotalSaldoPositif: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<double> getTotalSaldoNegatif() async {
    try {
      developer.log('Menghitung total saldo negatif', name: fileName);
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(saldo) as total FROM dompet WHERE saldo < 0 AND isDeleted = 0',
      );
      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }
      developer.log('Total saldo negatif: $total', name: fileName);
      return total;
    } catch (e) {
      developer.log('Gagal getTotalSaldoNegatif: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<DompetModel> items) async {
    try {
      developer.log('Memulai batch insert/update untuk ${items.length} item dompet', name: fileName);
      final db = await DatabaseHelper.instance.database;
      final batch = db.batch();
      for (var item in items) {
        batch.insert(
          'dompet',
          item.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      developer.log('Berhasil menyelesaikan batch insert/update dompet', name: fileName);
    } catch (e) {
      developer.log('Gagal sisipkanAtauPerbaruiBatch: $e', name: fileName, error: e);
      rethrow;
    }
  }

  Future<List<DompetModel>> getDompetByIds(List<String> ids) async {
    try {
      if (ids.isEmpty) {
        developer.log('getDompetByIds: List ID kosong', name: fileName);
        return [];
      }
      developer.log('Mengambil data dompet untuk ID: $ids', name: fileName);
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      developer.log('Berhasil mengambil ${maps.length} dompet dari list ID', name: fileName);
      return List.generate(maps.length, (i) {
        return DompetModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log('Gagal getDompetByIds: $e', name: fileName, error: e);
      rethrow;
    }
  }
}