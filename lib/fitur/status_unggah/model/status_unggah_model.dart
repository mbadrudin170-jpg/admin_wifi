// path: lib/fitur/status_unggah/model/status_unggah_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:share_global_saya/src/utils/parser_util.dart';

part 'status_unggah_model.freezed.dart';

/// Model ini merepresentasikan satu baris dalam tabel `status_unggah`.
/// Tabel menyimpan status sinkronisasi per tabel (kolom `tabel` sebagai
/// PRIMARY KEY), bukan bendera tunggal; bendera `perlu_unggah` global
/// disimpan di tabel `status_aplikasi` oleh `StatusUnggahOperasi`.
@freezed
abstract class StatusUnggahModel with _$StatusUnggahModel {
  const StatusUnggahModel._();

  const factory StatusUnggahModel({
    /// Nama tabel yang dilacak; kolom `tabel` (PRIMARY KEY).
    required String namaTabel,

    /// Status sinkronisasi (integer; 0 = sinkron, selain itu ada perubahan).
    required int status,

    /// Daftar ID baris yang perlu diunggah, dipisahkan koma.
    required String ids,

    /// Waktu terakhir baris diperbarui.
    DateTime? diperbarui,
  }) = _StatusUnggahModel;

  /// Konversi dari Map (yang didapat dari database SQLite) ke model.
  factory StatusUnggahModel.fromSqlite(Map<String, dynamic> map) {
    return StatusUnggahModel(
      namaTabel: ParserUtil.parseString(map[StatusUnggahSkema.namaTabel]),
      status: ParserUtil.parseInt(map[StatusUnggahSkema.status]),
      ids: ParserUtil.parseString(map[StatusUnggahSkema.ids]),
      diperbarui: ParserUtil.parseDateTime(
        map[StatusUnggahSkema.diperbarui],
      )?.toLocal(),
    );
  }

  /// Konversi dari model ke Map untuk disimpan ke database SQLite (UTC).
  Map<String, dynamic> toSqlite() {
    return {
      StatusUnggahSkema.namaTabel: namaTabel,
      StatusUnggahSkema.status: status,
      StatusUnggahSkema.ids: ids,
      StatusUnggahSkema.diperbarui: diperbarui?.toUtc().toIso8601String(),
    };
  }
}

abstract final class StatusUnggahSkema {
  static const String tabel = 'status_unggah';
  static const String namaTabel = 'tabel';
  static const String status = 'status';
  static const String ids = 'ids';
  static const String diperbarui = 'diperbarui';
}
