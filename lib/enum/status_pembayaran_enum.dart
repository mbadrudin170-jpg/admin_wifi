// path: lib/enum/status_pembayaran_enum.dart

import 'dart:developer' as developer;

// Enum untuk status pembayaran
enum StatusPembayaranEnum {
  lunas,
  belumLunas;

  String get displayName {
    developer.log(
      'Mengambil displayName untuk StatusPembayaran | Value: $this',
      name: 'StatusPembayaran-displayName getter 📝',
    );

    switch (this) {
      case StatusPembayaranEnum.lunas:
        developer.log(
          'DisplayName: Lunas',
          name: 'StatusPembayaran-displayName getter ✅',
        );
        return 'Lunas';
      case StatusPembayaranEnum.belumLunas:
        developer.log(
          'DisplayName: Belum Lunas',
          name: 'StatusPembayaran-displayName getter ✅',
        );
        return 'Belum Lunas';
    }
  }
}
