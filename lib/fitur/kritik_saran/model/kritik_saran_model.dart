// path: lib/fitur/kritik_saran/model/kritik_saran_model.dart
// diubah: Penamaan metode diseragamkan dan logika Firebase diperbaiki.

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

  /// Supabase mengembalikan baris sebagai `Map<String, dynamic>` dengan
  /// kunci yang sama dengan SQLite, jadi parsing sama dengan fromSqlite.
  factory KritikSaranModel.fromSupabase(Map<String, dynamic> map) {
    return KritikSaranModel.fromSqlite(map);
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

  Map<String, dynamic> toSupabase() {
    return {
      KritikSaranSkema.id: id,
      KritikSaranSkema.isi: isi,
      KritikSaranSkema.tanggal: tanggal.toUtc().toIso8601String(),
      KritikSaranSkema.userId: userId,
      KritikSaranSkema.diperbarui: (diperbarui ?? DateTime.now()).toUtc().toIso8601String(),
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
