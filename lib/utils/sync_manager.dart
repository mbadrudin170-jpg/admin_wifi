// lib/utils/sync_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class SyncManager {
  static const _kLastSyncTimestampKey = 'last_sync_timestamp';

  Future<DateTime> getLastSyncTimestamp() async {
    developer.log(
      '[SyncManager]-[getLastSyncTimestamp] 🔍 : Mencoba mengambil stempel waktu (timestamp) sinkronisasi terakhir...',
    );

    try {
      developer.log(
        '[SyncManager]-[getLastSyncTimestamp] 📡 : Membuka instance SharedPreferences...',
      );
      final prefs = await SharedPreferences.getInstance();
      
      final timestamp = prefs.getInt(_kLastSyncTimestampKey);
      
      // Jika belum pernah sinkronisasi, gunakan waktu yang sangat lampau
      // agar semua data terambil saat pertama kali.
      if (timestamp == null || timestamp == 0) {
        developer.log(
          '[SyncManager]-[getLastSyncTimestamp] ⚠️ : Timestamp tidak ditemukan atau bernilai 0. Mengembalikan nilai default (Epoch 0).',
        );
        return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      }

      final lastSync = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
      developer.log(
        '[SyncManager]-[getLastSyncTimestamp] ✅ : Berhasil mendapatkan timestamp terakhir: $lastSync',
      );
      return lastSync;
    } catch (e, s) {
      // Log error atau fallback
      developer.log(
        '[SyncManager]-[getLastSyncTimestamp] ❌ : Gagal mengambil stempel waktu sinkronisasi',
        name: 'SyncManager.getLastSync',
        error: e,
        stackTrace: s,
      );
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
  }

  Future<void> setLastSyncTimestamp(DateTime time) async {
    developer.log(
      '[SyncManager]-[setLastSyncTimestamp] 🚀 : Memulai penyimpanan timestamp baru: $time',
    );

    try {
      developer.log(
        '[SyncManager]-[setLastSyncTimestamp] 📡 : Menyiapkan penyimpanan data ke SharedPreferences...',
      );
      final prefs = await SharedPreferences.getInstance();
      
      final int millis = time.toUtc().millisecondsSinceEpoch;
      await prefs.setInt(
        _kLastSyncTimestampKey,
        millis,
      );

      developer.log(
        '[SyncManager]-[setLastSyncTimestamp] ✨ : Berhasil memperbarui timestamp sinkronisasi ke: $millis (UTC).',
      );
    } catch (e, s) {
      developer.log(
        '[SyncManager]-[setLastSyncTimestamp] ❌ : Gagal menyimpan stempel waktu sinkronisasi terbaru',
        error: e,
        stackTrace: s,
      );
    }
  }
}