// path: lib/data/operasi/kritik_saran_operasi.dart
import 'dart:developer' as developer;
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/kritik_saran_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

// Kelas ini menangani semua operasi database untuk entitas KritikSaran.
class KritikSaranOperasi {
  final dbHelper = DatabaseHelper.instance;
  final String fileName = 'kritik_saran_operasi.dart';

  // Fungsi untuk menyisipkan data kritik dan saran baru ke dalam database lokal.
  Future<void> createKritikSaran(KritikSaranModel kritikSaran) async {
    try {
      developer.log(
        'Memulai createKritikSaran untuk ID: ${kritikSaran.id}',
        name: fileName,
      );
      final db = await dbHelper.database;
      final now = DateTime.now();

      // ditambah: Menambahkan timestamp 'diperbarui' sebelum menyimpan.
      final data = kritikSaran.toSqlite()
        ..['diperbarui'] = now.toIso8601String();

      await db.insert(
        'kritik_saran',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      developer.log(
        'Berhasil createKritikSaran ID: ${kritikSaran.id}',
        name: fileName,
      );
    } catch (e) {
      developer.log('Gagal createKritikSaran: $e', name: fileName, error: e);
      rethrow;
    }
  }

  // Fungsi untuk mengambil semua data kritik dan saran dari database lokal.
  Future<List<KritikSaranModel>> getKritikSaran() async {
    try {
      developer.log(
        'Mengambil semua data kritik_saran (Order by tanggal DESC)',
        name: fileName,
      );
      final db = await dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        orderBy: 'tanggal DESC',
      );

      developer.log(
        'Berhasil mengambil ${maps.length} data kritik_saran',
        name: fileName,
      );
      return List.generate(maps.length, (i) {
        return KritikSaranModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log('Gagal getKritikSaran: $e', name: fileName, error: e);
      rethrow;
    }
  }

  // Fungsi untuk mengambil satu data kritik dan saran berdasarkan ID.
  Future<KritikSaranModel> getKritikSaranById(String id) async {
    try {
      developer.log('Mencari kritik_saran berdasarkan ID: $id', name: fileName);
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        developer.log('Data ditemukan untuk ID: $id', name: fileName);
        return KritikSaranModel.fromSqlite(maps.first);
      } else {
        developer.log('Data tidak ditemukan untuk ID: $id', name: fileName);
        throw Exception('ID $id tidak ditemukan');
      }
    } catch (e) {
      developer.log('Gagal getKritikSaranById: $e', name: fileName, error: e);
      rethrow;
    }
  }

  // ditambah: Fungsi untuk mendapatkan perubahan data sejak sinkronisasi terakhir.
  Future<List<KritikSaranModel>> getPerubahan(DateTime lastSync) async {
    try {
      developer.log(
        'Mengambil perubahan kritik_saran sejak: ${lastSync.toIso8601String()}',
        name: fileName,
      );
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        where: 'diperbarui > ?',
        whereArgs: [lastSync.toIso8601String()],
      );

      developer.log(
        'Ditemukan ${maps.length} perubahan kritik_saran',
        name: fileName,
      );
      return List.generate(maps.length, (i) {
        return KritikSaranModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log('Gagal getPerubahan: $e', name: fileName, error: e);
      rethrow;
    }
  }

  // ditambah: Fungsi untuk menyisipkan atau memperbarui data secara batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    List<KritikSaranModel> daftarKritikSaran,
  ) async {
    try {
      developer.log(
        'Memulai batch insert/update ${daftarKritikSaran.length} item',
        name: fileName,
      );
      final db = await dbHelper.database;
      final batch = db.batch();
      for (var kritikSaranModel in daftarKritikSaran) {
        batch.insert(
          'kritik_saran',
          kritikSaranModel.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      developer.log(
        'Berhasil menyelesaikan batch insert/update kritik_saran',
        name: fileName,
      );
    } catch (e) {
      developer.log(
        'Gagal sisipkanAtauPerbaruiBatch: $e',
        name: fileName,
        error: e,
      );
      rethrow;
    }
  }

  // ditambah: Fungsi untuk menghapus kritik saran berdasarkan ID
  Future<void> hapusKritikSaran(String id) async {
    try {
      developer.log('Menghapus kritik saran ID: $id', name: fileName);
      final db = await dbHelper.database;

      // Cek apakah data ada sebelum dihapus
      final data = await db.query(
        'kritik_saran',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (data.isEmpty) {
        developer.log(
          'Gagal menghapus: ID $id tidak ditemukan',
          name: fileName,
        );
        throw Exception('Data dengan ID $id tidak ditemukan');
      }

      // Hapus data
      await db.delete('kritik_saran', where: 'id = ?', whereArgs: [id]);

      developer.log(
        '✅ Berhasil menghapus kritik saran dengan ID: $id',
        name: fileName,
      );
    } catch (e) {
      developer.log(
        '❌ Gagal menghapus kritik saran: $e',
        name: fileName,
        error: e,
      );
      rethrow; // Melempar ulang error untuk ditangani di UI
    }
  }

  // ditambah: Fungsi untuk menghapus semua kritik saran
  Future<void> hapusSemuaKritikSaran() async {
    try {
      developer.log('Menghapus SEMUA data kritik_saran', name: fileName);
      final db = await dbHelper.database;

      int count = await db.delete('kritik_saran');

      developer.log(
        '✅ Berhasil menghapus semua kritik saran. Total baris: $count',
        name: fileName,
      );
    } catch (e) {
      developer.log(
        '❌ Gagal menghapus semua kritik saran: $e',
        name: fileName,
        error: e,
      );
      rethrow;
    }
  }

  // ditambah: Fungsi untuk menghapus kritik saran berdasarkan userId
  Future<void> hapusByUserId(String userId) async {
    try {
      developer.log(
        'Menghapus kritik saran untuk userId: $userId',
        name: fileName,
      );
      final db = await dbHelper.database;

      final deletedCount = await db.delete(
        'kritik_saran',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      developer.log(
        '✅ Berhasil menghapus $deletedCount kritik saran dari user: $userId',
        name: fileName,
      );
    } catch (e) {
      developer.log(
        '❌ Gagal menghapus kritik saran by userId: $e',
        name: fileName,
        error: e,
      );
      rethrow;
    }
  }

  Future<void> debugCekTabel() async {
    try {
      developer.log('--- DEBUG START: kritik_saran ---', name: fileName);
      final db = await dbHelper.database;

      // Cek apakah tabel ada
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='kritik_saran'",
      );
      developer.log(
        '📋 Tabel kritik_saran ada: ${result.isNotEmpty}',
        name: fileName,
      );

      // Cek jumlah data
      final count = await db.rawQuery(
        'SELECT COUNT(*) as count FROM kritik_saran',
      );
      developer.log('📊 Jumlah data: ${count.first['count']}', name: fileName);

      // Lihat struktur tabel
      final tableInfo = await db.rawQuery('PRAGMA table_info(kritik_saran)');
      developer.log('🏗️ Struktur tabel:', name: fileName);
      for (var col in tableInfo) {
        developer.log('  - ${col['name']} (${col['type']})', name: fileName);
      }

      // Lihat semua data
      final allData = await db.query('kritik_saran');
      developer.log('📦 Isi semua data:', name: fileName);
      for (var data in allData) {
        developer.log('  $data', name: fileName);
      }
      developer.log('--- DEBUG END ---', name: fileName);
    } catch (e) {
      developer.log('❌ Error debug: $e', name: fileName, error: e);
    }
  }

  // ditambah: Fungsi untuk mengunduh semua data dari koleksi 'kritik_saran' di Firebase.
  static Future<List<KritikSaranModel>> unduhDataDariFirebase() async {
    const String staticFileName = 'kritik_saran_operasi.dart';
    try {
      developer.log(
        'Memulai pengunduhan data dari Firestore koleksi: kritik_saran',
        name: staticFileName,
      );
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('kritik_saran')
          .get();
      final List<KritikSaranModel> data = snapshot.docs
          .map(
            (doc) => KritikSaranModel.fromFirebase(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();

      developer.log(
        'Berhasil mengunduh ${data.length} data kritik dan saran dari Firebase.',
        name: staticFileName,
      );
      return data;
    } catch (e, stackTrace) {
      developer.log(
        'Gagal mengunduh data kritik dan saran dari Firebase: $e',
        name: staticFileName,
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<List<KritikSaranModel>> getKritikSaranByIds(List<String> ids) async {
    try {
      if (ids.isEmpty) {
        developer.log('getKritikSaranByIds: List ID kosong', name: fileName);
        return [];
      }
      developer.log(
        'Mengambil data kritik_saran untuk multiple IDs: $ids',
        name: fileName,
      );
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );

      developer.log(
        'Berhasil mengambil ${maps.length} data berdasarkan list ID',
        name: fileName,
      );
      return List.generate(maps.length, (i) {
        return KritikSaranModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log('Gagal getKritikSaranByIds: $e', name: fileName, error: e);
      rethrow;
    }
  }
}
