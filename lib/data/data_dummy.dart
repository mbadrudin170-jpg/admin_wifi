// path: lib/data/data_dummy.dart

import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:uuid/uuid.dart'; // ditambahkan: import untuk Uuid

// untuk data dummy VersiApkUserModel
final dummyVersiApkUser = VersiApkUserModel(
  id: const Uuid().v4(), // ditambahkan: id unik untuk data dummy
  catatanRilis: 'Perbaikan bug dan peningkatan performa.',
  nomorBuildTerbaru: {'universal': 10, 'bit_32': 15, 'bit_64': 16}, // diubah: menyesuaikan dengan struktur baru
  tautanUnduhan: {
    'universal': 'https://example.com/app-universal.apk',
    'bit_32': 'https://example.com/app-32.apk',
    'bit_64': 'https://example.com/app-64.apk',
  },
  versiTerbaru: '1.2.3',
  wajibUpdate: false,
  youtubeTutorial: 'https://youtube.com/watch?v=example',
);
