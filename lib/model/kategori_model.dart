// path: lib/model/kategori_model.dart
// Model ini mendefinisikan struktur data untuk kategori dan sub-kategori transaksi.
// Ini termasuk tipe kategori (pemasukan atau pengeluaran) dan daftar sub-kategori.
// Digunakan untuk mengelola data kategori dari dan ke Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';

enum TipeKategori { pemasukan, pengeluaran, transfer }

// diubah: nama kelas untuk konsistensi penamaan
class KategoriModel {
  String? id;
  final String nama;
  final TipeKategori tipe;
  // diubah: tipe data list
  final List<SubKategoriModel> subKategori;
  DateTime? diperbarui;
  bool isDeleted;
  // ditambah: Menambahkan properti untuk timestamp pengarsipan.
  DateTime? diarsipkan;

  // diubah: nama konstruktor
  KategoriModel({
    this.id,
    required this.nama,
    required this.tipe,
    this.subKategori = const [],
    this.diperbarui,
    this.isDeleted = false,
    // ditambah: Menambahkan diarsipkan ke konstruktor.
    this.diarsipkan,
  });

  // ditambah: copyWith method
  KategoriModel copyWith({
    String? id,
    String? nama,
    TipeKategori? tipe,
    List<SubKategoriModel>? subKategori,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return KategoriModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      tipe: tipe ?? this.tipe,
      subKategori: subKategori ?? this.subKategori,
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  // ditambah: Helper untuk parsing tanggal dari berbagai format (Timestamp, String).
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  // diubah: nama factory dan tipe kembalian
  factory KategoriModel.fromMap(Map<String, dynamic> map) {
    // diubah: pembuatan instance kelas
    return KategoriModel(
      id: map['id'],
      nama: map['nama'] ?? '',
      tipe: TipeKategori.values.firstWhere(
        (e) => e.name == map['tipe'],
        orElse: () => TipeKategori.pemasukan,
      ),
      // diubah: menggunakan SubKategoriModel.fromMap
      subKategori: (map['subKategori'] as List<dynamic>? ?? [])
          .map(
            (subMap) =>
                SubKategoriModel.fromMap(subMap as Map<String, dynamic>),
          )
          .toList(),
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  /// Mengonversi objek Kategori menjadi Map untuk **database SQLite**.
  /// Properti subKategori dihilangkan karena disimpan di tabel terpisah.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'tipe': tipe.name,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0, // diubah: konsistensi dengan model lain
      'diarsipkan': diarsipkan?.toIso8601String(), // ditambah
      // Kolom 'subKategori' dihapus dari sini untuk menghindari error SQLite
    };
  }
}

// diubah: nama kelas untuk konsistensi penamaan
class SubKategoriModel {
  String? id;
  final String nama;
  DateTime? diperbarui;
  bool isDeleted;
  // ditambah: Menambahkan properti untuk timestamp pengarsipan.
  DateTime? diarsipkan;

  // diubah: nama konstruktor
  SubKategoriModel({
    this.id,
    required this.nama,
    this.diperbarui,
    this.isDeleted = false,
    // ditambah: Menambahkan diarsipkan ke konstruktor.
    this.diarsipkan,
  });

  // ditambah: copyWith method
  SubKategoriModel copyWith({
    String? id,
    String? nama,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return SubKategoriModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  // ditambah: Helper untuk parsing tanggal dari berbagai format (Timestamp, String).
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  // diubah: nama factory dan tipe kembalian
  factory SubKategoriModel.fromMap(Map<String, dynamic> map) {
    // diubah: pembuatan instance kelas
    return SubKategoriModel(
      id: map['id'],
      nama: map['nama'] ?? '',
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0, // diubah: konsistensi dengan model lain
      'diarsipkan': diarsipkan?.toIso8601String(), // ditambah
    };
  }
}
