// path: lib/data/operasi/status_unggah_operasi.dart
import 'dart:developer' as developer;
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/enum/nama_tabel_enum.dart';
import 'package:admin_wifi/model/status_unggah_model.dart';
import 'package:sqflite/sqflite.dart';

/// Kelas ini menyediakan lapisan abstraksi untuk semua operasi database (CRUD)
/// yang terkait dengan tabel `status_unggah`.
class StatusUnggahOperasi {
  final _dbHelper = DatabaseHelper.instance;
  final String fileName = 'status_unggah_operasi.dart';

  /// Menyimpan atau memperbarui [StatusUnggahModel].
  Future<void> simpanStatusUnggah(StatusUnggahModel status) async {
    try {
      developer.log('Memulai simpanStatusUnggah untuk tabel: ${status.tabel.name}', name: fileName);
      final db = await _dbHelper.database;
      
      await db.insert(
        'status_unggah',
        status.toSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      developer.log(
        '✅ Berhasil simpan/update status_unggah tabel: ${status.tabel.name} (Status: ${status.status}, Jumlah ID: ${status.ids.length})',
        name: fileName,
      );
    } catch (e) {
      developer.log('❌ Gagal simpanStatusUnggah: $e', name: fileName, error: e);
      rethrow;
    }
  }

  /// Mengambil semua [StatusUnggahModel] dari database.
  Future<List<StatusUnggahModel>> ambilSemuaStatusUnggah() async {
    try {
      developer.log('Mulai mengambil semua data dari tabel status_unggah', name: fileName);
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('status_unggah');

      if (maps.isEmpty) {
        developer.log('⚠️ Tabel status_unggah kosong.', name: fileName);
        return [];
      }

      developer.log('Data mentah ditemukan: ${maps.length} baris', name: fileName);

      final hasil = List.generate(maps.length, (i) {
        return StatusUnggahModel.fromSqlite(maps[i]);
      });

      developer.log(
        'Berhasil memproses ${hasil.length} StatusUnggahModel',
        name: fileName,
      );
      return hasil;
    } catch (e) {
      developer.log('❌ Gagal ambilSemuaStatusUnggah: $e', name: fileName, error: e);
      rethrow;
    }
  }

  /// Mengambil satu [StatusUnggahModel] berdasarkan [NamaTabel].
  Future<StatusUnggahModel?> ambilStatusUnggahByTabel(NamaTabel tabel) async {
    try {
      developer.log('Mengambil status_unggah untuk tabel: ${tabel.name}', name: fileName);
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'status_unggah',
        where: 'tabel = ?',
        whereArgs: [tabel.name],
      );

      if (maps.isNotEmpty) {
        developer.log('Data ditemukan untuk tabel: ${tabel.name}', name: fileName);
        return StatusUnggahModel.fromSqlite(maps.first);
      }
      
      developer.log('Data tidak ditemukan untuk tabel: ${tabel.name}', name: fileName);
      return null;
    } catch (e) {
      developer.log('❌ Gagal ambilStatusUnggahByTabel: $e', name: fileName, error: e);
      rethrow;
    }
  }

  /// Menghapus [StatusUnggahModel] dari database berdasarkan [NamaTabel].
  Future<void> hapusStatusUnggah(NamaTabel tabel) async {
    try {
      developer.log('Menghapus record status_unggah untuk tabel: ${tabel.name}', name: fileName);
      final db = await _dbHelper.database;
      int count = await db.delete(
        'status_unggah',
        where: 'tabel = ?',
        whereArgs: [tabel.name],
      );
      developer.log('✅ Berhasil hapus status_unggah. Baris terpengaruh: $count', name: fileName);
    } catch (e) {
      developer.log('❌ Gagal hapusStatusUnggah: $e', name: fileName, error: e);
      rethrow;
    }
  }

  /// Menambahkan daftar ID ke [StatusUnggahModel] yang ada dan menandainya sebagai perlu diunggah.
  Future<void> tambahIdDanUbahStatus(NamaTabel tabel, List<String> ids) async {
    try {
      developer.log('Menambahkan ${ids.length} ID baru ke status_unggah tabel: ${tabel.name}', name: fileName);
      
      // Ambil status yang ada, atau buat yang baru jika tidak ada.
      final statusSaatIni =
          await ambilStatusUnggahByTabel(tabel) ??
          StatusUnggahModel(tabel: tabel, status: false, ids: []);

      // Gabungkan daftar ID yang ada dengan yang baru, hindari duplikat.
      final idSet = <String>{...statusSaatIni.ids, ...ids};

      // Buat objek status yang diperbarui.
      final statusDiperbarui = statusSaatIni.copyWith(
        ids: idSet.toList(),
        status: true,
      );

      // Simpan status yang diperbarui ke database.
      await simpanStatusUnggah(statusDiperbarui);
      developer.log('✅ Update ID unik selesai. Total ID sekarang: ${idSet.length}', name: fileName);
    } catch (e) {
      developer.log('❌ Gagal tambahIdDanUbahStatus: $e', name: fileName, error: e);
      rethrow;
    }
  }

  /// Mereset status unggah untuk tabel tertentu.
  Future<void> resetStatus(NamaTabel tabel) async {
    try {
      developer.log('Mereset status unggah (ids = empty, status = false) untuk tabel: ${tabel.name}', name: fileName);
      final db = await _dbHelper.database;
      
      int count = await db.update(
        'status_unggah',
        {
          'status': 0, // false
          'ids': '[]', // JSON string untuk list kosong
        },
        where: 'tabel = ?',
        whereArgs: [tabel.name],
      );
      
      developer.log(
        '✅ Status unggah untuk tabel ${tabel.name} telah di-reset. Baris terpengaruh: $count',
        name: fileName,
      );
    } catch (e) {
      developer.log('❌ Gagal resetStatus: $e', name: fileName, error: e);
      rethrow;
    }
  }
}