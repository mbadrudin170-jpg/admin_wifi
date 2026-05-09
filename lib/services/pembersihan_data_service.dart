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
    developer.log(
      '[PembersihanDataService]-[jalankanJikaPerlu] 🚀 : Memicu fungsi pengecekan rutin pembersihan data...',
    );

    // 🚫 Cegah double eksekusi
    if (_sedangBerjalan) {
      developer.log(
        '[PembersihanDataService]-[jalankanJikaPerlu] 🛑 : Operasi ditolak karena ada proses pembersihan yang masih berjalan di latar belakang.',
        name: 'PembersihanDataService',
      );
      return;
    }

    _sedangBerjalan = true;
    developer.log(
      '[PembersihanDataService]-[jalankanJikaPerlu] 🔒 : Lock diaktifkan. Memulai evaluasi waktu pembersihan terakhir.',
      name: 'PembersihanDataService',
    );

    try {
      developer.log(
        '[PembersihanDataService]-[jalankanJikaPerlu] 📡 : Mengakses SharedPreferences untuk mengambil timestamp pembersihan terakhir...',
      );
      final prefs = await SharedPreferences.getInstance();

      final now = DateTime.now();
      final lastCleanupMillis = prefs.getInt(_keyLastCleanup);

      if (lastCleanupMillis != null) {
        final lastCleanup = DateTime.fromMillisecondsSinceEpoch(
          lastCleanupMillis,
        );

        final selisih = now.difference(lastCleanup);
        developer.log(
          '[PembersihanDataService]-[jalankanJikaPerlu] ⏳ : Terakhir dibersihkan pada $lastCleanup (Selisih: ${selisih.inHours} jam).',
        );

        // 🚫 Kalau belum 24 jam → stop
        if (selisih < const Duration(hours: 24)) {
          developer.log(
            '[PembersihanDataService]-[jalankanJikaPerlu] ⏭️ : Pembersihan data dilewati. Belum mencapai batas siklus 24 jam.',
            name: 'PembersihanDataService',
          );
          return;
        }
      } else {
        developer.log(
          '[PembersihanDataService]-[jalankanJikaPerlu] 🆕 : Data pembersihan terakhir tidak ditemukan. Ini kemungkinan eksekusi pertama kali.',
        );
      }

      developer.log(
        '[PembersihanDataService]-[jalankanJikaPerlu] 🛠️ : Kondisi terpenuhi. Memulai proses pembersihan data arsip kadaluarsa...',
        name: 'PembersihanDataService',
      );

      // ditambahkan: Mengambil pengaturan untuk mendapatkan batas hari dinamis.
      developer.log(
        '[PembersihanDataService]-[jalankanJikaPerlu] 🔍 : Mengambil konfigurasi "Hapus Otomatis" dari tabel pengaturan...',
      );
      final PengaturanModel pengaturan = await _pengaturanOperasi
          .getPengaturan();
      final int batasHari = pengaturan.hapusOtomatisDataArsip;

      developer.log(
        '[PembersihanDataService]-[jalankanJikaPerlu] 📅 : Konfigurasi aktif ditemukan. Batas retensi arsip adalah: $batasHari hari.',
        name: 'PembersihanDataService',
      );

      // ✅ Simpan dulu timestamp (anti loop kalau crash)
      developer.log(
        '[PembersihanDataService]-[jalankanJikaPerlu] 💾 : Memperbarui timestamp pembersihan terakhir ke sistem storage.',
      );
      await prefs.setInt(_keyLastCleanup, now.millisecondsSinceEpoch);

      // diubah: Memanggil fungsi dengan parameter 'batasHari' dari pengaturan.
      developer.log(
        '[PembersihanDataService]-[jalankanJikaPerlu] 🧨 : Menjalankan query penghapusan data masal pada DB...',
      );
      final totalTerhapus = await _operasi.hapusSemuaDataArsipKadaluarsa(
        batasHari: batasHari,
      );

      if (totalTerhapus > 0) {
        developer.log(
          '[PembersihanDataService]-[jalankanJikaPerlu] ✨ : Pembersihan data selesai dengan sukses. Total item yang dihapus: $totalTerhapus data.',
          name: 'PembersihanDataService',
        );
      } else {
        developer.log(
          '[PembersihanDataService]-[jalankanJikaPerlu] 📥 : Proses selesai. Tidak ada data yang kadaluarsa untuk dihapus pada siklus ini.',
          name: 'PembersihanDataService',
        );
      }
    } catch (e, s) {
      developer.log(
        '[PembersihanDataService]-[jalankanJikaPerlu] ❌ : Terjadi error fatal saat mencoba membersihkan data otomatis!',
        error: e,
        stackTrace: s,
        name: 'PembersihanDataService.Error',
      );
    } finally {
      _sedangBerjalan = false;
      developer.log(
        '[PembersihanDataService]-[jalankanJikaPerlu] 🔓 : Lock dilepaskan. Servis kembali ke status standby.',
      );
    }
  }
}