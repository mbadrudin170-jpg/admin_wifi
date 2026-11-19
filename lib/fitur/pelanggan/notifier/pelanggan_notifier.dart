// path: lib/fitur/pelanggan/notifier/pelanggan_notifier.dart

import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/db/operasi_sqlite.dart';
import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/fitur/pelanggan/state/pelanggan_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';

part 'pelanggan_notifier.g.dart';

@Riverpod(keepAlive: true)
class PelangganNotifier extends _$PelangganNotifier {
  final PelangganOperasi _operasi = PelangganOperasi();

  @override
  Future<PelangganState> build() async {
    L.i('Memuat daftar pelanggan dari database');
    return _ambilSemua();
  }

  Future<void> muatUlang() async {
    try {
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memuat ulang pelanggan: $e\n$s');
      rethrow;
    }
  }

  Future<PelangganState> _ambilSemua() async {
    final operasiSqlite = ref.read(operasiSqliteProvider);
    final maps = await operasiSqlite.ambil(
      PelangganSkema.tabel,
      where:
          '${PelangganSkema.diarsipkan} IS NULL AND ${PelangganSkema.isDeleted} = ?',
      whereArgs: const [0],
    );
    final daftar = maps.map(PelangganModel.fromSqlite).toList();
    return PelangganState(
      listPelanggan: daftar,
      jumlahPelanggan: daftar.length,
    );
  }

  Future<void> tambah(PelangganModel model) async {
    try {
      await _operasi.createPelanggan(model);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menambahkan pelanggan: $e\n$s');
      rethrow;
    }
  }

  Future<void> tambahBatch(List<PelangganModel> models) async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final data = models.map((item) => item.toSqlite()).toList();
      await operasiSqlite.tambahBatch(PelangganSkema.tabel, data);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menambahkan batch pelanggan: $e\n$s');
      rethrow;
    }
  }

  Future<void> ubah(PelangganModel model) async {
    try {
      await _operasi.updatePelanggan(model);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal mengubah pelanggan: $e\n$s');
      rethrow;
    }
  }

  Future<void> hapus(String id) async {
    try {
      await _operasi.arsipkanPelanggan(id);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menghapus pelanggan: $e\n$s');
      rethrow;
    }
  }
}
