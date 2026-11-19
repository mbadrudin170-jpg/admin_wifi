// path: lib/fitur/status_unggah/dummy/status_unggah_dummy.dart

import 'package:admin_wifi/fitur/status_unggah/model/status_unggah_model.dart';

/// Data dummy `StatusUnggahModel` untuk kebutuhan pratinjau UI dan
/// pengembangan. Tanggal mengikuti `DateTime.now()` agar tetap relevan.
abstract final class StatusUnggahDummy {
  static const int ID_STATUS_UNGGGAH_001 = 1;
  static const int ID_STATUS_UNGGGAH_002 = 2;

  static final List<StatusUnggahModel> dummyList = [
    StatusUnggahModel(id: ID_STATUS_UNGGGAH_001, perluUnggah: false),
    StatusUnggahModel(id: ID_STATUS_UNGGGAH_002, perluUnggah: true),
  ];
}
