// path: lib/fitur/pesanan/enum/status_filter_pesanan_enum.dart

import 'package:share_global_saya/src/utils/l.dart';

// Enum untuk filter status pesanan
enum StatusFilterPesananEnum {
  semua,
  baru,
  diproses,
  selesai,
  ditolak;

  String get label {
    L.i('Mengakses getter label untuk enum StatusFilterPesananEnum.');
    L.i('Nilai enum saat ini: $this');

    switch (this) {
      case StatusFilterPesananEnum.semua:
        L.i('Mengembalikan string "Semua" untuk nilai semua.');
        return 'Semua';
      case StatusFilterPesananEnum.baru:
        L.i('Mengembalikan string "Baru" untuk nilai baru.');
        return 'Baru';
      case StatusFilterPesananEnum.diproses:
        L.i('Mengembalikan string "Diproses" untuk nilai diproses.');
        return 'Diproses';
      case StatusFilterPesananEnum.selesai:
        L.i('Mengembalikan string "Selesai" untuk nilai selesai.');
        return 'Selesai';
      case StatusFilterPesananEnum.ditolak:
        L.i('Mengembalikan string "Ditolak" untuk nilai ditolak.');
        return 'Ditolak';
    }
  }
}
