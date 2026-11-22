// path: lib/fitur/transaksi/dummy/transaksi_dummy.dart

import 'package:admin_wifi/fitur/transaksi/enum/status_pembayaran_enum.dart';
import 'package:admin_wifi/fitur/transaksi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';

/// Data dummy `TransaksiModel` untuk kebutuhan pratinjau UI dan
/// pengembangan. Tanggal mengikuti `DateTime.now()` agar tetap relevan.
///
/// Nilai ID dompet, kategori, sub kategori, pelanggan, dan paket sengaja
/// SAMA dengan dummy sumber agar dummy `transaksi` dapat merujuk entitas
/// yang valid.
abstract final class TransaksiDummy {
  static const String ID_TRANSAKSI_001 = 'dd000001-0000-4000-8000-000000000001';
  static const String ID_TRANSAKSI_003 = 'dd000003-0000-4000-8000-000000000003';
  static const String ID_TRANSAKSI_005 = 'dd000005-0000-4000-8000-000000000005';

  static const String ID_DOMPET_001 = 'ee000001-0000-4000-8000-000000000001';
  static const String ID_DOMPET_002 = 'ee000002-0000-4000-8000-000000000002';

  static const String ID_KATEGORI_001 = 'ff000001-0000-4000-8000-000000000001';
  static const String ID_KATEGORI_002 = 'ff000002-0000-4000-8000-000000000002';

  static const String ID_SUB_KATEGORI_001 =
      'a0000001-0000-4000-8000-000000000001';
  static const String ID_SUB_KATEGORI_002 =
      'a0000002-0000-4000-8000-000000000002';

  static const String ID_PELANGGAN_001 = 'bb000001-0000-4000-8000-000000000001';
  static const String ID_PELANGGAN_002 = 'bb000002-0000-4000-8000-000000000002';

  static const String ID_PAKET_BULANAN = 'cc000001-0000-4000-8000-000000000001';
  static const String ID_PAKET_MINGGUAN =
      'cc000002-0000-4000-8000-000000000002';

  static final List<TransaksiModel> dummyList = [
    TransaksiModel(
      id: ID_TRANSAKSI_001,
      tanggal: DateTime.now().subtract(const Duration(days: 1)),
      keterangan: 'Pembayaran paket bulanan',
      jumlah: 100000,
      tipe: TipeTransaksi.pemasukan,
      idDompet: ID_DOMPET_001,
      idKategori: ID_KATEGORI_001,
      idSubKategori: ID_SUB_KATEGORI_001,
      idPelanggan: ID_PELANGGAN_001,
      idPaket: ID_PAKET_BULANAN,
      statusPembayaran: StatusPembayaranEnum.lunas,
      poinYangDihasilkan: 100,
      poinYangDigunakan: 0,
      diperbarui: DateTime.now().subtract(const Duration(days: 1)),
      durasiPaket: 1,
      tipeDurasiPaket: TipeDurasi.bulan,
      tanggalMulai: DateTime.now().subtract(const Duration(days: 1)),
      tanggalBerakhir: DateTime.now().add(const Duration(days: 29)),
      aktivasiPaket: true,
    ),
    TransaksiModel(
      id: ID_TRANSAKSI_003,
      tanggal: DateTime.now().subtract(const Duration(days: 3)),
      keterangan: 'Transfer ke dompet cadangan',
      jumlah: 50000,
      tipe: TipeTransaksi.transfer,
      idDompet: ID_DOMPET_001,
      idKategori: ID_KATEGORI_002,
      idDompetTujuan: ID_DOMPET_002,
      statusPembayaran: StatusPembayaranEnum.lunas,
      poinYangDihasilkan: 0,
      poinYangDigunakan: 0,
      diperbarui: DateTime.now().subtract(const Duration(days: 3)),
      aktivasiPaket: false,
    ),
    TransaksiModel(
      id: ID_TRANSAKSI_005,
      tanggal: DateTime.now().subtract(const Duration(hours: 5)),
      keterangan: 'Penukaran poin',
      jumlah: 0,
      tipe: TipeTransaksi.pengeluaran,
      idDompet: ID_DOMPET_002,
      idKategori: ID_KATEGORI_002,
      idSubKategori: ID_SUB_KATEGORI_002,
      idPelanggan: ID_PELANGGAN_002,
      idPaket: ID_PAKET_MINGGUAN,
      statusPembayaran: StatusPembayaranEnum.belumLunas,
      poinYangDihasilkan: 0,
      poinYangDigunakan: 50,
      diperbarui: DateTime.now().subtract(const Duration(hours: 4)),
      aktivasiPaket: false,
    ),
  ];
}
