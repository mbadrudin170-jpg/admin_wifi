// path: lib/fitur/pengaturan/dummy/pengaturan_dummy.dart

import 'package:admin_wifi/fitur/pengaturan/model/pengaturan_model.dart';

/// Data dummy `PengaturanModel` untuk kebutuhan pratinjau UI dan
/// pengembangan. Tanggal mengikuti `DateTime.now()` agar tetap relevan.
abstract final class PengaturanDummy {
  static final List<PengaturanModel> dummyList = [
    PengaturanModel(
      intervalSinkronisasiOtomatis: 24,
      hapusOtomatisDataArsip: 30,
      modePemeliharaan: false,
      infoPemeliharaan: '',
      diperbarui: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}
