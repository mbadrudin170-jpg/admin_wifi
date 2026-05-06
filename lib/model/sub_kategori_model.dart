// path: lib/model/sub_kategori_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SubKategoriModel {
  final String id;
  final String nama;
  final String idKategori;
  final DateTime? diperbarui;
  final bool isDeleted;
  final DateTime? diarsipkan;

  SubKategoriModel({
    String? id,
    required this.nama,
    required this.idKategori,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  SubKategoriModel copyWith({
    String? id,
    String? nama,
    String? idKategori,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return SubKategoriModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      idKategori: idKategori ?? this.idKategori,
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
      idKategori: map['id_kategori'] ?? '',
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'id_kategori': idKategori,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }
}
