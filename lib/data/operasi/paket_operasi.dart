// path: lib/data/operasi/paket_operasi.dart
import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/db/sqflite.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:share_global_saya/src/utils/l.dart';

class PaketOperasi {
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();

  Future<void> createPaket(PaketModel paket) async {
    L.i(
      'Mendelegasikan pembuatan paket ke OperasiDasar, method: createPaket, id: ${paket.id}',
    );
    try {
      final now = DateTime.now();
      final data = paket.copyWith(diperbarui: now).toSqlite();
      await _operasiDasar.sisipkan('paket', data);
      L.i(
        'Berhasil mendelegasikan pembuatan paket, method: createPaket, id: ${paket.id}',
      );
    } catch (e, s) {
      L.e(
        'Gagal mendelegasikan pembuatan paket, method: createPaket, id: ${paket.id}, error: $e Error: $e $s',
      );
      rethrow;
    }
  }

  Future<List<PaketModel>> getAllPaket() async {
    L.i('Memulai proses pengambilan semua data paket, method: getPaket');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE tipe
            WHEN 'jam' THEN durasi
            WHEN 'hari' THEN durasi * 24
            WHEN 'bulan' THEN durasi * 24 * 30
            ELSE 999999
          END as urutan
        FROM paket
        ORDER BY urutan ASC
      ''');

      if (maps.isNotEmpty) {
        L.i('Berhasil mengambil ${maps.length} data paket, method: getPaket');
      } else {
        L.w('Tidak ada data paket yang ditemukan, method: getPaket');
      }
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      L.e(
        'Gagal mengambil semua data paket, method: getPaket, error: $e Error: $e $s',
      );
      rethrow;
    }
  }

  Future<List<PaketModel>> getPaket() async {
    L.i(
      'Memulai proses pengambilan semua data paket aktif, method: getPaketAktif',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE tipe
            WHEN 'jam' THEN durasi
            WHEN 'hari' THEN durasi * 24
            WHEN 'bulan' THEN durasi * 24 * 30
            ELSE 999999
          END as urutan
        FROM paket
        WHERE isDeleted = 0
        ORDER BY urutan ASC
      ''');

      if (maps.isNotEmpty) {
        L.i(
          'Berhasil mengambil ${maps.length} data paket aktif, method: getPaketAktif',
        );
      } else {
        L.w('Tidak ada data paket aktif yang ditemukan, method: getPaketAktif');
      }
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      L.e(
        'Gagal mengambil semua data paket aktif, method: getPaketAktif, error: $e Error: $e $s',
      );
      rethrow;
    }
  }

  Future<List<PaketModel>> getPaketByIsPublic() async {
    L.i(
      'Memulai proses pengambilan semua data paket publik, method: getPaketByIsPublic',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE tipe
            WHEN 'jam' THEN durasi
            WHEN 'hari' THEN durasi * 24
            WHEN 'bulan' THEN durasi * 24 * 30
            ELSE 999999
          END as urutan
        FROM paket
        WHERE isDeleted = 0 AND isPublic = 1
        ORDER BY urutan ASC
      ''');

      if (maps.isNotEmpty) {
        L.i(
          'Berhasil mengambil ${maps.length} data paket publik, method: getPaketByIsPublic',
        );
      } else {
        L.w(
          'Tidak ada data paket publik yang ditemukan, method: getPaketByIsPublic',
        );
      }
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      L.e(
        'Gagal mengambil semua data paket publik, method: getPaketByIsPublic, error: $e Error: $e $s',
      );
      rethrow;
    }
  }

  Future<PaketModel?> getPaketById(String id) async {
    L.i(
      'Memulai pencarian paket berdasarkan ID, method: getPaketById, id: $id',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        L.i('Paket ditemukan, method: getPaketById, id: $id');
        return PaketModel.fromSqlite(maps.first);
      } else {
        L.w('Paket dengan ID $id tidak ditemukan, method: getPaketById');
        return null;
      }
    } catch (e, s) {
      L.e(
        'Gagal mencari paket berdasarkan ID, method: getPaketById, id: $id, error: $e Error: $e $s',
      );
      rethrow;
    }
  }

  Future<void> updatePaket(PaketModel paket) async {
    L.i(
      'Mendelegasikan pembaruan paket ke OperasiDasar, method: updatePaket, id: ${paket.id}',
    );
    try {
      final now = DateTime.now();
      final data = paket.copyWith(diperbarui: now).toSqlite();
      await _operasiDasar.perbarui('paket', data, paket.id);
      L.i(
        'Berhasil mendelegasikan pembaruan paket, method: updatePaket, id: ${paket.id}',
      );
    } catch (e, s) {
      L.e(
        'Gagal mendelegasikan pembaruan paket, method: updatePaket, id: ${paket.id}, error: $e Error: $e $s',
      );
      rethrow;
    }
  }

  Future<void> hapusPaket(String id) async {
    L.i(
      'Mendelegasikan penghapusan paket ke OperasiDasar, method: hapusPaket, id: $id',
    );
    try {
      await _operasiDasar.hapus('paket', id);
      L.i(
        'Berhasil mendelegasikan penghapusan paket, method: hapusPaket, id: $id',
      );
    } catch (e, s) {
      L.e(
        'Gagal mendelegasikan penghapusan paket, method: hapusPaket, id: $id, error: $e Error: $e $s',
      );
      rethrow;
    }
  }

  Future<void> hapusSemuaPaket() async {
    L.i('Memulai proses penghapusan semua data paket, method: hapusSemuaPaket');
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        int count = await txn.delete('paket');
        L.i(
          'Berhasil menghapus semua data paket. Total terhapus: $count, method: hapusSemuaPaket',
        );
        return count;
      });
    } catch (e, s) {
      L.e(
        'Gagal menghapus semua data paket, method: hapusSemuaPaket, error: $e Error: $e $s',
      );
      rethrow;
    }
  }

  Future<List<PaketModel>> getPerubahan(DateTime since) async {
    L.i(
      'Memulai pengambilan perubahan paket sejak ${since.toIso8601String()}, method: getPerubahan',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: 'diperbarui > ?',
        whereArgs: [since.toIso8601String()],
      );
      if (maps.isNotEmpty) {
        L.i('Ditemukan ${maps.length} perubahan paket, method: getPerubahan');
      } else {
        L.i(
          'Tidak ada perubahan paket ditemukan sejak ${since.toIso8601String()}, method: getPerubahan',
        );
      }
      return List.generate(maps.length, (i) => PaketModel.fromSqlite(maps[i]));
    } catch (e, s) {
      L.e(
        'Gagal mengambil perubahan paket, method: getPerubahan, error: $e Error: $e $s',
      );
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<PaketModel> items) async {
    L.i(
      'Mendelegasikan proses batch ke OperasiDasar untuk ${items.length} item paket, method: sisipkanAtauPerbaruiBatch',
    );
    try {
      final dataList = items.map((item) => item.toSqlite()).toList();
      await _operasiDasar.sisipkanAtauPerbaruiBatch('paket', dataList);
      L.i(
        'Berhasil mendelegasikan proses batch untuk ${items.length} item, method: sisipkanAtauPerbaruiBatch',
      );
    } catch (e, s) {
      L.e(
        'Gagal mendelegasikan proses batch, method: sisipkanAtauPerbaruiBatch, error: $e Error: $e $s',
      );
      rethrow;
    }
  }

  Future<List<PaketModel>> getPaketByIds(List<String> ids) async {
    L.i(
      'Memulai pengambilan paket berdasarkan list ID, method: getPaketByIds, ids: $ids',
    );
    try {
      if (ids.isEmpty) {
        L.w('List ID kosong, mengembalikan list kosong, method: getPaketByIds');
        return [];
      }
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      L.i(
        'Berhasil mengambil ${maps.length} paket dari ${ids.length} ID yang diminta, method: getPaketByIds',
      );
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      L.e(
        'Gagal mengambil paket berdasarkan list ID, method: getPaketByIds, error: $e Error: $e $s',
      );
      rethrow;
    }
  }
}
