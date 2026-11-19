// path: lib/fitur/kategori/dummy/sub_kategori_dummy.dart

import 'package:admin_wifi/fitur/kategori/model/sub_kategori_model.dart';

/// Data dummy `SubKategoriModel` untuk kebutuhan pratinjau UI dan
/// pengembangan. Tanggal mengikuti `DateTime.now()` agar tetap relevan.
///
/// Nilai ID kategori sengaja SAMA dengan `KategoriDummy.ID_KATEGORI_*`
/// (di `lib/fitur/kategori/dummy/kategori_dummy.dart`) agar dummy
/// `sub_kategori` dapat merujuk kategori yang valid.
abstract final class SubKategoriDummy {
  static const String ID_SUB_KATEGORI_001 =
      'a0000001-0000-4000-8000-000000000001';
  static const String ID_SUB_KATEGORI_002 =
      'a0000002-0000-4000-8000-000000000002';
  static const String ID_SUB_KATEGORI_003 =
      'a0000003-0000-4000-8000-000000000003';

  static const String ID_KATEGORI_001 = 'ff000001-0000-4000-8000-000000000001';
  static const String ID_KATEGORI_002 = 'ff000002-0000-4000-8000-000000000002';
  static const String ID_KATEGORI_003 = 'ff000003-0000-4000-8000-000000000003';

  static final List<SubKategoriModel> dummyList = [
    SubKategoriModel(
      id: ID_SUB_KATEGORI_001,
      nama: 'Gaji',
      idKategori: ID_KATEGORI_001,
      diperbarui: DateTime.now().subtract(const Duration(days: 9)),
    ),
    SubKategoriModel(
      id: ID_SUB_KATEGORI_002,
      nama: 'Belanja',
      idKategori: ID_KATEGORI_002,
      diperbarui: DateTime.now().subtract(const Duration(days: 7)),
    ),
    SubKategoriModel(
      id: ID_SUB_KATEGORI_003,
      nama: 'Transfer Antar Rekening',
      idKategori: ID_KATEGORI_003,
      diperbarui: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
}
