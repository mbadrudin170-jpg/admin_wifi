// path: lib/model/pelanggan_aktif_model.dart
import 'package:admin_wifi/model/enum/sync_status.dart';
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
  final SyncStatus syncStatus;
  final DateTime? diperbarui;
  final String statusSinkronisasi;

  // diubah: nama konstruktor
  PelangganAktifModel({
    String? id,
    required this.idPelanggan,
    required this.idPaket,
    required this.tanggalMulai,
    required this.tanggalBerakhir,
    required this.status,
    this.syncStatus = SyncStatus.synced, // Default ke synced
    this.diperbarui,
    this.statusSinkronisasi = 'SINKRON',
  }) : id = id ?? const Uuid().v4();

  // [FIXED] Menambahkan metode copyWith
  // diubah: nama metode dan tipe kembalian
  PelangganAktifModel copyWith({
    String? id,
    String? idPelanggan,
    String? idPaket,
    DateTime? tanggalMulai,
    DateTime? tanggalBerakhir,
    StatusPembayaran? status,
    SyncStatus? syncStatus,
    DateTime? diperbarui,
    String? statusSinkronisasi,
  }) {
    // diubah: pembuatan instance kelas
    return PelangganAktifModel(
      id: id ?? this.id,
      idPelanggan: idPelanggan ?? this.idPelanggan,
      idPaket: idPaket ?? this.idPaket,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalBerakhir: tanggalBerakhir ?? this.tanggalBerakhir,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      diperbarui: diperbarui ?? this.diperbarui,
      statusSinkronisasi: statusSinkronisasi ?? this.statusSinkronisasi,
    );
  }

  // diubah: nama factory dan tipe kembalian
  factory PelangganAktifModel.fromMap(Map<String, dynamic> map) {
    // diubah: pembuatan instance kelas
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
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == (map['sync_status'] ?? 'synced'),
        orElse: () => SyncStatus.synced,
      ),
      diperbarui: map['diperbarui'] != null
          ? DateTime.parse(map['diperbarui'])
          : null,
      statusSinkronisasi: map['status_sinkronisasi'] ?? 'SINKRON',
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
      'sync_status': syncStatus.name,
      'diperbarui': diperbarui?.toIso8601String(),
      'status_sinkronisasi': statusSinkronisasi,
    };
  }
}
