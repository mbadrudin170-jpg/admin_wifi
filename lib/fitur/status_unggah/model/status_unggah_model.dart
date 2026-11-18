// path: lib/model/status_unggah_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:share_global_saya/src/utils/parser_util.dart';

part 'status_unggah_model.freezed.dart';

/// Model ini merepresentasikan satu baris tunggal dalam tabel `status_unggah`.
/// Tujuannya adalah untuk bertindak sebagai "bendera" global yang menandakan
/// apakah ada perubahan lokal yang perlu diunggah ke server.
@freezed
abstract class StatusUnggahModel with _$StatusUnggahModel {
  const StatusUnggahModel._();

  const factory StatusUnggahModel({
    /// ID unik untuk baris ini, biasanya akan selalu 1.
    required int id,

    /// Bendera yang menandakan status. `true` jika ada data untuk diunggah,
    /// `false` jika tidak.
    required bool perluUnggah,
  }) = _StatusUnggahModel;

  // diubah: Nama metode diubah dari fromMap menjadi fromSqlite agar lebih jelas tujuannya
  /// Konversi dari Map (yang didapat dari database SQLite) ke model.
  factory StatusUnggahModel.fromSqlite(Map<String, dynamic> map) {
    return StatusUnggahModel(
      id: ParserUtil.parseInt(map[StatusUnggahSkema.id], defaultValue: 1),
      // Database SQLite tidak punya tipe boolean, jadi kita simpan sebagai integer (0 atau 1).
      // Konversi 1 menjadi true, dan lainnya menjadi false.
      perluUnggah: ParserUtil.parseBool(map[StatusUnggahSkema.perluUnggah]),
    );
  }

  // diubah: Nama metode diubah dari toMap menjadi toSqlite agar lebih jelas tujuannya
  /// Konversi dari model ke Map untuk disimpan ke database SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      StatusUnggahSkema.id: id,
      StatusUnggahSkema.perluUnggah: perluUnggah ? 1 : 0,
    };
  }
}

abstract final class StatusUnggahSkema {
  static const String tabel = 'status_unggah';
  static const String id = 'id';
  static const String perluUnggah = 'perlu_unggah';
  static const String namaTabel = 'tabel';
  static const String status = 'status';
  static const String ids = 'ids';
  static const String diperbarui = 'diperbarui';
}
