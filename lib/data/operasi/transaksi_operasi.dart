// path: lib/data/operasi/transaksi_operasi.dart
// diubah: Menyesuaikan pemanggilan metode model menjadi fromSqlite dan toSqlite.
// diubah: Mengganti logika update saldo bertahap dengan metode hitung ulang (SUM) untuk menjamin akurasi data.
import 'dart:developer' as developer;

import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:sqflite/sqflite.dart';

import 'package:admin_wifi/model/transaksi_model.dart'; // diubah: path absolut
import 'package:admin_wifi/data/sqlite.dart'; // diubah: path absolut

class TransaksiOperasi {
  static DatabaseHelper _dbHelper = DatabaseHelper.instance;

  TransaksiOperasi();

  static void testSetInstance(DatabaseHelper dbHelper) {
    _dbHelper = dbHelper;
  }

  Future<Database> get _db async => await _dbHelper.database;

  // ===================================================================
  // -- OPERASI DASAR CRUD (Create, Read, Update, Delete) --
  // ===================================================================
  // diubah: Logika perhitungan saldo diperbarui total untuk mendukung arsitektur baru.
  Future<void> _recalculateAndUpdateDompetSaldo(
    String idDompet,
    DatabaseExecutor txn,
  ) async {
    // Query ini adalah inti dari sistem saldo yang baru dan kuat.
    // Query ini menangani semua kasus: pemasukan, pengeluaran, dan transfer (baik sebagai sumber maupun tujuan).
    final totalResult = await txn.rawQuery(
      '''
      SELECT
        COALESCE(SUM(
          CASE
            -- pemasukan menambah saldo
            WHEN tipe = 'pemasukan'
              AND id_dompet = ?
            THEN jumlah

            -- pengeluaran mengurangi saldo
            WHEN tipe = 'pengeluaran'
              AND id_dompet = ?
            THEN -jumlah

            -- transfer dari dompet asal mengurangi saldo
            WHEN tipe = 'transfer'
              AND id_dompet = ?
            THEN -jumlah

            -- transfer ke dompet tujuan menambah saldo
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

    // Casting ke double untuk mendukung nilai desimal di masa depan.
    final totalSaldo = (totalResult.first['total'] as num?)?.toDouble() ?? 0.0;

    await txn.update(
      'dompet',
      {'saldo': totalSaldo},
      where: 'id = ?',
      whereArgs: [idDompet],
    );
  }

  Future<int> tambahTransaksi(TransaksiModel transaksi) async {
    final db = await _db;
    int id = 0;
    try {
      await db.transaction((txn) async {
        final data = transaksi.copyWith(diperbarui: DateTime.now());

        id = await txn.insert(
          'transaksi',
          data.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // diubah: Panggil fungsi hitung ulang untuk dompet yang terpengaruh.
        await _recalculateAndUpdateDompetSaldo(data.idDompet, txn);
        if (data.tipe ==
                TipeTransaksi
                    .transfer && // Use .name for enums in string comparison
            data.idDompetTujuan != null) {
          await _recalculateAndUpdateDompetSaldo(data.idDompetTujuan!, txn);
        }
      });
      developer.log(
        'Transaksi berhasil disimpan, saldo dompet dihitung ulang.',
        name: 'TransaksiOperasi.simpan',
      );
      return id;
    } catch (e) {
      developer.log(
        'Error saat menyimpan transaksi di SQLite: $e',
        name: 'TransaksiOperasi.simpan',
        error: e,
      );
      rethrow;
    }
  }

  Future<List<TransaksiModel>> ambilSemuaTransaksi() async {
    final db = await _dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'isDeleted = ?',
        whereArgs: [0],
        orderBy: 'tanggal DESC',
      );
      developer.log(
        'Mengambil semua transaksi dari SQLite',
        name: 'TransaksiOperasi.semua',
      );
      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log(
        'Error saat mengambil semua transaksi dari SQLite: $e',
        name: 'TransaksiOperasi.semua',
        error: e,
      );
      return [];
    }
  }

  Future<TransaksiModel?> getTransaksiById(String id) async {
    final db = await _db;

    final List<Map<String, dynamic>> maps = await db.query(
      'transaksi',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return TransaksiModel.fromSqlite(maps.first);
  }

  Future<List<TransaksiModel>> ambilTransaksiByPelangganId(
    String pelangganId,
  ) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaksi',
      where: 'id_pelanggan = ? AND isDeleted = ?',
      whereArgs: [pelangganId, 0],
      orderBy: 'tanggal DESC',
    );
    return List.generate(maps.length, (i) {
      return TransaksiModel.fromSqlite(maps[i]);
    });
  }

  // diubah: Query diperbaiki untuk menyertakan transaksi di mana dompet adalah tujuan (transfer masuk).
  Future<List<TransaksiModel>> ambilTransaksiByDompetId(String dompetId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaksi',
      where: '(id_dompet = ? OR id_dompet_tujuan = ?) AND isDeleted = ?',
      whereArgs: [dompetId, dompetId, 0],
      orderBy: 'tanggal DESC',
    );
    developer.log(
      'Mengambil transaksi untuk dompet $dompetId: $maps',
      name: 'TransaksiOperasi',
    );

    return List.generate(maps.length, (i) {
      return TransaksiModel.fromSqlite(maps[i]);
    });
  }

  // Future<List<TransaksiModel>> getTransaksiByPelanggan(
  //   String pelangganId,
  // ) async {
  //   final db = await _db;
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     'transaksi',
  //     where: 'id_pelanggan = ? AND isDeleted = ?',
  //     whereArgs: [pelangganId, 0],
  //     orderBy: 'tanggal DESC',
  //   );
  //   developer.log(
  //     'ambil semua transaksi berdasarkan idpelanggan : $maps',
  //     name: 'TransaksiOperasi',
  //   );
  //   return List.generate(maps.length, (i) {
  //     return TransaksiModel.fromSqlite(maps[i]);
  //   });
  // }
  // // file: lib/data/operasi/transaksi_operasi.dart

  // // ... (baris 191)
  // // diubah: untuk mengambil transaksi di mana aktivasiPaket adalah 1.
  Future<List<TransaksiModel>> getTransaksiByAktivasiPaket() async {
    final db = await _db;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'aktivasi_paket = ? AND isDeleted = ?',
        whereArgs: [1, 0], // diubah: untuk mencari nilai 1 secara eksplisit.
        orderBy: 'tanggal DESC',
      );
      developer.log(
        'Mengambil transaksi dengan aktivasi_paket = 1 dari SQLite', // diubah: pesan log disesuaikan.
        name:
            'TransaksiOperasi.getTransaksiByAktivasiPaket', // diubah: nama log disesuaikan.
      );
      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } catch (e) {
      developer.log(
        'Error saat mengambil transaksi dengan aktivasi_paket = 1: $e', // diubah: pesan log disesuaikan.
        name:
            'TransaksiOperasi.getTransaksiByAktivasiPaket', // diubah: nama log disesuaikan.
        error: e,
      );
      return [];
    }
  }

  // diubah: Perhitungan ulang ganda dihapus untuk efisiensi.
  Future<void> updateTransaksi(String id, TransaksiModel transaksiBaru) async {
    final db = await _dbHelper.database;

    try {
      await db.transaction((txn) async {
        final maps = await txn.query(
          'transaksi',
          where: 'id = ?',
          whereArgs: [id],
        );

        if (maps.isNotEmpty) {
          final transaksiLama = TransaksiModel.fromSqlite(maps.first);
          final dataUpdate = transaksiBaru.copyWith(diperbarui: DateTime.now());

          // 1. Update data transaksi itu sendiri
          await txn.update(
            'transaksi',
            dataUpdate.toSqlite(),
            where: 'id = ?',
            whereArgs: [id],
          );

          // 2. Kumpulkan semua dompet yang terpengaruh (lama dan baru) dan hitung ulang saldonya sekali saja.
          final affectedWallets = <String>{};
          affectedWallets.add(transaksiLama.idDompet);
          affectedWallets.add(dataUpdate.idDompet);
          if (transaksiLama.idDompetTujuan != null) {
            affectedWallets.add(transaksiLama.idDompetTujuan!);
          }
          if (dataUpdate.idDompetTujuan != null) {
            affectedWallets.add(dataUpdate.idDompetTujuan!);
          }

          for (final dompetId in affectedWallets) {
            await _recalculateAndUpdateDompetSaldo(dompetId, txn);
          }
        }
      });
      developer.log(
        'Transaksi berhasil diperbarui, saldo dompet dihitung ulang.',
        name: 'TransaksiOperasi.update',
      );
    } catch (e) {
      developer.log(
        'Error saat memperbarui transaksi di SQLite: $e',
        name: 'TransaksiOperasi.update',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> arsipkanTransaksi(String id) async {
    final db = await _db;
    try {
      await db.transaction((txn) async {
        final maps = await txn.query(
          'transaksi',
          where: 'id = ?',
          whereArgs: [id],
        );

        if (maps.isNotEmpty) {
          final transaksiLama = TransaksiModel.fromSqlite(maps.first);

          // 1. Hapus transaksi (soft delete)
          await txn.update(
            'transaksi',
            {'isDeleted': 1, 'diperbarui': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [id],
          );

          // 2. Hitung ulang saldo dompet yang terpengaruh.
          await _recalculateAndUpdateDompetSaldo(transaksiLama.idDompet, txn);
          if (transaksiLama.tipe ==
                  TipeTransaksi
                      .transfer && // Use .name for enums in string comparison
              transaksiLama.idDompetTujuan != null) {
            await _recalculateAndUpdateDompetSaldo(
              transaksiLama.idDompetTujuan!,
              txn,
            );
          }
        }
      });
      developer.log(
        'Transaksi berhasil dihapus, saldo dompet dihitung ulang.',
        name: 'TransaksiOperasi.hapus',
      );
    } catch (e) {
      developer.log(
        'Error saat menghapus transaksi di SQLite: $e',
        name: 'TransaksiOperasi.hapus',
        error: e,
      );
      rethrow;
    }
  }

  Future<double> getTotalPemasukan() async {
    final db = await _db;
    final result = await db.rawQuery(
      "SELECT SUM(jumlah) as jumlah FROM transaksi WHERE tipe = 'pemasukan' AND isDeleted = 0",
    );
    if (result.isNotEmpty && result.first['jumlah'] != null) {
      return (result.first['jumlah'] as num).toDouble();
    }
    return 0.0;
  }

  // diubah: Komentar yang salah telah dihapus. Fungsi ini mengembalikan nilai positif.
  Future<double> getTotalPengeluaran() async {
    final db = await _db;
    final result = await db.rawQuery(
      "SELECT SUM(jumlah) as jumlah FROM transaksi WHERE tipe = 'pengeluaran' AND isDeleted = 0",
    );
    if (result.isNotEmpty && result.first['jumlah'] != null) {
      return (result.first['jumlah'] as num).toDouble();
    }
    return 0.0;
  }

  Future<double> getNetTotal() async {
    final pemasukan = await getTotalPemasukan();
    final pengeluaran = await getTotalPengeluaran();
    return pemasukan - pengeluaran;
  }

  Future<int> getPoinYangDihasilkan(String idPelanggan) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(poin_yang_dihasilkan) as total FROM transaksi WHERE id_pelanggan = ? AND isDeleted = 0',
      [idPelanggan],
    );
    final total = result.first['total'];
    if (total is int) {
      return total;
    }
    return 0;
  }

  Future<int> getPoinYangDigunakan(String idPelanggan) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(poin_yang_digunakan) as total FROM transaksi WHERE id_pelanggan = ? AND isDeleted = 0',
      [idPelanggan],
    );
    final total = result.first['total'];
    if (total is int) {
      return total;
    }
    return 0;
  }

  Future<int> getTotalPoin(String idPelanggan) async {
    final poinDihasilkan = await getPoinYangDihasilkan(idPelanggan);
    final poinDigunakan = await getPoinYangDigunakan(idPelanggan);
    return poinDihasilkan - poinDigunakan;
  }

  // diubah: Logika batch disederhanakan dan dibuat lebih aman.
  Future<void> sisipkanAtauPerbaruiBatch(List<TransaksiModel> items) async {
    final db = await _db;
    Set<String> affectedWallets = {};

    await db.transaction((txn) async {
      final batch = txn.batch();
      for (var item in items) {
        batch.insert(
          'transaksi',
          item.copyWith(diperbarui: DateTime.now()).toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Kumpulkan semua ID dompet yang terpengaruh
        affectedWallets.add(item.idDompet);
        if (item.idDompetTujuan != null) {
          affectedWallets.add(item.idDompetTujuan!);
        }
      }
      await batch.commit(noResult: true);

      // Setelah semua transaksi di-commit, hitung ulang saldo untuk setiap dompet yang terpengaruh.
      for (String dompetId in affectedWallets) {
        await _recalculateAndUpdateDompetSaldo(dompetId, txn);
      }
    });
  }

  Future<List<TransaksiModel>> getTransaksiByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final db = await _db;
    final placeholders = List.filled(ids.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      'transaksi',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return List.generate(maps.length, (i) {
      return TransaksiModel.fromSqlite(maps[i]);
    });
  }
}
