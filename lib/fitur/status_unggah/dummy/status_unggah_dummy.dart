// path: lib/fitur/status_unggah/dummy/status_unggah_dummy.dart

import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/fitur/transaksi/dummy/transaksi_dummy.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/status_unggah/model/status_unggah_model.dart';

/// Data dummy `StatusUnggahModel` untuk kebutuhan pratinjau UI dan
/// pengembangan. Model tidak memiliki kolom `id` (PRIMARY KEY tabel
/// `status_unggah` adalah kolom `tabel`), sehingga tidak ada konstanta ID;
/// entri dikunci lewat nama tabel. Tanggal mengikuti `DateTime.now()` agar
/// tetap relevan; referensi ID pada `ids` memakai ID dari `TransaksiDummy`.
abstract final class StatusUnggahDummy {
  static final List<StatusUnggahModel> dummyList = [
    StatusUnggahModel(
      namaTabel: TransaksiSkema.tabel,
      status: 1,
      ids:
          '${TransaksiDummy.ID_TRANSAKSI_001},${TransaksiDummy.ID_TRANSAKSI_003}',
      diperbarui: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    StatusUnggahModel(
      namaTabel: PelangganSkema.tabel,
      status: 0,
      ids: '',
      diperbarui: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}
