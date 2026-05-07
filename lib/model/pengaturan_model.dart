// path: lib/model/pengaturan_model.dart
// diubah: Menghapus toMap() dan hanya menyisakan toMapForSqlite() dan toMapForFirebase().
// ditambah: _parseDateTime helper function untuk konsistensi.
import 'package:cloud_firestore/cloud_firestore.dart';

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

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  factory PengaturanModel.fromMap(Map<String, dynamic> map) {
    return PengaturanModel(
      intervalSinkronisasiOtomatis: map['interval_sinkronisasi_otomatis'] ?? 24,
      hapusOtomatisDataArsip: map['hapus_otomatis_data_arsip'] ?? 30,
      modePemeliharaan: (map['mode_pemeliharaan'] ?? 0) == 1,
      infoPemeliharaan: map['info_pemeliharaan'] ?? '',
      diperbarui: _parseDateTime(map['diperbarui']),
    );
  }

  // diubah: Hanya ada toMapForSqlite dan toMapForFirebase
  Map<String, dynamic> toMapForSqlite() {
    return {
      'interval_sinkronisasi_otomatis': intervalSinkronisasiOtomatis,
      'hapus_otomatis_data_arsip': hapusOtomatisDataArsip,
      'mode_pemeliharaan': modePemeliharaan ? 1 : 0,
      'info_pemeliharaan': infoPemeliharaan,
      'diperbarui': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toMapForFirebase() {
    return {
      'interval_sinkronisasi_otomatis': intervalSinkronisasiOtomatis,
      'hapus_otomatis_data_arsip': hapusOtomatisDataArsip,
      'mode_pemeliharaan': modePemeliharaan,
      'info_pemeliharaan': infoPemeliharaan,
      'diperbarui': DateTime.now().toIso8601String(),
    };
  }
}
