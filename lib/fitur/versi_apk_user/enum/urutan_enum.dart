// path: lib/fitur/versi_apk_user/enum/urutan_enum.dart

enum Urutan {
  buildZA,
  buildAZ,
  versiZA,
  versiAZ;

  String get label {
    switch (this) {
      case Urutan.buildZA:
        return 'Build (Terbaru ke Terlama)';
      case Urutan.buildAZ:
        return 'Build (Terlama ke Terbaru)';
      case Urutan.versiZA:
        return 'Versi (Z-A)';
      case Urutan.versiAZ:
        return 'Versi (A-Z)';
    }
  }
}
