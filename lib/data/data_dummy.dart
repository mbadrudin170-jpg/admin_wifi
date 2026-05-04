// path: lib/data/data_dummy.dart

import 'package:admin_wifi/model/versi_apk_user_model.dart';

// untuk data dummy VersiApkUserModel
final dummyVersiApkUser = VersiApkUserModel(
  catatanRilis: 'Perbaikan bug dan peningkatan performa.',
  nomorBuildTerbaru: {
    'prod': 10,
    'dev': 15,
  },
  tautanUnduhan: {
    'prod': 'https://example.com/app-prod.apk',
    'dev': 'https://example.com/app-dev.apk',
  },
  versiTerbaru: '1.2.3',
  wajibUpdate: false,
  youtubeTutorial: 'https://youtube.com/watch?v=example',
);
