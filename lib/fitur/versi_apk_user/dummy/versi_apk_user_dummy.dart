// path: lib/fitur/versi_apk_user/dummy/versi_apk_user_dummy.dart

import 'package:admin_wifi/fitur/versi_apk_user/model/versi_apk_user_model.dart';

/// Data dummy `VersiApkUserModel` untuk kebutuhan pratinjau UI dan
/// pengembangan. Tanggal mengikuti `DateTime.now()` agar tetap relevan.
abstract final class VersiApkUserDummy {
  static const String ID_VERSI_APK_USER_001 =
      'a4000001-0000-4000-8000-000000000001';

  static final List<VersiApkUserModel> dummyList = [
    VersiApkUserModel(
      id: ID_VERSI_APK_USER_001,
      catatanRilis: 'Perbaikan bug dan peningkatan performa.',
      versiTerbaru: '1.2.0',
      wajibUpdate: false,
      youtubeTutorial: 'https://youtube.com/watch?v=dummy',
      diperbarui: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
}
