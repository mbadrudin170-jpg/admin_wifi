// path: lib/data/operasi/transaksi_operasi.dart
import 'dart:developer' as developer;

import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:sqflite/sqflite.dart';

import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/data/sqlite.dart';

class TransaksiOperasi {
  static DatabaseHelper _dbHelper = DatabaseHelper.instance;

  TransaksiOperasi();

  static void testSetInstance(DatabaseHelper dbHelper) {
    _dbHelper = dbHelper;
    developer.log(
      'DatabaseHelper instance manual ditetapkan untuk testing',
      name: 'TransaksiOperasi.testSetInstance',
    );
  }

  Future<Database> get _db async => await _dbHelper.database;

  // ===================================================================
  // -- OPERASI DASAR CRUD (Create, Read, Update, Delete) --
  // ===================================================================

  Future<void> _recalculateAndUpdateDompetSaldo(
    String idDompet,
    DatabaseExecutor txn,
  ) async {
    try {
      developer.log(
        'Memulai hitung ulang saldo untuk Dompet ID: $idDompet',
        name: 'TransaksiOperasi.recalculate',
      );

      final totalResult = await txn.rawQuery(
        '''
        SELECT
          COALESCE(SUM(
            CASE
              WHEN tipe = 'pemasukan'
                AND id_dompet = ?
              THEN jumlah

              WHEN tipe = 'pengeluaran'
                AND id_dompet = ?
              THEN -jumlah

              WHEN tipe = 'transfer'
                AND id_dompet = ?
              THEN -jumlah

              WHEN tipe = 'transfer'
                AND id_dompet_tujuan = ?
              THEN jumlah

              ELSE 0
            END
          ), 0) as total
        FROM transaksi
        WHERE isDeleted = 0 AND (id_dompet = ? OR id_dompet_tujuan = ?)
        ''',
        [idDompet, idDompet, idDompet, idDompet, idDompet, idDompet],
      );

      final totalSaldo =
          (totalResult.first['total'] as num?)?.toDouble() ?? 0.0;

      await txn.update(
        'dompet',
        {'saldo': totalSaldo},
        where: 'id = ?',
        whereArgs: [idDompet],
      );

      developer.log(
        'Berhasil update saldo Dompet ID: $idDompet menjadi $totalSaldo',
        name: 'TransaksiOperasi.recalculate',
      );
    } catch (e) {
      developer.log(
        'Gagal hitung ulang saldo Dompet ID: $idDompet. Error: $e',
        name: 'TransaksiOperasi.recalculate',
        error: e,
      );
      rethrow;
    }
  }

  Future<int> tambahTransaksi(TransaksiModel transaksi) async {
    final db = await _db;
    int id = 0;
    try {
      await db.transaction((txn) async {
        developer.log(
          'Memulai transaksi database untuk tambahTransaksi',
          name: 'TransaksiOperasi.tambahTransaksi',
        );
        final data = transaksi.copyWith(diperbarui: DateTime.now());

        id = await txn.insert(
          'transaksi',
          data.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        developer.log(
          'Data transaksi berhasil masuk ke tabel dengan row ID: $id',
          name: 'TransaksiOperasi.tambahTransaksi',
        );

        await _recalculateAndUpdateDompetSaldo(data.idDompet, txn);
        if (data.tipe == TipeTransaksi.transfer &&
            data.idDompetTujuan != null) {
          developer.log(
            'Deteksi transaksi transfer, menghitung saldo dompet tujuan: ${data.idDompetTujuan}',
            name: 'TransaksiOperasi.tambahTransaksi',
          );
          await _recalculateAndUpdateDompetSaldo(data.idDompetTujuan!, txn);
        }
      });
      developer.log(
        'Seluruh proses tambah transaksi ID: ${transaksi.id} berhasil diselesaikan.',
        name: 'TransaksiOperasi.tambahTransaksi',
      );
      return id;
    } catch (e) {
      developer.log(
        'Gagal menambah transaksi ID: ${transaksi.id}. Error: $e',
        name: 'TransaksiOperasi.tambahTransaksi',
        error: e,
      );
      rethrow;
    }
  }

  Future<List<TransaksiModel>> ambilSemuaTransaksi() async {
    final db = await _dbHelper.database;
    try {
      developer.log(
        'Mengambil data semua transaksi (isDeleted = 0)',
        name: 'TransaksiOperasi.ambilSemuaTransaksi',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'isDeleted = ?',
        whereArgs: [0],
        orderBy: 'tanggal DESC',
      );

      developer.log(
        'Berhasil mengambil ${maps.length} data transaksi dari SQLite',
        name: 'TransaksiOperasi.ambilSemuaTransaksi',
      );
      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log(
        'Gagal mengambil semua transaksi. Error: $e',
        name: 'TransaksiOperasi.ambilSemuaTransaksi',
        error: e,
      );
      return [];
    }
  }

  Future<TransaksiModel?> getTransaksiById(String id) async {
    final db = await _db;
    try {
      developer.log(
        'Mencari transaksi berdasarkan ID: $id',
        name: 'TransaksiOperasi.getTransaksiById',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        developer.log(
          'Transaksi dengan ID: $id tidak ditemukan',
          name: 'TransaksiOperasi.getTransaksiById',
        );
        return null;
      }

      developer.log(
        'Transaksi ID: $id ditemukan.',
        name: 'TransaksiOperasi.getTransaksiById',
      );
      return TransaksiModel.fromSqlite(maps.first);
    } catch (e) {
      developer.log(
        'Gagal mengambil transaksi ID: $id. Error: $e',
        name: 'TransaksiOperasi.getTransaksiById',
        error: e,
      );
      return null;
    }
  }

  Future<List<TransaksiModel>> ambilTransaksiByPelangganId(
    String pelangganId,
  ) async {
    final db = await _db;
    try {
      developer.log(
        'Mengambil transaksi untuk Pelanggan ID: $pelangganId',
        name: 'TransaksiOperasi.ambilTransaksiByPelangganId',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'id_pelanggan = ? AND isDeleted = ?',
        whereArgs: [pelangganId, 0],
        orderBy: 'tanggal DESC',
      );
      developer.log(
        'Ditemukan ${maps.length} transaksi untuk Pelanggan ID: $pelangganId',
        name: 'TransaksiOperasi.ambilTransaksiByPelangganId',
      );
      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log(
        'Error ambil transaksi pelanggan: $e',
        name: 'TransaksiOperasi.ambilTransaksiByPelangganId',
        error: e,
      );
      return [];
    }
  }

  Future<List<TransaksiModel>> ambilTransaksiByDompetId(String dompetId) async {
    final db = await _db;
    try {
      developer.log(
        'Mengambil transaksi terkait Dompet ID: $dompetId (asal/tujuan)',
        name: 'TransaksiOperasi.ambilTransaksiByDompetId',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: '(id_dompet = ? OR id_dompet_tujuan = ?) AND isDeleted = ?',
        whereArgs: [dompetId, dompetId, 0],
        orderBy: 'tanggal DESC',
      );
      developer.log(
        'Ditemukan ${maps.length} transaksi untuk Dompet ID: $dompetId',
        name: 'TransaksiOperasi.ambilTransaksiByDompetId',
      );

      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log(
        'Error ambil transaksi dompet: $e',
        name: 'TransaksiOperasi.ambilTransaksiByDompetId',
        error: e,
      );
      return [];
    }
  }

  Future<List<TransaksiModel>> getTransaksiByAktivasiPaket() async {
    final db = await _db;
    try {
      developer.log(
        'Mengambil transaksi dengan status aktivasi_paket = 1',
        name: 'TransaksiOperasi.getTransaksiByAktivasiPaket',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'aktivasi_paket = ? AND isDeleted = ?',
        whereArgs: [1, 0],
        orderBy: 'tanggal DESC',
      );
      developer.log(
        'Berhasil mengambil ${maps.length} transaksi aktivasi paket.',
        name: 'TransaksiOperasi.getTransaksiByAktivasiPaket',
      );
      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log(
        'Error saat mengambil transaksi aktivasi_paket: $e',
        name: 'TransaksiOperasi.getTransaksiByAktivasiPaket',
        error: e,
      );
      return [];
    }
  }

  Future<void> updateTransaksi(String id, TransaksiModel transaksiBaru) async {
    final db = await _dbHelper.database;
    try {
      await db.transaction((txn) async {
        developer.log(
          'Memulai update transaksi database ID: $id',
          name: 'TransaksiOperasi.updateTransaksi',
        );
        final maps = await txn.query(
          'transaksi',
          where: 'id = ?',
          whereArgs: [id],
        );

        if (maps.isNotEmpty) {
          final transaksiLama = TransaksiModel.fromSqlite(maps.first);
          final dataUpdate = transaksiBaru.copyWith(diperbarui: DateTime.now());

          await txn.update(
            'transaksi',
            dataUpdate.toSqlite(),
            where: 'id = ?',
            whereArgs: [id],
          );
          developer.log(
            'Data transaksi ID: $id diperbarui di tabel transaksi',
            name: 'TransaksiOperasi.updateTransaksi',
          );

          final affectedWallets = <String>{};
          affectedWallets.add(transaksiLama.idDompet);
          affectedWallets.add(dataUpdate.idDompet);
          if (transaksiLama.idDompetTujuan != null) {
            affectedWallets.add(transaksiLama.idDompetTujuan!);
          }

          if (dataUpdate.idDompetTujuan != null) {
            affectedWallets.add(dataUpdate.idDompetTujuan!);
          }

          developer.log(
            'Mengupdate saldo untuk dompet yang terpengaruh: $affectedWallets',
            name: 'TransaksiOperasi.updateTransaksi',
          );
          for (final dompetId in affectedWallets) {
            await _recalculateAndUpdateDompetSaldo(dompetId, txn);
          }
        } else {
          developer.log(
            'Update gagal: Transaksi ID $id tidak ditemukan di DB.',
            name: 'TransaksiOperasi.updateTransaksi',
          );
        }
      });
      developer.log(
        'Proses updateTransaksi ID: $id selesai.',
        name: 'TransaksiOperasi.updateTransaksi',
      );
    } catch (e) {
      developer.log(
        'Gagal update transaksi ID: $id. Error: $e',
        name: 'TransaksiOperasi.updateTransaksi',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> arsipkanTransaksi(String id) async {
    final db = await _db;
    try {
      await db.transaction((txn) async {
        developer.log(
          'Memulai proses pengarsipan (Soft Delete) ID: $id',
          name: 'TransaksiOperasi.arsipkanTransaksi',
        );
        final maps = await txn.query(
          'transaksi',
          where: 'id = ?',
          whereArgs: [id],
        );

        if (maps.isNotEmpty) {
          final transaksiLama = TransaksiModel.fromSqlite(maps.first);

          await txn.update(
            'transaksi',
            {'isDeleted': 1, 'diperbarui': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [id],
          );
          developer.log(
            'Flag isDeleted diatur ke 1 untuk ID: $id',
            name: 'TransaksiOperasi.arsipkanTransaksi',
          );

          await _recalculateAndUpdateDompetSaldo(transaksiLama.idDompet, txn);
          if (transaksiLama.tipe == TipeTransaksi.transfer &&
              transaksiLama.idDompetTujuan != null) {
            await _recalculateAndUpdateDompetSaldo(
              transaksiLama.idDompetTujuan!,
              txn,
            );
          }
        } else {
          developer.log(
            'Arsip gagal: Transaksi ID $id tidak ditemukan.',
            name: 'TransaksiOperasi.arsipkanTransaksi',
          );
        }
      });
      developer.log(
        'Transaksi ID: $id berhasil diarsipkan.',
        name: 'TransaksiOperasi.arsipkanTransaksi',
      );
    } catch (e) {
      developer.log(
        'Gagal mengarsipkan transaksi ID: $id. Error: $e',
        name: 'TransaksiOperasi.arsipkanTransaksi',
        error: e,
      );
      rethrow;
    }
  }

  Future<double> getTotalPemasukan() async {
    final db = await _db;
    try {
      developer.log(
        'Menghitung total seluruh pemasukan',
        name: 'TransaksiOperasi.getTotalPemasukan',
      );
      final result = await db.rawQuery(
        "SELECT SUM(jumlah) as jumlah FROM transaksi WHERE tipe = 'pemasukan' AND isDeleted = 0",
      );
      double total = 0.0;
      if (result.isNotEmpty && result.first['jumlah'] != null) {
        total = (result.first['jumlah'] as num).toDouble();
      }
      developer.log(
        'Total pemasukan: $total',
        name: 'TransaksiOperasi.getTotalPemasukan',
      );
      return total;
    } catch (e) {
      developer.log(
        'Error hitung total pemasukan: $e',
        name: 'TransaksiOperasi.getTotalPemasukan',
        error: e,
      );
      return 0.0;
    }
  }

  Future<double> getTotalPengeluaran() async {
    final db = await _db;
    try {
      developer.log(
        'Menghitung total seluruh pengeluaran',
        name: 'TransaksiOperasi.getTotalPengeluaran',
      );
      final result = await db.rawQuery(
        "SELECT SUM(jumlah) as jumlah FROM transaksi WHERE tipe = 'pengeluaran' AND isDeleted = 0",
      );
      double total = 0.0;
      if (result.isNotEmpty && result.first['jumlah'] != null) {
        total = (result.first['jumlah'] as num).toDouble();
      }
      developer.log(
        'Total pengeluaran: $total',
        name: 'TransaksiOperasi.getTotalPengeluaran',
      );
      return total;
    } catch (e) {
      developer.log(
        'Error hitung total pengeluaran: $e',
        name: 'TransaksiOperasi.getTotalPengeluaran',
        error: e,
      );
      return 0.0;
    }
  }

  Future<double> getNetTotal() async {
    developer.log(
      'Menghitung Net Total (Pemasukan - Pengeluaran)',
      name: 'TransaksiOperasi.getNetTotal',
    );
    final pemasukan = await getTotalPemasukan();
    final pengeluaran = await getTotalPengeluaran();
    final net = pemasukan - pengeluaran;
    developer.log(
      'Hasil Net Total: $net',
      name: 'TransaksiOperasi.getNetTotal',
    );
    return net;
  }

  Future<int> getPoinYangDihasilkan(String idPelanggan) async {
    final db = await _dbHelper.database;
    try {
      developer.log(
        'Menghitung poin yang dihasilkan Pelanggan: $idPelanggan',
        name: 'TransaksiOperasi.getPoinYangDihasilkan',
      );
      final result = await db.rawQuery(
        'SELECT SUM(poin_yang_dihasilkan) as total FROM transaksi WHERE id_pelanggan = ? AND isDeleted = 0',
        [idPelanggan],
      );
      final total = result.first['total'] as int? ?? 0;
      developer.log(
        'Poin dihasilkan: $total',
        name: 'TransaksiOperasi.getPoinYangDihasilkan',
      );
      return total;
    } catch (e) {
      developer.log(
        'Error hitung poin dihasilkan: $e',
        name: 'TransaksiOperasi.getPoinYangDihasilkan',
        error: e,
      );
      return 0;
    }
  }

  Future<int> getPoinYangDigunakan(String idPelanggan) async {
    final db = await _dbHelper.database;
    try {
      developer.log(
        'Menghitung poin yang digunakan Pelanggan: $idPelanggan',
        name: 'TransaksiOperasi.getPoinYangDigunakan',
      );
      final result = await db.rawQuery(
        'SELECT SUM(poin_yang_digunakan) as total FROM transaksi WHERE id_pelanggan = ? AND isDeleted = 0',
        [idPelanggan],
      );
      final total = result.first['total'] as int? ?? 0;
      developer.log(
        'Poin digunakan: $total',
        name: 'TransaksiOperasi.getPoinYangDigunakan',
      );
      return total;
    } catch (e) {
      developer.log(
        'Error hitung poin digunakan: $e',
        name: 'TransaksiOperasi.getPoinYangDigunakan',
        error: e,
      );
      return 0;
    }
  }

  Future<int> getTotalPoin(String idPelanggan) async {
    developer.log(
      'Menghitung saldo poin akhir Pelanggan: $idPelanggan',
      name: 'TransaksiOperasi.getTotalPoin',
    );
    final poinDihasilkan = await getPoinYangDihasilkan(idPelanggan);
    final poinDigunakan = await getPoinYangDigunakan(idPelanggan);
    final total = poinDihasilkan - poinDigunakan;
    developer.log(
      'Saldo poin akhir: $total',
      name: 'TransaksiOperasi.getTotalPoin',
    );
    return total;
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<TransaksiModel> items) async {
    final db = await _db;
    Set<String> affectedWallets = {};

    try {
      await db.transaction((txn) async {
        developer.log(
          'Memulai proses Batch insert/update untuk ${items.length} item',
          name: 'TransaksiOperasi.batch',
        );
        final batch = txn.batch();
        for (var item in items) {
          batch.insert(
            'transaksi',
            item.copyWith(diperbarui: DateTime.now()).toSqlite(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          affectedWallets.add(item.idDompet);
          if (item.idDompetTujuan != null) {
            affectedWallets.add(item.idDompetTujuan!);
          }
        }
        await batch.commit(noResult: true);
        developer.log(
          'Batch commit selesai. Menghitung ulang saldo untuk dompet: $affectedWallets',
          name: 'TransaksiOperasi.batch',
        );

        for (String dompetId in affectedWallets) {
          await _recalculateAndUpdateDompetSaldo(dompetId, txn);
        }
      });
      developer.log(
        'Proses Batch transaksi berhasil sepenuhnya.',
        name: 'TransaksiOperasi.batch',
      );
    } catch (e) {
      developer.log(
        'Gagal menjalankan Batch transaksi. Error: $e',
        name: 'TransaksiOperasi.batch',
        error: e,
      );
      rethrow;
    }
  }

  Future<List<TransaksiModel>> getTransaksiByIds(List<String> ids) async {
    if (ids.isEmpty) {
      developer.log(
        'Pencarian Batch ID dibatalkan karena list ID kosong.',
        name: 'TransaksiOperasi.getTransaksiByIds',
      );
      return [];
    }
    final db = await _db;
    try {
      developer.log(
        'Mengambil transaksi berdasarkan list ID: $ids',
        name: 'TransaksiOperasi.getTransaksiByIds',
      );
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      developer.log(
        'Berhasil mengambil ${maps.length} transaksi dari list ID.',
        name: 'TransaksiOperasi.getTransaksiByIds',
      );
      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log(
        'Error saat ambil transaksi by IDs: $e',
        name: 'TransaksiOperasi.getTransaksiByIds',
        error: e,
      );
      return [];
    }
  }
}
