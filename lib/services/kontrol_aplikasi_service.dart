// path: lib/services/kontrol_aplikasi_service.dart
import 'package:share_global_saya/src/utils/l.dart';

// untuk mengontrol status aplikasi pengguna dari jarak jauh
class KontrolAplikasiService {
  // Firebase dihapus; status maintenance default false (offline).
  Future<bool> dapatkanStatusMaintenance() async {
    L.i('Firebase tidak tersedia; status maintenance default false.');
    return false;
  }

  Future<void> aturStatusMaintenance(bool status) async {
    L.i(
      'Firebase tidak tersedia; perubahan status maintenance diabaikan: $status',
    );
  }
}
