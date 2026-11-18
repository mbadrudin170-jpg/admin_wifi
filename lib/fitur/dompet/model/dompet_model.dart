// path: lib/model/dompet_model.dart
// diubah: Menggunakan UUID untuk ID dan memastikan non-nullable.
// diubah: Direfactor menggunakan Freezed (abstract class + const factory).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:share_global_saya/src/utils/parser_util.dart';

part 'dompet_model.freezed.dart';

@freezed
abstract class DompetModel with _$DompetModel {
  const DompetModel._();

  const factory DompetModel({
    required String id,
    required String namaDompet,
    required double saldo,
    DateTime? diperbarui,
    @Default(false) bool isDeleted,
    DateTime? diarsipkan,
  }) = _DompetModel;

  /// Firestore menyimpan `Timestamp`; SQLite menyimpan ISO-8601 string (UTC).
  /// Keduanya dinormalisasi lewat [ParserUtil.parseDateTime].
  static DateTime? _parseTanggal(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toLocal();
    }

    return ParserUtil.parseDateTime(value)?.toLocal();
  }

  // Konversi dari format database lokal (SQLite)
  // diubah: nama metode dari fromMap menjadi fromSqlite untuk konsistensi
  factory DompetModel.fromSqlite(Map<String, dynamic> map) {
    return DompetModel(
      id: ParserUtil.parseString(map[DompetSkema.id]),
      namaDompet: ParserUtil.parseString(map[DompetSkema.namaDompet]),
      saldo: ParserUtil.parseDouble(map[DompetSkema.saldo]),
      diperbarui: _parseTanggal(map[DompetSkema.diperbarui]),
      isDeleted: ParserUtil.parseBool(map[DompetSkema.isDeleted]),
      diarsipkan: _parseTanggal(map[DompetSkema.diarsipkan]),
    );
  }

  // Konversi ke format database lokal (SQLite)
  Map<String, dynamic> toSqlite() {
    return {
      DompetSkema.id: id,
      DompetSkema.namaDompet: namaDompet,
      DompetSkema.saldo: saldo,
      DompetSkema.diperbarui: diperbarui?.toUtc().toIso8601String(),
      DompetSkema.isDeleted: isDeleted ? 1 : 0,
      DompetSkema.diarsipkan: diarsipkan?.toUtc().toIso8601String(),
    };
  }

  // --- Interaksi Firestore ---
  // saya ubah ke fromFirebase
  // ditambahkan: Factory constructor dari data Firestore
  factory DompetModel.fromFirebase(String id, Map<String, dynamic> data) {
    return DompetModel(
      id: id,
      namaDompet: ParserUtil.parseString(data[DompetSkema.namaDompet]),
      saldo: ParserUtil.parseDouble(data[DompetSkema.saldo]),
      diperbarui: _parseTanggal(data[DompetSkema.diperbarui]),
      isDeleted: ParserUtil.parseBool(data[DompetSkema.isDeleted]),
      diarsipkan: _parseTanggal(data[DompetSkema.diarsipkan]),
    );
  }

  // ditambahkan: Metode konversi ke format Firestore
  Map<String, dynamic> toFirebase() {
    // saya ubah ke toFirebase
    return {
      DompetSkema.namaDompet: namaDompet,
      DompetSkema.saldo: saldo,
      DompetSkema.diperbarui: FieldValue.serverTimestamp(),
      DompetSkema.isDeleted: isDeleted,
      if (diarsipkan != null)
        DompetSkema.diarsipkan: Timestamp.fromDate(diarsipkan!.toUtc()),
    };
  }
}

abstract final class DompetSkema {
  static const String tabel = 'dompet';
  static const String id = 'id';
  static const String namaDompet = 'namaDompet';
  static const String saldo = 'saldo';
  static const String diperbarui = 'diperbarui';
  static const String isDeleted = 'isDeleted';
  static const String diarsipkan = 'diarsipkan';
}
