// path: lib/fitur/pesanan/model/pesanan_model.dart
// diubah: Penamaan metode diseragamkan dan logika Firebase disesuaikan.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:share_global_saya/src/utils/parser_util.dart';

part 'pesanan_model.freezed.dart';

@freezed
abstract class PesananModel with _$PesananModel {
  const PesananModel._();

  const factory PesananModel({
    required String id,
    required String idPelanggan,
    required String idPaket,
    required DateTime tanggal,
    required String status,
    DateTime? diperbarui,
    @Default(false) bool isDeleted,
    DateTime? diarsipkan,
  }) = _PesananModel;

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

  factory PesananModel.fromSqlite(Map<String, dynamic> map) {
    return PesananModel(
      id: ParserUtil.parseString(map[PesananSkema.id]),
      idPelanggan: ParserUtil.parseString(map[PesananSkema.idPelanggan]),
      idPaket: ParserUtil.parseString(map[PesananSkema.idPaket]),
      tanggal:
          _parseTanggal(map[PesananSkema.tanggal]) ??
          (throw ArgumentError.notNull('tanggal dari SQLite')),
      status: ParserUtil.parseString(
        map[PesananSkema.status],
        defaultValue: 'baru',
      ),
      diperbarui: _parseTanggal(map[PesananSkema.diperbarui]),
      isDeleted: ParserUtil.parseBool(map[PesananSkema.isDeleted]),
      diarsipkan: _parseTanggal(map[PesananSkema.diarsipkan]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      PesananSkema.id: id,
      PesananSkema.idPelanggan: idPelanggan,
      PesananSkema.idPaket: idPaket,
      PesananSkema.tanggal: tanggal.toUtc().toIso8601String(),
      PesananSkema.status: status,
      PesananSkema.diperbarui: diperbarui?.toUtc().toIso8601String(),
      PesananSkema.isDeleted: isDeleted ? 1 : 0,
      PesananSkema.diarsipkan: diarsipkan?.toUtc().toIso8601String(),
    };
  }

  // =========================
  // FIREBASE
  // =========================

  factory PesananModel.fromFirebase(String id, Map<String, dynamic> data) {
    return PesananModel(
      id: id,
      idPelanggan: ParserUtil.parseString(data[PesananSkema.idPelanggan]),
      idPaket: ParserUtil.parseString(data[PesananSkema.idPaket]),
      tanggal:
          _parseTanggal(data[PesananSkema.tanggal]) ??
          (throw ArgumentError.notNull('tanggal dari Firebase')),
      status: ParserUtil.parseString(
        data[PesananSkema.status],
        defaultValue: 'baru',
      ),
      diperbarui: _parseTanggal(data[PesananSkema.diperbarui]),
      isDeleted: ParserUtil.parseBool(data[PesananSkema.isDeleted]),
      diarsipkan: _parseTanggal(data[PesananSkema.diarsipkan]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      PesananSkema.id: id,
      PesananSkema.idPelanggan: idPelanggan,
      PesananSkema.idPaket: idPaket,
      PesananSkema.tanggal: Timestamp.fromDate(tanggal.toUtc()),
      PesananSkema.status: status,
      PesananSkema.diperbarui: FieldValue.serverTimestamp(),
      PesananSkema.isDeleted: isDeleted,
      if (diarsipkan != null)
        PesananSkema.diarsipkan: Timestamp.fromDate(diarsipkan!.toUtc()),
    };
  }
}

abstract final class PesananSkema {
  static const String tabel = 'pesanan';
  static const String id = 'id';
  static const String idPelanggan = 'id_pelanggan';
  static const String idPaket = 'id_paket';
  static const String tanggal = 'tanggal';
  static const String status = 'status';
  static const String diperbarui = 'diperbarui';
  static const String isDeleted = 'isDeleted';
  static const String diarsipkan = 'diarsipkan';
}
