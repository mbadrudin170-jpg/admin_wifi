
// path: lib/services/kontrol_aplikasi_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// untuk mengontrol status aplikasi pengguna dari jarak jauh
class KontrolAplikasiService {
  // Mendapatkan referensi ke koleksi 'pengaturan' di Firestore.
  // ditambah: Menambahkan referensi koleksi untuk Firestore
  final CollectionReference _pengaturanRef =
      FirebaseFirestore.instance.collection('pengaturan');

  // untuk mendapatkan status maintenance dari firestore
  Future<bool> dapatkanStatusMaintenance() async {
    try {
      // Mendapatkan dokumen 'status_aplikasi' dari koleksi.
      // ditambah: Mengambil data dari dokumen spesifik
      final doc = await _pengaturanRef.doc('status_aplikasi').get();

      // Jika dokumen ada dan berisi field 'sedang_maintenance', kembalikan nilainya.
      // ditambah: Logika untuk memeriksa keberadaan data dan mengembalikan nilai
      if (doc.exists && (doc.data() as Map<String, dynamic>).containsKey('sedang_maintenance')) {
        return doc['sedang_maintenance'] as bool;
      }
      // Jika dokumen tidak ada atau field tidak ada, default ke false (tidak maintenance).
      // ditambah: Nilai default jika data tidak ditemukan
      return false;
    } catch (e, s) {
      // Mencatat error jika gagal mengambil data.
      // ditambah: Penanganan error
      developer.log(
        'Gagal mengambil status maintenance',
        error: e,
        stackTrace: s,
        name: 'KontrolAplikasiService',
      );
      // Mengembalikan false sebagai fallback jika terjadi error.
      return false;
    }
  }

  // untuk mengubah status maintenance di firestore
  Future<void> aturStatusMaintenance(bool status) async {
    try {
      // Mengatur (atau membuat jika belum ada) dokumen 'status_aplikasi'
      // dengan field 'sedang_maintenance'.
      // ditambah: Menyimpan atau memperbarui data di Firestore
      await _pengaturanRef.doc('status_aplikasi').set({
        'sedang_maintenance': status,
      });
    } catch (e, s) {
      // Mencatat error jika gagal menyimpan data.
      // ditambah: Penanganan error
      developer.log(
        'Gagak mengatur status maintenance',
        error: e,
        stackTrace: s,
        name: 'KontrolAplikasiService',
      );
      // Melempar kembali error agar bisa ditangani di UI jika perlu.
      rethrow;
    }
  }
}
