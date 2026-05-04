// path: lib/model/pelanggan_aktif_model.dart
// diubah: Menggunakan UUID untuk ID dan memastikan non-nullable.
import 'package:uuid/uuid.dart';
import 'enum/status_pembayaran.dart';

class PelangganAktifModel {
  final String id;
  final String idPelanggan;
  final String idPaket;
  final DateTime tanggalMulai;
  final DateTime tanggalBerakhir;
  final StatusPembayaran status;
  final DateTime? diperbarui;
  final bool isDeleted;
  final DateTime? diarsipkan;

  PelangganAktifModel({
    String? id, // diubah: id bisa null saat pembuatan
    required this.idPelanggan,
    required this.idPaket,
    required this.tanggalMulai,
    required this.tanggalBerakhir,
    required this.status,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4(); // ditambah: inisialisasi UUID jika id null

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      if (value.runtimeType.toString().contains('Timestamp')) {
        return value.toDate();
      }
    } catch (_) {}
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  PelangganAktifModel copyWith({
    String? id,
    String? idPelanggan,
    String? idPaket,
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
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalBerakhir: tanggalBerakhir ?? this.tanggalBerakhir,
      status: status ?? this.status,
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  factory PelangganAktifModel.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String?;
    if (id == null || id.isEmpty) {
      throw ArgumentError(
        'Gagal membuat PelangganAktifModel: ID tidak boleh null atau kosong. Data: $map',
      );
    }

    final idPelanggan = map['id_pelanggan'] as String?;
    if (idPelanggan == null || idPelanggan.isEmpty) {
      throw ArgumentError(
        'Gagal membuat PelangganAktifModel: id_pelanggan tidak boleh null atau kosong. Data: $map',
      );
    }

    final idPaket = map['id_paket'] as String?;
    if (idPaket == null || idPaket.isEmpty) {
      throw ArgumentError(
        'Gagal membuat PelangganAktifModel: id_paket tidak boleh null atau kosong. Data: $map',
      );
    }

    return PelangganAktifModel(
      id: id,
      idPelanggan: idPelanggan,
      idPaket: idPaket,
      tanggalMulai: DateTime.parse(map['tanggalMulai']),
      tanggalBerakhir: DateTime.parse(map['tanggalBerakhir']),
      status: StatusPembayaran.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StatusPembayaran.lunas,
      ),
      diperbarui: map['diperbarui'] != null
          ? DateTime.parse(map['diperbarui'])
          : null,
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_pelanggan': idPelanggan,
      'id_paket': idPaket,
      'tanggalMulai': tanggalMulai.toIso8601String(),
      'tanggalBerakhir': tanggalBerakhir.toIso8601String(),
      'status': status.name,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }
}
