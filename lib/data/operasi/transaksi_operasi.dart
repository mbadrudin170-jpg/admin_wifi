// path: lib/data/operasi/transaksi_operasi.dart
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/enum/sync_status.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:sqflite/sqflite.dart';

class TransaksiOperasi {
  final dbHelper = DatabaseHelper.instance;

  // ===================================================================
  // -- OPERASI DASAR CRUD (Create, Read, Update, Delete) --
  // ===================================================================

  /// (Create) Menambahkan satu transaksi baru ke dalam database.
  Future<int> tambahTransaksi(TransaksiModel transaksi) async {
    final db = await dbHelper.database;
    final dataBaru = transaksi.salinDengan(
      syncStatus: SyncStatus.write,
      diperbarui: DateTime.now(),
    );
    return await db.insert(
      'transaksi',
      dataBaru.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// (Read) Mengambil semua data transaksi dari database.
  Future<List<TransaksiModel>> ambilSemuaTransaksi() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaksi',
      orderBy: 'tanggal DESC',
    );
    return List.generate(maps.length, (i) {
      return TransaksiModel.fromMap(maps[i]);
    });
  }

  /// (Update) Memperbarui data satu transaksi yang ada di database.
  Future<void> updateTransaksi(TransaksiModel transaksi) async {
    final db = await dbHelper.database;
    final dataUpdate = transaksi.salinDengan(
      syncStatus: SyncStatus.update,
      diperbarui: DateTime.now(),
    );
    await db.update(
      'transaksi',
      dataUpdate.toMap(),
      where: 'id = ?',
      whereArgs: [transaksi.id],
    );
  }

  /// (Delete) Menandai satu transaksi untuk dihapus saat sinkronisasi berikutnya.
  Future<void> deleteTransaksi(String id) async {
    final db = await dbHelper.database;
    // diubah: Menggunakan .name untuk mencocokkan tipe TEXT
    await db.rawUpdate(
      '''
      UPDATE transaksi 
      SET sync_status = ?, diperbarui = ? 
      WHERE id = ?
      ''',
      [SyncStatus.deleted.name, DateTime.now().toIso8601String(), id],
    );
  }

  // ===================================================================
  // -- FUNGSI AGREGASI SALDO (Penjumlahan & Perhitungan) --
  // ===================================================================

  /// Menghitung total dari semua transaksi bertipe 'Pemasukan'.
  Future<double> getTotalPemasukan() async {
    final db = await dbHelper.database;
    // diubah: Menggunakan .name untuk query
    final result = await db.rawQuery(
      "SELECT SUM(jumlah) as jumlah FROM transaksi WHERE tipe = 'pemasukan' AND sync_status != ?",
      [SyncStatus.deleted.name],
    );
    if (result.isNotEmpty && result.first['jumlah'] != null) {
      return (result.first['jumlah'] as num).toDouble();
    }
    return 0.0;
  }

  /// Menghitung total dari semua transaksi bertipe 'Pengeluaran'.
  Future<double> getTotalPengeluaran() async {
    final db = await dbHelper.database;
    // diubah: Menggunakan .name untuk query
    final result = await db.rawQuery(
      "SELECT SUM(jumlah) as jumlah FROM transaksi WHERE tipe = 'pengeluaran' AND sync_status != ?",
      [SyncStatus.deleted.name],
    );
    if (result.isNotEmpty && result.first['jumlah'] != null) {
      return (result.first['jumlah'] as num).toDouble();
    }
    return 0.0;
  }

  /// Menghitung selisih bersih antara total pemasukan dan pengeluaran.
  Future<double> getNetTotal() async {
    final pemasukan = await getTotalPemasukan();
    final pengeluaran = await getTotalPengeluaran();
    return pemasukan - pengeluaran;
  }

  // ===================================================================
  // -- FUNGSI SINKRONISASI (Untuk Firebase, dll) --
  // ===================================================================

  /// Mengambil semua record yang berubah (dibuat/diperbarui/dihapus).
  Future<List<TransaksiModel>> getPerubahan() async {
    final db = await dbHelper.database;
    // diubah: Menggunakan .name untuk query
    final List<Map<String, dynamic>> maps = await db.query(
      'transaksi',
      where: 'sync_status != ?',
      whereArgs: [SyncStatus.synced.name],
    );
    return List.generate(maps.length, (i) => TransaksiModel.fromMap(maps[i]));
  }

  /// Menyisipkan atau memperbarui beberapa item sekaligus secara efisien (batch).
  Future<void> sisipkanAtauPerbaruiBatch(List<TransaksiModel> items) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (var item in items) {
      final dataSynced = item.salinDengan(syncStatus: SyncStatus.synced);
      batch.insert(
        'transaksi',
        dataSynced.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
