// path: lib/model/pelanggan_model.dart
// Model ini merepresentasikan data pelanggan dengan soft delete.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

// Enum untuk status pelanggan, mendukung soft delete.
enum StatusPelanggan { aktif, diarsip }

// diubah: nama kelas untuk konsistensi penamaan
class PelangganModel {
  final String id;
  final String nama;
  final String telepon;
  final String alamat;
  final String password;
  final String macAddress;
  final StatusPelanggan status;
  final DateTime? diperbarui;
  final DateTime? diarsipkan;

  // diubah: nama konstruktor
  PelangganModel({
    String? id,
    required this.nama,
    required this.telepon,
    required this.alamat,
    required this.password,
    this.macAddress = '',
    this.status = StatusPelanggan.aktif,
    this.diperbarui,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  // Helper untuk parsing tanggal dari berbagai format (Timestamp, String)
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  // diubah: nama factory dan tipe kembalian
  factory PelangganModel.fromMap(Map<String, dynamic> map) {
    // diubah: pembuatan instance kelas
    return PelangganModel(
      id: map['id'],
      nama: map['nama'] ?? '',
      telepon: map['telepon'] ?? '',
      alamat: map['alamat'] ?? '',
      password: map['password'] ?? '',
      macAddress: map['mac_address'] ?? '',
      status: StatusPelanggan.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StatusPelanggan.aktif, // Default ke aktif jika tidak ada
      ),
      diperbarui: _parseDateTime(map['diperbarui']),
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'telepon': telepon,
      'alamat': alamat,
      'password': password,
      'mac_address': macAddress,
      'status': status.name,
      'diperbarui': diperbarui?.toIso8601String(),
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }
}
