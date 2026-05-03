// path: lib/services/cek_langganan_kadaluarsa_service.dart
// diubah: Menyederhanakan logika dengan memanggil fungsi arsipkan yang sudah ada.
import 'dart:developer';

import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';

/// Service ini bertanggung jawab untuk memeriksa dan mengarsipkan
/// langganan pelanggan aktif yang telah kedaluwarsa secara berkala.
class CekLanggananKadaluarsaService {
  final PelangganAktifOperasi _pelangganAktifOperasi = PelangganAktifOperasi();

  /// Memproses semua pelanggan aktif, menemukan yang kedaluwarsa,
  /// dan memanggil operasi untuk mengarsipkan mereka.
  Future<void> prosesLanggananKadaluarsa() async {
    try {
      log('Memulai pengecekan dan pengarsipan langganan kedaluwarsa...',
          name: 'CekLangganan');

      // Memanggil satu fungsi yang sudah menangani seluruh logika
      final jumlahDiarsipkan = await _pelangganAktifOperasi.arsipkanPelangganKadaluarsa();

      if (jumlahDiarsipkan > 0) {
        log(
          'Berhasil mengarsipkan $jumlahDiarsipkan langganan kedaluwarsa.',
          name: 'CekLangganan',
        );
      } else {
        log(
          'Tidak ada langganan kedaluwarsa yang ditemukan untuk diarsipkan.',
          name: 'CekLangganan',
        );
      }

      log(
        'Proses pengecekan langganan kedaluwarsa selesai.',
        name: 'CekLangganan',
      );
    } catch (e, s) {
      log(
        'Terjadi error saat memproses langganan kedaluwarsa',
        name: 'CekLanggananError',
        error: e,
        stackTrace: s,
        level: 1000,
      );
    }
  }
}
