// path: lib/services/pembersihan_data_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_wifi/data/operasi/pembersihan_data_operasi.dart';
// ditambahkan: Import untuk mengakses operasi dan model pengaturan.
import 'package:admin_wifi/data/operasi/pengaturan_operasi.dart';
import 'package:admin_wifi/model/pengaturan_model.dart';
import 'dart:developer' as developer;

class PembersihanDataService {
  static const String _keyLastCleanup = 'last_cleanup_timestamp';

  final PembersihanDataOperasi _operasi = PembersihanDataOperasi();
  // ditambahkan: Instance untuk operasi pengaturan.
  final PengaturanOperasi _pengaturanOperasi = PengaturanOperasi();

  /// Lock sederhana untuk mencegah eksekusi ganda
  static bool _sedangBerjalan = false;

  Future<void> jalankanJikaPerlu() async {
    // 🚫 Cegah double eksekusi
    if (_sedangBerjalan) {
      developer.log(
        'Pembersihan data sudah berjalan, skip eksekusi baru.',
        name: 'PembersihanDataService',
      );
      return;
    }
    _sedangBerjalan = true;
    developer.log(
      'Memulai pengecekan untuk pembersihan data.',
      name: 'PembersihanDataService',
    );

    try {
      final prefs = await SharedPreferences.getInstance();

      final now = DateTime.now();
      final lastCleanupMillis = prefs.getInt(_keyLastCleanup);

      if (lastCleanupMillis != null) {
        final lastCleanup = DateTime.fromMillisecondsSinceEpoch(
          lastCleanupMillis,
        );

        final selisih = now.difference(lastCleanup);

        // 🚫 Kalau belum 24 jam → stop
        if (selisih < const Duration(hours: 24)) {
          developer.log(
            'Pembersihan data tidak diperlukan, belum 24 jam.',
            name: 'PembersihanDataService',
          );
          return;
        }
      }

      developer.log(
        'Pembersihan data diperlukan, memulai proses...',
        name: 'PembersihanDataService',
      );

      // ditambahkan: Mengambil pengaturan untuk mendapatkan batas hari dinamis.
      final PengaturanModel pengaturan = await _pengaturanOperasi
          .getPengaturan();
      final int batasHari = pengaturan.hapusOtomatisDataArsip;

      developer.log(
        'Batas hari untuk penghapusan arsip: $batasHari hari.',
        name: 'PembersihanDataService',
      );

      // ✅ Simpan dulu timestamp (anti loop kalau crash)
      await prefs.setInt(_keyLastCleanup, now.millisecondsSinceEpoch);

      // diubah: Memanggil fungsi dengan parameter 'batasHari' dari pengaturan.
      final totalTerhapus = await _operasi.hapusSemuaDataArsipKadaluarsa(
        batasHari: batasHari,
      );

      if (totalTerhapus > 0) {
        developer.log(
          'Pembersihan data berhasil. Total terhapus: $totalTerhapus item.',
          name: 'PembersihanDataService',
        );
      } else {
        developer.log(
          'Pembersihan data dijalankan, tidak ada item kadaluarsa yang ditemukan.',
          name: 'PembersihanDataService',
        );
      }
    } catch (e, s) {
      developer.log(
        'Error saat pembersihan data',
        error: e,
        stackTrace: s,
        name: 'PembersihanDataService.Error',
      );
    } finally {
      _sedangBerjalan = false;
    }
  }
}
