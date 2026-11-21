// path: lib/fitur/transaksi/model/transaksi_model.dart
// diubah: Model digabungkan dengan RiwayatLanggananModel dan denormalisasi data dihapus.
import 'package:admin_wifi/enum/status_pembayaran_enum.dart';
import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart'; // Impor untuk TipeDurasi

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:share_global_saya/src/utils/parser_util.dart';

part 'transaksi_model.freezed.dart';

// ditambahkan: tipe 'langganan' untuk mencatat aktivasi/penukaran paket.

@freezed
abstract class TransaksiModel with _$TransaksiModel {
  const TransaksiModel._();

  const factory TransaksiModel({
    required String id,
    required DateTime tanggal,
    required String keterangan,
    required double jumlah,
    required TipeTransaksi tipe,
    required String idDompet,
    required String idKategori,
    String? idDompetTujuan,
    String? idPelanggan,
    String? idPaket,
    String? idSubKategori,
    @Default(StatusPembayaranEnum.belumLunas)
    StatusPembayaranEnum statusPembayaran,
    @Default(0) int poinYangDihasilkan,
    @Default(0) int poinYangDigunakan,
    DateTime? diperbarui,
    DateTime? diarsipkan,
    @Default(false) bool isDeleted,
    int? durasiPaket,
    TipeDurasi? tipeDurasiPaket,
    DateTime? tanggalMulai,
    DateTime? tanggalBerakhir,
    @Default(false) bool aktivasiPaket,
  }) = _TransaksiModel;

  /// Firestore menyimpan `Timestamp`; SQLite menyimpan ISO-8601 string (UTC).
  /// Keduanya dinormalisasi lewat [ParserUtil.parseDateTime].
  static DateTime? _parseTanggal(dynamic value) {
    return ParserUtil.parseDateTime(value)?.toLocal();
  }

  factory TransaksiModel.fromSqlite(Map<String, dynamic> map) {
    return TransaksiModel(
      id: ParserUtil.parseString(map[TransaksiSkema.id]),
      tanggal:
          _parseTanggal(map[TransaksiSkema.tanggal]) ??
          (throw ArgumentError.notNull('tanggal dari SQLite')),
      keterangan: ParserUtil.parseString(map[TransaksiSkema.keterangan]),
      jumlah: ParserUtil.parseDouble(map[TransaksiSkema.jumlah]),
      tipe:
          ParserUtil.safeParseEnum(
            TipeTransaksi.values,
            ParserUtil.parseStringOrNull(map[TransaksiSkema.tipe]),
          ) ??
          (throw ArgumentError(
            'TipeTransaksi tidak valid: ${map[TransaksiSkema.tipe]}',
          )),
      idDompet: ParserUtil.parseString(map[TransaksiSkema.idDompet]),
      idKategori: ParserUtil.parseString(map[TransaksiSkema.idKategori]),
      idDompetTujuan: ParserUtil.parseStringOrNull(
        map[TransaksiSkema.idDompetTujuan],
      ),
      idPelanggan: ParserUtil.parseStringOrNull(
        map[TransaksiSkema.idPelanggan],
      ),
      idPaket: ParserUtil.parseStringOrNull(map[TransaksiSkema.idPaket]),
      idSubKategori: ParserUtil.parseStringOrNull(
        map[TransaksiSkema.idSubKategori],
      ),
      statusPembayaran:
          ParserUtil.safeParseEnum(
            StatusPembayaranEnum.values,
            ParserUtil.parseStringOrNull(map[TransaksiSkema.statusPembayaran]),
          ) ??
          StatusPembayaranEnum.belumLunas,
      poinYangDihasilkan: ParserUtil.parseInt(
        map[TransaksiSkema.poinYangDihasilkan],
      ),
      poinYangDigunakan: ParserUtil.parseInt(
        map[TransaksiSkema.poinYangDigunakan],
      ),
      diperbarui: _parseTanggal(map[TransaksiSkema.diperbarui]),
      diarsipkan: _parseTanggal(map[TransaksiSkema.diarsipkan]),
      isDeleted: ParserUtil.parseBool(map[TransaksiSkema.isDeleted]),
      durasiPaket: ParserUtil.parseIntOrNull(map[TransaksiSkema.durasiPaket]),
      tipeDurasiPaket: ParserUtil.safeParseEnum(
        TipeDurasi.values,
        ParserUtil.parseStringOrNull(map[TransaksiSkema.tipeDurasiPaket]),
      ),
      tanggalMulai: _parseTanggal(map[TransaksiSkema.tanggalMulai]),
      tanggalBerakhir: _parseTanggal(map[TransaksiSkema.tanggalBerakhir]),
      aktivasiPaket: ParserUtil.parseBool(map[TransaksiSkema.aktivasiPaket]),
    );
  }

  /// Supabase mengembalikan baris sebagai `Map<String, dynamic>` dengan
  /// kunci yang sama dengan SQLite, jadi parsing sama dengan fromSqlite.
  factory TransaksiModel.fromSupabase(Map<String, dynamic> map) {
    return TransaksiModel.fromSqlite(map);
  }

  Map<String, dynamic> toSqlite() {
    return {
      TransaksiSkema.id: id,
      TransaksiSkema.tanggal: tanggal.toUtc().toIso8601String(),
      TransaksiSkema.keterangan: keterangan,
      TransaksiSkema.jumlah: jumlah,
      TransaksiSkema.tipe: tipe.name,
      TransaksiSkema.idDompet: idDompet,
      TransaksiSkema.idKategori: idKategori,
      TransaksiSkema.idDompetTujuan: idDompetTujuan,
      TransaksiSkema.idPelanggan: idPelanggan,
      TransaksiSkema.idPaket: idPaket,
      TransaksiSkema.idSubKategori: idSubKategori,
      TransaksiSkema.statusPembayaran: statusPembayaran.name,
      TransaksiSkema.poinYangDihasilkan: poinYangDihasilkan,
      TransaksiSkema.poinYangDigunakan: poinYangDigunakan,
      TransaksiSkema.diperbarui: diperbarui?.toUtc().toIso8601String(),
      TransaksiSkema.diarsipkan: diarsipkan?.toUtc().toIso8601String(),
      TransaksiSkema.isDeleted: isDeleted ? 1 : 0,
      TransaksiSkema.durasiPaket: durasiPaket,
      TransaksiSkema.tipeDurasiPaket: tipeDurasiPaket?.name,
      TransaksiSkema.tanggalMulai: tanggalMulai?.toUtc().toIso8601String(),
      TransaksiSkema.tanggalBerakhir: tanggalBerakhir
          ?.toUtc()
          .toIso8601String(),
      TransaksiSkema.aktivasiPaket: aktivasiPaket ? 1 : 0,
    };
  }

  Map<String, dynamic> toSupabase() {
    return {
      TransaksiSkema.id: id,
      TransaksiSkema.tanggal: tanggal.toUtc().toIso8601String(),
      TransaksiSkema.keterangan: keterangan,
      TransaksiSkema.jumlah: jumlah,
      TransaksiSkema.tipe: tipe.name,
      TransaksiSkema.idDompet: idDompet,
      TransaksiSkema.idKategori: idKategori,
      TransaksiSkema.idDompetTujuan: idDompetTujuan,
      TransaksiSkema.idPelanggan: idPelanggan,
      TransaksiSkema.idPaket: idPaket,
      TransaksiSkema.idSubKategori: idSubKategori,
      TransaksiSkema.statusPembayaran: statusPembayaran.name,
      TransaksiSkema.poinYangDihasilkan: poinYangDihasilkan,
      TransaksiSkema.poinYangDigunakan: poinYangDigunakan,
      TransaksiSkema.diperbarui: (diperbarui ?? DateTime.now())
          .toUtc()
          .toIso8601String(),
      TransaksiSkema.diarsipkan: diarsipkan?.toUtc().toIso8601String(),
      TransaksiSkema.isDeleted: isDeleted,
      TransaksiSkema.durasiPaket: durasiPaket,
      TransaksiSkema.tipeDurasiPaket: tipeDurasiPaket?.name,
      TransaksiSkema.tanggalMulai: tanggalMulai?.toUtc().toIso8601String(),
      TransaksiSkema.tanggalBerakhir: tanggalBerakhir
          ?.toUtc()
          .toIso8601String(),
      TransaksiSkema.aktivasiPaket: aktivasiPaket,
    };
  }
}

abstract final class TransaksiSkema {
  static const String tabel = 'transaksi';
  static const String id = 'id';
  static const String keterangan = 'keterangan';
  static const String jumlah = 'jumlah';
  static const String tanggal = 'tanggal';
  static const String tipe = 'tipe';
  static const String idDompet = 'id_dompet';
  static const String idKategori = 'id_kategori';
  static const String idSubKategori = 'id_sub_kategori';
  static const String idPelanggan = 'id_pelanggan';
  static const String idPaket = 'id_paket';
  static const String diperbarui = 'diperbarui';
  static const String diarsipkan = 'diarsipkan';
  static const String isDeleted = 'is_deleted';
  static const String idDompetTujuan = 'id_dompet_tujuan';
  static const String poinYangDihasilkan = 'poin_yang_dihasilkan';
  static const String poinYangDigunakan = 'poin_yang_digunakan';
  static const String statusPembayaran = 'status_pembayaran';
  static const String durasiPaket = 'durasi_paket';
  static const String tipeDurasiPaket = 'tipe_durasi_paket';
  static const String tanggalMulai = 'tanggal_mulai';
  static const String tanggalBerakhir = 'tanggal_berakhir';
  static const String aktivasiPaket = 'aktivasi_paket';
}
