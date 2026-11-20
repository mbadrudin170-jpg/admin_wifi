// path: lib/fitur/transaksi/notifier/transaksi_notifier.dart

import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/db/sqlite/operasi_sqlite.dart';
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/transaksi/state/transaksi_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:sqflite/sqflite.dart';

part 'transaksi_notifier.g.dart';

@Riverpod(keepAlive: true)
class TransaksiNotifier extends _$TransaksiNotifier {
  final OperasiDasar _operasiDasar = OperasiDasar();

  @override
  Future<TransaksiState> build() async {
    return _ambilSemua();
  }

  Future<Database> get _db async => await DatabaseHelper.instance.database;

  Future<void> muatUlang() async {
    try {
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memuat ulang transaksi: $e\n$s');
      rethrow;
    }
  }

  Future<TransaksiState> _ambilSemua() async {
    final operasiSqlite = ref.read(operasiSqliteProvider);
    final maps = await operasiSqlite.ambil(
      TransaksiSkema.tabel,
      where: '${TransaksiSkema.isDeleted} = ?',
      whereArgs: const [0],
      orderBy: 'tanggal DESC',
    );
    final daftar = maps.map(TransaksiModel.fromSqlite).toList();
    return TransaksiState(
      listTransaksi: daftar,
      jumlahTransaksi: daftar.length,
    );
  }

  Future<void> _recalculateAndUpdateDompetSaldo(
    String idDompet,
    DatabaseExecutor txn,
  ) async {
    try {
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
    } catch (e, s) {
      L.e('Gagal hitung ulang saldo Dompet ID: $idDompet. Error: $e $s');
      rethrow;
    }
  }

  Future<int> tambahTransaksi(TransaksiModel transaksi) async {
    try {
      final id = await _operasiDasar.jalankanOperasiKompleks<int>((txn) async {
        final data = transaksi.copyWith(diperbarui: DateTime.now());

        final newId = await txn.insert(
          'transaksi',
          data.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await _recalculateAndUpdateDompetSaldo(data.idDompet, txn);
        if (data.tipe == TipeTransaksi.transfer &&
            data.idDompetTujuan != null) {
          await _recalculateAndUpdateDompetSaldo(data.idDompetTujuan!, txn);
        }
        return newId;
      });
      state = AsyncValue.data(await _ambilSemua());
      return id;
    } catch (e, s) {
      L.e('Gagal menambah transaksi ID: ${transaksi.id}. Error: $e $s');
      rethrow;
    }
  }

  Future<void> tambah(TransaksiModel model) async {
    try {
      await tambahTransaksi(model);
    } catch (e, s) {
      L.e('Gagal menambahkan transaksi: $e\n$s');
      rethrow;
    }
  }

  Future<List<TransaksiModel>> ambilSemuaTransaksi() async {
    final db = await _db;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        TransaksiSkema.tabel,
        where: '${TransaksiSkema.isDeleted} = ?',
        whereArgs: const [0],
        orderBy: '${TransaksiSkema.tanggal} DESC',
      );
      return maps.map(TransaksiModel.fromSqlite).toList();
    } catch (e, s) {
      L.e('Gagal mengambil semua transaksi. Error: $e $s');
      return [];
    }
  }

  Future<void> updateTransaksi(String id, TransaksiModel transaksiBaru) async {
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final maps = await txn.query(
          TransaksiSkema.tabel,
          where: '${TransaksiSkema.id} = ?',
          whereArgs: [id],
        );

        if (maps.isNotEmpty) {
          final transaksiLama = TransaksiModel.fromSqlite(maps.first);
          final dataUpdate = transaksiBaru.copyWith(diperbarui: DateTime.now());

          await txn.update(
            TransaksiSkema.tabel,
            dataUpdate.toSqlite(),
            where: '${TransaksiSkema.id} = ?',
            whereArgs: [id],
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

          for (final dompetId in affectedWallets) {
            await _recalculateAndUpdateDompetSaldo(dompetId, txn);
          }
        }
      });
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal update transaksi ID: $id. Error: $e $s');
      rethrow;
    }
  }

  Future<void> ubah(TransaksiModel model) async {
    try {
      await updateTransaksi(model.id, model);
    } catch (e, s) {
      L.e('Gagal mengubah transaksi: $e\n$s');
      rethrow;
    }
  }

  Future<void> arsipkanTransaksi(String id) async {
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final maps = await txn.query(
          TransaksiSkema.tabel,
          where: '${TransaksiSkema.id} = ?',
          whereArgs: [id],
        );

        if (maps.isNotEmpty) {
          final transaksiLama = TransaksiModel.fromSqlite(maps.first);

          await txn.update(
            TransaksiSkema.tabel,
            {
              TransaksiSkema.isDeleted: 1,
              TransaksiSkema.diperbarui: DateTime.now().toIso8601String(),
            },
            where: '${TransaksiSkema.id} = ?',
            whereArgs: [id],
          );

          await _recalculateAndUpdateDompetSaldo(transaksiLama.idDompet, txn);
          if (transaksiLama.tipe == TipeTransaksi.transfer &&
              transaksiLama.idDompetTujuan != null) {
            await _recalculateAndUpdateDompetSaldo(
              transaksiLama.idDompetTujuan!,
              txn,
            );
          }
        }
      });
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal mengarsipkan transaksi ID: $id. Error: $e $s');
      rethrow;
    }
  }

  Future<int> hitungTotalPoin(String idPelanggan) async {
    return state.value?.getTotalPoin(idPelanggan) ?? 0;
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<TransaksiModel> items) async {
    final affectedWallets = <String>{};
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        final batch = txn.batch();
        for (final item in items) {
          batch.insert(
            TransaksiSkema.tabel,
            item.copyWith(diperbarui: DateTime.now()).toSqlite(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          affectedWallets.add(item.idDompet);
          if (item.idDompetTujuan != null) {
            affectedWallets.add(item.idDompetTujuan!);
          }
        }
        await batch.commit(noResult: true);

        for (final dompetId in affectedWallets) {
          await _recalculateAndUpdateDompetSaldo(dompetId, txn);
        }
      });
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menjalankan Batch transaksi. Error: $e $s');
      rethrow;
    }
  }
  }

/// Kontainer global untuk mengakses [TransaksiNotifier] di luar konteks Riverpod.
final ProviderContainer _transaksiGlobalContainer = ProviderContainer();

TransaksiNotifier get transaksiNotifierGlobal =>
    _transaksiGlobalContainer.read(transaksiProvider.notifier);
