// path: lib/model/kategori_model.dart
// diperbaiki: Menghapus cast yang tidak perlu untuk meningkatkan kebersihan kode.
// diubah: Logika parsing subkategori yang lebih aman dan ID yang lebih ketat.
// diubah: Memperbaiki panggilan ke toMap pada subkategori menjadi toMapForSqlite dan toMapForFirebase.
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
    // ditambah: Logika parsing subkategori yang lebih aman dan jelas
    List<SubKategoriModel> parseSubKategori(dynamic data) {
      if (data == null) return [];

      try {
        List<dynamic> list;
        if (data is String && data.isNotEmpty) {
          list = jsonDecode(data);
        } else if (data is List) {
          list = data;
        } else {
          return [];
        }

        return list
            .map(
              (item) => SubKategoriModel.fromMap(item as Map<String, dynamic>),
            )
            .toList();
      } catch (e) {
        // Jika terjadi error parsing, kembalikan list kosong untuk mencegah crash
        return [];
      }
    }

    return KategoriModel(
      id: map['id'], // diubah: ID harus berasal dari map, tidak boleh dibuat baru di sini.
      nama: map['nama'] ?? '',
      tipe: TipeKategori.values.firstWhere(
        (e) => e.name == map['tipe'],
        orElse: () => TipeKategori.pemasukan,
      ),
      subKategori: parseSubKategori(map['id_sub_kategori']),
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  Map<String, dynamic> toMapForSqlite() {
    return {
      'id': id,
      'nama': nama,
      'tipe': tipe.name,
      // diubah: Memanggil toMapForSqlite() pada subkategori
      'id_sub_kategori': jsonEncode(
        subKategori.map((sub) => sub.toMapForSqlite()).toList(),
      ),
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMapForFirebase() {
    return {
      'id': id,
      'nama': nama,
      'tipe': tipe.name,
      // diubah: Memanggil toMapForFirebase() pada subkategori
      'id_sub_kategori': jsonEncode(
        subKategori.map((sub) => sub.toMapForFirebase()).toList(),
      ),
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }
}
