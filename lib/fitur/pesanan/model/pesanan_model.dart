// path: lib/fitur/pesanan/model/pesanan_model.dart
// diubah: Penamaan metode diseragamkan dan logika Firebase disesuaikan.
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

  /// Supabase mengembalikan baris sebagai `Map<String, dynamic>` dengan
  /// kunci yang sama dengan SQLite, jadi parsing sama dengan fromSqlite.
  factory PesananModel.fromSupabase(Map<String, dynamic> map) {
    return PesananModel.fromSqlite(map);
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

  Map<String, dynamic> toSupabase() {
    return {
      PesananSkema.id: id,
      PesananSkema.idPelanggan: idPelanggan,
      PesananSkema.idPaket: idPaket,
      PesananSkema.tanggal: tanggal.toUtc().toIso8601String(),
      PesananSkema.status: status,
      PesananSkema.diperbarui: (diperbarui ?? DateTime.now()).toUtc().toIso8601String(),
      PesananSkema.isDeleted: isDeleted,
      if (diarsipkan != null)
        PesananSkema.diarsipkan: diarsipkan?.toUtc().toIso8601String(),
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
