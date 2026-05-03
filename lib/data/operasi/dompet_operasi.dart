// path : lib/data/operasi/dompet_operasi.dart
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_wifi/model/enum/sync_status.dart';

class DompetOperasi {
  final dbHelper = DatabaseHelper.instance;

  /* OPERASI CRUD KE SQLITE */

  // diubah: Menambahkan logika untuk mengatur status sinkronisasi secara eksplisit
  Future<void> createDompet(DompetModel dompet) async {
    final db = await dbHelper.database;
    // diubah: Menggunakan 'copyWith' yang merupakan nama metode standar.
    final dompetBaru = dompet.copyWith(
      syncStatus: SyncStatus.write,
      diperbarui: DateTime.now(),
    );
    await db.insert(
      'dompet',
      dompetBaru.toMap(), // Menyimpan objek yang sudah di-override
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

  Future<void> updateDompet(DompetModel dompet) async {
    final db = await dbHelper.database;
    await db.update(
      'dompet',
      dompet.toMap(),
      where: 'id = ?',
      whereArgs: [dompet.id],
    );
  }

  Future<void> deleteDompet(String id) async {
    final db = await dbHelper.database;
    await db.delete('dompet', where: 'id = ?', whereArgs: [id]);
  }

  // == FUNGSI PENGHITUNGAN SALDO ==

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

  // == METODE BARU UNTUK SINKRONISASI INKREMENTAL ==

  Future<List<DompetModel>> getPerubahan(DateTime since) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dompet',
      where: 'diperbarui > ?',
      whereArgs: [since.toIso8601String()],
    );
    return List.generate(maps.length, (i) => DompetModel.fromMap(maps[i]));
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<DompetModel> items) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (var item in items) {
      batch.insert(
        'dompet',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> unggahDompetKeFirebase() async {
    final db = await dbHelper.database;
    final firestore = FirebaseFirestore.instance;

    final List<Map<String, dynamic>> maps = await db.query(
      'dompet',
      where: 'sync_status != ?',
      whereArgs: [SyncStatus.synced.name],
    );

    if (maps.isEmpty) {
      return;
    }

    final List<DompetModel> daftarDompet = List.generate(
      maps.length,
      (i) => DompetModel.fromMap(maps[i]),
    );

    final batchFirestore = firestore.batch();
    final batchLokal = db.batch();

    for (final dompet in daftarDompet) {
      final docRef = firestore.collection('dompet').doc(dompet.id);

      switch (dompet.syncStatus) {
        case SyncStatus.write:
          final dataUnggah = dompet.toMap();
          dataUnggah.remove('sync_status');
          batchFirestore.set(docRef, dataUnggah);
          batchLokal.update(
            'dompet',
            {'sync_status': SyncStatus.synced.name},
            where: 'id = ?',
            whereArgs: [dompet.id],
          );
          break;

        case SyncStatus.update:
          final dataUnggah = dompet.toMap();
          dataUnggah.remove('sync_status');
          batchFirestore.update(docRef, dataUnggah);
          batchLokal.update(
            'dompet',
            {'sync_status': SyncStatus.synced.name},
            where: 'id = ?',
            whereArgs: [dompet.id],
          );
          break;

        case SyncStatus.deleted:
          batchFirestore.delete(docRef);
          batchLokal.delete('dompet', where: 'id = ?', whereArgs: [dompet.id]);
          break;

        case SyncStatus.synced:
          break;
      }
    }

    try {
      await batchFirestore.commit();
      await batchLokal.commit(noResult: true);
    } catch (e) {
      //
    }
  }
}
