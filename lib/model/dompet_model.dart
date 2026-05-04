// path: lib/model/dompet_model.dart
// diubah: Hapus impor sync_status dan semua properti terkait.
import 'package:cloud_firestore/cloud_firestore.dart';

// Model ini merepresentasikan entitas dompet dalam aplikasi.
class DompetModel {
  final String? id;
  final String namaDompet;
  final double saldo;
  final DateTime? diperbarui;
  // dihapus: karena tidak digunakan lagi
  // final SyncStatus syncStatus;
  final bool isDeleted;
  final DateTime? diarsipkan;

  DompetModel({
    this.id,
    required this.namaDompet,
    required this.saldo,
    this.diperbarui,
    // dihapus: karena tidak digunakan lagi
    // this.syncStatus = SyncStatus.synced,
    this.isDeleted = false,
    this.diarsipkan,
  });

  /// Membuat salinan objek Dompet dengan nilai yang diperbarui.
  DompetModel copyWith({
    String? id,
    String? namaDompet,
    double? saldo,
    DateTime? diperbarui,
    // dihapus: karena tidak digunakan lagi
    // SyncStatus? syncStatus,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return DompetModel(
      id: id ?? this.id,
      namaDompet: namaDompet ?? this.namaDompet,
      saldo: saldo ?? this.saldo,
      diperbarui: diperbarui ?? this.diperbarui,
      // dihapus: karena tidak digunakan lagi
      // syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  // Mengonversi Map dari database menjadi objek Dompet.
  factory DompetModel.fromMap(Map<String, dynamic> map) {
    return DompetModel(
      id: map['id'],
      namaDompet: map['namaDompet'],
      saldo: (map['saldo'] as num).toDouble(),
      diperbarui: _parseDateTime(map['diperbarui']),
      // dihapus: karena tidak digunakan lagi
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  // Mengonversi objek Dompet menjadi Map untuk database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaDompet': namaDompet,
      'saldo': saldo,
      'diperbarui': diperbarui?.toIso8601String(),
      // dihapus: karena tidak digunakan lagi
      // 'sync_status': syncStatus.name,
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }
}
