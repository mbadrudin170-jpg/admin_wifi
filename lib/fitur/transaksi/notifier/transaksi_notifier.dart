// path: lib/fitur/transaksi/notifier/transaksi_notifier.dart

import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
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
    final daftar = await _operasi.ambilSemuaTransaksi();
    return TransaksiState(
      listTransaksi: daftar,
      jumlahTransaksi: daftar.length,
    );
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
