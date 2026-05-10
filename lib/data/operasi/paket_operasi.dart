// path: lib/data/operasi/paket_operasi.dart
import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/data/operasi/status_unggah_operasi.dart';

class PaketOperasi {
  final dbHelper = DatabaseHelper.instance;
  // Tambah: instance dari OperasiDasar
  final OperasiDasar _operasiDasar = OperasiDasar();
  final String _fileName = 'paket_operasi.dart';

  // Diubah: Menggunakan OperasiDasar.sisipkan
  Future<void> createPaket(PaketModel paket) async {
    Log.info(
      'Mendelegasikan pembuatan paket ke OperasiDasar - file: $_fileName, method: createPaket, id: ${paket.id}',
    );
    try {
      final now = DateTime.now();
      final data = paket.copyWith(diperbarui: now).toSqlite();
      await _operasiDasar.sisipkan('paket', data);
      Log.info(
        'Berhasil mendelegasikan pembuatan paket - file: $_fileName, method: createPaket, id: ${paket.id}',
      );
    } catch (e, s) {
      Log.error(
        'Gagal mendelegasikan pembuatan paket - file: $_fileName, method: createPaket, id: ${paket.id}, error: $e',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<List<PaketModel>> getPaket() async {
    Log.info(
      'Memulai proses pengambilan semua data paket - file: $_fileName, method: getPaket',
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
        ORDER BY urutan ASC
      ''');

      if (maps.isNotEmpty) {
        Log.info(
          'Berhasil mengambil ${maps.length} data paket - file: $_fileName, method: getPaket',
        );
      } else {
        Log.warning(
          'Tidak ada data paket yang ditemukan - file: $_fileName, method: getPaket',
        );
      }
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error(
        'Gagal mengambil semua data paket - file: $_fileName, method: getPaket, error: $e',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<PaketModel?> getPaketById(String id) async {
    Log.info(
      'Memulai pencarian paket berdasarkan ID - file: $_fileName, method: getPaketById, id: $id',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info(
          'Paket ditemukan - file: $_fileName, method: getPaketById, id: $id',
        );
        return PaketModel.fromSqlite(maps.first);
      } else {
        Log.warning(
          'Paket dengan ID $id tidak ditemukan - file: $_fileName, method: getPaketById',
        );
        return null;
      }
    } catch (e, s) {
      Log.error(
        'Gagal mencari paket berdasarkan ID - file: $_fileName, method: getPaketById, id: $id, error: $e',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  // Diubah: Menggunakan OperasiDasar.perbarui
  Future<void> updatePaket(PaketModel paket) async {
    Log.info(
      'Mendelegasikan pembaruan paket ke OperasiDasar - file: $_fileName, method: updatePaket, id: ${paket.id}',
    );
    try {
      final now = DateTime.now();
      final data = paket.copyWith(diperbarui: now).toSqlite();
      await _operasiDasar.perbarui('paket', data, paket.id);
      Log.info(
        'Berhasil mendelegasikan pembaruan paket - file: $_fileName, method: updatePaket, id: ${paket.id}',
      );
    } catch (e, s) {
      Log.error(
        'Gagal mendelegasikan pembaruan paket - file: $_fileName, method: updatePaket, id: ${paket.id}, error: $e',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  // Diubah: Menggunakan OperasiDasar.hapus
  Future<void> hapusPaket(String id) async {
    Log.info(
      'Mendelegasikan penghapusan paket ke OperasiDasar - file: $_fileName, method: hapusPaket, id: $id',
    );
    try {
      await _operasiDasar.hapus('paket', id);
      Log.info(
        'Berhasil mendelegasikan penghapusan paket - file: $_fileName, method: hapusPaket, id: $id',
      );
    } catch (e, s) {
      Log.error(
        'Gagal mendelegasikan penghapusan paket - file: $_fileName, method: hapusPaket, id: $id, error: $e',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<void> hapusSemuaPaket() async {
    Log.info(
      'Memulai proses penghapusan semua data paket - file: $_fileName, method: hapusSemuaPaket',
    );
    final db = await dbHelper.database;
    final statusUnggahOperasi = StatusUnggahOperasi();
    try {
      await db.transaction((txn) async {
        await statusUnggahOperasi.setPerluUnggah(true, transaction: txn);
        int count = await txn.delete('paket');
        Log.info(
          'Berhasil menghapus semua data paket. Total terhapus: $count - file: $_fileName, method: hapusSemuaPaket',
        );
      });
    } catch (e, s) {
      Log.error(
        'Gagal menghapus semua data paket - file: $_fileName, method: hapusSemuaPaket, error: $e',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<List<PaketModel>> getPerubahan(DateTime since) async {
    Log.info(
      'Memulai pengambilan perubahan paket sejak ${since.toIso8601String()} - file: $_fileName, method: getPerubahan',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: 'diperbarui > ?',
        whereArgs: [since.toIso8601String()],
      );
      if (maps.isNotEmpty) {
        Log.info(
          'Ditemukan ${maps.length} perubahan paket - file: $_fileName, method: getPerubahan',
        );
      } else {
        Log.info(
          'Tidak ada perubahan paket ditemukan sejak ${since.toIso8601String()} - file: $_fileName, method: getPerubahan',
        );
      }
      return List.generate(maps.length, (i) => PaketModel.fromSqlite(maps[i]));
    } catch (e, s) {
      Log.error(
        'Gagal mengambil perubahan paket - file: $_fileName, method: getPerubahan, error: $e',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  // Diubah: Menggunakan OperasiDasar.sisipkanAtauPerbaruiBatch
  Future<void> sisipkanAtauPerbaruiBatch(List<PaketModel> items) async {
    Log.info(
      'Mendelegasikan proses batch ke OperasiDasar untuk ${items.length} item paket - file: $_fileName, method: sisipkanAtauPerbaruiBatch',
    );
    try {
      final dataList = items.map((item) => item.toSqlite()).toList();
      await _operasiDasar.sisipkanAtauPerbaruiBatch('paket', dataList);
      Log.info(
        'Berhasil mendelegasikan proses batch untuk ${items.length} item - file: $_fileName, method: sisipkanAtauPerbaruiBatch',
      );
    } catch (e, s) {
      Log.error(
        'Gagal mendelegasikan proses batch - file: $_fileName, method: sisipkanAtauPerbaruiBatch, error: $e',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<List<PaketModel>> getPaketByIds(List<String> ids) async {
    Log.info(
      'Memulai pengambilan paket berdasarkan list ID - file: $_fileName, method: getPaketByIds, ids: $ids',
    );
    try {
      if (ids.isEmpty) {
        Log.warning(
          'List ID kosong, mengembalikan list kosong - file: $_fileName, method: getPaketByIds',
        );
        return [];
      }
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info(
        'Berhasil mengambil ${maps.length} paket dari ${ids.length} ID yang diminta - file: $_fileName, method: getPaketByIds',
      );
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error(
        'Gagal mengambil paket berdasarkan list ID - file: $_fileName, method: getPaketByIds, error: $e',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}
