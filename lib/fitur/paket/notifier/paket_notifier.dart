// path: lib/fitur/paket/notifier/paket_notifier.dart

import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/db/operasi_sqlite.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/paket/state/paket_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';

part 'paket_notifier.g.dart';

@Riverpod(keepAlive: true)
class PaketNotifier extends _$PaketNotifier {
  final PaketOperasi _operasi = PaketOperasi();

  @override
  Future<PaketState> build() async {
    L.i('Memuat daftar paket dari database');
    return _ambilSemua();
  }

  Future<void> muatUlang() async {
    try {
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memuat ulang paket: $e\n$s');
      rethrow;
    }
  }

  Future<PaketState> _ambilSemua() async {
    final operasiSqlite = ref.read(operasiSqliteProvider);
    final maps = await operasiSqlite.ambil(
      PaketSkema.tabel,
      where: '${PaketSkema.isDeleted} = ?',
      whereArgs: const [0],
      orderBy:
          "CASE tipe WHEN 'jam' THEN durasi WHEN 'hari' THEN durasi * 24 WHEN 'bulan' THEN durasi * 24 * 30 ELSE 999999 END ASC",
    );
    final daftar = maps.map(PaketModel.fromSqlite).toList();
    return PaketState(listPaket: daftar, jumlahPaket: daftar.length);
  }

  Future<void> tambah(PaketModel model) async {
    try {
      await _operasi.createPaket(model);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menambahkan paket: $e\n$s');
      rethrow;
    }
  }

  Future<void> tambahBatch(List<PaketModel> models) async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final data = models.map((item) => item.toSqlite()).toList();
      await operasiSqlite.tambahBatch(PaketSkema.tabel, data);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menambahkan batch paket: $e\n$s');
      rethrow;
    }
  }

  Future<void> ubah(PaketModel model) async {
    try {
      await _operasi.updatePaket(model);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal mengubah paket: $e\n$s');
      rethrow;
    }
  }

  /// Penghapusan paket dilakukan permanen (tidak ada soft delete).
  Future<void> hapus(String id) async {
    try {
      await _operasi.hapusPaket(id);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menghapus paket: $e\n$s');
      rethrow;
    }
  }
}
