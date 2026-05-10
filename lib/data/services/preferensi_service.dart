// path: lib/data/services/preferensi_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

/// Note : untuk tema gelap nanti kita aktifkan lagi kalau semuanya sudah fix
// Menggunakan SharedPreferencesAsync untuk konsistensi dengan pola async/await di seluruh aplikasi.
// Ini adalah kelas wrapper yang menyediakan akses aman dan terpusat ke SharedPreferences.
class PreferensiService {
  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  // --- PRIVATE KEYS ---
  // Menggunakan konstanta privat untuk menghindari kesalahan ketik di bagian lain aplikasi.
  // static const String _keyTemaGelap = 'tema_gelap';
  static const String _keyTerakhirUnduh = 'terakhir_unduh';
  static const String _keyTerakhirUnggah = 'terakhir_unggah';

  // --- PENGATURAN TEMA ---

  /// Menyimpan preferensi mode gelap.
  // static Future<void> simpanTemaGelap(bool nilai) async {
  //   try {
  //     await _prefs.setBool(_keyTemaGelap, nilai);
  //     developer.log('[PreferensiService] ☀️/🌙: Mode gelap disimpan ke: $nilai');
  //   } catch (e, s) {
  //     developer.log(
  //       '[PreferensiService] ❌: Gagal menyimpan mode gelap',
  //       error: e,
  //       stackTrace: s,
  //     );
  //   }
  // }

  // /// Mengambil preferensi mode gelap. Defaultnya adalah false (mode terang).
  // static Future<bool> ambilTemaGelap() async {
  //   try {
  //     final bool? temaGelap = await _prefs.getBool(_keyTemaGelap);
  //     developer.log('[PreferensiService] ☀️/🌙: Mode gelap diambil: ${temaGelap ?? false}');
  //     return temaGelap ?? false;
  //   } catch (e, s) {
  //     developer.log(
  //       '[PreferensiService] ❌: Gagal mengambil mode gelap, mengembalikan default (false).',
  //       error: e,
  //       stackTrace: s,
  //     );
  //     return false; // Mengembalikan nilai default jika terjadi kesalahan
  //   }
  // }

  // --- SINKRONISASI TIMESTAMP ---

  /// Mengambil timestamp terakhir kali data diunduh dari server.
  /// Mengembalikan DateTime Epoch (1970) jika tidak ada data.
  static Future<DateTime> getTerakhirUnduh() async {
    developer.log(
      'Mengambil timestamp terakhir unduh dengan key: $_keyTerakhirUnduh',
      name: 'PreferensiService-getTerakhirUnduh ℹ️',
    );

    final result = await _getTimestamp(_keyTerakhirUnduh, 'Unduh');

    developer.log(
      'Timestamp terakhir unduh berhasil diambil: $result',
      name: 'PreferensiService-getTerakhirUnduh ✅',
    );

    return result;
  }

  /// Menyimpan timestamp terakhir kali data diunduh dari server.
  static Future<void> setTerakhirUnduh(DateTime waktu) async {
    developer.log(
      'Menyimpan timestamp terakhir unduh: $waktu dengan key: $_keyTerakhirUnduh',
      name: 'PreferensiService-setTerakhirUnduh ℹ️',
    );

    await _setTimestamp(_keyTerakhirUnduh, waktu, 'Unduh');

    developer.log(
      'Timestamp terakhir unduh berhasil disimpan',
      name: 'PreferensiService-setTerakhirUnduh ✅',
    );
  }

  /// Mengambil timestamp terakhir kali data diunggah ke server.
  /// Mengembalikan DateTime Epoch (1970) jika tidak ada data.
  static Future<DateTime> getTerakhirUnggah() async {
    developer.log(
      'Mengambil timestamp terakhir unggah dengan key: $_keyTerakhirUnggah',
      name: 'PreferensiService-getTerakhirUnggah ℹ️',
    );

    final result = await _getTimestamp(_keyTerakhirUnggah, 'Unggah');

    developer.log(
      'Timestamp terakhir unggah berhasil diambil: $result',
      name: 'PreferensiService-getTerakhirUnggah ✅',
    );

    return result;
  }

  /// Menyimpan timestamp terakhir kali data diunggah ke server.
  static Future<void> setTerakhirUnggah(DateTime waktu) async {
    developer.log(
      'Menyimpan timestamp terakhir unggah: $waktu dengan key: $_keyTerakhirUnggah',
      name: 'PreferensiService-setTerakhirUnggah ℹ️',
    );

    await _setTimestamp(_keyTerakhirUnggah, waktu, 'Unggah');

    developer.log(
      'Timestamp terakhir unggah berhasil disimpan',
      name: 'PreferensiService-setTerakhirUnggah ✅',
    );
  }

  // --- PRIVATE HELPER METHODS ---

  /// Metode pembantu generik untuk mengambil nilai timestamp.
  static Future<DateTime> _getTimestamp(String key, String label) async {
    developer.log(
      'Membaca timestamp $label dari SharedPreferences | Key: $key',
      name: 'PreferensiService-_getTimestamp 📝',
    );

    try {
      final timestamp = await _prefs.getInt(key);

      if (timestamp == null || timestamp == 0) {
        developer.log(
          'Timestamp $label kosong atau null. Mengembalikan Epoch 0.',
          name: 'PreferensiService-_getTimestamp ⚠️',
        );

        developer.log(
          '[PreferensiService] ⚠️: Timestamp $label kosong. Mengembalikan Epoch 0.',
        );
        return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      }

      final date = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);

      developer.log(
        'Timestamp $label berhasil dibaca: $date | Raw value: $timestamp milliseconds',
        name: 'PreferensiService-_getTimestamp ✅',
      );

      developer.log(
        '[PreferensiService] ✅: Berhasil ambil timestamp $label: $date',
      );
      return date;
    } catch (e, s) {
      developer.log(
        '[PreferensiService] ❌: Gagal ambil timestamp $label, mengembalikan Epoch 0.',
        error: e,
        stackTrace: s,
      );

      developer.log(
        'Error saat membaca timestamp $label: $e | Key: $key',
        name: 'PreferensiService-_getTimestamp ❌',
        error: e,
        stackTrace: s,
      );

      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
  }

  /// Metode pembantu generik untuk menyimpan nilai timestamp.
  static Future<void> _setTimestamp(
    String key,
    DateTime time,
    String label,
  ) async {
    developer.log(
      'Menyimpan timestamp $label ke SharedPreferences | Value: $time | Key: $key',
      name: 'PreferensiService-_setTimestamp 📝',
    );

    try {
      final int millis = time.toUtc().millisecondsSinceEpoch;

      developer.log(
        'Konversi DateTime ke milliseconds: $millis (UTC)',
        name: 'PreferensiService-_setTimestamp 🔄',
      );

      await _prefs.setInt(key, millis);

      developer.log(
        '[PreferensiService] ✨: Timestamp $label diperbarui ke: $time (UTC)',
      );

      developer.log(
        'Timestamp $label berhasil disimpan | Milliseconds: $millis | UTC: $time',
        name: 'PreferensiService-_setTimestamp ✅',
      );
    } catch (e, s) {
      developer.log(
        '[PreferensiService] ❌: Gagal simpan timestamp $label',
        error: e,
        stackTrace: s,
      );

      developer.log(
        'Error saat menyimpan timestamp $label: $e | Key: $key | Value: $time',
        name: 'PreferensiService-_setTimestamp ❌',
        error: e,
        stackTrace: s,
      );
    }
  }
}
