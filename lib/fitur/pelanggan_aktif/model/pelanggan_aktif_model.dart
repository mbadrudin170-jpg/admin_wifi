// path: lib/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart

import 'package:admin_wifi/enum/status_pembayaran_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:share_global_saya/src/utils/parser_util.dart';

part 'pelanggan_aktif_model.freezed.dart';

/// Konstanta nama tabel dan nama field database `pelanggan_aktif`
/// (snake_case; nilai cocok persis dengan skema `onCreate`/`onUpgrade` —
/// lihat `lib/db/oncreate_sqflite.dart`.
///
/// Kelas terpisah dari `PelangganAktifModel` karena anggota statis tidak
/// boleh senama dengan anggota instance freezed (`conflicting_static_and_instance`).
/// Catatan: nama field `isDeleted` memang camelCase pada skema, jangan diubah.
abstract final class PelangganAktifSkema {
  static const String tabel = 'pelanggan_aktif';

  static const String id = 'id';
  static const String idPelanggan = 'id_pelanggan';
  static const String idPaket = 'id_paket';
  static const String idTransaksi = 'id_transaksi';
  static const String tanggalMulai = 'tanggal_mulai';
  static const String tanggalBerakhir = 'tanggal_berakhir';
  static const String status = 'status';
  static const String diperbarui = 'diperbarui';
  static const String isDeleted = 'isDeleted';
  static const String diarsipkan = 'diarsipkan';
}

@freezed
abstract class PelangganAktifModel with _$PelangganAktifModel {
  const PelangganAktifModel._();

  // diubah (freezed): `id` wajib diisi pemanggil — Freezed tidak bisa memberi
  // default non-konstan (auto-UUID); pemanggil mode baru meneruskan `''` dan
  // PelangganAktifOperasi mengisi UUID saat id kosong.
  const factory PelangganAktifModel({
    required String id,
    required String idPelanggan,
    required String idPaket,
    String? idTransaksi,
    required DateTime tanggalMulai,
    required DateTime tanggalBerakhir,
    required StatusPembayaranEnum status,
    DateTime? diperbarui,
    @Default(false) bool isDeleted,
    DateTime? diarsipkan,
  }) = _PelangganAktifModel;

  /// Firestore menyimpan `Timestamp`; SQLite menyimpan ISO-8601 string.
  /// Keduanya dinormalisasi lewat [ParserUtil.parseDateTime].
  static DateTime? _parseTanggal(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toLocal();
    }

    return ParserUtil.parseDateTime(value)?.toLocal();
  }

  factory PelangganAktifModel.fromSqlite(Map<String, dynamic> map) {
    try {
      // diubah: Key snake_case 'tanggal_mulai' dan 'tanggal_berakhir' disamakan dengan konstanta skema.
      final tanggalMulai = _parseTanggal(map[PelangganAktifSkema.tanggalMulai]);
      final tanggalBerakhir = _parseTanggal(
        map[PelangganAktifSkema.tanggalBerakhir],
      );

      // diubah: Menghapus fallback DateTime.now() yang berbahaya dan menggantinya dengan validasi.
      if (tanggalMulai == null) {
        throw ArgumentError.notNull('tanggal_mulai dari SQLite');
      }
      if (tanggalBerakhir == null) {
        throw ArgumentError.notNull('tanggal_berakhir dari SQLite');
      }

      final model = PelangganAktifModel(
        id: ParserUtil.parseString(map[PelangganAktifSkema.id]),
        idPelanggan: ParserUtil.parseString(
          map[PelangganAktifSkema.idPelanggan],
        ),
        idPaket: ParserUtil.parseString(map[PelangganAktifSkema.idPaket]),
        idTransaksi: ParserUtil.parseStringOrNull(
          map[PelangganAktifSkema.idTransaksi],
        ),
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status:
            ParserUtil.safeParseEnum(
              StatusPembayaranEnum.values,
              ParserUtil.parseStringOrNull(map[PelangganAktifSkema.status]),
            ) ??
            StatusPembayaranEnum.lunas,
        diperbarui: _parseTanggal(map[PelangganAktifSkema.diperbarui]),
        isDeleted: ParserUtil.parseBool(map[PelangganAktifSkema.isDeleted]),
        diarsipkan: _parseTanggal(map[PelangganAktifSkema.diarsipkan]),
      );

      L.i('Data dimuat dari SQLite');
      return model;
    } catch (e, stack) {
      L.e('Gagal parsing SQLite: $map Error: $e $stack');
      rethrow;
    }
  }

  factory PelangganAktifModel.fromFirebase(
    String id,
    Map<String, dynamic> data,
  ) {
    try {
      // diubah: Menghapus fallback DateTime.now() yang berbahaya dan menggantinya dengan validasi.
      // Nama field Firestore disamakan dengan kolom SQLite (snake_case).
      final tanggalMulai = _parseTanggal(
        data[PelangganAktifSkema.tanggalMulai],
      );
      final tanggalBerakhir = _parseTanggal(
        data[PelangganAktifSkema.tanggalBerakhir],
      );

      if (tanggalMulai == null) {
        throw ArgumentError.notNull('tanggal_mulai dari Firebase');
      }
      if (tanggalBerakhir == null) {
        throw ArgumentError.notNull('tanggal_berakhir dari Firebase');
      }

      final model = PelangganAktifModel(
        id: id,
        idPelanggan: ParserUtil.parseString(
          data[PelangganAktifSkema.idPelanggan],
        ),
        idPaket: ParserUtil.parseString(data[PelangganAktifSkema.idPaket]),
        idTransaksi: ParserUtil.parseStringOrNull(
          data[PelangganAktifSkema.idTransaksi],
        ),
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status:
            ParserUtil.safeParseEnum(
              StatusPembayaranEnum.values,
              ParserUtil.parseStringOrNull(data[PelangganAktifSkema.status]),
            ) ??
            StatusPembayaranEnum.lunas,
        diperbarui: _parseTanggal(data[PelangganAktifSkema.diperbarui]),
        isDeleted: ParserUtil.parseBool(data[PelangganAktifSkema.isDeleted]),
        diarsipkan: _parseTanggal(data[PelangganAktifSkema.diarsipkan]),
      );

      L.i('Data ditarik dari Firebase');
      return model;
    } catch (e, stack) {
      L.e('Gagal parsing Firebase: $data Error: $e $stack');
      rethrow;
    }
  }

  Map<String, dynamic> toSqlite() {
    return {
      PelangganAktifSkema.id: id,
      PelangganAktifSkema.idPelanggan: idPelanggan,
      PelangganAktifSkema.idPaket: idPaket,
      PelangganAktifSkema.idTransaksi: idTransaksi,
      PelangganAktifSkema.tanggalMulai: tanggalMulai.toUtc().toIso8601String(),
      PelangganAktifSkema.tanggalBerakhir: tanggalBerakhir
          .toUtc()
          .toIso8601String(),
      PelangganAktifSkema.status: status.name,
      PelangganAktifSkema.diperbarui: diperbarui?.toUtc().toIso8601String(),
      PelangganAktifSkema.isDeleted: isDeleted ? 1 : 0,
      PelangganAktifSkema.diarsipkan: diarsipkan?.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toFirebase() {
    final Map<String, dynamic> data = {
      PelangganAktifSkema.id: id,
      PelangganAktifSkema.idPelanggan: idPelanggan,
      PelangganAktifSkema.idPaket: idPaket,
      PelangganAktifSkema.idTransaksi: idTransaksi,
      PelangganAktifSkema.tanggalMulai: Timestamp.fromDate(
        tanggalMulai.toUtc(),
      ),
      PelangganAktifSkema.tanggalBerakhir: Timestamp.fromDate(
        tanggalBerakhir.toUtc(),
      ),
      PelangganAktifSkema.status: status.name,
      PelangganAktifSkema.isDeleted: isDeleted,
      PelangganAktifSkema.diperbarui: FieldValue.serverTimestamp(),
    };
    if (diarsipkan != null) {
      data[PelangganAktifSkema.diarsipkan] = Timestamp.fromDate(
        diarsipkan!.toUtc(),
      );
    }

    L.api('Firestore/Pelanggan/$id', data, method: 'SET');
    return data;
  }
}
