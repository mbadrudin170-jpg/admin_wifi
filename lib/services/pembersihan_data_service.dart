// path: lib/services/pembersihan_data_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_wifi/data/operasi/pembersihan_data_operasi.dart';

class PembersihanDataService {
  static const String _keyLastCleanup = 'last_cleanup_timestamp';

  final PembersihanDataOperasi _operasi = PembersihanDataOperasi();

  /// Lock sederhana untuk mencegah eksekusi ganda
  static bool _sedangBerjalan = false;

  Future<void> jalankanJikaPerlu() async {
    // 🚫 Cegah double eksekusi
    if (_sedangBerjalan) return;
    _sedangBerjalan = true;

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
          return;
        }
      }

      // ✅ Simpan dulu timestamp (anti loop kalau crash)
      await prefs.setInt(_keyLastCleanup, now.millisecondsSinceEpoch);

      // ✅ Jalankan pembersihan
      final totalTerhapus = await _operasi.hapusSemuaDataArsipKadaluarsa();

      print('Pembersihan data dijalankan. Total terhapus: $totalTerhapus');
    } catch (e) {
      print('Error saat pembersihan data: $e');
    } finally {
      _sedangBerjalan = false;
    }
  }
}
