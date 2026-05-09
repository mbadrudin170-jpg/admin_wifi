// path: lib/services/cek_langganan_kadaluarsa_service.dart
// diubah: Menyederhanakan logika dengan memanggil fungsi arsipkan yang sudah ada.
import 'dart:developer' as developer;

import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';

/// Service ini bertanggung jawab untuk memeriksa dan mengarsipkan
/// langganan pelanggan aktif yang telah kedaluwarsa secara berkala.
class CekLanggananKadaluarsaService {
  final PelangganAktifOperasi _pelangganAktifOperasi = PelangganAktifOperasi();

  /// Memproses semua pelanggan aktif, menemukan yang kedaluwarsa,
  /// dan memanggil operasi untuk mengarsipkan mereka.
  Future<void> prosesLanggananKadaluarsa() async {
    developer.log(
      '[CekLanggananKadaluarsaService]-[prosesLanggananKadaluarsa] 🚀 : Memulai siklus pengecekan dan pengarsipan langganan yang telah kedaluwarsa...',
    );

    try {
      developer.log(
        '[CekLanggananKadaluarsaService]-[prosesLanggananKadaluarsa] 📡 : Menghubungi PelangganAktifOperasi untuk mengeksekusi batch pengarsipan otomatis...',
      );

      // Memanggil satu fungsi yang sudah menangani seluruh logika
      final jumlahDiarsipkan = await _pelangganAktifOperasi
          .arsipkanPelangganKadaluarsa();

      if (jumlahDiarsipkan > 0) {
        developer.log(
          '[CekLanggananKadaluarsaService]-[prosesLanggananKadaluarsa] ✨ : Operasi berhasil! Sebanyak $jumlahDiarsipkan data pelanggan kedaluwarsa telah dipindahkan ke tabel arsip.',
        );
      } else {
        developer.log(
          '[CekLanggananKadaluarsaService]-[prosesLanggananKadaluarsa] 📥 : Hasil pengecekan bersih. Tidak ditemukan data pelanggan yang memenuhi kriteria kedaluwarsa saat ini.',
        );
      }

      developer.log(
        '[CekLanggananKadaluarsaService]-[prosesLanggananKadaluarsa] ✅ : Seluruh rangkaian proses pengecekan langganan kedaluwarsa telah diselesaikan dengan sukses.',
      );
    } catch (e, s) {
      developer.log(
        '[CekLanggananKadaluarsaService]-[prosesLanggananKadaluarsa] ❌ : Terjadi kesalahan fatal selama proses pengolahan data kedaluwarsa!',
        name: 'CekLanggananError',
        error: e,
        stackTrace: s,
        level: 1000,
      );
    }
  }
}