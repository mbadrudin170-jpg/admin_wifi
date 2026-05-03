// path: lib/model/dompet_model.dart
// diubah/ditambah: Tambah impor untuk status sinkronisasi.
import 'package:admin_wifi/model/enum/sync_status.dart';

// Model ini merepresentasikan entitas dompet dalam aplikasi.
// Ini mencakup properti seperti ID, nama dompet, saldo, tanggal diperbarui, dan status sinkronisasi.
// Digunakan untuk mengelola data dompet dari dan ke Firestore serta database lokal.

class Dompet {
  final String? id;
  final String namaDompet;
  final double saldo;
  final DateTime? diperbarui;
  // diubah/ditambah: Menambahkan properti untuk status sinkronisasi.
  final SyncStatus syncStatus;

  Dompet({
    this.id,
    required this.namaDompet,
    required this.saldo,
    this.diperbarui,
    // diubah: Mengubah nilai default dari write menjadi synced agar konsisten dengan pola PelangganAktif
    this.syncStatus = SyncStatus.synced,
  });

  // diubah/ditambah: Menambahkan metode 'salinDengan' untuk imutabilitas.
  /// Membuat salinan objek Dompet dengan nilai yang diperbarui.
  Dompet salinDengan({
    String? id,
    String? namaDompet,
    double? saldo,
    DateTime? diperbarui,
    SyncStatus? syncStatus,
  }) {
    return Dompet(
      id: id ?? this.id,
      namaDompet: namaDompet ?? this.namaDompet,
      saldo: saldo ?? this.saldo,
      diperbarui: diperbarui ?? this.diperbarui,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  // diubah/ditambah: Diperbarui untuk menangani 'syncStatus'.
  // Mengonversi Map dari database menjadi objek Dompet.
  factory Dompet.fromMap(Map<String, dynamic> map) {
    return Dompet(
      id: map['id'],
      namaDompet: map['namaDompet'],
      saldo: (map['saldo'] as num).toDouble(),
      diperbarui: map['diperbarui'] != null ? DateTime.parse(map['diperbarui']) : null,
      // Mengurai status sinkronisasi dari string, default ke 'synced' jika tidak ada.
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == map['sync_status'],
        orElse: () => SyncStatus.synced,
      ),
    );
  }

  // diubah/ditambah: Diperbarui untuk menyertakan 'sync_status'.
  // Mengonversi objek Dompet menjadi Map untuk database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaDompet': namaDompet,
      'saldo': saldo,
      'diperbarui': diperbarui?.toIso8601String(),
      'sync_status': syncStatus.name, // Simpan sebagai string.
    };
  }
}
