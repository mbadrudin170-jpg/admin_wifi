// path: lib/model/pengaturan_model.dart
// diubah: Penamaan metode diseragamkan dan logika Firebase disesuaikan.
import 'package:cloud_firestore/cloud_firestore.dart';

class PengaturanModel {
  final int intervalSinkronisasiOtomatis;
  final int hapusOtomatisDataArsip;
  final bool modePemeliharaan;
  final String infoPemeliharaan;
  final DateTime? diperbarui;

  PengaturanModel({
    this.intervalSinkronisasiOtomatis = 24,
    this.hapusOtomatisDataArsip = 30,
    this.modePemeliharaan = false,
    this.infoPemeliharaan = '',
    this.diperbarui,
  });

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  // =========================
  // SQLITE
  // =========================

  factory PengaturanModel.fromSqlite(Map<String, dynamic> map) {
    return PengaturanModel(
      intervalSinkronisasiOtomatis:
          map['interval_sinkronisasi_otomatis'] as int? ?? 24,
      hapusOtomatisDataArsip: map['hapus_otomatis_data_arsip'] as int? ?? 30,
      modePemeliharaan: (map['mode_pemeliharaan'] as int? ?? 0) == 1,
      infoPemeliharaan: map['info_pemeliharaan'] as String? ?? '',
      diperbarui: _parseDateTime(map['diperbarui']),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'interval_sinkronisasi_otomatis': intervalSinkronisasiOtomatis,
      'hapus_otomatis_data_arsip': hapusOtomatisDataArsip,
      'mode_pemeliharaan': modePemeliharaan ? 1 : 0,
      'info_pemeliharaan': infoPemeliharaan,
      'diperbarui': DateTime.now().toIso8601String(),
    };
  }

  // =========================
  // FIREBASE
  // =========================

  factory PengaturanModel.fromFirebase(Map<String, dynamic> data) {
    return PengaturanModel(
      intervalSinkronisasiOtomatis:
          data['interval_sinkronisasi_otomatis'] as int? ?? 24,
      hapusOtomatisDataArsip: data['hapus_otomatis_data_arsip'] as int? ?? 30,
      modePemeliharaan: data['mode_pemeliharaan'] as bool? ?? false,
      infoPemeliharaan: data['info_pemeliharaan'] as String? ?? '',
      diperbarui: _parseDateTime(data['diperbarui']),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      'id': 'default', // ID statis untuk dokumen pengaturan
      'interval_sinkronisasi_otomatis': intervalSinkronisasiOtomatis,
      'hapus_otomatis_data_arsip': hapusOtomatisDataArsip,
      'mode_pemeliharaan': modePemeliharaan,
      'info_pemeliharaan': infoPemeliharaan,
      'diperbarui': FieldValue.serverTimestamp(),
    };
  }
}
