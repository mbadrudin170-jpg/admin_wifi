// path: lib/model/pesanan_model.dart
// diubah: Mengganti toMap() dengan toMapForSqlite() dan toMapForFirebase()
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PesananModel {
  final String id;
  final String idPelanggan;
  final String idPaket;
  final DateTime tanggal;
  final String status;
  final DateTime? diperbarui;
  final bool isDeleted;
  final DateTime? diarsipkan;

  PesananModel({
    String? id,
    required this.idPelanggan,
    required this.idPaket,
    required this.tanggal,
    required this.status,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  PesananModel copyWith({
    String? id,
    String? idPelanggan,
    String? idPaket,
    DateTime? tanggal,
    String? status,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return PesananModel(
      id: id ?? this.id,
      idPelanggan: idPelanggan ?? this.idPelanggan,
      idPaket: idPaket ?? this.idPaket,
      tanggal: tanggal ?? this.tanggal,
      status: status ?? this.status,
      diperbarui: diperbarui ?? this.diperbarui,
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

  // diubah: Nama metode menjadi toMapForSqlite
  Map<String, dynamic> toMapForSqlite() {
    return {
      'id': id,
      'id_pelanggan': idPelanggan,
      'id_paket': idPaket,
      'tanggal': tanggal.toIso8601String(),
      'status': status,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  // ditambahkan: Metode toMapForFirebase
  Map<String, dynamic> toMapForFirebase() {
    return {
      'id': id,
      'id_pelanggan': idPelanggan,
      'id_paket': idPaket,
      'tanggal': tanggal,
      'status': status,
      'diperbarui': diperbarui,
      'isDeleted': isDeleted,
      'diarsipkan': diarsipkan,
    };
  }

  factory PesananModel.fromMap(Map<String, dynamic> map) {
    return PesananModel(
      id: map['id'] as String? ?? '',
      idPelanggan: map['id_pelanggan'] ?? '',
      idPaket: map['id_paket'] ?? '',
      tanggal: _parseDateTime(map['tanggal']) ?? DateTime.now(),
      status: map['status'] ?? 'baru',
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }
}
