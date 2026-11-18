// path: lib/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart

import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/enum/status_pembayaran_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPelanggan': idPelanggan,
      'idPaket': idPaket,
      'idTransaksi': idTransaksi,
      'tanggalMulai': tanggalMulai.toIso8601String(),
      'tanggalBerakhir': tanggalBerakhir.toIso8601String(),
      'status': status.name,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);

    Log.warning('Format DateTime tidak dikenali: $value');
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';

    Log.warning('Format Boolean tidak dikenali, default ke false: $value');
    return false;
  }

  factory PelangganAktifModel.fromSqlite(Map<String, dynamic> map) {
    try {
      // diubah: Menggunakan key snake_case 'tanggal_mulai' dan 'tanggal_berakhir' agar cocok dengan database.
      final tanggalMulai = _parseDateTime(map['tanggal_mulai']);
      final tanggalBerakhir = _parseDateTime(map['tanggal_berakhir']);

      // diubah: Menghapus fallback DateTime.now() yang berbahaya dan menggantinya dengan validasi.
      if (tanggalMulai == null) {
        throw ArgumentError.notNull('tanggal_mulai dari SQLite');
      }
      if (tanggalBerakhir == null) {
        throw ArgumentError.notNull('tanggal_berakhir dari SQLite');
      }

      final model = PelangganAktifModel(
        id: map['id'] as String,
        idPelanggan: map['id_pelanggan'] as String? ?? '',
        idPaket: map['id_paket'] as String? ?? '',
        idTransaksi: map['id_transaksi'] as String?,
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status: StatusPembayaranEnum.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => StatusPembayaranEnum.lunas,
        ),
        diperbarui: _parseDateTime(map['diperbarui']),
        isDeleted: _parseBool(map['isDeleted']),
        diarsipkan: _parseDateTime(map['diarsipkan']),
      );

      Log.info('Data dimuat dari SQLite');
      return model;
    } catch (e, stack) {
      Log.error('Gagal parsing SQLite: $map', error: e, stackTrace: stack);
      rethrow;
    }
  }

  factory PelangganAktifModel.fromFirebase(
    String id,
    Map<String, dynamic> data,
  ) {
    try {
      // diubah: Menghapus fallback DateTime.now() yang berbahaya dan menggantinya dengan validasi.
      final tanggalMulai = _parseDateTime(data['tanggalMulai']);
      final tanggalBerakhir = _parseDateTime(data['tanggalBerakhir']);

      if (tanggalMulai == null) {
        throw ArgumentError.notNull('tanggalMulai dari Firebase');
      }
      if (tanggalBerakhir == null) {
        throw ArgumentError.notNull('tanggalBerakhir dari Firebase');
      }

      final model = PelangganAktifModel(
        id: id,
        idPelanggan: data['id_pelanggan'] as String? ?? '',
        idPaket: data['id_paket'] as String? ?? '',
        idTransaksi: data['id_transaksi'] as String?,
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status: StatusPembayaranEnum.values.firstWhere(
          (e) => e.name == data['status'],
          orElse: () => StatusPembayaranEnum.lunas,
        ),
        diperbarui: _parseDateTime(data['diperbarui']),
        isDeleted: _parseBool(data['isDeleted']),
        diarsipkan: _parseDateTime(data['diarsipkan']),
      );

      Log.info('Data ditarik dari Firebase');
      return model;
    } catch (e, stack) {
      Log.error('Gagal parsing Firebase: $data', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'id_pelanggan': idPelanggan,
      'id_paket': idPaket,
      'id_transaksi': idTransaksi,
      'tanggal_mulai': tanggalMulai.toIso8601String(), // snake_case
      'tanggal_berakhir': tanggalBerakhir.toIso8601String(), // snake_case
      'status': status.name,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirebase() {
    final Map<String, dynamic> data = {
      'id': id,
      'id_pelanggan': idPelanggan,
      'id_paket': idPaket,
      'id_transaksi': idTransaksi,
      'tanggalMulai': Timestamp.fromDate(tanggalMulai), // camelCase
      'tanggalBerakhir': Timestamp.fromDate(tanggalBerakhir), // camelCase
      'status': status.name,
      'isDeleted': isDeleted,
      'diperbarui': FieldValue.serverTimestamp(),
    };
    if (diarsipkan != null) {
      data['diarsipkan'] = Timestamp.fromDate(diarsipkan!);
    }

    Log.api('Firestore/Pelanggan/$id', data, method: 'SET');
    return data;
  }
}
