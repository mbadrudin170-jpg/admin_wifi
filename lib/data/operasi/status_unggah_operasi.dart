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

  /// Menyimpan atau memperbarui [StatusUnggahModel].
  ///
  /// Jika record dengan `tabel` yang sama sudah ada, record tersebut akan diperbarui.
  /// Jika tidak, record baru akan dibuat.
  Future<void> simpanStatusUnggah(StatusUnggahModel status) async {
    final db = await _dbHelper.database;
    await db.insert(
      'status_unggah',
      status.toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Mengambil semua [StatusUnggahModel] dari database.
  ///
  /// Mengembalikan daftar kosong jika tidak ada data.
  Future<List<StatusUnggahModel>> ambilSemuaStatusUnggah() async {
    developer.log(
      'Mulai mengambil semua status unggah',
      name: 'StatusUnggahOperasi',
    );
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('status_unggah');

    if (maps.isEmpty) {
      developer.log(
        'Tidak ada data status unggah yang ditemukan.',
        name: 'StatusUnggahOperasi',
      );
      return [];
    }

    developer.log('Data mentah dari DB: $maps', name: 'StatusUnggahOperasi');

    final hasil = List.generate(maps.length, (i) {
      return StatusUnggahModel.fromSqlite(maps[i]);
    });

    developer.log(
      'Hasil setelah diproses: ${hasil.map((e) => e.toFirebase()).toList()}',
      name: 'StatusUnggahOperasi',
    );
    return hasil;
  }

  /// Mengambil satu [StatusUnggahModel] berdasarkan [NamaTabel].
  ///
  /// Mengembalikan `null` jika tidak ada data yang ditemukan.
  Future<StatusUnggahModel?> ambilStatusUnggahByTabel(NamaTabel tabel) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'status_unggah',
      where: 'tabel = ?',
      whereArgs: [tabel.name],
    );
    if (maps.isNotEmpty) {
      return StatusUnggahModel.fromSqlite(maps.first);
    }
    return null;
  }

  /// Menghapus [StatusUnggahModel] dari database berdasarkan [NamaTabel].
  Future<void> hapusStatusUnggah(NamaTabel tabel) async {
    final db = await _dbHelper.database;
    await db.delete(
      'status_unggah',
      where: 'tabel = ?',
      whereArgs: [tabel.name],
    );
  }

  /// Menambahkan daftar ID ke [StatusUnggahModel] yang ada dan menandainya sebagai
  /// perlu diunggah.
  ///
  /// Jika tidak ada status untuk [tabel] yang diberikan, status baru akan dibuat.
  /// Fungsi ini memastikan bahwa ID yang ditambahkan bersifat unik.
  Future<void> tambahIdDanUbahStatus(NamaTabel tabel, List<String> ids) async {
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
  }

  /// Mereset status unggah untuk tabel tertentu.
  ///
  /// Ini akan mengatur `status` menjadi `false` dan mengosongkan daftar `ids`.
  /// Biasanya dipanggil setelah proses unggah ke Firebase berhasil.
  Future<void> resetStatus(NamaTabel tabel) async {
    final db = await _dbHelper.database;
    // diperbaiki: Nama tabel 'status_ungah' menjadi 'status_unggah'.
    await db.update(
      'status_unggah',
      {
        'status': 0, // false
        'ids': '[]', // JSON string untuk list kosong
      },
      where: 'tabel = ?',
      whereArgs: [tabel.name],
    );
    developer.log(
      'Status unggah untuk tabel ${tabel.name} telah di-reset.',
      name: 'StatusUnggahOperasi',
    );
  }
}
