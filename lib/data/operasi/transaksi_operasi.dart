// path: lib/data/operasi/transaksi_operasi.dart
// diubah: Fungsi ambilSemuaTransaksi sekarang hanya mengambil data yang tidak dihapus (isDeleted = 0).
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:sqflite/sqflite.dart';

class TransaksiOperasi {
  // diubah: dbHelper sekarang tidak final agar bisa diganti untuk testing.
  static DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Constructor standar yang digunakan oleh aplikasi.
  TransaksiOperasi();

  // ditambah: metode untuk mengganti instance dbHelper untuk testing.
  static void testSetInstance(DatabaseHelper dbHelper) {
    _dbHelper = dbHelper;
  }

  // diubah: getter ini memastikan kode lain tetap bisa mengakses database dengan cara yang sama.
  Future<Database> get _db async => await _dbHelper.database;

  // ===================================================================
  // -- OPERASI DASAR CRUD (Create, Read, Update, Delete) --
  // ===================================================================

  Future<void> tambahTransaksi(TransaksiModel transaksi) async {
    final db = await _db;
    await db.transaction((txn) async {
      final dataBaru = transaksi.copyWith(diperbarui: DateTime.now());
      await txn.insert(
        'transaksi',
        dataBaru.toMapForSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (transaksi.tipe == TipeTransaksi.pemasukan) {
        await txn.rawUpdate(
          'UPDATE dompet SET saldo = saldo + ? WHERE id = ?',
          [transaksi.jumlah, transaksi.idDompet],
        );
      } else if (transaksi.tipe == TipeTransaksi.pengeluaran) {
        await txn.rawUpdate(
          'UPDATE dompet SET saldo = saldo - ? WHERE id = ?',
          [transaksi.jumlah, transaksi.idDompet],
        );
      } else if (transaksi.tipe == TipeTransaksi.transfer) {
        await txn.rawUpdate(
          'UPDATE dompet SET saldo = saldo - ? WHERE id = ?',
          [transaksi.jumlah, transaksi.idDompet],
        );
        if (transaksi.idDompetTujuan != null) {
          await txn.rawUpdate(
            'UPDATE dompet SET saldo = saldo + ? WHERE id = ?',
            [transaksi.jumlah, transaksi.idDompetTujuan],
          );
        }
      }
    });
  }

  Future<List<TransaksiModel>> ambilSemuaTransaksi() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaksi',
      where: 'isDeleted = ?', // Hanya ambil data yang belum dihapus
      whereArgs: [0],
      orderBy: 'tanggal DESC',
    );
    return List.generate(maps.length, (i) {
      return TransaksiModel.fromMap(maps[i]);
    });
  }

  // ditambahkan: Fungsi untuk mengambil transaksi berdasarkan ID dompet.
  Future<List<TransaksiModel>> ambilTransaksiByDompetId(String dompetId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaksi',
      where: 'id_dompet = ? AND isDeleted = ?',
      whereArgs: [dompetId, 0],
      orderBy: 'tanggal DESC',
    );
    return List.generate(maps.length, (i) {
      return TransaksiModel.fromMap(maps[i]);
    });
  }

  Future<void> updateTransaksi(TransaksiModel transaksiBaru) async {
    final db = await _db;

    await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query(
        'transaksi',
        where: 'id = ?',
        whereArgs: [transaksiBaru.id],
      );

      if (maps.isNotEmpty) {
        final transaksiLama = TransaksiModel.fromMap(maps.first);

        if (transaksiLama.tipe == TipeTransaksi.pemasukan) {
          await txn.rawUpdate(
            'UPDATE dompet SET saldo = saldo - ? WHERE id = ?',
            [transaksiLama.jumlah, transaksiLama.idDompet],
          );
        } else if (transaksiLama.tipe == TipeTransaksi.pengeluaran) {
          await txn.rawUpdate(
            'UPDATE dompet SET saldo = saldo + ? WHERE id = ?',
            [transaksiLama.jumlah, transaksiLama.idDompet],
          );
        } else if (transaksiLama.tipe == TipeTransaksi.transfer) {
          await txn.rawUpdate(
            'UPDATE dompet SET saldo = saldo + ? WHERE id = ?',
            [transaksiLama.jumlah, transaksiLama.idDompet],
          );
          if (transaksiLama.idDompetTujuan != null) {
            await txn.rawUpdate(
              'UPDATE dompet SET saldo = saldo - ? WHERE id = ?',
              [transaksiLama.jumlah, transaksiLama.idDompetTujuan],
            );
          }
        }

        final dataUpdate = transaksiBaru.copyWith(diperbarui: DateTime.now());
        if (dataUpdate.tipe == TipeTransaksi.pemasukan) {
          await txn.rawUpdate(
            'UPDATE dompet SET saldo = saldo + ? WHERE id = ?',
            [dataUpdate.jumlah, dataUpdate.idDompet],
          );
        } else if (dataUpdate.tipe == TipeTransaksi.pengeluaran) {
          await txn.rawUpdate(
            'UPDATE dompet SET saldo = saldo - ? WHERE id = ?',
            [dataUpdate.jumlah, dataUpdate.idDompet],
          );
        } else if (dataUpdate.tipe == TipeTransaksi.transfer) {
          await txn.rawUpdate(
            'UPDATE dompet SET saldo = saldo - ? WHERE id = ?',
            [dataUpdate.jumlah, dataUpdate.idDompet],
          );
          if (dataUpdate.idDompetTujuan != null) {
            await txn.rawUpdate(
              'UPDATE dompet SET saldo = saldo + ? WHERE id = ?',
              [dataUpdate.jumlah, dataUpdate.idDompetTujuan],
            );
          }
        }

        await txn.update(
          'transaksi',
          dataUpdate.toMapForSqlite(),
          where: 'id = ?',
          whereArgs: [dataUpdate.id],
        );
      }
    });
  }

  Future<void> arsipkanTransaksi(String id) async {
    final db = await _db;

    await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query(
        'transaksi',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final transaksi = TransaksiModel.fromMap(maps.first);

        if (transaksi.tipe == TipeTransaksi.pemasukan) {
          await txn.rawUpdate(
            'UPDATE dompet SET saldo = saldo - ? WHERE id = ?',
            [transaksi.jumlah, transaksi.idDompet],
          );
        } else if (transaksi.tipe == TipeTransaksi.pengeluaran) {
          await txn.rawUpdate(
            'UPDATE dompet SET saldo = saldo + ? WHERE id = ?',
            [transaksi.jumlah, transaksi.idDompet],
          );
        } else if (transaksi.tipe == TipeTransaksi.transfer) {
          await txn.rawUpdate(
            'UPDATE dompet SET saldo = saldo + ? WHERE id = ?',
            [transaksi.jumlah, transaksi.idDompet],
          );
          if (transaksi.idDompetTujuan != null) {
            await txn.rawUpdate(
              'UPDATE dompet SET saldo = saldo - ? WHERE id = ?',
              [transaksi.jumlah, transaksi.idDompetTujuan],
            );
          }
        }

        await txn.update(
          'transaksi',
          {'isDeleted': 1, 'diarsipkan': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
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

  Future<void> sisipkanAtauPerbaruiBatch(List<TransaksiModel> items) async {
    final db = await _db;
    final batch = db.batch();
    for (var item in items) {
      batch.insert(
        'transaksi',
        item.copyWith(diperbarui: DateTime.now()).toMapForSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (item.tipe == TipeTransaksi.pemasukan) {
        batch.rawUpdate('UPDATE dompet SET saldo = saldo + ? WHERE id = ?', [
          item.jumlah,
          item.idDompet,
        ]);
      } else if (item.tipe == TipeTransaksi.pengeluaran) {
        batch.rawUpdate('UPDATE dompet SET saldo = saldo - ? WHERE id = ?', [
          item.jumlah,
          item.idDompet,
        ]);
      } else if (item.tipe == TipeTransaksi.transfer) {
        batch.rawUpdate('UPDATE dompet SET saldo = saldo - ? WHERE id = ?', [
          item.jumlah,
          item.idDompet,
        ]);
        if (item.idDompetTujuan != null) {
          batch.rawUpdate('UPDATE dompet SET saldo = saldo + ? WHERE id = ?', [
            item.jumlah,
            item.idDompetTujuan,
          ]);
        }
      }
    }
    await batch.commit(noResult: true);
  }
}
