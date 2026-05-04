// lib/utils/sync_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class SyncManager {
  static const _kLastSyncTimestampKey = 'last_sync_timestamp';

  Future<DateTime> getLastSyncTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_kLastSyncTimestampKey);
      // Jika belum pernah sinkronisasi, gunakan waktu yang sangat lampau
      // agar semua data terambil saat pertama kali.
      if (timestamp == null || timestamp == 0) {
        return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      }
      return DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
    } catch (e, s) {
      // Log error atau fallback
      developer.log(
        'Error getting last sync timestamp',
        name: 'SyncManager.getLastSync',
        error: e,
        stackTrace: s,
      );
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
  }

  Future<void> setLastSyncTimestamp(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _kLastSyncTimestampKey,
      time.toUtc().millisecondsSinceEpoch,
    );
  }
}
