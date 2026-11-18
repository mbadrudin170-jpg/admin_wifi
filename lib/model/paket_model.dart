// path: lib/model/paket_model.dart
// ditambahkan: Import cloud_firestore untuk FieldValue dan Timestamp.
// diubah: Menghapus field `jumlahPoin` yang tidak lagi digunakan.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:share_global_saya/src/utils/parser_util.dart';

part 'paket_model.freezed.dart';

enum TipeDurasi {
  menit,
  jam,
  hari,
  bulan;

  String get label {
    switch (this) {
      case TipeDurasi.menit:
        return 'Menit';
      case TipeDurasi.jam:
        return 'Jam';
      case TipeDurasi.hari:
        return 'Hari';
      case TipeDurasi.bulan:
        return 'Bulan';
    }
  }
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
  // PARSER UTIL
  // =========================

  /// Firestore menyimpan `Timestamp`; SQLite menyimpan ISO-8601 string (UTC).
  /// Keduanya dinormalisasi lewat [ParserUtil.parseDateTime].
  static DateTime? _parseTanggal(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toLocal();
    }

    return ParserUtil.parseDateTime(value)?.toLocal();
  }

  // =========================
  // SQLITE
  // =========================

  factory PaketModel.fromSqlite(Map<String, dynamic> map) {
    return PaketModel(
      id: ParserUtil.parseString(map[PaketSkema.id]),
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
      isPublic: ParserUtil.parseBool(map[PaketSkema.isPublic]),
      isDeleted: ParserUtil.parseBool(map[PaketSkema.isDeleted]),
      diperbarui: _parseTanggal(map[PaketSkema.diperbarui]),
      diarsipkan: _parseTanggal(map[PaketSkema.diarsipkan]),
    );
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
      PaketSkema.diperbarui: diperbarui?.toUtc().toIso8601String(),
      PaketSkema.diarsipkan: diarsipkan?.toUtc().toIso8601String(),
    };
  }

  // =========================
  // FIREBASE
  // =========================

  factory PaketModel.fromFirebase(String id, Map<String, dynamic> data) {
    return PaketModel(
      id: id,
      nama: ParserUtil.parseString(data[PaketSkema.nama]),
      harga: ParserUtil.parseInt(data[PaketSkema.harga]),
      durasi: ParserUtil.parseInt(data[PaketSkema.durasi]),
      tipe:
          ParserUtil.safeParseEnum(
            TipeDurasi.values,
            ParserUtil.parseStringOrNull(data[PaketSkema.tipe]),
          ) ??
          TipeDurasi.hari,
      poinHadiah: ParserUtil.parseInt(data[PaketSkema.poinHadiah]),
      poinPenukaran: ParserUtil.parseInt(data[PaketSkema.poinPenukaran]),
      isPublic: ParserUtil.parseBool(data[PaketSkema.isPublic]),
      isDeleted: ParserUtil.parseBool(data[PaketSkema.isDeleted]),
      diperbarui: _parseTanggal(data[PaketSkema.diperbarui]),
      diarsipkan: _parseTanggal(data[PaketSkema.diarsipkan]),
    );
  }

  // diubah: Menggunakan FieldValue.serverTimestamp() dan Timestamp untuk konsistensi.
  Map<String, dynamic> toFirebase() {
    final Map<String, dynamic> data = {
      PaketSkema.id: id,
      PaketSkema.nama: nama,
      PaketSkema.harga: harga,
      PaketSkema.durasi: durasi,
      PaketSkema.tipe: tipe.name,
      PaketSkema.poinHadiah: poinHadiah,
      PaketSkema.poinPenukaran: poinPenukaran,
      PaketSkema.isPublic: isPublic,
      PaketSkema.isDeleted: isDeleted,
      PaketSkema.diperbarui: FieldValue.serverTimestamp(),
    };
    if (diarsipkan != null) {
      data[PaketSkema.diarsipkan] = Timestamp.fromDate(diarsipkan!.toUtc());
    }
    return data;
  }
}

abstract final class PaketSkema {
  static const String tabel = 'paket';
  static const String id = 'id';
  static const String nama = 'nama';
  static const String harga = 'harga';
  static const String durasi = 'durasi';
  static const String tipe = 'tipe';
  static const String jumlahPoin = 'jumlahPoin';
  static const String diperbarui = 'diperbarui';
  static const String isDeleted = 'isDeleted';
  static const String diarsipkan = 'diarsipkan';
  static const String poinHadiah = 'poin_hadiah';
  static const String poinPenukaran = 'poin_penukaran';
  static const String isPublic = 'isPublic';
}
