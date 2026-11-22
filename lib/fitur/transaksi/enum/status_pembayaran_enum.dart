// path: lib/enum/status_pembayaran_enum.dart

import 'package:share_global_saya/src/utils/l.dart';

// Enum untuk status pembayaran
enum StatusPembayaranEnum {
  lunas,
  belumLunas;

  String get label {
    L.i('Mengakses getter label untuk enum StatusPembayaranEnum.');
    L.i('Nilai enum saat ini: $this');

    switch (this) {
      case StatusPembayaranEnum.lunas:
        L.i('Mengembalikan string "Lunas" untuk nilai lunas.');
        return 'Lunas';
      case StatusPembayaranEnum.belumLunas:
        L.i('Mengembalikan string "Belum Lunas" untuk nilai belumLunas.');
        return 'Belum Lunas';
    }
  }
}
