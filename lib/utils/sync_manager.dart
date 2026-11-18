// path: lib/utils/sync_manager.dart
import 'package:admin_wifi/data/services/preferensi_service.dart';
import 'package:share_global_saya/src/utils/l.dart';

class SyncManager {
  Future<DateTime> getTerakhirUnduh() async {
    L.i('Meminta timestamp terakhir unduh dari PreferensiService');
    final result = await PreferensiService.getTerakhirUnduh();
    // diubah: jika null, kembalikan Epoch 0 sebagai default
    final a = result ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    L.i('Timestamp terakhir unduh yang digunakan: $a');
    return a;
  }

  Future<void> setTerakhirUnduh(DateTime time) async {
    L.i('Menyimpan timestamp terakhir unduh: $time');
    await PreferensiService.setTerakhirUnduh(time);
    L.i('Timestamp terakhir unduh berhasil disimpan');
  }

  Future<DateTime> getTerakhirUnggah() async {
    L.i('Meminta timestamp terakhir unggah dari PreferensiService');
    final result = await PreferensiService.getTerakhirUnggah();
    // diubah: jika null, kembalikan Epoch 0 sebagai default
    final a = result ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    L.i('Timestamp terakhir unggah yang digunakan: $a');
    return a;
  }

  Future<void> setTerakhirUnggah(DateTime time) async {
    L.i('Menyimpan timestamp terakhir unggah: $time');
    await PreferensiService.setTerakhirUnggah(time);
    L.i('Timestamp terakhir unggah berhasil disimpan');
  }
}
