// path: lib/model/pelanggan_model.dart
// Model ini merepresentasikan data pelanggan dengan soft delete.
// diubah: Field 'diperbarui' dijadikan nullable untuk konsistensi.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PelangganModel {
  final String id;
  final String nama;
  final String telepon;
  final String alamat;
  final String password;
  final String macAddress;
  final bool isDeleted;

  final DateTime? diperbarui; // diubah: menjadi nullable
  final DateTime? diarsipkan;

  // ditambah: Getter untuk memeriksa apakah pelanggan aktif.
  bool get isAktif => diarsipkan == null && !isDeleted;

  PelangganModel({
    String? id,
    required this.nama,
    required this.telepon,
    required this.alamat,
    required this.password,
    this.macAddress = '',
    this.diperbarui, // diubah: tidak lagi required
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  PelangganModel copyWith({
    String? id,
    String? nama,
    String? telepon,
    String? alamat,
    String? password,
    String? macAddress,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return PelangganModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      telepon: telepon ?? this.telepon,
      alamat: alamat ?? this.alamat,
      password: password ?? this.password,
      macAddress: macAddress ?? this.macAddress,
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  // Helper untuk parsing tanggal dari berbagai format (Timestamp, String)
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  factory PelangganModel.fromMap(Map<String, dynamic> map) {
    return PelangganModel(
      id: map['id'] as String? ?? '',
      nama: map['nama'] ?? '',
      telepon: map['telepon'] ?? '',
      alamat: map['alamat'] ?? '',
      password: map['password'] ?? '',
      macAddress: map['mac_address'] ?? '',
      diperbarui: _parseDateTime(
        map['diperbarui'],
      ), // diubah: Tidak perlu nilai default
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  Map<String, dynamic> toMapForSqlite() {
    return {
      'id': id,
      'nama': nama,
      'telepon': telepon,
      'alamat': alamat,
      'password': password,
      'mac_address': macAddress,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMapForFirebase() {
    return {
      'id': id,
      'nama': nama,
      'telepon': telepon,
      'alamat': alamat,
      'password': password,
      'mac_address': macAddress,
      'diperbarui': diperbarui,
      'isDeleted': isDeleted,
      'diarsipkan': diarsipkan,
    };
  }
}
