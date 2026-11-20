// path: lib/fitur/dompet/notifier/dompet_notifier.dart

import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/db/sqlite/operasi_sqlite.dart';
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/dompet/state/dompet_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:sqflite/sqflite.dart';

part 'dompet_notifier.g.dart';

@Riverpod(keepAlive: true)
class DompetNotifier extends _$DompetNotifier {
  final OperasiDasar _operasiDasar = OperasiDasar();

  @override
  Future<DompetState> build() async {
    L.i('Memuat daftar dompet dari database');
    return _ambilSemua();
  }

  Future<Database> get _db async => await DatabaseHelper.instance.database;

  Future<void> muatUlang() async {
    try {
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memuat ulang dompet: $e\n$s');
      rethrow;
    }
  }

  Future<DompetState> _ambilSemua() async {
    final operasiSqlite = ref.read(operasiSqliteProvider);
    final maps = await operasiSqlite.ambil(
      DompetSkema.tabel,
      where:
          '${DompetSkema.isDeleted} = 0 AND ${DompetSkema.diarsipkan} IS NULL',
    );
    final daftar = maps.map(DompetModel.fromSqlite).toList();
    return DompetState(listDompet: daftar, jumlahDompet: daftar.length);
  }

  Future<void> createDompet(DompetModel dompet) async {
    L.i('Memulai createDompet untuk dompet: ${dompet.toSqlite()}');
    try {
      final data = dompet.copyWith(diperbarui: DateTime.now()).toSqlite();
      await _operasiDasar.sisipkan(DompetSkema.tabel, data);
      state = AsyncValue.data(await _ambilSemua());
      L.i('Berhasil membuat dompet dengan ID data: ${dompet.id}');
    } catch (e, s) {
      L.e('Gagal saat createDompet Error: $e $s');
      rethrow;
    }
  }

  Future<void> tambah(DompetModel model) async {
    try {
      await createDompet(model);
    } catch (e, s) {
      L.e('Gagal menambahkan dompet: $e\n$s');
      rethrow;
    }
  }

  Future<void> tambahBatch(List<DompetModel> models) async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final data = models.map((item) => item.toSqlite()).toList();
      await operasiSqlite.tambahBatch(DompetSkema.tabel, data);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menambahkan batch dompet: $e\n$s');
      rethrow;
    }
  }

  Future<void> updateDompet(DompetModel dompet) async {
    L.i('Memulai updateDompet untuk dompet: ${dompet.toSqlite()}');
    try {
      final data = dompet.copyWith(diperbarui: DateTime.now()).toSqlite();
      await _operasiDasar.perbarui(DompetSkema.tabel, data, dompet.id);
      state = AsyncValue.data(await _ambilSemua());
      L.i('Berhasil updateDompet untuk ID: ${dompet.id}.');
    } catch (e, s) {
      L.e('Gagal saat updateDompet untuk ID: ${dompet.id} Error: $e $s');
      rethrow;
    }
  }

  Future<void> ubah(DompetModel model) async {
    try {
      await updateDompet(model);
    } catch (e, s) {
      L.e('Gagal mengubah dompet: $e\n$s');
      rethrow;
    }
  }

  Future<void> hapus(String id) async {
    try {
      await arsipkanSatuDompet(id);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menghapus dompet: $e\n$s');
      rethrow;
    }
  }

  Future<List<DompetModel>> getDompet({
    bool tampilkanDiarsipkan = false,
  }) async {
    L.i('Memulai getDompet (tampilkanDiarsipkan: $tampilkanDiarsipkan).');
    try {
      final db = await _db;
      final query = tampilkanDiarsipkan
          ? 'is_deleted = 0'
          : 'is_deleted = 0 AND diarsipkan IS NULL';
      final List<Map<String, dynamic>> maps = await db.query(
        DompetSkema.tabel,
        where: query,
      );

      final listDompet = List.generate(
        maps.length,
        (i) => DompetModel.fromSqlite(maps[i]),
      );
      L.i('Berhasil mengambil ${listDompet.length} data dompet.');
      return listDompet;
    } catch (e, s) {
      L.e('Gagal saat getDompet Error: $e $s');
      rethrow;
    }
  }

  Future<DompetModel?> getDompetById(String id) async {
    L.i('Memulai getDompetById untuk ID: $id');
    try {
      final db = await _db;
      final List<Map<String, dynamic>> maps = await db.query(
        DompetSkema.tabel,
        where: 'id = ? AND is_deleted = 0',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final dompet = DompetModel.fromSqlite(maps.first);
        L.i('Dompet dengan ID: $id ditemukan. Data: ${dompet.toSqlite()}');
        return dompet;
      }

      L.w('Dompet dengan ID: $id tidak ditemukan di database.');
      return null;
    } catch (e, s) {
      L.e('Gagal saat getDompetById untuk ID: $id Error: $e $s');
      rethrow;
    }
  }

  Future<void> arsipSemuaDompet() async {
    L.i('Memulai proses pengarsipan untuk semua dompet.');
    try {
      final daftarDompetAktif = await getDompet(tampilkanDiarsipkan: false);
      L.i(
        'Ditemukan ${daftarDompetAktif.length} dompet aktif untuk diarsipkan.',
      );

      for (final dompet in daftarDompetAktif) {
        await updateDompet(dompet.copyWith(diarsipkan: DateTime.now()));
      }

      L.i('Proses pengarsipan semua dompet telah selesai.');
    } catch (e, s) {
      L.e('Gagal saat proses pengarsipan massal dompet. Error: $e $s');
      rethrow;
    }
  }

  Future<void> hapusSemuaDompet() async {
    L.w(
      'PERINGATAN: Memulai hapusSemuaDompet. Ini adalah operasi destruktif yang akan menghapus semua dompet secara permanen.',
    );
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final count = await txn.delete(DompetSkema.tabel);
        L.i(
          'Berhasil hapusSemuaDompet. Total baris yang dihapus permanen: $count',
        );
      });
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal saat hapusSemuaDompet Error: $e $s');
      rethrow;
    }
  }

  Future<void> arsipkanSatuDompet(String id) async {
    L.i('Memulai arsipkanSatuDompet (soft delete) untuk ID: $id');
    try {
      final now = DateTime.now();
      final Map<String, dynamic> dataToUpdate = {
        DompetSkema.diarsipkan: now.toIso8601String(),
        DompetSkema.diperbarui: now.toIso8601String(),
        DompetSkema.isDeleted: 1,
      };

      await _operasiDasar.perbarui(DompetSkema.tabel, dataToUpdate, id);

      L.i('Berhasil arsipkanSatuDompet untuk ID: $id.');
    } catch (e, s) {
      L.e('Gagal saat arsipkanSatuDompet untuk ID: $id Error: $e $s');
      rethrow;
    }
  }

  Future<double> getTotalSaldo() async {
    L.i(
      'Memulai getTotalSaldo (menghitung total saldo dari semua dompet aktif).',
    );
    try {
      final db = await _db;
      final result = await db.rawQuery(
        'SELECT SUM(saldo) as total FROM ${DompetSkema.tabel} WHERE is_deleted = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      L.i('Berhasil menghitung total saldo: $total');
      return total;
    } catch (e, s) {
      L.e('Gagal saat getTotalSaldo Error: $e $s');
      rethrow;
    }
  }

  Future<double> getTotalSaldoPositif() async {
    L.i(
      'Memulai getTotalSaldoPositif (menghitung total saldo > 0 dari dompet aktif).',
    );
    try {
      final db = await _db;
      final result = await db.rawQuery(
        'SELECT SUM(saldo) as total FROM ${DompetSkema.tabel} WHERE saldo > 0 AND is_deleted = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      L.i('Berhasil menghitung total saldo positif: $total');
      return total;
    } catch (e, s) {
      L.e('Gagal saat getTotalSaldoPositif Error: $e $s');
      rethrow;
    }
  }

  Future<double> getTotalSaldoNegatif() async {
    L.i(
      'Memulai getTotalSaldoNegatif (menghitung total saldo < 0 dari dompet aktif).',
    );
    try {
      final db = await _db;
      final result = await db.rawQuery(
        'SELECT SUM(saldo) as total FROM ${DompetSkema.tabel} WHERE saldo < 0 AND is_deleted = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      L.i('Berhasil menghitung total saldo negatif: $total');
      return total;
    } catch (e, s) {
      L.e('Gagal saat getTotalSaldoNegatif Error: $e $s');
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
      await _operasiDasar.sisipkanAtauPerbaruiBatch(DompetSkema.tabel, data);
      state = AsyncValue.data(await _ambilSemua());
      L.i(
        'Berhasil menyelesaikan sisipkanAtauPerbaruiBatch untuk ${items.length} item.',
      );
    } catch (e, s) {
      L.e('Gagal saat menjalankan sisipkanAtauPerbaruiBatch Error: $e $s');
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
      final db = await _db;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        DompetSkema.tabel,
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
    } catch (e, s) {
      L.e('Gagal saat getDompetByIds Error: $e $s');
      rethrow;
    }
  }
}

final ProviderContainer _dompetGlobalContainer = ProviderContainer();

DompetNotifier get dompetNotifierGlobal =>
    _dompetGlobalContainer.read(dompetProvider.notifier);
