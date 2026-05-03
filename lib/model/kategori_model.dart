// path: lib/model/kategori_model.dart
// Model ini mendefinisikan struktur data untuk kategori dan sub-kategori transaksi.
// Ini termasuk tipe kategori (pemasukan atau pengeluaran) dan daftar sub-kategori.
// Digunakan untuk mengelola data kategori dari dan ke Firestore.

enum TipeKategori { pemasukan, pengeluaran }

// diubah: nama kelas untuk konsistensi penamaan
class KategoriModel {
  String? id;
  final String nama;
  final TipeKategori tipe;
  // diubah: tipe data list
  final List<SubKategoriModel> subKategori;
  DateTime? diperbarui; // <-- Kolom baru ditambahkan

  // diubah: nama konstruktor
  KategoriModel({
    this.id,
    required this.nama,
    required this.tipe,
    this.subKategori = const [],
    this.diperbarui,
  });

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
          .map((subMap) => SubKategoriModel.fromMap(subMap as Map<String, dynamic>))
          .toList(),
      diperbarui: map['diperbarui'] != null
          ? DateTime.parse(map['diperbarui'])
          : null,
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
      // Kolom 'subKategori' dihapus dari sini untuk menghindari error SQLite
    };
  }
}

// diubah: nama kelas untuk konsistensi penamaan
class SubKategoriModel {
  String? id;
  final String nama;
  DateTime? diperbarui; // <-- Kolom baru ditambahkan

  // diubah: nama konstruktor
  SubKategoriModel({this.id, required this.nama, this.diperbarui});

  // diubah: nama factory dan tipe kembalian
  factory SubKategoriModel.fromMap(Map<String, dynamic> map) {
    // diubah: pembuatan instance kelas
    return SubKategoriModel(
      id: map['id'],
      nama: map['nama'] ?? '',
      diperbarui: map['diperbarui'] != null
          ? DateTime.parse(map['diperbarui'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'diperbarui': diperbarui?.toIso8601String(),
    };
  }
}
