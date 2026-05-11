import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_wifi/debug/log.dart'; // Path import diperbarui

class PreferensiService {
  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static const String _keyTerakhirUnduh = 'terakhir_unduh';
  static const String _keyTerakhirUnggah = 'terakhir_unggah';

  static Future<DateTime> getTerakhirUnduh() async {
    Log.info(
      'Mengambil timestamp terakhir unduh dengan key: $_keyTerakhirUnduh',
    );
    final result = await _getTimestamp(_keyTerakhirUnduh, 'Unduh');
    Log.info('Timestamp terakhir unduh berhasil diambil: $result');
    return result;
  }

  static Future<void> setTerakhirUnduh(DateTime waktu) async {
    Log.info(
      'Menyiapkan penyimpanan timestamp terakhir unduh: $waktu $_keyTerakhirUnduh',
    );
    await _setTimestamp(_keyTerakhirUnduh, waktu, 'Unduh');
    Log.info('Timestamp terakhir unduh berhasil disimpan');
  }

  static Future<DateTime> getTerakhirUnggah() async {
    Log.info(
      'Mengambil timestamp terakhir unggah dengan key: $_keyTerakhirUnggah',
    );
    final result = await _getTimestamp(_keyTerakhirUnggah, 'Unggah');
    Log.info('Timestamp terakhir unggah berhasil diambil: $result');
    return result;
  }

  static Future<void> setTerakhirUnggah(DateTime waktu) async {
    Log.info(
      'Menyiapkan penyimpanan timestamp terakhir unggah: $waktu $_keyTerakhirUnggah',
    );
    await _setTimestamp(_keyTerakhirUnggah, waktu, 'Unggah');
    Log.info('Timestamp terakhir unggah berhasil disimpan');
  }

  static Future<DateTime> _getTimestamp(String key, String label) async {
    Log.info('Membaca timestamp $label dari SharedPreferences | Key: $key');
    try {
      final timestamp = await _prefs.getInt(key);
      if (timestamp == null || timestamp == 0) {
        Log.warning(
          'Timestamp $label kosong. Mengembalikan Epoch 0. Key: $key',
        );
        return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      }
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
      Log.info('Timestamp $label berhasil dibaca: $date');
      return date;
    } catch (e, s) {
      Log.error(
        'Error saat membaca timestamp $label: $e',
        error: e,
        stackTrace: s,
      );
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
  }

  static Future<void> _setTimestamp(
    String key,
    DateTime time,
    String label,
  ) async {
    Log.info(
      'Menyimpan timestamp $label ke SharedPreferences | Value: $time | Key: $key',
    );
    try {
      final int millis = time.toUtc().millisecondsSinceEpoch;
      await _prefs.setInt(key, millis);
      Log.info('✨ Timestamp $label berhasil disimpan | UTC: $time');
    } catch (e, s) {
      Log.error(
        'Error saat menyimpan timestamp $label: $e',
        error: e,
        stackTrace: s,
      );
    }
  }
}
