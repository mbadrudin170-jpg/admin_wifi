// path: lib/fitur/pelanggan_aktif/notifer/pengguna_aktif_notifier.dart

import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/state/pelanggan_aktif_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';

part 'pengguna_aktif_notifier.g.dart';

@Riverpod(keepAlive: true)
class PenggunaAktifNotifier extends _$PenggunaAktifNotifier {
  final PelangganAktifOperasi _operasi = PelangganAktifOperasi();

  @override
  Future<PelangganAktifState> build() async {
    L.i('Memuat daftar pelanggan aktif dari database');
    return _ambilSemua();
  }

  Future<void> muatUlang() async {
    try {
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal memuat ulang pelanggan aktif: $e\n$s');
      rethrow;
    }
  }

  Future<PelangganAktifState> _ambilSemua() async {
    final daftar = await _operasi.ambilSemuaPelangganAktif();
    return PelangganAktifState(
      listPelangganAktif: daftar,
      jumlahPelangganAktif: daftar.length,
    );
  }

  Future<PelangganAktifModel> tambah(PelangganAktifModel model) async {
    try {
      final hasil = await _operasi.createPelangganAktif(model);
      state = AsyncValue.data(await _ambilSemua());
      return hasil;
    } catch (e, s) {
      L.e('Gagal menambahkan pelanggan aktif: $e\n$s');
      rethrow;
    }
  }

  Future<void> tambahBatch(List<PelangganAktifModel> models) async {
    try {
      await _operasi.sisipkanAtauPerbaruiBatch(models);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menambahkan batch pelanggan aktif: $e\n$s');
      rethrow;
    }
  }

  Future<PelangganAktifModel> ubah(PelangganAktifModel model) async {
    try {
      final hasil = await _operasi.updatePelangganAktif(model);
      state = AsyncValue.data(await _ambilSemua());
      return hasil;
    } catch (e, s) {
      L.e('Gagal mengubah pelanggan aktif: $e\n$s');
      rethrow;
    }
  }

  Future<void> hapus(String id) async {
    try {
      await _operasi.arsipkanPelangganAktif(id);
      state = AsyncValue.data(await _ambilSemua());
    } catch (e, s) {
      L.e('Gagal menghapus pelanggan aktif: $e\n$s');
      rethrow;
    }
  }
}
