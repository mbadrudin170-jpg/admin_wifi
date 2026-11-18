// path: lib/data/operasi/pelanggan_operasi.dart
import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/db/sqflite.dart';
import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:share_global_saya/src/utils/l.dart';

class PelangganOperasi {
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();

  Future<void> createPelanggan(PelangganModel pelanggan) async {
    L.i('Memulai pembuatan pelanggan dengan ID: ${pelanggan.id}');
    try {
      final pelangganUntukDisimpan = pelanggan.copyWith(
        diperbarui: DateTime.now(),
      );
      final data = pelangganUntukDisimpan.toSqlite();

      await _operasiDasar.sisipkan('pelanggan', data);

      L.i(
        'Pelanggan (ID: ${pelangganUntukDisimpan.id}) berhasil dibuat di database lokal.',
      );
    } catch (e, s) {
      L.e('Gagal membuat pelanggan. Error: $e $s');
      rethrow;
    }
  }

  Future<List<PelangganModel>> getPelanggan() async {
    L.i(
      'Mengambil semua pelanggan yang aktif (tidak diarsipkan dan tidak dihapus).',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'diarsipkan IS NULL AND isDeleted = ?',
        whereArgs: [0],
      );

      L.i('Berhasil mengambil ${maps.length} pelanggan aktif.');
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      L.e('Gagal mengambil pelanggan aktif. Error: $e $s');
      rethrow;
    }
  }

  Future<List<PelangganModel>> getAllPelanggan() async {
    L.i('Mengambil SEMUA data pelanggan dari database lokal.');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('pelanggan');

      L.i('Berhasil mengambil total ${maps.length} pelanggan.');
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      L.e('Gagal mengambil semua data pelanggan. Error: $e $s');
      rethrow;
    }
  }

  Future<PelangganModel?> getPelangganById(String id) async {
    L.i('Mencari pelanggan berdasarkan ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        L.i('Pelanggan dengan ID: $id ditemukan.');
        return PelangganModel.fromSqlite(maps.first);
      }
      L.w('Pelanggan dengan ID: $id tidak ditemukan.');
      return null;
    } catch (e, s) {
      L.e('Gagal mencari pelanggan berdasarkan ID. Error: $e $s');
      rethrow;
    }
  }

  Future<void> updatePelanggan(PelangganModel pelanggan) async {
    L.i('Memulai pembaruan untuk pelanggan ID: ${pelanggan.id}');
    try {
      final data = pelanggan.copyWith(diperbarui: DateTime.now()).toSqlite();

      await _operasiDasar.perbarui('pelanggan', data, pelanggan.id);

      L.i('Berhasil memperbarui pelanggan ID: ${pelanggan.id}.');
    } catch (e, s) {
      L.e('Gagal memperbarui pelanggan. Error: $e $s');
      rethrow;
    }
  }

  Future<void> deletePelanggan(String id, {bool softDelete = true}) async {
    L.i(
      'Memulai proses penghapusan untuk pelanggan ID: $id (softDelete: $softDelete)',
    );
    try {
      if (softDelete) {
        await _operasiDasar.perbarui('pelanggan', {
          'isDeleted': 1,
          'diperbarui': DateTime.now().toIso8601String(),
        }, id);
        L.i('Berhasil melakukan soft delete pada pelanggan ID: $id.');
      } else {
        await _operasiDasar.hapus('pelanggan', id);
        L.w(
          'Berhasil melakukan hard delete (penghapusan permanen) pada pelanggan ID: $id.',
        );
      }
    } catch (e, s) {
      L.e('Gagal menghapus pelanggan. Error: $e $s');
      rethrow;
    }
  }

  Future<List<PelangganModel>> getPerubahan(DateTime since) async {
    L.i('Mengambil perubahan pelanggan sejak: ${since.toIso8601String()}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'diperbarui > ?',
        whereArgs: [since.toIso8601String()],
      );
      L.i(
        'Ditemukan ${maps.length} perubahan pelanggan sejak waktu yang ditentukan.',
      );
      return List.generate(
        maps.length,
        (i) => PelangganModel.fromSqlite(maps[i]),
      );
    } catch (e, s) {
      L.e('Gagal mengambil perubahan pelanggan. Error: $e $s');
      rethrow;
    }
  }

  Future<void> arsipkanPelanggan(String id) async {
    L.i('Mengarsipkan pelanggan ID: $id');
    try {
      final now = DateTime.now();
      await _operasiDasar.perbarui('pelanggan', {
        'isDeleted': 1,
        'diarsipkan': now.toIso8601String(),
        'diperbarui': now.toIso8601String(),
      }, id);
      L.i('Berhasil mengarsipkan pelanggan ID: $id.');
    } catch (e, s) {
      L.e('Gagal mengarsipkan pelanggan. Error: $e $s');
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<PelangganModel> items) async {
    if (items.isEmpty) {
      L.i('Tidak ada item untuk diproses dalam batch.');
      return;
    }
    L.i('Memulai batch insert/update untuk ${items.length} pelanggan.');
    try {
      final data = items.map((item) {
        final itemToSave = item.copyWith(diperbarui: DateTime.now());
        return itemToSave.toSqlite();
      }).toList();

      await _operasiDasar.sisipkanAtauPerbaruiBatch('pelanggan', data);
      L.i(
        'Berhasil menyelesaikan operasi batch untuk ${items.length} pelanggan.',
      );
    } catch (e, s) {
      L.e('Gagal menjalankan operasi batch. Error: $e $s');
      rethrow;
    }
  }

  Future<List<PelangganModel>> getPelangganByIds(List<String> ids) async {
    if (ids.isEmpty) {
      L.i('List ID kosong, tidak ada pelanggan yang diambil.');
      return [];
    }
    L.i('Mengambil data pelanggan untuk ${ids.length} ID.');
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      L.i(
        'Berhasil mengambil ${maps.length} pelanggan berdasarkan list ID yang diberikan.',
      );
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      L.e('Gagal mengambil pelanggan berdasarkan list ID. Error: $e $s');
      rethrow;
    }
  }
}
