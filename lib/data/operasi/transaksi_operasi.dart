// path: lib/data/operasi/transaksi_operasi.dart
// diubah: Memperbaiki bug di sisipkanAtauPerbaruiBatch yang tidak memperbarui saldo dompet.
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:sqflite/sqflite.dart';

class TransaksiOperasi {
  // diubah: dbHelper sekarang tidak final agar bisa diganti untuk testing.
  DatabaseHelper dbHelper;

  // Constructor standar yang digunakan oleh aplikasi.
  TransaksiOperasi() : dbHelper = DatabaseHelper.instance;

  // ditambah: Constructor khusus untuk testing agar bisa memakai database in-memory.
  TransaksiOperasi.testing(this.dbHelper);

  // diubah: getter ini memastikan kode lain tetap bisa mengakses database dengan cara yang sama.
  Future<Database> get _db async => await dbHelper.database;

  // ===================================================================
  // -- OPERASI DASAR CRUD (Create, Read, Update, Delete) --
  // ===================================================================

  Future<void> tambahTransaksi(TransaksiModel transaksi) async {
    final db = await _db;
    await db.transaction((txn) async {
      final dataBaru = transaksi.salinDengan(diperbarui: DateTime.now());
      await txn.insert(
        'transaksi',
        dataBaru.toMap(),
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

        final dataUpdate = transaksiBaru.salinDengan(
          diperbarui: DateTime.now(),
        );
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
          dataUpdate.toMap(),
          where: 'id = ?',
          whereArgs: [dataUpdate.id],
        );
      }
    });
  }

  Future<void> deleteTransaksi(String id) async {
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

        await txn.delete('transaksi', where: 'id = ?', whereArgs: [id]);
      }
    });
  }

  Future<double> getTotalPemasukan() async {
    final db = await _db;
    final result = await db.rawQuery(
      "SELECT SUM(jumlah) as jumlah FROM transaksi WHERE tipe = 'pemasukan'",
    );
    if (result.isNotEmpty && result.first['jumlah'] != null) {
      return (result.first['jumlah'] as num).toDouble();
    }
    return 0.0;
  }

  Future<double> getTotalPengeluaran() async {
    final db = await _db;
    final result = await db.rawQuery(
      "SELECT SUM(jumlah) as jumlah FROM transaksi WHERE tipe = 'pengeluaran'",
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

  // diubah: Fungsi ini sekarang dengan benar memperbarui saldo dompet.
  // PERINGATAN: Fungsi ini sekarang hanya aman untuk INSERT, tidak untuk UPDATE.
  Future<void> sisipkanAtauPerbaruiBatch(List<TransaksiModel> items) async {
    final db = await _db;
    final batch = db.batch();
    for (var item in items) {
      // Menyisipkan record transaksi itu sendiri
      batch.insert(
        'transaksi',
        item.salinDengan(diperbarui: DateTime.now()).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // ditambah: Logika untuk memperbarui saldo dompet berdasarkan tipe transaksi
      if (item.tipe == TipeTransaksi.pemasukan) {
        batch.rawUpdate(
          'UPDATE dompet SET saldo = saldo + ? WHERE id = ?',
          [item.jumlah, item.idDompet],
        );
      } else if (item.tipe == TipeTransaksi.pengeluaran) {
        batch.rawUpdate(
          'UPDATE dompet SET saldo = saldo - ? WHERE id = ?',
          [item.jumlah, item.idDompet],
        );
      } else if (item.tipe == TipeTransaksi.transfer) {
        batch.rawUpdate(
          'UPDATE dompet SET saldo = saldo - ? WHERE id = ?',
          [item.jumlah, item.idDompet],
        );
        if (item.idDompetTujuan != null) {
          batch.rawUpdate(
            'UPDATE dompet SET saldo = saldo + ? WHERE id = ?',
            [item.jumlah, item.idDompetTujuan],
          );
        }
      }
    }
    await batch.commit(noResult: true);
  }
}
