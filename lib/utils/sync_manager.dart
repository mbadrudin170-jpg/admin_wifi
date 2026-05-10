// path: lib/utils/sync_manager.dart
import 'package:admin_wifi/data/services/preferensi_service.dart';

/// Kelas SyncManager sekarang bertindak sebagai fasad (facade) sederhana
/// yang mendelegasikan semua panggilan ke PreferensiService.
/// Perubahan ini memusatkan logika SharedPreferences di satu tempat (PreferensiService)
/// dan membuat SyncManager lebih bersih dan fokus pada tugasnya sebagai "penjaga" timestamp sinkronisasi.
class SyncManager {
  // --- LOGIKA TERAKHIR UNDUH ---

  // diubah: Mendelegasikan pemanggilan ke PreferensiService
  Future<DateTime> getTerakhirUnduh() async {
    return PreferensiService.getTerakhirUnduh();
  }

  // diubah: Mendelegasikan pemanggilan ke PreferensiService
  Future<void> setTerakhirUnduh(DateTime time) async {
    await PreferensiService.setTerakhirUnduh(time);
  }

  // --- LOGIKA TERAKHIR UNGGAH ---

  // diubah: Mendelegasikan pemanggilan ke PreferensiService
  Future<DateTime> getTerakhirUnggah() async {
    return PreferensiService.getTerakhirUnggah();
  }

  // diubah: Mendelegasikan pemanggilan ke PreferensiService
  Future<void> setTerakhirUnggah(DateTime time) async {
    await PreferensiService.setTerakhirUnggah(time);
  }

  // dihapus: Metode helper privat (_getTimestamp, _setTimestamp) dan semua referensi
  // ke SharedPreferences telah dihapus karena logikanya sekarang terpusat di PreferensiService.
}
