// path: lib/model/kategori_model.dart
// diubah: Menggunakan 'id_sub_kategori' sebagai key di map dan memperbaiki bug copyWith.
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:admin_wifi/model/sub_kategori_model.dart';

enum TipeKategori { pemasukan, pengeluaran, transfer }

class KategoriModel {
  final String id;
  final String nama;
  final TipeKategori tipe;
  final List<SubKategoriModel> subKategori;
  final DateTime? diperbarui;
  final bool isDeleted;
  final DateTime? diarsipkan;

  KategoriModel({
    String? id,
    required this.nama,
    required this.tipe,
    this.subKategori = const [],
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

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
    List<SubKategoriModel> subKategoriList = [];
    // diubah: Membaca dari field 'id_sub_kategori'
    final subKategoriData = map['id_sub_kategori'];
    if (subKategoriData is String && subKategoriData.isNotEmpty) {
      final List<dynamic> decodedList = jsonDecode(subKategoriData);
      subKategoriList = decodedList
          .map((subMap) => SubKategoriModel.fromMap(subMap as Map<String, dynamic>))
          .toList();
    } else if (subKategoriData is List) {
       subKategoriList = (subKategoriData as List<dynamic>)
          .map((subMap) => SubKategoriModel.fromMap(subMap as Map<String, dynamic>))
          .toList();
    }

    return KategoriModel(
      id: map['id'] ?? const Uuid().v4(),
      nama: map['nama'] ?? '',
      tipe: TipeKategori.values.firstWhere(
        (e) => e.name == map['tipe'],
        orElse: () => TipeKategori.pemasukan,
      ),
      subKategori: subKategoriList,
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
      // diubah: Menyimpan ke field 'id_sub_kategori'
      'id_sub_kategori': jsonEncode(subKategori.map((sub) => sub.toMap()).toList()),
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }
}
