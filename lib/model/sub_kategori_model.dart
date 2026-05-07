// path: lib/model/sub_kategori_model.dart
// diubah: Nama field dipertahankan sebagai idKategori, namun key di map tetap id_kategori untuk konsistensi DB.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SubKategoriModel {
  final String id;
  final String nama;
  final String idKategori; // dipertahankan sesuai permintaan
  final DateTime? diperbarui;
  final bool isDeleted;
  final DateTime? diarsipkan;

  SubKategoriModel({
    String? id,
    required this.nama,
    required this.idKategori, // dipertahankan
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  SubKategoriModel copyWith({
    String? id,
    String? nama,
    String? idKategori, // dipertahankan
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return SubKategoriModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      idKategori: idKategori ?? this.idKategori, // dipertahankan
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  factory SubKategoriModel.fromMap(Map<String, dynamic> map) {
    return SubKategoriModel(
      id: map['id'] ?? '',
      nama: map['nama'] ?? '',
      idKategori: map['id_kategori'] ?? '', // diubah: key map tetap snake_case
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: map['isDeleted'] == 1 || map['isDeleted'] == true,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  Map<String, dynamic> toMapForSqlite() {
    return {
      'id': id,
      'nama': nama,
      'id_kategori': idKategori, // diubah: key map tetap snake_case
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMapForFirebase() {
    return {
      'id': id,
      'nama': nama,
      'id_kategori': idKategori, // diubah: key map tetap snake_case
      'diperbarui': diperbarui,
      'isDeleted': isDeleted,
      'diarsipkan': diarsipkan,
    };
  }
}
