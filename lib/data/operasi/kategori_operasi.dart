// path: lib/data/operasi/kategori_operasi.dart
import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:sqflite/sqflite.dart';

class KategoriOperasi {
  final dbHelper = DatabaseHelper.instance;

  Future<KategoriModel> createKategori(KategoriModel kategori) async {
    Log.info('Memulai createKategori untuk kategori: ${kategori.toSqlite()}');
    try {
      final db = await dbHelper.database;
      final kategoriBaru = kategori.copyWith(
        diperbarui: DateTime.now(),
      );
      final data = kategoriBaru.toSqlite();

      await db.insert(
        'kategori',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      Log.info('Berhasil membuat kategori baru dengan ID: ${kategoriBaru.id}');
      return kategoriBaru;
    } catch (e, st) {
      Log.error('Gagal saat createKategori', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<KategoriModel>> getKategori() async {
    Log.info('Memulai getKategori (mengambil semua kategori yang tidak diarsipkan).');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: 'diarsipkan IS NULL',
      );
      final listKategori = List.generate(maps.length, (i) => KategoriModel.fromSqlite(maps[i]));
      Log.info('Berhasil mengambil ${listKategori.length} data kategori.');
      return listKategori;
    } catch (e, st) {
      Log.error('Gagal saat getKategori', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<KategoriModel> getKategoriById(String id) async {
    Log.info('Memulai getKategoriById untuk ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        final kategori = KategoriModel.fromSqlite(maps.first);
        Log.info('Kategori dengan ID: $id ditemukan. Data: ${kategori.toSqlite()}');
        return kategori;
      } else {
        Log.error('Kategori dengan ID $id tidak ditemukan di database.');
        throw Exception('Kategori dengan ID $id tidak ditemukan.');
      }
    } catch (e, st) {
      Log.error('Gagal saat getKategoriById untuk ID: $id', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<KategoriModel>> getKategoriByTipe(TipeKategori tipe) async {
    Log.info('Memulai getKategoriByTipe untuk tipe: ${tipe.name}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: 'tipe = ? AND diarsipkan IS NULL',
        whereArgs: [tipe.name],
      );
      final listKategori = List.generate(maps.length, (i) => KategoriModel.fromSqlite(maps[i]));
      Log.info('Berhasil mengambil ${listKategori.length} data kategori untuk tipe ${tipe.name}.');
      return listKategori;
    } catch (e, st) {
      Log.error('Gagal saat getKategoriByTipe untuk tipe: ${tipe.name}', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> update(KategoriModel kategori) async {
    Log.info('Memulai update untuk kategori: ${kategori.toSqlite()}');
    try {
      final db = await dbHelper.database;
      final data = kategori.copyWith(diperbarui: DateTime.now()).toSqlite();
      int count = await db.update(
        'kategori',
        data,
        where: 'id = ?',
        whereArgs: [kategori.id],
      );
      Log.info('Berhasil update kategori untuk ID: ${kategori.id}. Jumlah baris terpengaruh: $count');
    } catch (e, st) {
      Log.error('Gagal saat update kategori ID: ${kategori.id}', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    Log.warning('PERINGATAN: Memulai operasi delete (hard delete) untuk kategori ID: $id');
    try {
      final db = await dbHelper.database;
      int count = await db.delete('kategori', where: 'id = ?', whereArgs: [id]);
      Log.info('Berhasil delete kategori ID: $id. Jumlah baris yang dihapus permanen: $count');
    } catch (e, st) {
      Log.error('Gagal saat delete kategori ID: $id', error: e, stackTrace: st);
      rethrow;
    }
  }
  
  Future<void> arsipkanSatuKategori(String id) async {
    Log.info('Memulai arsipkanSatuKategori (soft delete) untuk ID: $id');
    try {
      final db = await dbHelper.database;
      final now = DateTime.now();
      final Map<String, dynamic> dataToUpdate = {
        'diarsipkan': now.toIso8601String(),
        'diperbarui': now.toIso8601String(),
        'isDeleted': 1,
      };
      
      int count = await db.update('kategori', dataToUpdate, where: 'id = ?', whereArgs: [id]);
      
      Log.info('Berhasil arsipkanSatuKategori untuk ID: $id. Jumlah baris terpengaruh: $count');
    } catch (e, st) {
      Log.error('Gagal saat arsipkanSatuKategori untuk ID: $id', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> bersihkanDanSisipkanSemua(List<KategoriModel> items) async {
    Log.warning('PERINGATAN: Memulai bersihkanDanSisipkanSemua. Ini akan menghapus semua kategori dan menggantinya dengan ${items.length} item baru.');
     if (items.isEmpty) {
      Log.warning('List item untuk bersihkanDanSisipkanSemua kosong, hanya operasi pembersihan yang akan dilakukan.');
    }
    try {
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        await txn.delete('kategori');
        Log.info('Tabel kategori berhasil dibersihkan.');
        for (var item in items) {
          await txn.insert('kategori', item.toSqlite());
        }
        Log.info('Berhasil menyisipkan ${items.length} item baru ke tabel kategori.');
      });
    } catch (e, st) {
      Log.error('Gagal saat menjalankan bersihkanDanSisipkanSemua', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<KategoriModel>> getPerubahan(DateTime since) async {
    Log.info('Memulai getPerubahan untuk kategori sejak: ${since.toIso8601String()}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: 'diperbarui > ?',
        whereArgs: [since.toIso8601String()],
      );
      final listKategori = List.generate(maps.length, (i) => KategoriModel.fromSqlite(maps[i]));
      Log.info('Berhasil menemukan ${listKategori.length} perubahan kategori sejak ${since.toIso8601String()}.');
      return listKategori;
    } catch (e, st) {
      Log.error('Gagal saat getPerubahan kategori', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<KategoriModel> items) async {
    Log.info('Memulai sisipkanAtauPerbaruiBatch untuk ${items.length} item kategori.');
    if (items.isEmpty) {
      Log.warning('List item untuk batch kosong, tidak ada operasi yang dilakukan.');
      return;
    }
    try {
      final db = await dbHelper.database;
      final batch = db.batch();
      for (var item in items) {
        batch.insert(
          'kategori',
          item.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      Log.info('Berhasil menyelesaikan sisipkanAtauPerbaruiBatch untuk ${items.length} item kategori.');
    } catch (e, st) {
      Log.error('Gagal saat menjalankan sisipkanAtauPerbaruiBatch kategori', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<KategoriModel>> getKategoriByIds(List<String> ids) async {
    Log.info('Memulai getKategoriByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning('List ID untuk getKategoriByIds kosong, mengembalikan list kosong.');
      return [];
    }
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      final listKategori = List.generate(maps.length, (i) => KategoriModel.fromSqlite(maps[i]));
      Log.info('Berhasil mengambil ${listKategori.length} kategori dari ${ids.length} ID yang diminta.');
      return listKategori;
    } catch (e, st) {
      Log.error('Gagal saat getKategoriByIds', error: e, stackTrace: st);
      rethrow;
    }
  }
}
