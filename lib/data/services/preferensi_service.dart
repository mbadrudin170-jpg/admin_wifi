// path: lib/data/services/preferensi_service.dart
import 'package:share_global_saya/src/utils/l.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferensiService {
  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  static const String _keyTerakhirUnduh = 'terakhir_unduh';
  static const String _keyTerakhirUnggah = 'terakhir_unggah';

  static Future<DateTime?> getTerakhirUnduh() async {
    L.i('Mengambil timestamp terakhir unduh dengan key: $_keyTerakhirUnduh');
    final result = await _getTimestamp(_keyTerakhirUnduh, 'Unduh');
    L.i('Timestamp terakhir unduh: ${result ?? "null"}');
    return result;
  }

  static Future<void> setTerakhirUnduh(DateTime waktu) async {
    L.i(
      'Menyiapkan penyimpanan timestamp terakhir unduh: $waktu $_keyTerakhirUnduh',
    );
    await _setTimestamp(_keyTerakhirUnduh, waktu, 'Unduh');
    L.i('Timestamp terakhir unduh berhasil disimpan');
  }

  static Future<DateTime?> getTerakhirUnggah() async {
    L.i('Mengambil timestamp terakhir unggah dengan key: $_keyTerakhirUnggah');
    final result = await _getTimestamp(_keyTerakhirUnggah, 'Unggah');
    L.i('Timestamp terakhir unggah: ${result ?? "null"}');
    return result;
  }

  static Future<void> setTerakhirUnggah(DateTime waktu) async {
    L.i(
      'Menyiapkan penyimpanan timestamp terakhir unggah: $waktu $_keyTerakhirUnggah',
    );
    await _setTimestamp(_keyTerakhirUnggah, waktu, 'Unggah');
    L.i('Timestamp terakhir unggah berhasil disimpan');
  }

  static Future<DateTime?> _getTimestamp(String key, String label) async {
    L.i('Membaca timestamp $label dari SharedPreferences | Key: $key');
    final prefs = await _prefs;
    final timestamp = prefs.getInt(key);

    if (timestamp == null || timestamp == 0) {
      L.i('Timestamp $label kosong atau belum di-set. Mengembalikan null.');
      return null; // diubah: mengembalikan null jika tidak ada data
    }

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
    L.i('Timestamp $label berhasil dibaca: $date');
    return date;
  }

  static Future<void> _setTimestamp(
    String key,
    DateTime time,
    String label,
  ) async {
    L.i(
      'Menyimpan timestamp $label ke SharedPreferences | Value: $time | Key: $key',
    );
    try {
      final prefs = await _prefs;
      final int millis = time.toUtc().millisecondsSinceEpoch;
      await prefs.setInt(key, millis);
      L.i('✨ Timestamp $label berhasil disimpan | UTC: $time');
    } catch (e, s) {
      L.e('Error saat menyimpan timestamp $label: $e Error: $e $s');
    }
  }
}
