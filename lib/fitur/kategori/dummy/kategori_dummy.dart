// path: lib/fitur/kategori/dummy/kategori_dummy.dart

import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';

/// Data dummy `KategoriModel` untuk kebutuhan pratinjau UI dan
/// pengembangan. Tanggal mengikuti `DateTime.now()` agar tetap relevan.
abstract final class KategoriDummy {
  static const String ID_KATEGORI_001 = 'ff000001-0000-4000-8000-000000000001';
  static const String ID_KATEGORI_002 = 'ff000002-0000-4000-8000-000000000002';
  static const String ID_KATEGORI_003 = 'ff000003-0000-4000-8000-000000000003';

  static final List<KategoriModel> dummyList = [
    KategoriModel(
      id: ID_KATEGORI_001,
      nama: 'Pemasukan',
      tipe: TipeKategori.pemasukan,
      diperbarui: DateTime.now().subtract(const Duration(days: 10)),
    ),
    KategoriModel(
      id: ID_KATEGORI_002,
      nama: 'Pengeluaran',
      tipe: TipeKategori.pengeluaran,
      diperbarui: DateTime.now().subtract(const Duration(days: 8)),
    ),
    KategoriModel(
      id: ID_KATEGORI_003,
      nama: 'Transfer',
      tipe: TipeKategori.transfer,
      diperbarui: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
}
