// path: lib/fitur/voucher/dummy/voucher_dummy.dart

import 'package:admin_wifi/fitur/paket/dummy/paket_dummy.dart';
import 'package:admin_wifi/fitur/voucher/model/voucher_model.dart';

/// Data dummy `VoucherModel` untuk kebutuhan pratinjau UI dan pengembangan.
/// Tanggal mengikuti `DateTime.now()` agar tetap relevan.
///
/// Nilai `idPaket` sengaja memakai konstanta `PaketDummy.ID_PAKET_*`
/// (`lib/fitur/paket/dummy/paket_dummy.dart`) agar voucher dapat merujuk
/// paket yang valid.
abstract final class VoucherDummy {
  static const String ID_VOUCHER_001 = '11000001-0000-4000-8000-000000000001';
  static const String ID_VOUCHER_002 = '11000002-0000-4000-8000-000000000002';
  static const String ID_VOUCHER_003 = '11000003-0000-4000-8000-000000000003';

  static final List<VoucherModel> dummyList = [
    VoucherModel(
      id: ID_VOUCHER_001,
      idPaket: PaketDummy.ID_PAKET_BULANAN,
      tanggalDibuat: DateTime.now().subtract(const Duration(days: 5)),
      voucher: 'VOUCHER-BULANAN-001',
      kadaluarsa: DateTime.now().add(const Duration(days: 25)),
    ),
    VoucherModel(
      id: ID_VOUCHER_002,
      idPaket: PaketDummy.ID_PAKET_MINGGUAN,
      tanggalDibuat: DateTime.now().subtract(const Duration(days: 2)),
      voucher: 'VOUCHER-MINGGUAN-002',
      kadaluarsa: DateTime.now().add(const Duration(days: 5)),
    ),
    VoucherModel(
      id: ID_VOUCHER_003,
      idPaket: PaketDummy.ID_PAKET_TAHUNAN,
      tanggalDibuat: DateTime.now().subtract(const Duration(days: 1)),
      voucher: 'VOUCHER-TAHUNAN-003',
      kadaluarsa: null,
    ),
  ];
}
