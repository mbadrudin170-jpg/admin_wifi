// path: lib/fitur/paket/notifier/paket_notifier.dart

import 'package:admin_wifi/data/operasi/paket_operasi.dart';
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
    final daftar = await _operasi.getPaket();
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
      await _operasi.sisipkanAtauPerbaruiBatch(models);
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
