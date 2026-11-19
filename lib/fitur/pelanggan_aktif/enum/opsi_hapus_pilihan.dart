// path: lib/fitur/pelanggan_aktif/enum/opsi_hapus_pilihan.dart

enum OpsiHapusPilihan { hapusSemua, arsipkanKadaluarsa, batal }

extension OpsiHapusPilihanLabel on OpsiHapusPilihan {
  String get label {
    switch (this) {
      case OpsiHapusPilihan.hapusSemua:
        return 'Hapus Semua';
      case OpsiHapusPilihan.arsipkanKadaluarsa:
        return 'Arsipkan Kadaluarsa';
      case OpsiHapusPilihan.batal:
        return 'Batal';
    }
  }
}
