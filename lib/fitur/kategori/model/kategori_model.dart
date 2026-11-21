// path: lib/fitur/kategori/model/kategori_model.dart
// diubah: Penamaan metode diseragamkan dan logika Firebase diperbaiki.
import 'dart:convert';

import 'package:admin_wifi/fitur/kategori/model/sub_kategori_model.dart';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:share_global_saya/src/utils/parser_util.dart';

part 'kategori_model.freezed.dart';

enum TipeKategori { pemasukan, pengeluaran, transfer }

@freezed
abstract class KategoriModel with _$KategoriModel {
  const KategoriModel._();

  const factory KategoriModel({
    required String id,
    required String nama,
    required TipeKategori tipe,
    @Default(<SubKategoriModel>[]) List<SubKategoriModel> subKategori,
    DateTime? diperbarui,
    @Default(false) bool isDeleted,
    DateTime? diarsipkan,
  }) = _KategoriModel;

  /// Firestore menyimpan `Timestamp`; SQLite menyimpan ISO-8601 string (UTC).
  /// Keduanya dinormalisasi lewat [ParserUtil.parseDateTime].
  static DateTime? _parseTanggal(dynamic value) {
    return ParserUtil.parseDateTime(value)?.toLocal();
  }

  // diubah: Nama metode dari fromMap menjadi fromSqlite
  factory KategoriModel.fromSqlite(Map<String, dynamic> map) {
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
              (item) =>
                  SubKategoriModel.fromSqlite(item as Map<String, dynamic>),
            )
            .toList();
      } catch (e) {
        return [];
      }
    }

    return KategoriModel(
      id: ParserUtil.parseString(map[KategoriSkema.id]),
      nama: ParserUtil.parseString(map[KategoriSkema.nama]),
      tipe:
          ParserUtil.safeParseEnum(
            TipeKategori.values,
            ParserUtil.parseStringOrNull(map[KategoriSkema.tipe]),
          ) ??
          TipeKategori.pemasukan,
      subKategori: parseSubKategori(map[KategoriSkema.idSubKategori]),
      diperbarui: _parseTanggal(map[KategoriSkema.diperbarui]),
      isDeleted: ParserUtil.parseBool(map[KategoriSkema.isDeleted]),
      diarsipkan: _parseTanggal(map[KategoriSkema.diarsipkan]),
    );
  }

  // diubah: Nama metode dari toMapForSqlite menjadi toSqlite
  Map<String, dynamic> toSqlite() {
    return {
      KategoriSkema.id: id,
      KategoriSkema.nama: nama,
      KategoriSkema.tipe: tipe.name,
      KategoriSkema.idSubKategori: jsonEncode(
        subKategori.map((sub) => sub.toSqlite()).toList(),
      ),
      KategoriSkema.diperbarui: diperbarui?.toUtc().toIso8601String(),
      KategoriSkema.isDeleted: isDeleted ? 1 : 0,
      KategoriSkema.diarsipkan: diarsipkan?.toUtc().toIso8601String(),
    };
  }

  /// Supabase mengembalikan baris sebagai `Map<String, dynamic>` dengan
  /// kunci yang sama dengan SQLite, jadi parsing sama dengan fromSqlite.
  factory KategoriModel.fromSupabase(Map<String, dynamic> map) {
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
              (item) =>
                  SubKategoriModel.fromSupabase(item as Map<String, dynamic>),
            )
            .toList();
      } catch (e) {
        return [];
      }
    }

    return KategoriModel(
      id: ParserUtil.parseString(map[KategoriSkema.id]),
      nama: ParserUtil.parseString(map[KategoriSkema.nama]),
      tipe:
          ParserUtil.safeParseEnum(
            TipeKategori.values,
            ParserUtil.parseStringOrNull(map[KategoriSkema.tipe]),
          ) ??
          TipeKategori.pemasukan,
      subKategori: parseSubKategori(map[KategoriSkema.idSubKategori]),
      diperbarui: _parseTanggal(map[KategoriSkema.diperbarui]),
      isDeleted: ParserUtil.parseBool(map[KategoriSkema.isDeleted]),
      diarsipkan: _parseTanggal(map[KategoriSkema.diarsipkan]),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      KategoriSkema.id: id,
      KategoriSkema.nama: nama,
      KategoriSkema.tipe: tipe.name,
      KategoriSkema.idSubKategori: subKategori
          .map((sub) => sub.toSupabase())
          .toList(),
      KategoriSkema.diperbarui: (diperbarui ?? DateTime.now())
          .toUtc()
          .toIso8601String(),
      KategoriSkema.isDeleted: isDeleted,
      if (diarsipkan != null)
        KategoriSkema.diarsipkan: diarsipkan?.toUtc().toIso8601String(),
    };
  }
}

abstract final class KategoriSkema {
  static const String tabel = 'kategori';
  static const String id = 'id';
  static const String nama = 'nama';
  static const String tipe = 'tipe';
  static const String idSubKategori = 'id_sub_kategori';
  static const String diperbarui = 'diperbarui';
  static const String isDeleted = 'is_deleted';
  static const String diarsipkan = 'diarsipkan';
}
