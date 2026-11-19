// path: lib/fitur/kritik_saran/dummy/kritik_saran_dummy.dart

import 'package:admin_wifi/fitur/kritik_saran/model/kritik_saran_model.dart';

/// Data dummy `KritikSaranModel` untuk kebutuhan pratinjau UI dan
/// pengembangan. Tanggal mengikuti `DateTime.now()` agar tetap relevan.
///
/// Nilai ID pelanggan sengaja SAMA dengan `PelangganDummy.ID_PELANGGAN_*`
/// (di `lib/fitur/pelanggan/dummy/pelanggan_dummy.dart`) agar dummy
/// `kritik_saran` dapat merujuk pelanggan yang valid.
abstract final class KritikSaranDummy {
  static const String ID_KRITIK_SARAN_001 =
      'a1000001-0000-4000-8000-000000000001';
  static const String ID_KRITIK_SARAN_002 =
      'a1000002-0000-4000-8000-000000000002';
  static const String ID_KRITIK_SARAN_003 =
      'a1000003-0000-4000-8000-000000000003';

  static const String ID_PELANGGAN_001 = 'bb000001-0000-4000-8000-000000000001';
  static const String ID_PELANGGAN_002 = 'bb000002-0000-4000-8000-000000000002';
  static const String ID_PELANGGAN_003 = 'bb000003-0000-4000-8000-000000000003';

  static final List<KritikSaranModel> dummyList = [
    KritikSaranModel(
      id: ID_KRITIK_SARAN_001,
      isi: 'Koneksi sering putus saat jam sibuk.',
      tanggal: DateTime.now().subtract(const Duration(days: 4)),
      userId: ID_PELANGGAN_001,
      diperbarui: DateTime.now().subtract(const Duration(days: 4)),
    ),
    KritikSaranModel(
      id: ID_KRITIK_SARAN_002,
      isi: 'Paket bulanan sangat membantu.',
      tanggal: DateTime.now().subtract(const Duration(days: 2)),
      userId: ID_PELANGGAN_002,
      diperbarui: DateTime.now().subtract(const Duration(days: 2)),
    ),
    KritikSaranModel(
      id: ID_KRITIK_SARAN_003,
      isi: 'Mohon tambah metode pembayaran.',
      tanggal: DateTime.now().subtract(const Duration(hours: 6)),
      userId: ID_PELANGGAN_003,
      diperbarui: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];
}
