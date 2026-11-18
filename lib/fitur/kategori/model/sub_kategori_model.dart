// path: lib/fitur/kategori/model/sub_kategori_model.dart
// diubah: Penamaan metode diseragamkan (fromSqlite, toSqlite, fromFirebase, toFirebase).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:share_global_saya/src/utils/parser_util.dart';

part 'sub_kategori_model.freezed.dart';

@freezed
abstract class SubKategoriModel with _$SubKategoriModel {
  const SubKategoriModel._();

  const factory SubKategoriModel({
    required String id,
    required String nama,
    required String idKategori,
    DateTime? diperbarui,
    @Default(false) bool isDeleted,
    DateTime? diarsipkan,
  }) = _SubKategoriModel;

  /// Firestore menyimpan `Timestamp`; SQLite menyimpan ISO-8601 string (UTC).
  /// Keduanya dinormalisasi lewat [ParserUtil.parseDateTime].
  static DateTime? _parseTanggal(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toLocal();
    }

    return ParserUtil.parseDateTime(value)?.toLocal();
  }

  // diubah: Nama metode diubah dari fromMap menjadi fromSqlite
  factory SubKategoriModel.fromSqlite(Map<String, dynamic> map) {
    return SubKategoriModel(
      id: ParserUtil.parseString(map[SubKategoriSkema.id]),
      nama: ParserUtil.parseString(map[SubKategoriSkema.nama]),
      idKategori: ParserUtil.parseString(map[SubKategoriSkema.idKategori]),
      diperbarui: _parseTanggal(map[SubKategoriSkema.diperbarui]),
      isDeleted: ParserUtil.parseBool(map[SubKategoriSkema.isDeleted]),
      diarsipkan: _parseTanggal(map[SubKategoriSkema.diarsipkan]),
    );
  }

  // diubah: Nama metode diubah dari toMapForSqlite menjadi toSqlite
  Map<String, dynamic> toSqlite() {
    return {
      SubKategoriSkema.id: id,
      SubKategoriSkema.nama: nama,
      SubKategoriSkema.idKategori: idKategori,
      SubKategoriSkema.diperbarui: diperbarui?.toUtc().toIso8601String(),
      SubKategoriSkema.isDeleted: isDeleted ? 1 : 0,
      SubKategoriSkema.diarsipkan: diarsipkan?.toUtc().toIso8601String(),
    };
  }

  // ditambahkan: Factory fromFirebase
  factory SubKategoriModel.fromFirebase(String id, Map<String, dynamic> data) {
    return SubKategoriModel(
      id: id,
      nama: ParserUtil.parseString(data[SubKategoriSkema.nama]),
      idKategori: ParserUtil.parseString(data[SubKategoriSkema.idKategori]),
      diperbarui: _parseTanggal(data[SubKategoriSkema.diperbarui]),
      isDeleted: ParserUtil.parseBool(data[SubKategoriSkema.isDeleted]),
      diarsipkan: _parseTanggal(data[SubKategoriSkema.diarsipkan]),
    );
  }

  // diubah: Nama metode diubah dari toMapForFirebase menjadi toFirebase
  Map<String, dynamic> toFirebase() {
    return {
      SubKategoriSkema.id: id,
      SubKategoriSkema.nama: nama,
      SubKategoriSkema.idKategori: idKategori,
      SubKategoriSkema.diperbarui: FieldValue.serverTimestamp(),
      SubKategoriSkema.isDeleted: isDeleted,
      if (diarsipkan != null)
        SubKategoriSkema.diarsipkan: Timestamp.fromDate(diarsipkan!.toUtc()),
    };
  }
}

abstract final class SubKategoriSkema {
  static const String tabel = 'sub_kategori';
  static const String id = 'id';
  static const String nama = 'nama';
  static const String idKategori = 'id_kategori';
  static const String diperbarui = 'diperbarui';
  static const String isDeleted = 'isDeleted';
  static const String diarsipkan = 'diarsipkan';
}
