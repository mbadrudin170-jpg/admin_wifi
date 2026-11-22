// path: lib/fitur/dompet/notifier/dompet_notifier.dart

import 'package:admin_wifi/db/sqlite/operasi_sqlite.dart';
import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/dompet/state/dompet_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';

part 'dompet_notifier.g.dart';

@Riverpod(keepAlive: true)
class DompetNotifier extends _$DompetNotifier {
  final OperasiSqlite _operasiSqlite = OperasiSqlite();

  @override
  Future<DompetState> build() async {
    return _ambilSemua();
  }

  Future<void> muatUlang() async {
    try {
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memuat ulang dompet: $e $s');
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

  Future<void> tambah(DompetModel dompet) async {
    L.i('Memulai tambah dompet: ${dompet.toSqlite()}');
    try {
      final data = dompet.copyWith(diperbarui: DateTime.now()).toSqlite();
      await _operasiSqlite.sisipkan(DompetSkema.tabel, data);
      state = AsyncValue.data(await _ambilSemua());
      L.i('Berhasil membuat dompet dengan ID data: ${dompet.id}');
    } catch (e, s) {
      L.e('Gagal saat tambah dompet Error: $e $s');
      rethrow;
    }
  }

  Future<void> tambahBatch(List<DompetModel> models) async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final data = models.map((item) => item.toSqlite()).toList();
      await operasiSqlite.sisipkanAtauPerbaruiBatch(DompetSkema.tabel, data);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menambahkan batch dompet: $e $s');
      rethrow;
    }
  }

  Future<void> ubah(DompetModel dompet) async {
    L.i('Memulai ubah dompet: ${dompet.toSqlite()}');
    try {
      final data = dompet.copyWith(diperbarui: DateTime.now()).toSqlite();
      await _operasiSqlite.perbarui(DompetSkema.tabel, data, dompet.id);
      state = AsyncValue.data(await _ambilSemua());
      L.i('Berhasil ubah dompet untuk ID: ${dompet.id}.');
    } catch (e, s) {
      L.e('Gagal saat ubah dompet untuk ID: ${dompet.id} Error: $e $s');
      rethrow;
    }
  }

  Future<void> hapus(String id) async {
    try {
      await arsipkanSatuDompet(id);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menghapus dompet: $e $s');
      rethrow;
    }
  }

  Future<void> arsipSemuaDompet() async {
    try {
      final stateData = await future;
      final daftarDompetAktif = stateData.listDompet;
      L.i(
        'Ditemukan ${daftarDompetAktif.length} dompet aktif untuk diarsipkan.',
      );

      for (final dompet in daftarDompetAktif) {
        await ubah(dompet.copyWith(diarsipkan: DateTime.now()));
      }
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
      await _operasiSqlite.jalankanOperasiKompleks((txn) async {
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

      await _operasiSqlite.perbarui(DompetSkema.tabel, dataToUpdate, id);

      L.i('Berhasil arsipkanSatuDompet untuk ID: $id.');
    } catch (e, s) {
      L.e('Gagal saat arsipkanSatuDompet untuk ID: $id Error: $e $s');
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<DompetModel> items) async {
    L.i('Memulai sisipkanAtauPerbaruiBatch untuk ${items.length} item dompet.');
    if (items.isEmpty) {
      return;
    }
    try {
      final data = items.map((item) => item.toSqlite()).toList();
      await _operasiSqlite.sisipkanAtauPerbaruiBatch(DompetSkema.tabel, data);
      state = AsyncValue.data(await _ambilSemua());
      L.i(
        'Berhasil menyelesaikan sisipkanAtauPerbaruiBatch untuk ${items.length} item.',
      );
    } catch (e, s) {
      L.e('Gagal saat menjalankan sisipkanAtauPerbaruiBatch Error: $e $s');
      rethrow;
    }
  }
}

final ProviderContainer _dompetGlobalContainer = ProviderContainer();

DompetNotifier get dompetNotifierGlobal =>
    _dompetGlobalContainer.read(dompetProvider.notifier);
