// path: lib/model/pelanggan_aktif_model.dart
// diubah: Hapus impor sync_status dan semua properti terkait.
import 'package:uuid/uuid.dart';
import 'enum/status_pembayaran.dart';

// diubah: nama kelas untuk konsistensi penamaan
class PelangganAktifModel {
  final String id;
  final String idPelanggan;
  final String idPaket;
  final DateTime tanggalMulai;
  final DateTime tanggalBerakhir;
  final StatusPembayaran status;
  // dihapus: karena tidak digunakan lagi
  // final SyncStatus syncStatus;
  final DateTime? diperbarui;
  final String statusSinkronisasi;

  // tambahan: soft delete & arsip
  final bool isDeleted;
  final DateTime? diarsipkan;

  // diubah: nama konstruktor
  PelangganAktifModel({
    String? id,
    required this.idPelanggan,
    required this.idPaket,
    required this.tanggalMulai,
    required this.tanggalBerakhir,
    required this.status,
    // dihapus: karena tidak digunakan lagi
    // this.syncStatus = SyncStatus.synced,
    this.diperbarui,
    this.statusSinkronisasi = 'SINKRON',
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  // helper parsing aman datetime
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

  // [FIXED] Menambahkan metode copyWith
  PelangganAktifModel copyWith({
    String? id,
    String? idPelanggan,
    String? idPaket,
    DateTime? tanggalMulai,
    DateTime? tanggalBerakhir,
    StatusPembayaran? status,
    // dihapus: karena tidak digunakan lagi
    // SyncStatus? syncStatus,
    DateTime? diperbarui,
    String? statusSinkronisasi,
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
      // dihapus: karena tidak digunakan lagi
      // syncStatus: syncStatus ?? this.syncStatus,
      diperbarui: diperbarui ?? this.diperbarui,
      statusSinkronisasi: statusSinkronisasi ?? this.statusSinkronisasi,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  factory PelangganAktifModel.fromMap(Map<String, dynamic> map) {
    return PelangganAktifModel(
      id: map['id'],
      idPelanggan: map['id_pelanggan'],
      idPaket: map['id_paket'],
      tanggalMulai: DateTime.parse(map['tanggalMulai']),
      tanggalBerakhir: DateTime.parse(map['tanggalBerakhir']),
      status: StatusPembayaran.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StatusPembayaran.lunas,
      ),
      // dihapus: karena tidak digunakan lagi
      diperbarui: map['diperbarui'] != null
          ? DateTime.parse(map['diperbarui'])
          : null,
      statusSinkronisasi: map['status_sinkronisasi'] ?? 'SINKRON',

      // tambahan field baru
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
      // dihapus: karena tidak digunakan lagi
      // 'sync_status': syncStatus.name,
      'diperbarui': diperbarui?.toIso8601String(),
      'status_sinkronisasi': statusSinkronisasi,

      // tambahan field baru
      'isDeleted': isDeleted,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }
}
