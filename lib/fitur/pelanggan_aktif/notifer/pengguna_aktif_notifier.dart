// path: lib/fitur/pelanggan_aktif/notifer/pengguna_aktif_notifier.dart

import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/fitur/state/pelanggan_aktif_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pengguna_aktif_notifier.g.dart';

@Riverpod(keepAlive: true)
class PenggunaAktifNotifier extends _$PenggunaAktifNotifier {
  final PelangganAktifOperasi _operasi = PelangganAktifOperasi();

  @override
  Future<PelangganAktifState> build() async {
    Log.info('Memuat daftar pelanggan aktif dari database');
    return _ambilSemua();
  }

  Future<void> muatUlang() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_ambilSemua);
  }

  Future<PelangganAktifState> _ambilSemua() async {
    final daftar = await _operasi.ambilSemuaPelangganAktif();
    return PelangganAktifState(
      listPelangganAktif: daftar,
      jumlahPelangganAktif: daftar.length,
    );
  }
}
