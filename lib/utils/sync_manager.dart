// path: lib/utils/sync_manager.dart
import 'dart:developer' as developer;
import 'package:admin_wifi/data/services/preferensi_service.dart';

/// Kelas SyncManager sekarang bertindak sebagai fasad (facade) sederhana
/// yang mendelegasikan semua panggilan ke PreferensiService.
/// Perubahan ini memusatkan logika SharedPreferences di satu tempat (PreferensiService)
/// dan membuat SyncManager lebih bersih dan fokus pada tugasnya sebagai "penjaga" timestamp sinkronisasi.
class SyncManager {
  // --- LOGIKA TERAKHIR UNDUH ---

  // diubah: Mendelegasikan pemanggilan ke PreferensiService
  Future<DateTime> getTerakhirUnduh() async {
    developer.log(
      'Meminta timestamp terakhir unduh dari PreferensiService',
      name: 'SyncManager-getTerakhirUnduh 🔄',
    );

    final result = await PreferensiService.getTerakhirUnduh();

    developer.log(
      'Timestamp terakhir unduh berhasil diambil: $result',
      name: 'SyncManager-getTerakhirUnduh ✅',
    );

    return result;
  }

  // diubah: Mendelegasikan pemanggilan ke PreferensiService
  Future<void> setTerakhirUnduh(DateTime time) async {
    developer.log(
      'Menyimpan timestamp terakhir unduh: $time',
      name: 'SyncManager-setTerakhirUnduh ℹ️',
    );

    await PreferensiService.setTerakhirUnduh(time);

    developer.log(
      'Timestamp terakhir unduh berhasil disimpan',
      name: 'SyncManager-setTerakhirUnduh ✅',
    );
  }

  // --- LOGIKA TERAKHIR UNGGAH ---

  // diubah: Mendelegasikan pemanggilan ke PreferensiService
  Future<DateTime> getTerakhirUnggah() async {
    developer.log(
      'Meminta timestamp terakhir unggah dari PreferensiService',
      name: 'SyncManager-getTerakhirUnggah 🔄',
    );

    final result = await PreferensiService.getTerakhirUnggah();

    developer.log(
      'Timestamp terakhir unggah berhasil diambil: $result',
      name: 'SyncManager-getTerakhirUnggah ✅',
    );

    return result;
  }

  // diubah: Mendelegasikan pemanggilan ke PreferensiService
  Future<void> setTerakhirUnggah(DateTime time) async {
    developer.log(
      'Menyimpan timestamp terakhir unggah: $time',
      name: 'SyncManager-setTerakhirUnggah ℹ️',
    );

    await PreferensiService.setTerakhirUnggah(time);

    developer.log(
      'Timestamp terakhir unggah berhasil disimpan',
      name: 'SyncManager-setTerakhirUnggah ✅',
    );
  }

  // dihapus: Metode helper privat (_getTimestamp, _setTimestamp) dan semua referensi
  // ke SharedPreferences telah dihapus karena logikanya sekarang terpusat di PreferensiService.
}
