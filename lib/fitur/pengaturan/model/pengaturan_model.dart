// path: lib/fitur/pengaturan/model/pengaturan_model.dart
// diubah: Menghapus properti 'id' yang tidak diperlukan karena tabel pengaturan tidak memilikinya.


import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:share_global_saya/src/utils/parser_util.dart';

part 'pengaturan_model.freezed.dart';

@freezed
abstract class PengaturanModel with _$PengaturanModel {
  const PengaturanModel._();

  const factory PengaturanModel({
    @Default(24) int intervalSinkronisasiOtomatis,
    @Default(30) int hapusOtomatisDataArsip,
    @Default(false) bool modePemeliharaan,
    @Default('') String infoPemeliharaan,
    DateTime? diperbarui,
  }) = _PengaturanModel;

  /// Firestore menyimpan `Timestamp`; SQLite menyimpan ISO-8601 string (UTC).
  /// Keduanya dinormalisasi lewat [ParserUtil.parseDateTime].
  static DateTime? _parseTanggal(dynamic value) {
    return ParserUtil.parseDateTime(value)?.toLocal();
  }

  // =========================
  // SQLITE
  // =========================

  factory PengaturanModel.fromSqlite(Map<String, dynamic> map) {
    return PengaturanModel(
      intervalSinkronisasiOtomatis: ParserUtil.parseInt(
        map[PengaturanSkema.intervalSinkronisasiOtomatis],
        defaultValue: 24,
      ),
      hapusOtomatisDataArsip: ParserUtil.parseInt(
        map[PengaturanSkema.hapusOtomatisDataArsip],
        defaultValue: 30,
      ),
      modePemeliharaan: ParserUtil.parseBool(
        map[PengaturanSkema.modePemeliharaan],
      ),
      infoPemeliharaan: ParserUtil.parseString(
        map[PengaturanSkema.infoPemeliharaan],
      ),
      diperbarui: _parseTanggal(map[PengaturanSkema.diperbarui]),
    );
  }

  /// Supabase mengembalikan baris sebagai `Map<String, dynamic>` dengan
  /// kunci yang sama dengan SQLite, jadi parsing sama dengan fromSqlite.
  factory PengaturanModel.fromSupabase(Map<String, dynamic> map) {
    return PengaturanModel.fromSqlite(map);
  }

  Map<String, dynamic> toSqlite() {
    return {
      PengaturanSkema.intervalSinkronisasiOtomatis:
          intervalSinkronisasiOtomatis,
      PengaturanSkema.hapusOtomatisDataArsip: hapusOtomatisDataArsip,
      PengaturanSkema.modePemeliharaan: modePemeliharaan ? 1 : 0,
      PengaturanSkema.infoPemeliharaan: infoPemeliharaan,
      PengaturanSkema.diperbarui: DateTime.now().toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabase() {
    return {
      PengaturanSkema.intervalSinkronisasiOtomatis:
          intervalSinkronisasiOtomatis,
      PengaturanSkema.hapusOtomatisDataArsip: hapusOtomatisDataArsip,
      PengaturanSkema.modePemeliharaan: modePemeliharaan,
      PengaturanSkema.infoPemeliharaan: infoPemeliharaan,
      PengaturanSkema.diperbarui: (diperbarui ?? DateTime.now()).toUtc().toIso8601String(),
    };
  }
}

abstract final class PengaturanSkema {
  static const String tabel = 'pengaturan';
  static const String intervalSinkronisasiOtomatis =
      'interval_sinkronisasi_otomatis';
  static const String hapusOtomatisDataArsip = 'hapus_otomatis_data_arsip';
  static const String diperbarui = 'diperbarui';
  static const String modePemeliharaan = 'mode_pemeliharaan';
  static const String infoPemeliharaan = 'info_pemeliharaan';
}
