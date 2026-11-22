// path: lib/fitur/pesanan/notifier/pesanan_notifier.dart
// diubah: Memindahkan logika dari PesananOperasi ke notifier ini.

import 'package:admin_wifi/db/sqlite/operasi_sqlite.dart';
import 'package:admin_wifi/fitur/pesanan/model/pesanan_model.dart';
import 'package:admin_wifi/fitur/pesanan/state/pesanan_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';

part 'pesanan_notifier.g.dart';

@Riverpod(keepAlive: true)
class PesananNotifier extends _$PesananNotifier {
  @override
  Future<PesananState> build() async {
    return _ambilSemua();
  }

  Future<void> muatUlang() async {
    try {
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memuat ulang pesanan: $e $s');
      rethrow;
    }
  }

  Future<PesananState> _ambilSemua() async {
    final operasiSqlite = ref.read(operasiSqliteProvider);
    final maps = await operasiSqlite.ambil('pesanan', orderBy: 'tanggal DESC');
    final daftar = maps.map(PesananModel.fromSqlite).toList();
    return PesananState(listPesanan: daftar, jumlahPesanan: daftar.length);
  }

  Future<void> simpanPesanan(PesananModel pesanan) async {
    L.i('Menyimpan pesanan baru - ID: ${pesanan.id}');
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      await operasiSqlite.sisipkan('pesanan', pesanan.toSqlite());
      await muatUlang();
    } catch (e, s) {
      L.e('Gagal menyimpan pesanan - ID: ${pesanan.id} Error: $e $s');
      rethrow;
    }
  }

  Future<List<PesananModel>> ambilSemuaPesanan() async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
        'pesanan',
        orderBy: 'tanggal DESC',
      );
      return maps.map(PesananModel.fromSqlite).toList();
    } catch (e, s) {
      L.e('Gagal mengambil semua pesanan Error: $e $s');
      rethrow;
    }
  }

  Future<List<PesananModel>> ambilPesananByStatus(String status) async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final maps = await operasiSqlite.ambil(
        'pesanan',
        where: 'status = ?',
        whereArgs: [status],
        orderBy: 'tanggal DESC',
      );
      return maps.map(PesananModel.fromSqlite).toList();
    } catch (e, s) {
      L.e('Gagal mengambil pesanan by status Error: $e $s');
      rethrow;
    }
  }

  Future<void> updateStatusPesanan(String id, String status) async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      await operasiSqlite.perbarui('pesanan', {'status': status}, id);
      await muatUlang();
    } catch (e, s) {
      L.e('Gagal update status pesanan Error: $e $s');
      rethrow;
    }
  }

  Future<void> hapusPesanan(String id) async {
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      await operasiSqlite.hapus('pesanan', id: id);
      await muatUlang();
    } catch (e, s) {
      L.e('Gagal hapus pesanan Error: $e $s');
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<PesananModel> items) async {
    if (items.isEmpty) return;
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final data = items.map((i) => i.toSqlite()).toList();
      await operasiSqlite.sisipkanAtauPerbaruiBatch('pesanan', data);
      await muatUlang();
    } catch (e, s) {
      L.e('Gagal sisipkanAtauPerbaruiBatch pesanan Error: $e $s');
      rethrow;
    }
  }

  Future<List<PesananModel>> getPesananByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final operasiSqlite = ref.read(operasiSqliteProvider);
      final placeholders = List.filled(ids.length, '?').join(',');
      final maps = await operasiSqlite.ambil(
        'pesanan',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      return maps.map(PesananModel.fromSqlite).toList();
    } catch (e, s) {
      L.e('Gagal getPesananByIds Error: $e $s');
      rethrow;
    }
  }
}

/// Kontainer global
final ProviderContainer _pesananGlobalContainer = ProviderContainer();

PesananNotifier get pesananNotifierGlobal =>
    _pesananGlobalContainer.read(pesananProvider.notifier);
