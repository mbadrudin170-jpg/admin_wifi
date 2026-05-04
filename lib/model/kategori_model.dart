// path: lib/model/kategori_model.dart
// diubah: Menggunakan UUID untuk ID dan memastikan non-nullable.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum TipeKategori { pemasukan, pengeluaran, transfer }

class KategoriModel {
  final String id; // diubah: menjadi non-nullable
  final String nama;
  final TipeKategori tipe;
  final List<SubKategoriModel> subKategori;
  DateTime? diperbarui;
  bool isDeleted;
  DateTime? diarsipkan;

  KategoriModel({
    String? id, // diubah: id bisa null saat pembuatan
    required this.nama,
    required this.tipe,
    this.subKategori = const [],
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4(); // ditambah: inisialisasi UUID jika id null

  KategoriModel copyWith({
    String? id,
    String? nama,
    TipeKategori? tipe,
    List<SubKategoriModel>? subKategori,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return KategoriModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      tipe: tipe ?? this.tipe,
      subKategori: subKategori ?? this.subKategori,
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  factory KategoriModel.fromMap(Map<String, dynamic> map) {
    return KategoriModel(
      id: map['id'],
      nama: map['nama'] ?? '',
      tipe: TipeKategori.values.firstWhere(
        (e) => e.name == map['tipe'],
        orElse: () => TipeKategori.pemasukan,
      ),
      subKategori: (map['subKategori'] as List<dynamic>? ?? [])
          .map((subMap) => SubKategoriModel.fromMap(subMap as Map<String, dynamic>))
          .toList(),
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'tipe': tipe.name,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }
}

class SubKategoriModel {
  final String id; // diubah: menjadi non-nullable
  final String nama;
  DateTime? diperbarui;
  bool isDeleted;
  DateTime? diarsipkan;

  SubKategoriModel({
    String? id, // diubah: id bisa null saat pembuatan
    required this.nama,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4(); // ditambah: inisialisasi UUID jika id null

  SubKategoriModel copyWith({
    String? id,
    String? nama,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return SubKategoriModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  factory SubKategoriModel.fromMap(Map<String, dynamic> map) {
    return SubKategoriModel(
      id: map['id'],
      nama: map['nama'] ?? '',
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }
}
