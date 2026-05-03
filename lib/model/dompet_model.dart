// path: lib/model/dompet_model.dart
// diubah/ditambah: Tambah impor untuk status sinkronisasi, properti isDeleted, dan Timestamp.
import 'package:admin_wifi/model/enum/sync_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Model ini merepresentasikan entitas dompet dalam aplikasi.
class DompetModel {
  final String? id;
  final String namaDompet;
  final double saldo;
  final DateTime? diperbarui;
  final SyncStatus syncStatus;
  // ditambah: Menambahkan properti untuk soft delete.
  final bool isDeleted;
  // ditambah: Menambahkan properti untuk timestamp pengarsipan.
  final DateTime? diarsipkan;

  DompetModel({
    this.id,
    required this.namaDompet,
    required this.saldo,
    this.diperbarui,
    this.syncStatus = SyncStatus.synced,
    // ditambah: Menambahkan nilai default untuk isDeleted.
    this.isDeleted = false,
    // ditambah: Menambahkan diarsipkan ke konstruktor.
    this.diarsipkan,
  });

  // diubah: Mengganti nama 'salinDengan' menjadi 'copyWith' agar sesuai konvensi.
  /// Membuat salinan objek Dompet dengan nilai yang diperbarui.
  DompetModel copyWith({
    String? id,
    String? namaDompet,
    double? saldo,
    DateTime? diperbarui,
    SyncStatus? syncStatus,
    bool? isDeleted, // ditambah: isDeleted ke copyWith.
    DateTime? diarsipkan, // ditambah: diarsipkan ke copyWith.
  }) {
    return DompetModel(
      id: id ?? this.id,
      namaDompet: namaDompet ?? this.namaDompet,
      saldo: saldo ?? this.saldo,
      diperbarui: diperbarui ?? this.diperbarui,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted, // ditambah: isDeleted ke copyWith.
      diarsipkan: diarsipkan ?? this.diarsipkan, // ditambah: diarsipkan ke copyWith.
    );
  }

  // ditambah: Helper untuk parsing tanggal dari berbagai format (Timestamp, String).
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  // diubah/ditambah: Diperbarui untuk menangani 'syncStatus', 'isDeleted', dan 'diarsipkan'.
  // Mengonversi Map dari database menjadi objek Dompet.
  factory DompetModel.fromMap(Map<String, dynamic> map) {
    return DompetModel(
      id: map['id'],
      namaDompet: map['namaDompet'],
      saldo: (map['saldo'] as num).toDouble(),
      diperbarui: _parseDateTime(map['diperbarui']),
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == map['sync_status'],
        orElse: () => SyncStatus.synced,
      ),
      // ditambah: Menangani boolean dari Firestore (true) dan integer dari SQLite (1).
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  // diubah/ditambah: Diperbarui untuk menyertakan 'sync_status', 'isDeleted', dan 'diarsipkan'.
  // Mengonversi objek Dompet menjadi Map untuk database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaDompet': namaDompet,
      'saldo': saldo,
      'diperbarui': diperbarui?.toIso8601String(),
      'sync_status': syncStatus.name,
      // ditambah: Menyimpan sebagai integer (1 untuk true, 0 untuk false) untuk kompatibilitas SQLite.
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }
}
