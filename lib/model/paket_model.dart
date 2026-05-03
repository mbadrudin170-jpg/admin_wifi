// path: lib/model/paket_model.dart
// diubah: Menambahkan metode copyWith untuk konsistensi.

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

// diubah: nama kelas untuk konsistensi penamaan
class PaketModel {
  final String id; // PERBAIKAN: ID tidak boleh nullable
  final String nama;
  final int harga;
  final int durasi;
  final TipeDurasi tipe;

  final DateTime? diperbarui;

  // tambahan: soft delete & arsip
  final bool isDeleted;
  final DateTime? diarsipkan;

  // diubah: nama konstruktor
  PaketModel({
    String? id,
    required this.nama,
    required this.harga,
    required this.durasi,
    required this.tipe,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  // ditambah: Metode copyWith untuk membuat salinan objek dengan nilai yang diperbarui.
  PaketModel copyWith({
    String? id,
    String? nama,
    int? harga,
    int? durasi,
    TipeDurasi? tipe,
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
      diperbarui: map['diperbarui'] != null
          ? DateTime.parse(map['diperbarui'])
          : null,

      // tambahan field baru
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  // Konversi dari objek Paket ke Map (untuk database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'durasi': durasi,
      'tipe': tipe.name,
      'diperbarui': diperbarui?.toIso8601String(),

      // tambahan field baru
      'isDeleted': isDeleted,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }
}
