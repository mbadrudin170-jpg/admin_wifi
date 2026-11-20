// path: lib/fitur/pelanggan/model/pelanggan_model.dart
// diubah: Logika Firebase disesuaikan dengan standar Timestamp.
// diubah: Direfactor menggunakan Freezed (abstract class + const factory).


import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:share_global_saya/src/utils/parser_util.dart';

part 'pelanggan_model.freezed.dart';

@freezed
abstract class PelangganModel with _$PelangganModel {
  const PelangganModel._();

  const factory PelangganModel({
    required String id,
    required String nama,
    required String telepon,
    required String alamat,
    required String password,
    @Default('') String macAddress,
    @Default(false) bool isDeleted,
    DateTime? diperbarui,
    DateTime? diarsipkan,
  }) = _PelangganModel;

  // =========================
  // PARSER UTIL
  // =========================

  /// Firestore menyimpan `Timestamp`; SQLite menyimpan ISO-8601 string (UTC).
  /// Keduanya dinormalisasi lewat [ParserUtil.parseDateTime].
  static DateTime? _parseTanggal(dynamic value) {
    return ParserUtil.parseDateTime(value)?.toLocal();
  }

  // =========================
  // SQLITE
  // =========================

  factory PelangganModel.fromSqlite(Map<String, dynamic> map) {
    return PelangganModel(
      id: ParserUtil.parseString(map[PelangganSkema.id]),
      nama: ParserUtil.parseString(map[PelangganSkema.nama]),
      telepon: ParserUtil.parseString(map[PelangganSkema.telepon]),
      alamat: ParserUtil.parseString(map[PelangganSkema.alamat]),
      password: ParserUtil.parseString(map[PelangganSkema.password]),
      macAddress: ParserUtil.parseString(map[PelangganSkema.macAddress]),
      isDeleted: ParserUtil.parseBool(map[PelangganSkema.isDeleted]),
      diperbarui: _parseTanggal(map[PelangganSkema.diperbarui]),
      diarsipkan: _parseTanggal(map[PelangganSkema.diarsipkan]),
    );
  }

  /// Supabase mengembalikan baris sebagai `Map<String, dynamic>` dengan
  /// kunci yang sama dengan SQLite, jadi parsing sama dengan fromSqlite.
  factory PelangganModel.fromSupabase(Map<String, dynamic> map) {
    return PelangganModel.fromSqlite(map);
  }

  Map<String, dynamic> toSqlite() {
    return {
      PelangganSkema.id: id,
      PelangganSkema.nama: nama,
      PelangganSkema.telepon: telepon,
      PelangganSkema.alamat: alamat,
      PelangganSkema.password: password,
      PelangganSkema.macAddress: macAddress,
      PelangganSkema.isDeleted: isDeleted ? 1 : 0,
      PelangganSkema.diperbarui: diperbarui?.toUtc().toIso8601String(),
      PelangganSkema.diarsipkan: diarsipkan?.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabase() {
    final Map<String, dynamic> data = {
      PelangganSkema.id: id,
      PelangganSkema.nama: nama,
      PelangganSkema.telepon: telepon,
      PelangganSkema.alamat: alamat,
      PelangganSkema.password: password,
      PelangganSkema.macAddress: macAddress,
      PelangganSkema.isDeleted: isDeleted,
      PelangganSkema.diperbarui: (diperbarui ?? DateTime.now()).toUtc().toIso8601String(),
    };
    if (diarsipkan != null) {
      data[PelangganSkema.diarsipkan] = diarsipkan?.toUtc().toIso8601String();
    }
    return data;
  }
}

abstract final class PelangganSkema {
  static const String tabel = 'pelanggan';
  static const String id = 'id';
  static const String nama = 'nama';
  static const String telepon = 'telepon';
  static const String alamat = 'alamat';
  static const String password = 'password';
  static const String macAddress = 'mac_address';
  static const String status = 'status';
  static const String diperbarui = 'diperbarui';
  static const String diarsipkan = 'diarsipkan';
  static const String isDeleted = 'is_deleted';
}
