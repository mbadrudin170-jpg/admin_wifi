// path: lib/data/services/preferensi_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

// Menggunakan SharedPreferencesAsync untuk konsistensi dengan pola async/await di seluruh aplikasi.
// Ini adalah kelas wrapper yang menyediakan akses aman dan terpusat ke SharedPreferences.
class PreferensiService {
  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  // --- PRIVATE KEYS ---
  // Menggunakan konstanta privat untuk menghindari kesalahan ketik di bagian lain aplikasi.
  static const String _keyTemaGelap = 'tema_gelap';
  static const String _keyTerakhirUnduh = 'terakhir_unduh';
  static const String _keyTerakhirUnggah = 'terakhir_unggah';

  // --- PENGATURAN TEMA ---

  /// Menyimpan preferensi mode gelap.
  static Future<void> simpanTemaGelap(bool nilai) async {
    try {
      await _prefs.setBool(_keyTemaGelap, nilai);
      developer.log('[PreferensiService] ☀️/🌙: Mode gelap disimpan ke: $nilai');
    } catch (e, s) {
      developer.log(
        '[PreferensiService] ❌: Gagal menyimpan mode gelap',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Mengambil preferensi mode gelap. Defaultnya adalah false (mode terang).
  static Future<bool> ambilTemaGelap() async {
    try {
      final bool? temaGelap = await _prefs.getBool(_keyTemaGelap);
      developer.log('[PreferensiService] ☀️/🌙: Mode gelap diambil: ${temaGelap ?? false}');
      return temaGelap ?? false;
    } catch (e, s) {
      developer.log(
        '[PreferensiService] ❌: Gagal mengambil mode gelap, mengembalikan default (false).',
        error: e,
        stackTrace: s,
      );
      return false; // Mengembalikan nilai default jika terjadi kesalahan
    }
  }

  // --- SINKRONISASI TIMESTAMP ---

  /// Mengambil timestamp terakhir kali data diunduh dari server.
  /// Mengembalikan DateTime Epoch (1970) jika tidak ada data.
  static Future<DateTime> getTerakhirUnduh() async {
    return _getTimestamp(_keyTerakhirUnduh, 'Unduh');
  }

  /// Menyimpan timestamp terakhir kali data diunduh dari server.
  static Future<void> setTerakhirUnduh(DateTime waktu) async {
    await _setTimestamp(_keyTerakhirUnduh, waktu, 'Unduh');
  }

  /// Mengambil timestamp terakhir kali data diunggah ke server.
  /// Mengembalikan DateTime Epoch (1970) jika tidak ada data.
  static Future<DateTime> getTerakhirUnggah() async {
    return _getTimestamp(_keyTerakhirUnggah, 'Unggah');
  }

  /// Menyimpan timestamp terakhir kali data diunggah ke server.
  static Future<void> setTerakhirUnggah(DateTime waktu) async {
    await _setTimestamp(_keyTerakhirUnggah, waktu, 'Unggah');
  }

  // --- PRIVATE HELPER METHODS ---

  /// Metode pembantu generik untuk mengambil nilai timestamp.
  static Future<DateTime> _getTimestamp(String key, String label) async {
    try {
      final timestamp = await _prefs.getInt(key);
      if (timestamp == null || timestamp == 0) {
        developer.log('[PreferensiService] ⚠️: Timestamp $label kosong. Mengembalikan Epoch 0.');
        return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      }
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
      developer.log('[PreferensiService] ✅: Berhasil ambil timestamp $label: $date');
      return date;
    } catch (e, s) {
      developer.log(
        '[PreferensiService] ❌: Gagal ambil timestamp $label, mengembalikan Epoch 0.',
        error: e,
        stackTrace: s,
      );
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
  }

  /// Metode pembantu generik untuk menyimpan nilai timestamp.
  static Future<void> _setTimestamp(String key, DateTime time, String label) async {
    try {
      final int millis = time.toUtc().millisecondsSinceEpoch;
      await _prefs.setInt(key, millis);
      developer.log('[PreferensiService] ✨: Timestamp $label diperbarui ke: $time (UTC)');
    } catch (e, s) {
      developer.log(
        '[PreferensiService] ❌: Gagal simpan timestamp $label',
        error: e,
        stackTrace: s,
      );
    }
  }
}
