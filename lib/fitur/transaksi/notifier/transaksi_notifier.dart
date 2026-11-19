// path: lib/fitur/transaksi/notifier/transaksi_notifier.dart

import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/db/sqlite/operasi_sqlite.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/transaksi/state/transaksi_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';

part 'transaksi_notifier.g.dart';

@Riverpod(keepAlive: true)
class TransaksiNotifier extends _$TransaksiNotifier {
  final TransaksiOperasi _operasi = TransaksiOperasi();

  @override
  Future<TransaksiState> build() async {
    L.i('Memuat daftar transaksi dari database');
    return _ambilSemua();
  }

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

  /// Menghitung saldo poin akhir [idPelanggan].
  Future<int> hitungTotalPoin(String idPelanggan) async {
    return _operasi.getTotalPoin(idPelanggan);
  }

  Future<void> tambah(TransaksiModel model) async {
    try {
      await _operasi.tambahTransaksi(model);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menambahkan transaksi: $e\n$s');
      rethrow;
    }
  }

  Future<void> ubah(TransaksiModel model) async {
    try {
      await _operasi.updateTransaksi(model.id, model);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal mengubah transaksi: $e\n$s');
      rethrow;
    }
  }
}
