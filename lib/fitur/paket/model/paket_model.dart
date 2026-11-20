// path: lib/fitur/paket/model/paket_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:share_global_saya/src/utils/parser_util.dart';

part 'paket_model.freezed.dart';

enum TipeDurasi {
  menit,
  jam,
  hari,
  bulan;

  String get label => switch (this) {
    TipeDurasi.menit => 'Menit',
    TipeDurasi.jam => 'Jam',
    TipeDurasi.hari => 'Hari',
    TipeDurasi.bulan => 'Bulan',
  };
}

@freezed
abstract class PaketModel with _$PaketModel {
  const PaketModel._();

  const factory PaketModel({
    required String id,
    required String nama,
    required int harga,
    required int durasi,
    required TipeDurasi tipe,
    @Default(0) int poinHadiah,
    @Default(0) int poinPenukaran,
    @Default(true) bool isPublic,
    DateTime? diperbarui,
    @Default(false) bool isDeleted,
    DateTime? diarsipkan,
  }) = _PaketModel;

  // =========================
  // PARSER
  // =========================

  /// Firestore menyimpan `Timestamp`; SQLite dan Supabase menyimpan
  /// ISO-8601 string (UTC). Keduanya dinormalisasi ke waktu lokal.
  static DateTime? _parseTanggal(dynamic value) {
    return ParserUtil.parseDateTime(value)?.toLocal();
  }

  /// Nilai kosong (`null`) dianggap `true`, sama dengan `@Default(true)`.
  static bool _parseIsPublic(dynamic value) {
    return value == null ? true : ParserUtil.parseBool(value);
  }

  /// Satu pintu untuk SQLite, Firebase, dan Supabase karena ketiganya
  /// memakai nama kunci yang sama dari [PaketSkema].
  ///
  /// [id] diisi bila id berasal dari luar map (mis. id dokumen Firestore).
  static PaketModel _fromMap(String? id, Map<String, dynamic> map) {
    return PaketModel(
      id: id ?? ParserUtil.parseString(map[PaketSkema.id]),
      nama: ParserUtil.parseString(map[PaketSkema.nama]),
      harga: ParserUtil.parseInt(map[PaketSkema.harga]),
      durasi: ParserUtil.parseInt(map[PaketSkema.durasi]),
      tipe:
          ParserUtil.safeParseEnum(
            TipeDurasi.values,
            ParserUtil.parseStringOrNull(map[PaketSkema.tipe]),
          ) ??
          TipeDurasi.hari,
      poinHadiah: ParserUtil.parseInt(map[PaketSkema.poinHadiah]),
      poinPenukaran: ParserUtil.parseInt(map[PaketSkema.poinPenukaran]),
      isPublic: _parseIsPublic(map[PaketSkema.isPublic]),
      isDeleted: ParserUtil.parseBool(map[PaketSkema.isDeleted]),
      diperbarui: _parseTanggal(map[PaketSkema.diperbarui]),
      diarsipkan: _parseTanggal(map[PaketSkema.diarsipkan]),
    );
  }

  // =========================
  // SQLITE
  // =========================

  factory PaketModel.fromSqlite(Map<String, dynamic> map) {
    return _fromMap(null, map);
  }

  Map<String, dynamic> toSqlite() {
    return {
      PaketSkema.id: id,
      PaketSkema.nama: nama,
      PaketSkema.harga: harga,
      PaketSkema.durasi: durasi,
      PaketSkema.tipe: tipe.name,
      PaketSkema.poinHadiah: poinHadiah,
      PaketSkema.poinPenukaran: poinPenukaran,
      PaketSkema.isPublic: isPublic ? 1 : 0,
      PaketSkema.isDeleted: isDeleted ? 1 : 0,
      PaketSkema.diperbarui: (diperbarui ?? DateTime.now())
          .toUtc()
          .toIso8601String(),
      PaketSkema.diarsipkan: diarsipkan?.toUtc().toIso8601String(),
    };
  }

  // =========================
  // SUPABASE
  // =========================

  /// Supabase (PostgREST) mengembalikan baris sebagai `Map<String, dynamic>`.
  factory PaketModel.fromSupabase(Map<String, dynamic> map) {
    return _fromMap(null, map);
  }

  /// Waktu ditulis dalam ISO-8601 UTC. `diarsipkan` dikirim `null` secara
  /// eksplisit agar kolom ikut dikosongkan saat upsert.
  Map<String, dynamic> toSupabase() {
    return {
      PaketSkema.id: id,
      PaketSkema.nama: nama,
      PaketSkema.harga: harga,
      PaketSkema.durasi: durasi,
      PaketSkema.tipe: tipe.name,
      PaketSkema.poinHadiah: poinHadiah,
      PaketSkema.poinPenukaran: poinPenukaran,
      PaketSkema.isPublic: isPublic,
      PaketSkema.isDeleted: isDeleted,
      PaketSkema.diperbarui: (diperbarui ?? DateTime.now())
          .toUtc()
          .toIso8601String(),
      PaketSkema.diarsipkan: diarsipkan?.toUtc().toIso8601String(),
    };
  }
}

/// Nilai konstanta harus sama persis dengan nama kolom SQLite, field
/// Firestore, dan kolom Supabase.
abstract final class PaketSkema {
  static const String tabel = 'paket';
  static const String id = 'id';
  static const String nama = 'nama';
  static const String harga = 'harga';
  static const String durasi = 'durasi';
  static const String tipe = 'tipe';
  static const String jumlahPoin = 'jumlah_poin';
  static const String diperbarui = 'diperbarui';
  static const String isDeleted = 'is_deleted';
  static const String diarsipkan = 'diarsipkan';
  static const String poinHadiah = 'poin_hadiah';
  static const String poinPenukaran = 'poin_penukaran';
  static const String isPublic = 'is_public';
}
