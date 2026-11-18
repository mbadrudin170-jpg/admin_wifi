// path: lib/fitur/paket/dummy/paket_dummy.dart

import 'package:admin_wifi/fitur/paket/model/paket_model.dart';

/// Data dummy `PaketModel` untuk kebutuhan pratinjau UI dan pengembangan.
/// Tanggal mengikuti `DateTime.now()` agar tetap relevan.
///
/// Nilai ID sengaja SAMA dengan `PelangganAktifDummy.ID_PAKET_*` (di
/// `lib/fitur/pelanggan_aktif/dummy/pelanggan_aktif_dummy.dart`) agar dummy
/// `pelanggan_aktif` dapat merujuk paket yang valid.
abstract final class PaketDummy {
  static const String ID_PAKET_BULANAN = 'cc000001-0000-4000-8000-000000000001';
  static const String ID_PAKET_MINGGUAN =
      'cc000002-0000-4000-8000-000000000002';
  static const String ID_PAKET_TAHUNAN = 'cc000003-0000-4000-8000-000000000003';

  static final List<PaketModel> dummyList = [
    PaketModel(
      id: ID_PAKET_BULANAN,
      nama: 'Paket Bulanan',
      harga: 100000,
      durasi: 1,
      tipe: TipeDurasi.bulan,
      poinHadiah: 100,
      poinPenukaran: 50,
      isPublic: true,
      diperbarui: DateTime.now().subtract(const Duration(days: 30)),
    ),
    PaketModel(
      id: ID_PAKET_MINGGUAN,
      nama: 'Paket Mingguan',
      harga: 30000,
      durasi: 7,
      tipe: TipeDurasi.hari,
      poinHadiah: 30,
      poinPenukaran: 15,
      isPublic: true,
      diperbarui: DateTime.now().subtract(const Duration(days: 20)),
    ),
    PaketModel(
      id: ID_PAKET_TAHUNAN,
      nama: 'Paket Tahunan',
      harga: 1200000,
      durasi: 12,
      tipe: TipeDurasi.bulan,
      poinHadiah: 1000,
      poinPenukaran: 500,
      isPublic: true,
      diperbarui: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];
}
