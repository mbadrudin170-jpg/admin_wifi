// path: lib/model/pelanggan_aktif_model.dart
// diubah: Penamaan metode diseragamkan dan logika Firebase diperbaiki.
import 'package:admin_wifi/enum/status_pembayaran.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PelangganAktifModel {
  final String id;
  final String idPelanggan;
  final String idPaket;
  final String? idTransaksi;
  final DateTime tanggalMulai;
  final DateTime tanggalBerakhir;
  final StatusPembayaran status;
  final DateTime? diperbarui;
  final bool isDeleted;
  final DateTime? diarsipkan;

  PelangganAktifModel({
    String? id,
    required this.idPelanggan,
    required this.idPaket,
    this.idTransaksi,
    required this.tanggalMulai,
    required this.tanggalBerakhir,
    required this.status,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  PelangganAktifModel copyWith({
    String? id,
    String? idPelanggan,
    String? idPaket,
    String? idTransaksi,
    DateTime? tanggalMulai,
    DateTime? tanggalBerakhir,
    StatusPembayaran? status,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return PelangganAktifModel(
      id: id ?? this.id,
      idPelanggan: idPelanggan ?? this.idPelanggan,
      idPaket: idPaket ?? this.idPaket,
      idTransaksi: idTransaksi ?? this.idTransaksi,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalBerakhir: tanggalBerakhir ?? this.tanggalBerakhir,
      status: status ?? this.status,
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  // diubah: Nama metode dan validasi diperbaiki
  factory PelangganAktifModel.fromSqlite(Map<String, dynamic> map) {
    final id = map['id'] as String?;
    if (id == null || id.isEmpty) {
      throw ArgumentError('ID tidak boleh null atau kosong', 'id');
    }
    return PelangganAktifModel(
      id: id,
      idPelanggan: map['id_pelanggan'] ?? '',
      idPaket: map['id_paket'] ?? '',
      idTransaksi: map['id_transaksi'],
      tanggalMulai: _parseDateTime(map['tanggalMulai']) ?? DateTime.now(),
      tanggalBerakhir: _parseDateTime(map['tanggalBerakhir']) ?? DateTime.now(),
      status: StatusPembayaran.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StatusPembayaran.lunas,
      ),
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: _parseBool(map['isDeleted']),
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  // diubah: Nama metode
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'id_pelanggan': idPelanggan,
      'id_paket': idPaket,
      'id_transaksi': idTransaksi,
      'tanggalMulai': tanggalMulai.toIso8601String(),
      'tanggalBerakhir': tanggalBerakhir.toIso8601String(),
      'status': status.name,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  // ditambahkan: Factory fromFirebase
  factory PelangganAktifModel.fromFirebase(
    String id,
    Map<String, dynamic> data,
  ) {
    return PelangganAktifModel(
      id: id,
      idPelanggan: data['id_pelanggan'] ?? '',
      idPaket: data['id_paket'] ?? '',
      idTransaksi: data['id_transaksi'],
      tanggalMulai: _parseDateTime(data['tanggalMulai']) ?? DateTime.now(),
      tanggalBerakhir:
          _parseDateTime(data['tanggalBerakhir']) ?? DateTime.now(),
      status: StatusPembayaran.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => StatusPembayaran.lunas,
      ),
      diperbarui: _parseDateTime(data['diperbarui']),
      isDeleted: _parseBool(data['isDeleted']),
      diarsipkan: _parseDateTime(data['diarsipkan']),
    );
  }

  // diubah: Nama metode dan logika diperbarui diubah
  Map<String, dynamic> toFirebase() {
    final Map<String, dynamic> data = {
      'id': id,
      'id_pelanggan': idPelanggan,
      'id_paket': idPaket,
      'id_transaksi': idTransaksi,
      'tanggalMulai': Timestamp.fromDate(tanggalMulai),
      'tanggalBerakhir': Timestamp.fromDate(tanggalBerakhir),
      'status': status.name,
      'isDeleted': isDeleted,
      'diperbarui': FieldValue.serverTimestamp(),
    };
    if (diarsipkan != null) {
      data['diarsipkan'] = Timestamp.fromDate(diarsipkan!);
    }
    return data;
  }
}
