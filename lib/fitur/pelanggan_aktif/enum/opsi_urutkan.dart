// path: lib/fitur/pelanggan_aktif/enum/opsi_urutkan.dart

enum OpsiUrutkan {
  tanggalBerakhir,
  tanggalMulai,
  diPerbarui,
  namaAZ,
  namaZA,
  lunas,
  belumLunas,
  paketAktif,
  paketTidakAktif,
}

extension OpsiUrutkanLabel on OpsiUrutkan {
  String get label {
    switch (this) {
      case OpsiUrutkan.tanggalBerakhir:
        return 'Tanggal Berakhir';
      case OpsiUrutkan.tanggalMulai:
        return 'Tanggal Mulai';
      case OpsiUrutkan.diPerbarui:
        return 'Terakhir Diperbarui';
      case OpsiUrutkan.namaAZ:
        return 'Nama (A-Z)';
      case OpsiUrutkan.namaZA:
        return 'Nama (Z-A)';
      case OpsiUrutkan.lunas:
        return 'Status Pembayaran (Lunas)';
      case OpsiUrutkan.belumLunas:
        return 'Status Pembayaran (Belum Lunas)';
      case OpsiUrutkan.paketAktif:
        return 'Status Paket (Aktif)';
      case OpsiUrutkan.paketTidakAktif:
        return 'Status Paket (Tidak Aktif)';
    }
  }
}
