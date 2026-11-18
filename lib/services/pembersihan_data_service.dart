// path: lib/services/pembersihan_data_service.dart

import 'package:admin_wifi/data/operasi/pembersihan_data_operasi.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ditambahkan: Import untuk mengakses operasi dan model pengaturan.
import 'package:admin_wifi/data/operasi/pengaturan_operasi.dart';
import 'package:admin_wifi/fitur/pengaturan/model/pengaturan_model.dart';

class PembersihanDataService {
  static const String _keyLastCleanup = 'last_cleanup_timestamp';

  final PembersihanDataOperasi _operasi = PembersihanDataOperasi();
  // ditambahkan: Instance untuk operasi pengaturan.
  final PengaturanOperasi _pengaturanOperasi = PengaturanOperasi();

  /// Lock sederhana untuk mencegah eksekusi ganda
  static bool _sedangBerjalan = false;

  Future<void> jalankanJikaPerlu() async {
    L.i('Memicu fungsi pengecekan rutin pembersihan data...');

    // 🚫 Cegah double eksekusi
    if (_sedangBerjalan) {
      L.w(
        'Operasi ditolak karena ada proses pembersihan yang masih berjalan di latar belakang.',
      );
      return;
    }

    _sedangBerjalan = true;
    L.i('Lock diaktifkan. Memulai evaluasi waktu pembersihan terakhir.');

    try {
      L.i(
        'Mengakses SharedPreferences untuk mengambil timestamp pembersihan terakhir...',
      );
      final prefs = await SharedPreferences.getInstance();

      final now = DateTime.now();
      final lastCleanupMillis = prefs.getInt(_keyLastCleanup);

      if (lastCleanupMillis != null) {
        final lastCleanup = DateTime.fromMillisecondsSinceEpoch(
          lastCleanupMillis,
        );

        final selisih = now.difference(lastCleanup);
        L.i(
          'Terakhir dibersihkan pada $lastCleanup (Selisih: ${selisih.inHours} jam).',
        );

        // 🚫 Kalau belum 24 jam → stop
        if (selisih < const Duration(hours: 24)) {
          L.i('Pembersihan data dilewati. Belum mencapai batas siklus 24 jam.');
          return;
        }
      } else {
        L.i(
          'Data pembersihan terakhir tidak ditemukan. Ini kemungkinan eksekusi pertama kali.',
        );
      }

      L.i(
        'Kondisi terpenuhi. Memulai proses pembersihan data arsip kadaluarsa...',
      );

      // ditambahkan: Mengambil pengaturan untuk mendapatkan batas hari dinamis.
      L.i('Mengambil konfigurasi "Hapus Otomatis" dari tabel pengaturan...');
      final PengaturanModel pengaturan = await _pengaturanOperasi
          .getPengaturan();
      final int batasHari = pengaturan.hapusOtomatisDataArsip;

      L.i(
        'Konfigurasi aktif ditemukan. Batas retensi arsip adalah: $batasHari hari.',
      );

      // ✅ Simpan dulu timestamp (anti loop kalau crash)
      L.i('Memperbarui timestamp pembersihan terakhir ke sistem storage.');
      await prefs.setInt(_keyLastCleanup, now.millisecondsSinceEpoch);

      // diubah: Memanggil fungsi dengan parameter 'batasHari' dari pengaturan.
      L.i('Menjalankan query penghapusan data masal pada DB...');
      final totalTerhapus = await _operasi.hapusSemuaDataArsipKadaluarsa(
        batasHari: batasHari,
      );

      if (totalTerhapus > 0) {
        L.i(
          'Pembersihan data selesai dengan sukses. Total item yang dihapus: $totalTerhapus data.',
        );
      } else {
        L.i(
          'Proses selesai. Tidak ada data yang kadaluarsa untuk dihapus pada siklus ini.',
        );
      }
    } catch (e, s) {
      L.e(
        'Terjadi error fatal saat mencoba membersihkan data otomatis! Error: $e $s',
      );
    } finally {
      _sedangBerjalan = false;
      L.i('Lock dilepaskan. Servis kembali ke status standby.');
    }
  }
}
