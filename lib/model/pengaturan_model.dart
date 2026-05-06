// path: lib/model/pengaturan_model.dart

class PengaturanModel {
  final int intervalSinkronisasiOtomatis;
  final int hapusOtomatisDataArsip;
  final bool modePemeliharaan;
  final String infoPemeliharaan;
  final DateTime? diperbarui;

  PengaturanModel({
    required this.intervalSinkronisasiOtomatis,
    required this.hapusOtomatisDataArsip,
    required this.modePemeliharaan,
    required this.infoPemeliharaan,
    this.diperbarui,
  });

  factory PengaturanModel.fromMap(Map<String, dynamic> map) {
    return PengaturanModel(
      intervalSinkronisasiOtomatis: map['interval_sinkronisasi_otomatis'] ?? 24,
      hapusOtomatisDataArsip: map['hapus_otomatis_data_arsip'] ?? 30,
      modePemeliharaan: (map['mode_pemeliharaan'] ?? 0) == 1,
      // ditambahkan: Mengambil data info pemeliharaan
      infoPemeliharaan: map['info_pemeliharaan'] ?? '',
      diperbarui: map['diperbarui'] != null
          ? DateTime.parse(map['diperbarui'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'interval_sinkronisasi_otomatis': intervalSinkronisasiOtomatis,
      'hapus_otomatis_data_arsip': hapusOtomatisDataArsip,
      'mode_pemeliharaan': modePemeliharaan ? 1 : 0,
      // ditambahkan: Menyimpan data info pemeliharaan
      'info_pemeliharaan': infoPemeliharaan,
      'diperbarui': DateTime.now().toIso8601String(),
    };
  }
}
