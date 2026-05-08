// path: lib/model/paket_model.dart
// diubah: Menambahkan properti jumlahPoin untuk fitur poin.
// ditambahkan: Metode toMapForFirebase untuk memastikan isDeleted adalah boolean.

import 'package:uuid/uuid.dart';

// Enum untuk tipe durasi paket
enum TipeDurasi {
  menit,
  jam,
  hari,
  bulan;

  // Getter untuk mendapatkan nama yang ramah pengguna
  String get displayName {
    switch (this) {
      case TipeDurasi.menit:
        return 'Menit';
      case TipeDurasi.jam:
        return 'Jam';
      case TipeDurasi.hari:
        return 'Hari';
      case TipeDurasi.bulan:
        return 'Bulan';
    }
  }
}

class PaketModel {
  final String id;
  final String nama;
  final int harga;
  final int durasi;
  final TipeDurasi tipe;
  final int jumlahPoin;
  final int poinHadiah;
  final int poinPenukaran;
  final DateTime? diperbarui;
  final bool isDeleted;
  final DateTime? diarsipkan;

  PaketModel({
    String? id,
    required this.nama,
    required this.harga,
    required this.durasi,
    required this.tipe,
    this.jumlahPoin = 0,
    this.poinHadiah = 0,
    this.poinPenukaran = 0,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  PaketModel copyWith({
    String? id,
    String? nama,
    int? harga,
    int? durasi,
    TipeDurasi? tipe,
    int? jumlahPoin,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return PaketModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      durasi: durasi ?? this.durasi,
      tipe: tipe ?? this.tipe,
      jumlahPoin: jumlahPoin ?? this.jumlahPoin, // ditambahkan: properti baru
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  // helper parsing datetime aman (Firestore / String / null)
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    // Firestore Timestamp handling (dynamic-safe)
    try {
      if (value.runtimeType.toString().contains('Timestamp')) {
        return value.toDate();
      }
    } catch (_) {}

    if (value is DateTime) return value;

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  // Konversi dari Map (dari database) ke objek Paket
  factory PaketModel.fromMap(Map<String, dynamic> map) {
    return PaketModel(
      id: map['id'],
      nama: map['nama'],
      harga: map['harga'],
      durasi: map['durasi'],
      tipe: TipeDurasi.values.firstWhere(
        (e) => e.name == map['tipe'],
        orElse: () => TipeDurasi.hari,
      ),
      jumlahPoin: map['jumlahPoin'] ?? 0,
      poinHadiah: map['poin_hadiah'] ?? map['poinHadiah'] ?? 0,
      poinPenukaran: map['poin_penukaran'] ?? map['poinPenukaran'] ?? 0,
      diperbarui: map['diperbarui'] != null
          ? DateTime.parse(map['diperbarui'])
          : null,
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  // Konversi dari objek Paket ke Map (untuk database lokal SQLite)
  Map<String, dynamic> toMapForSqlite() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'durasi': durasi,
      'tipe': tipe.name,
      'jumlahPoin': jumlahPoin, // ditambahkan: properti baru
      'poin_hadiah': poinHadiah,
      'poin_penukaran': poinPenukaran,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0, // diubah: Untuk kompatibilitas SQLite
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  // ditambahkan: Konversi ke Map untuk Firebase (isDeleted sebagai boolean)
  Map<String, dynamic> toMapForFirebase() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'durasi': durasi,
      'tipe': tipe.name,
      'jumlahPoin': jumlahPoin,
      'poin_hadiah': poinHadiah,
      'poin_penukaran': poinPenukaran,

      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted, // tetap boolean untuk Firebase
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }
}
