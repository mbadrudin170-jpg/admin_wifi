// path: lib/data/operasi/transaksi_operasi.dart
import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:sqflite/sqflite.dart';

class TransaksiOperasi {
  static DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();

  TransaksiOperasi();

  static void testSetInstance(DatabaseHelper dbHelper) {
    _dbHelper = dbHelper;
    L.i(
      'DatabaseHelper instance manual ditetapkan untuk testing - method: testSetInstance',
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
      L.i(
        'Memulai hitung ulang saldo untuk Dompet ID: $idDompet - method: _recalculateAndUpdateDompetSaldo',
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
        WHERE is_deleted = 0 AND (id_dompet = ? OR id_dompet_tujuan = ?)
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

      L.i(
        'Berhasil update saldo Dompet ID: $idDompet menjadi $totalSaldo - method: _recalculateAndUpdateDompetSaldo',
      );
    } catch (e, stackTrace) {
      L.e(
        'Gagal hitung ulang saldo Dompet ID: $idDompet. Error: $e - method: _recalculateAndUpdateDompetSaldo Error: $e $stackTrace',
      );
      rethrow;
    }
  }

  Future<int> tambahTransaksi(TransaksiModel transaksi) async {
    try {
      final id = await _operasiDasar.jalankanOperasiKompleks<int>((txn) async {
        L.i(
          'Memulai transaksi database untuk tambahTransaksi - method: tambahTransaksi',
        );
        final data = transaksi.copyWith(diperbarui: DateTime.now());

        final newId = await txn.insert(
          'transaksi',
          data.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        L.i(
          'Data transaksi berhasil masuk ke tabel dengan row ID: $newId - method: tambahTransaksi',
        );

        await _recalculateAndUpdateDompetSaldo(data.idDompet, txn);
        if (data.tipe == TipeTransaksi.transfer &&
            data.idDompetTujuan != null) {
          L.i(
            'Deteksi transaksi transfer, menghitung saldo dompet tujuan: ${data.idDompetTujuan} - method: tambahTransaksi',
          );
          await _recalculateAndUpdateDompetSaldo(data.idDompetTujuan!, txn);
        }
        return newId;
      });
      L.i(
        'Seluruh proses tambah transaksi ID: ${transaksi.id} berhasil diselesaikan - method: tambahTransaksi',
      );
      return id;
    } catch (e, stackTrace) {
      L.e(
        'Gagal menambah transaksi ID: ${transaksi.id}. Error: $e - method: tambahTransaksi Error: $e $stackTrace',
      );
      rethrow;
    }
  }

  Future<List<TransaksiModel>> ambilSemuaTransaksi() async {
    final db = await _dbHelper.database;
    try {
      L.i(
        'Mengambil data semua transaksi (is_deleted = 0) - method: ambilSemuaTransaksi',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'is_deleted = ?',
        whereArgs: [0],
        orderBy: 'tanggal DESC',
      );

      L.i(
        'Berhasil mengambil ${maps.length} data transaksi dari SQLite - method: ambilSemuaTransaksi',
      );
      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } catch (e, stackTrace) {
      L.e(
        'Gagal mengambil semua transaksi. Error: $e - method: ambilSemuaTransaksi Error: $e $stackTrace',
      );
      return [];
    }
  }

  Future<TransaksiModel?> getTransaksiById(String id) async {
    final db = await _db;
    try {
      L.i('Mencari transaksi berdasarkan ID: $id - method: getTransaksiById');
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        L.w(
          'Transaksi dengan ID: $id tidak ditemukan - method: getTransaksiById',
        );
        return null;
      }

      L.i('Transaksi ID: $id ditemukan - method: getTransaksiById');
      return TransaksiModel.fromSqlite(maps.first);
    } catch (e, stackTrace) {
      L.e(
        'Gagal mengambil transaksi ID: $id. Error: $e - method: getTransaksiById Error: $e $stackTrace',
      );
      return null;
    }
  }

  Future<List<TransaksiModel>> ambilTransaksiByPelangganId(
    String pelangganId,
  ) async {
    final db = await _db;
    try {
      L.i(
        'Mengambil transaksi untuk Pelanggan ID: $pelangganId - method: ambilTransaksiByPelangganId',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'id_pelanggan = ? AND is_deleted = ?',
        whereArgs: [pelangganId, 0],
        orderBy: 'tanggal DESC',
      );
      L.i(
        'Ditemukan ${maps.length} transaksi untuk Pelanggan ID: $pelangganId - method: ambilTransaksiByPelangganId',
      );
      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } catch (e, stackTrace) {
      L.e(
        'Error ambil transaksi pelanggan: $e - method: ambilTransaksiByPelangganId Error: $e $stackTrace',
      );
      return [];
    }
  }

  Future<List<TransaksiModel>> ambilTransaksiByDompetId(String dompetId) async {
    final db = await _db;
    try {
      L.i(
        'Mengambil transaksi terkait Dompet ID: $dompetId (asal/tujuan) - method: ambilTransaksiByDompetId',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: '(id_dompet = ? OR id_dompet_tujuan = ?) AND is_deleted = ?',
        whereArgs: [dompetId, dompetId, 0],
        orderBy: 'tanggal DESC',
      );
      L.i(
        'Ditemukan ${maps.length} transaksi untuk Dompet ID: $dompetId - method: ambilTransaksiByDompetId',
      );

      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } catch (e, stackTrace) {
      L.e(
        'Error ambil transaksi dompet: $e - method: ambilTransaksiByDompetId Error: $e $stackTrace',
      );
      return [];
    }
  }

  Future<List<TransaksiModel>> getTransaksiByAktivasiPaket() async {
    final db = await _db;
    try {
      L.i(
        'Mengambil transaksi dengan status aktivasi_paket = 1 - method: getTransaksiByAktivasiPaket',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'aktivasi_paket = ? AND is_deleted = ?',
        whereArgs: [1, 0],
        orderBy: 'tanggal DESC',
      );
      L.i(
        'Berhasil mengambil ${maps.length} transaksi aktivasi paket - method: getTransaksiByAktivasiPaket',
      );
      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } catch (e, stackTrace) {
      L.e(
        'Error saat mengambil transaksi aktivasi_paket: $e - method: getTransaksiByAktivasiPaket Error: $e $stackTrace',
      );
      return [];
    }
  }

  Future<void> updateTransaksi(String id, TransaksiModel transaksiBaru) async {
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        L.i(
          'Memulai update transaksi database ID: $id - method: updateTransaksi',
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
          L.i(
            'Data transaksi ID: $id diperbarui di tabel transaksi - method: updateTransaksi',
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

          L.i(
            'Mengupdate saldo untuk dompet yang terpengaruh: $affectedWallets - method: updateTransaksi',
          );
          for (final dompetId in affectedWallets) {
            await _recalculateAndUpdateDompetSaldo(dompetId, txn);
          }
        } else {
          L.w(
            'Update gagal: Transaksi ID $id tidak ditemukan di DB - method: updateTransaksi',
          );
        }
      });
      L.i('Proses updateTransaksi ID: $id selesai - method: updateTransaksi');
    } catch (e, stackTrace) {
      L.e(
        'Gagal update transaksi ID: $id. Error: $e - method: updateTransaksi Error: $e $stackTrace',
      );
      rethrow;
    }
  }

  Future<void> arsipkanTransaksi(String id) async {
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        L.i(
          'Memulai proses pengarsipan (Soft Delete) ID: $id - method: arsipkanTransaksi',
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
            {'is_deleted': 1, 'diperbarui': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [id],
          );
          L.i(
            'Flag isDeleted diatur ke 1 untuk ID: $id - method: arsipkanTransaksi',
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
          L.w(
            'Arsip gagal: Transaksi ID $id tidak ditemukan - method: arsipkanTransaksi',
          );
        }
      });
      L.i('Transaksi ID: $id berhasil diarsipkan - method: arsipkanTransaksi');
    } catch (e, stackTrace) {
      L.e(
        'Gagal mengarsipkan transaksi ID: $id. Error: $e - method: arsipkanTransaksi Error: $e $stackTrace',
      );
      rethrow;
    }
  }

  Future<double> getTotalPemasukan() async {
    final db = await _db;
    try {
      L.i('Menghitung total seluruh pemasukan - method: getTotalPemasukan');
      final result = await db.rawQuery(
        "SELECT SUM(jumlah) as jumlah FROM transaksi WHERE tipe = 'pemasukan' AND is_deleted = 0",
      );
      double total = 0.0;
      if (result.isNotEmpty && result.first['jumlah'] != null) {
        total = (result.first['jumlah'] as num).toDouble();
      }
      L.i('Total pemasukan: $total - method: getTotalPemasukan');
      return total;
    } catch (e, stackTrace) {
      L.e(
        'Error hitung total pemasukan: $e - method: getTotalPemasukan Error: $e $stackTrace',
      );
      return 0.0;
    }
  }

  Future<double> getTotalPengeluaran() async {
    final db = await _db;
    try {
      L.i('Menghitung total seluruh pengeluaran - method: getTotalPengeluaran');
      final result = await db.rawQuery(
        "SELECT SUM(jumlah) as jumlah FROM transaksi WHERE tipe = 'pengeluaran' AND is_deleted = 0",
      );
      double total = 0.0;
      if (result.isNotEmpty && result.first['jumlah'] != null) {
        total = (result.first['jumlah'] as num).toDouble();
      }
      L.i('Total pengeluaran: $total - method: getTotalPengeluaran');
      return total;
    } catch (e, stackTrace) {
      L.e(
        'Error hitung total pengeluaran: $e - method: getTotalPengeluaran Error: $e $stackTrace',
      );
      return 0.0;
    }
  }

  Future<double> getNetTotal() async {
    L.i('Menghitung Net Total (Pemasukan - Pengeluaran) - method: getNetTotal');
    final pemasukan = await getTotalPemasukan();
    final pengeluaran = await getTotalPengeluaran();
    final net = pemasukan - pengeluaran;
    L.i('Hasil Net Total: $net - method: getNetTotal');
    return net;
  }

  Future<int> getPoinYangDihasilkan(String idPelanggan) async {
    final db = await _dbHelper.database;
    try {
      L.i(
        'Menghitung poin yang dihasilkan Pelanggan: $idPelanggan - method: getPoinYangDihasilkan',
      );
      final result = await db.rawQuery(
        'SELECT SUM(poin_yang_dihasilkan) as total FROM transaksi WHERE id_pelanggan = ? AND is_deleted = 0',
        [idPelanggan],
      );
      final total = result.first['total'] as int? ?? 0;
      L.i('Poin dihasilkan: $total - method: getPoinYangDihasilkan');
      return total;
    } catch (e, stackTrace) {
      L.e(
        'Error hitung poin dihasilkan: $e - method: getPoinYangDihasilkan Error: $e $stackTrace',
      );
      return 0;
    }
  }

  Future<int> getPoinYangDigunakan(String idPelanggan) async {
    final db = await _dbHelper.database;
    try {
      L.i(
        'Menghitung poin yang digunakan Pelanggan: $idPelanggan - method: getPoinYangDigunakan',
      );
      final result = await db.rawQuery(
        'SELECT SUM(poin_yang_digunakan) as total FROM transaksi WHERE id_pelanggan = ? AND is_deleted = 0',
        [idPelanggan],
      );
      final total = result.first['total'] as int? ?? 0;
      L.i('Poin digunakan: $total - method: getPoinYangDigunakan');
      return total;
    } catch (e, stackTrace) {
      L.e(
        'Error hitung poin digunakan: $e - method: getPoinYangDigunakan Error: $e $stackTrace',
      );
      return 0;
    }
  }

  Future<int> getTotalPoin(String idPelanggan) async {
    L.i(
      'Menghitung saldo poin akhir Pelanggan: $idPelanggan - method: getTotalPoin',
    );
    final poinDihasilkan = await getPoinYangDihasilkan(idPelanggan);
    final poinDigunakan = await getPoinYangDigunakan(idPelanggan);
    final total = poinDihasilkan - poinDigunakan;
    L.i('Saldo poin akhir: $total - method: getTotalPoin');
    return total;
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<TransaksiModel> items) async {
    Set<String> affectedWallets = {};

    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        L.i(
          'Memulai proses Batch insert/update untuk ${items.length} item - method: sisipkanAtauPerbaruiBatch',
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
        L.i(
          'Batch commit selesai. Menghitung ulang saldo untuk dompet: $affectedWallets - method: sisipkanAtauPerbaruiBatch',
        );

        for (String dompetId in affectedWallets) {
          await _recalculateAndUpdateDompetSaldo(dompetId, txn);
        }
      });
      L.i(
        'Proses Batch transaksi berhasil sepenuhnya - method: sisipkanAtauPerbaruiBatch',
      );
    } catch (e, stackTrace) {
      L.e(
        'Gagal menjalankan Batch transaksi. Error: $e - method: sisipkanAtauPerbaruiBatch Error: $e $stackTrace',
      );
      rethrow;
    }
  }

  Future<List<TransaksiModel>> getTransaksiByIds(List<String> ids) async {
    if (ids.isEmpty) {
      L.w(
        'Pencarian Batch ID dibatalkan karena list ID kosong - method: getTransaksiByIds',
      );
      return [];
    }
    final db = await _db;
    try {
      L.i(
        'Mengambil transaksi berdasarkan list ID: $ids - method: getTransaksiByIds',
      );
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      L.i(
        'Berhasil mengambil ${maps.length} transaksi dari list ID - method: getTransaksiByIds',
      );
      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } catch (e, stackTrace) {
      L.e(
        'Error saat ambil transaksi by IDs: $e - method: getTransaksiByIds Error: $e $stackTrace',
      );
      return [];
    }
  }
}
