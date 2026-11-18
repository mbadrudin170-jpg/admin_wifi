// path: lib/fitur/kritik_saran/model/kritik_saran_model.dart
// diubah: Penamaan metode diseragamkan dan logika Firebase diperbaiki.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:share_global_saya/src/utils/parser_util.dart';

part 'kritik_saran_model.freezed.dart';

@freezed
abstract class KritikSaranModel with _$KritikSaranModel {
  const KritikSaranModel._();

  const factory KritikSaranModel({
    required String id,
    required String isi,
    required DateTime tanggal,
    required String userId,
    DateTime? diperbarui,
  }) = _KritikSaranModel;

  /// Firestore menyimpan `Timestamp`; SQLite menyimpan ISO-8601 string (UTC).
  /// Keduanya dinormalisasi lewat [ParserUtil.parseDateTime].
  static DateTime? _parseTanggal(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toLocal();
    }

    return ParserUtil.parseDateTime(value)?.toLocal();
  }

  // diubah: Nama metode dari fromMap menjadi fromSqlite
  factory KritikSaranModel.fromSqlite(Map<String, dynamic> map) {
    return KritikSaranModel(
      id: ParserUtil.parseStringOrNull(map[KritikSaranSkema.id]) ?? '',
      isi: ParserUtil.parseString(map[KritikSaranSkema.isi]),
      userId: ParserUtil.parseString(map[KritikSaranSkema.userId]),
      tanggal:
          _parseTanggal(map[KritikSaranSkema.tanggal]) ??
          (throw ArgumentError.notNull('tanggal dari SQLite')),
      diperbarui: _parseTanggal(map[KritikSaranSkema.diperbarui]),
    );
  }

  // diubah: Nama metode dari toMapForSqlite menjadi toSqlite
  Map<String, dynamic> toSqlite() {
    return {
      KritikSaranSkema.id: id,
      KritikSaranSkema.isi: isi,
      KritikSaranSkema.tanggal: tanggal.toUtc().toIso8601String(),
      KritikSaranSkema.userId: userId,
      KritikSaranSkema.diperbarui: diperbarui?.toUtc().toIso8601String(),
    };
  }

  // ditambahkan: Factory fromFirebase
  factory KritikSaranModel.fromFirebase(String id, Map<String, dynamic> data) {
    return KritikSaranModel(
      id: id,
      isi: ParserUtil.parseString(data[KritikSaranSkema.isi]),
      userId: ParserUtil.parseString(data[KritikSaranSkema.userId]),
      tanggal:
          _parseTanggal(data[KritikSaranSkema.tanggal]) ??
          (throw ArgumentError.notNull('tanggal dari Firebase')),
      diperbarui: _parseTanggal(data[KritikSaranSkema.diperbarui]),
    );
  }

  // diubah: Nama metode dan logika diperbarui diubah
  Map<String, dynamic> toFirebase() {
    return {
      KritikSaranSkema.id: id,
      KritikSaranSkema.isi: isi,
      KritikSaranSkema.tanggal: Timestamp.fromDate(tanggal.toUtc()),
      KritikSaranSkema.userId: userId,
      KritikSaranSkema.diperbarui: FieldValue.serverTimestamp(),
    };
  }
}

abstract final class KritikSaranSkema {
  static const String tabel = 'kritik_saran';
  static const String id = 'id';
  static const String isi = 'isi';
  static const String tanggal = 'tanggal';
  static const String userId = 'userId';
  static const String diperbarui = 'diperbarui';
}
