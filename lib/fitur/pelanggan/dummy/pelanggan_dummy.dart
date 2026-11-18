// path: lib/fitur/pelanggan/dummy/pelanggan_dummy.dart

import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';

/// Data dummy `PelangganModel` untuk kebutuhan pratinjau UI dan pengembangan.
/// Tanggal mengikuti `DateTime.now()` agar tetap relevan.
///
/// Nilai ID sengaja SAMA dengan `PelangganAktifDummy.ID_PELANGGAN_*` (di
/// `lib/fitur/pelanggan_aktif/dummy/pelanggan_aktif_dummy.dart`) agar dummy
/// `pelanggan_aktif` dapat merujuk entitas pelanggan yang valid.
abstract final class PelangganDummy {
  static const String ID_PELANGGAN_001 = 'bb000001-0000-4000-8000-000000000001';
  static const String ID_PELANGGAN_002 = 'bb000002-0000-4000-8000-000000000002';
  static const String ID_PELANGGAN_003 = 'bb000003-0000-4000-8000-000000000003';
  static const String ID_PELANGGAN_004 = 'bb000004-0000-4000-8000-000000000004';
  static const String ID_PELANGGAN_005 = 'bb000005-0000-4000-8000-000000000005';

  static final List<PelangganModel> dummyList = [
    PelangganModel(
      id: ID_PELANGGAN_001,
      nama: 'Budi Santoso',
      telepon: '081234567001',
      alamat: 'Jl. Melati No. 12, Bekasi',
      password: 'rahasia123',
      macAddress: 'AA:BB:CC:DD:EE:01',
      diperbarui: DateTime.now().subtract(const Duration(days: 30)),
    ),
    PelangganModel(
      id: ID_PELANGGAN_002,
      nama: 'Siti Aminah',
      telepon: '081234567002',
      alamat: 'Jl. Anggrek No. 7, Jakarta Selatan',
      password: 'rahasia123',
      macAddress: 'AA:BB:CC:DD:EE:02',
      diperbarui: DateTime.now().subtract(const Duration(days: 20)),
    ),
    PelangganModel(
      id: ID_PELANGGAN_003,
      nama: 'Andi Wijaya',
      telepon: '081234567003',
      alamat: 'Jl. Kenanga No. 45, Depok',
      password: 'rahasia123',
      macAddress: 'AA:BB:CC:DD:EE:03',
      diperbarui: DateTime.now().subtract(const Duration(days: 10)),
    ),
    PelangganModel(
      id: ID_PELANGGAN_004,
      nama: 'Dewi Lestari',
      telepon: '081234567004',
      alamat: 'Jl. Mawar No. 3, Tangerang',
      password: 'rahasia123',
      macAddress: 'AA:BB:CC:DD:EE:04',
      diperbarui: DateTime.now().subtract(const Duration(days: 5)),
    ),
    PelangganModel(
      id: ID_PELANGGAN_005,
      nama: 'Rudi Hartono',
      telepon: '081234567005',
      alamat: 'Jl. Flamboyan No. 28, Bogor',
      password: 'rahasia123',
      macAddress: 'AA:BB:CC:DD:EE:05',
      diperbarui: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}
