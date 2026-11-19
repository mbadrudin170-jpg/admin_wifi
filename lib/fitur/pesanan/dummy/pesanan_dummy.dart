// path: lib/fitur/pesanan/dummy/pesanan_dummy.dart

import 'package:admin_wifi/fitur/pesanan/model/pesanan_model.dart';

/// Data dummy `PesananModel` untuk kebutuhan pratinjau UI dan
/// pengembangan. Tanggal mengikuti `DateTime.now()` agar tetap relevan.
///
/// Nilai ID pelanggan dan paket sengaja SAMA dengan `PelangganDummy` dan
/// `PaketDummy` agar dummy `pesanan` dapat merujuk entitas yang valid.
abstract final class PesananDummy {
  static const String ID_PESANAN_001 = 'a2000001-0000-4000-8000-000000000001';
  static const String ID_PESANAN_002 = 'a2000002-0000-4000-8000-000000000002';
  static const String ID_PESANAN_003 = 'a2000003-0000-4000-8000-000000000003';

  static const String ID_PELANGGAN_001 = 'bb000001-0000-4000-8000-000000000001';
  static const String ID_PELANGGAN_002 = 'bb000002-0000-4000-8000-000000000002';
  static const String ID_PELANGGAN_003 = 'bb000003-0000-4000-8000-000000000003';

  static const String ID_PAKET_BULANAN = 'cc000001-0000-4000-8000-000000000001';
  static const String ID_PAKET_MINGGUAN =
      'cc000002-0000-4000-8000-000000000002';
  static const String ID_PAKET_TAHUNAN = 'cc000003-0000-4000-8000-000000000003';

  static final List<PesananModel> dummyList = [
    PesananModel(
      id: ID_PESANAN_001,
      idPelanggan: ID_PELANGGAN_001,
      idPaket: ID_PAKET_BULANAN,
      tanggal: DateTime.now().subtract(const Duration(days: 1)),
      status: 'baru',
      diperbarui: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PesananModel(
      id: ID_PESANAN_002,
      idPelanggan: ID_PELANGGAN_002,
      idPaket: ID_PAKET_MINGGUAN,
      tanggal: DateTime.now().subtract(const Duration(hours: 12)),
      status: 'diproses',
      diperbarui: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    PesananModel(
      id: ID_PESANAN_003,
      idPelanggan: ID_PELANGGAN_003,
      idPaket: ID_PAKET_TAHUNAN,
      tanggal: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'selesai',
      diperbarui: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];
}
