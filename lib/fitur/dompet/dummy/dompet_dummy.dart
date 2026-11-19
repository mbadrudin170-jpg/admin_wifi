// path: lib/fitur/dompet/dummy/dompet_dummy.dart

import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';

/// Data dummy `DompetModel` untuk kebutuhan pratinjau UI dan
/// pengembangan. Tanggal mengikuti `DateTime.now()` agar tetap relevan.
abstract final class DompetDummy {
  static const String ID_DOMPET_001 = 'ee000001-0000-4000-8000-000000000001';
  static const String ID_DOMPET_002 = 'ee000002-0000-4000-8000-000000000002';
  static const String ID_DOMPET_003 = 'ee000003-0000-4000-8000-000000000003';

  static final List<DompetModel> dummyList = [
    DompetModel(
      id: ID_DOMPET_001,
      namaDompet: 'Dompet Utama',
      saldo: 1500000,
      diperbarui: DateTime.now().subtract(const Duration(days: 5)),
    ),
    DompetModel(
      id: ID_DOMPET_002,
      namaDompet: 'Dompet Cadangan',
      saldo: 250000,
      diperbarui: DateTime.now().subtract(const Duration(days: 2)),
    ),
    DompetModel(
      id: ID_DOMPET_003,
      namaDompet: 'Dompet Poin',
      saldo: 0,
      isDeleted: false,
      diperbarui: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];
}
