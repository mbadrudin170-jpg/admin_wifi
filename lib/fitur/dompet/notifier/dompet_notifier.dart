// path: lib/fitur/dompet/notifier/dompet_notifier.dart

import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/db/sqlite/operasi_sqlite.dart';
import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/dompet/state/dompet_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';

part 'dompet_notifier.g.dart';

@Riverpod(keepAlive: true)
class DompetNotifier extends _$DompetNotifier {
  final DompetOperasi _operasi = DompetOperasi();

  @override
  Future<DompetState> build() async {
    L.i('Memuat daftar dompet dari database');
    return _ambilSemua();
  }

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

  Future<void> tambah(DompetModel model) async {
    try {
      await _operasi.createDompet(model);
      state = AsyncValue.data(await _ambilSemua());
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

  Future<void> ubah(DompetModel model) async {
    try {
      await _operasi.updateDompet(model);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal mengubah dompet: $e\n$s');
      rethrow;
    }
  }

  Future<void> hapus(String id) async {
    try {
      await _operasi.arsipkanSatuDompet(id);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menghapus dompet: $e\n$s');
      rethrow;
    }
  }
}
