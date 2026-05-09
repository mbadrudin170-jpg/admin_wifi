// path: lib/model/pengaturan_model.dart
// diubah: Menambahkan properti 'id' dan menyesuaikan semua metode untuk konsistensi.
import 'package:cloud_firestore/cloud_firestore.dart';

class PengaturanModel {
  // ditambahkan: Properti ID untuk konsistensi.
  final String id;
  final int intervalSinkronisasiOtomatis;
  final int hapusOtomatisDataArsip;
  final bool modePemeliharaan;
  final String infoPemeliharaan;
  final DateTime? diperbarui;

  // diubah: Konstruktor diperbaiki untuk menerima dan menginisialisasi ID, dengan nilai default 'default'.
  PengaturanModel({
    String? id,
    this.intervalSinkronisasiOtomatis = 24,
    this.hapusOtomatisDataArsip = 30,
    this.modePemeliharaan = false,
    this.infoPemeliharaan = '',
    this.diperbarui,
  }) : id = id ?? 'default';

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  // =========================
  // SQLITE
  // =========================

  // diubah: Factory fromSqlite diperbarui untuk membaca ID dari map.
  factory PengaturanModel.fromSqlite(Map<String, dynamic> map) {
    return PengaturanModel(
      id: map['id'] as String? ?? 'default',
      intervalSinkronisasiOtomatis:
          map['interval_sinkronisasi_otomatis'] as int? ?? 24,
      hapusOtomatisDataArsip: map['hapus_otomatis_data_arsip'] as int? ?? 30,
      modePemeliharaan: (map['mode_pemeliharaan'] as int? ?? 0) == 1,
      infoPemeliharaan: map['info_pemeliharaan'] as String? ?? '',
      diperbarui: _parseDateTime(map['diperbarui']),
    );
  }

  // diubah: Metode toSqlite diperbarui untuk menyertakan ID.
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
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

  // diubah: Factory fromFirebase sekarang juga membaca 'id'.
  factory PengaturanModel.fromFirebase(Map<String, dynamic> data) {
    return PengaturanModel(
      id: data['id'] as String? ?? 'default',
      intervalSinkronisasiOtomatis:
          data['interval_sinkronisasi_otomatis'] as int? ?? 24,
      hapusOtomatisDataArsip: data['hapus_otomatis_data_arsip'] as int? ?? 30,
      modePemeliharaan: data['mode_pemeliharaan'] as bool? ?? false,
      infoPemeliharaan: data['info_pemeliharaan'] as String? ?? '',
      diperbarui: _parseDateTime(data['diperbarui']),
    );
  }

  // diubah: Metode toFirebase sekarang juga menyertakan 'id'.
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'interval_sinkronisasi_otomatis': intervalSinkronisasiOtomatis,
      'hapus_otomatis_data_arsip': hapusOtomatisDataArsip,
      'mode_pemeliharaan': modePemeliharaan,
      'info_pemeliharaan': infoPemeliharaan,
      'diperbarui': FieldValue.serverTimestamp(),
    };
  }
}
