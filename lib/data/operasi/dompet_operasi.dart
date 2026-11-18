// path: lib/data/operasi/dompet_operasi.dart
import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/db/sqflite.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:share_global_saya/src/utils/l.dart';

class DompetOperasi {
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();

  Future<void> createDompet(DompetModel dompet) async {
    L.i('Memulai createDompet untuk dompet: ${dompet.toSqlite()}');
    try {
      final data = dompet.copyWith(diperbarui: DateTime.now()).toSqlite();
      await _operasiDasar.sisipkan('dompet', data);
      L.i('Berhasil membuat dompet dengan ID data: ${dompet.id}');
    } catch (e, st) {
      L.e('Gagal saat createDompet Error: $e $st');
      rethrow;
    }
  }

  // diubah: Menambahkan parameter untuk memfilter dompet yang diarsipkan
  Future<List<DompetModel>> getDompet({
    bool tampilkanDiarsipkan = false,
  }) async {
    L.i('Memulai getDompet (tampilkanDiarsipkan: $tampilkanDiarsipkan).');
    try {
      final db = await dbHelper.database;
      // diubah: query disesuaikan berdasarkan parameter
      final query = tampilkanDiarsipkan
          ? 'isDeleted = 0'
          : 'isDeleted = 0 AND diarsipkan IS NULL';
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: query,
      );

      final listDompet = List.generate(
        maps.length,
        (i) => DompetModel.fromSqlite(maps[i]),
      );
      L.i('Berhasil mengambil ${listDompet.length} data dompet.');
      return listDompet;
    } catch (e, st) {
      L.e('Gagal saat getDompet Error: $e $st');
      rethrow;
    }
  }

  Future<DompetModel?> getDompetById(String id) async {
    L.i('Memulai getDompetById untuk ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: 'id = ? AND isDeleted = 0',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final dompet = DompetModel.fromSqlite(maps.first);
        L.i('Dompet dengan ID: $id ditemukan. Data: ${dompet.toSqlite()}');
        return dompet;
      }

      L.w('Dompet dengan ID: $id tidak ditemukan di database.');
      return null;
    } catch (e, st) {
      L.e('Gagal saat getDompetById untuk ID: $id Error: $e $st');
      rethrow;
    }
  }

  Future<void> updateDompet(DompetModel dompet) async {
    L.i('Memulai updateDompet untuk dompet: ${dompet.toSqlite()}');
    try {
      final data = dompet.copyWith(diperbarui: DateTime.now()).toSqlite();
      await _operasiDasar.perbarui('dompet', data, dompet.id);
      L.i('Berhasil updateDompet untuk ID: ${dompet.id}.');
    } catch (e, st) {
      L.e('Gagal saat updateDompet untuk ID: ${dompet.id} Error: $e $st');
      rethrow;
    }
  }

  // ditambah: Fungsi baru untuk mengarsipkan semua dompet
  /// Mengarsipkan semua dompet yang belum diarsipkan.
  Future<void> arsipSemuaDompet() async {
    L.i('Memulai proses pengarsipan untuk semua dompet.');
    try {
      // 1. Ambil semua dompet yang aktif (belum diarsipkan)
      final daftarDompetAktif = await getDompet(tampilkanDiarsipkan: false);
      L.i(
        'Ditemukan ${daftarDompetAktif.length} dompet aktif untuk diarsipkan.',
      );

      // 2. Loop melalui setiap dompet dan arsipkan
      for (final dompet in daftarDompetAktif) {
        // 3. Panggil `updateDompet` untuk mengarsipkan satu per satu
        await updateDompet(dompet.copyWith(diarsipkan: DateTime.now()));
      }

      L.i('Proses pengarsipan semua dompet telah selesai.');
    } catch (e, st) {
      L.e('Gagal saat proses pengarsipan massal dompet. Error: $e $st');
      rethrow;
    }
  }

  Future<void> hapusSemuaDompet() async {
    L.w(
      'PERINGATAN: Memulai hapusSemuaDompet. Ini adalah operasi destruktif yang akan menghapus semua dompet secara permanen.',
    );
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final count = await txn.delete('dompet');
        L.i(
          'Berhasil hapusSemuaDompet. Total baris yang dihapus permanen: $count',
        );
      });
    } catch (e, st) {
      L.e('Gagal saat hapusSemuaDompet Error: $e $st');
      rethrow;
    }
  }

  Future<void> arsipkanSatuDompet(String id) async {
    L.i('Memulai arsipkanSatuDompet (soft delete) untuk ID: $id');
    try {
      final now = DateTime.now();
      final Map<String, dynamic> dataToUpdate = {
        'diarsipkan': now.toIso8601String(),
        'diperbarui': now.toIso8601String(),
        'isDeleted': 1,
      };

      await _operasiDasar.perbarui('dompet', dataToUpdate, id);

      L.i('Berhasil arsipkanSatuDompet untuk ID: $id.');
    } catch (e, st) {
      L.e('Gagal saat arsipkanSatuDompet untuk ID: $id Error: $e $st');
      rethrow;
    }
  }

  Future<double> getTotalSaldo() async {
    L.i(
      'Memulai getTotalSaldo (menghitung total saldo dari semua dompet aktif).',
    );
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(saldo) as total FROM dompet WHERE isDeleted = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      L.i('Berhasil menghitung total saldo: $total');
      return total;
    } catch (e, st) {
      L.e('Gagal saat getTotalSaldo Error: $e $st');
      rethrow;
    }
  }

  Future<double> getTotalSaldoPositif() async {
    L.i(
      'Memulai getTotalSaldoPositif (menghitung total saldo > 0 dari dompet aktif).',
    );
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(saldo) as total FROM dompet WHERE saldo > 0 AND isDeleted = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      L.i('Berhasil menghitung total saldo positif: $total');
      return total;
    } catch (e, st) {
      L.e('Gagal saat getTotalSaldoPositif Error: $e $st');
      rethrow;
    }
  }

  Future<double> getTotalSaldoNegatif() async {
    L.i(
      'Memulai getTotalSaldoNegatif (menghitung total saldo < 0 dari dompet aktif).',
    );
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(saldo) as total FROM dompet WHERE saldo < 0 AND isDeleted = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      L.i('Berhasil menghitung total saldo negatif: $total');
      return total;
    } catch (e, st) {
      L.e('Gagal saat getTotalSaldoNegatif Error: $e $st');
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<DompetModel> items) async {
    L.i('Memulai sisipkanAtauPerbaruiBatch untuk ${items.length} item dompet.');
    if (items.isEmpty) {
      L.w('List item untuk batch kosong, tidak ada operasi yang dilakukan.');
      return;
    }
    try {
      final data = items.map((item) => item.toSqlite()).toList();
      await _operasiDasar.sisipkanAtauPerbaruiBatch('dompet', data);
      L.i(
        'Berhasil menyelesaikan sisipkanAtauPerbaruiBatch untuk ${items.length} item.',
      );
    } catch (e, st) {
      L.e('Gagal saat menjalankan sisipkanAtauPerbaruiBatch Error: $e $st');
      rethrow;
    }
  }

  Future<List<DompetModel>> getDompetByIds(List<String> ids) async {
    L.i('Memulai getDompetByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      L.w('List ID untuk getDompetByIds kosong, mengembalikan list kosong.');
      return [];
    }
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );

      final listDompet = List.generate(
        maps.length,
        (i) => DompetModel.fromSqlite(maps[i]),
      );
      L.i(
        'Berhasil mengambil ${listDompet.length} dompet dari ${ids.length} ID yang diminta.',
      );
      return listDompet;
    } catch (e, st) {
      L.e('Gagal saat getDompetByIds Error: $e $st');
      rethrow;
    }
  }
}
