// path: lib/fitur/pelanggan_aktif/dummy/pelanggan_aktif_dummy.dart

import 'package:admin_wifi/enum/status_pembayaran_enum.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';

/// Data dummy `PelangganAktifModel` untuk kebutuhan pratinjau UI dan
/// pengembangan. Tanggal mengikuti `DateTime.now()` agar tetap relevan.
abstract final class PelangganAktifDummy {
  static const String ID_PA_001 = 'aa000001-0000-4000-8000-000000000001';
  static const String ID_PA_002 = 'aa000002-0000-4000-8000-000000000002';
  static const String ID_PA_003 = 'aa000003-0000-4000-8000-000000000003';
  static const String ID_PA_004 = 'aa000004-0000-4000-8000-000000000004';
  static const String ID_PA_005 = 'aa000005-0000-4000-8000-000000000005';

  static const String ID_PELANGGAN_001 = 'bb000001-0000-4000-8000-000000000001';
  static const String ID_PELANGGAN_002 = 'bb000002-0000-4000-8000-000000000002';
  static const String ID_PELANGGAN_003 = 'bb000003-0000-4000-8000-000000000003';
  static const String ID_PELANGGAN_004 = 'bb000004-0000-4000-8000-000000000004';
  static const String ID_PELANGGAN_005 = 'bb000005-0000-4000-8000-000000000005';

  static const String ID_PAKET_BULANAN = 'cc000001-0000-4000-8000-000000000001';
  static const String ID_PAKET_MINGGUAN =
      'cc000002-0000-4000-8000-000000000002';
  static const String ID_PAKET_TAHUNAN = 'cc000003-0000-4000-8000-000000000003';

  static const String ID_TRANSAKSI_001 = 'dd000001-0000-4000-8000-000000000001';
  static const String ID_TRANSAKSI_003 = 'dd000003-0000-4000-8000-000000000003';
  static const String ID_TRANSAKSI_005 = 'dd000005-0000-4000-8000-000000000005';

  static final List<PelangganAktifModel> dummyList = [
    PelangganAktifModel(
      id: ID_PA_001,
      idPelanggan: ID_PELANGGAN_001,
      idPaket: ID_PAKET_BULANAN,
      idTransaksi: ID_TRANSAKSI_001,
      tanggalMulai: DateTime.now().subtract(const Duration(days: 10)),
      tanggalBerakhir: DateTime.now().add(const Duration(days: 20)),
      status: StatusPembayaranEnum.lunas,
      diperbarui: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PelangganAktifModel(
      id: ID_PA_002,
      idPelanggan: ID_PELANGGAN_002,
      idPaket: ID_PAKET_MINGGUAN,
      tanggalMulai: DateTime.now().subtract(const Duration(days: 3)),
      tanggalBerakhir: DateTime.now().add(const Duration(days: 4)),
      status: StatusPembayaranEnum.belumLunas,
    ),
    PelangganAktifModel(
      id: ID_PA_003,
      idPelanggan: ID_PELANGGAN_003,
      idPaket: ID_PAKET_TAHUNAN,
      idTransaksi: ID_TRANSAKSI_003,
      tanggalMulai: DateTime.now().subtract(const Duration(days: 100)),
      tanggalBerakhir: DateTime.now().add(const Duration(days: 265)),
      status: StatusPembayaranEnum.lunas,
      diperbarui: DateTime.now().subtract(const Duration(days: 30)),
    ),
    PelangganAktifModel(
      id: ID_PA_004,
      idPelanggan: ID_PELANGGAN_004,
      idPaket: ID_PAKET_BULANAN,
      tanggalMulai: DateTime.now().subtract(const Duration(days: 25)),
      tanggalBerakhir: DateTime.now().add(const Duration(days: 5)),
      status: StatusPembayaranEnum.lunas,
    ),
    PelangganAktifModel(
      id: ID_PA_005,
      idPelanggan: ID_PELANGGAN_005,
      idPaket: ID_PAKET_MINGGUAN,
      idTransaksi: ID_TRANSAKSI_005,
      tanggalMulai: DateTime.now().subtract(const Duration(days: 6)),
      tanggalBerakhir: DateTime.now().add(const Duration(days: 1)),
      status: StatusPembayaranEnum.belumLunas,
      diperbarui: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];
}
