// path: lib/data/services/sinkronisasi_database.dart
// diubah: Memindahkan logika unduh data ke file terpisah (LayananUnduhData).
import 'package:admin_wifi/data/sync/unduh_data.dart';
import 'package:admin_wifi/data/sync/unggah_data.dart';
import 'package:admin_wifi/utils/sync_manager.dart';

class LayananSinkronisasi {
  final SyncManager _syncManager = SyncManager();
  final LayananUnduhData _unduhData = LayananUnduhData();
  final LayananUnggahData _unggahData = LayananUnggahData();

  Future<DateTime> dapatkanWaktuSinkronisasiTerakhir() async {
    return await _syncManager.getLastSyncTimestamp();
  }

  Future<void> sinkronisasiData() async {
    final waktuSinkronisasiTerakhir = await dapatkanWaktuSinkronisasiTerakhir();

    if (waktuSinkronisasiTerakhir.millisecondsSinceEpoch == 0) {
      await _unggahData.unggahSemuaData();
      await _unduhData.unduhSemuaData();
      await SyncManager().setLastSyncTimestamp(DateTime.now());
    } else {
      // Implement incremental sync logic here
    }
  }
}
