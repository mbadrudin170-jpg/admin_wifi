// path: lib/services/cek_langganan_kadaluarsa_service.dart
// diubah: Menyederhanakan logika dengan memanggil fungsi arsipkan yang sudah ada.

import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:share_global_saya/src/utils/l.dart';

/// Service ini bertanggung jawab untuk memeriksa dan mengarsipkan
/// langganan pelanggan aktif yang telah kedaluwarsa secara berkala.
class CekLanggananKadaluarsaService {
  final PelangganAktifOperasi _pelangganAktifOperasi = PelangganAktifOperasi();

  /// Memproses semua pelanggan aktif, menemukan yang kedaluwarsa,
  /// dan memanggil operasi untuk mengarsipkan mereka.
  Future<void> prosesLanggananKadaluarsa() async {
    L.i(
      'Memulai siklus pengecekan dan pengarsipan langganan yang telah kedaluwarsa...',
    );

    try {
      L.i(
        'Menghubungi PelangganAktifOperasi untuk mengeksekusi batch pengarsipan otomatis...',
      );

      // Memanggil satu fungsi yang sudah menangani seluruh logika
      final jumlahDiarsipkan = await _pelangganAktifOperasi
          .arsipkanPelangganKadaluarsa();

      if (jumlahDiarsipkan > 0) {
        L.i(
          'Operasi berhasil! Sebanyak $jumlahDiarsipkan data pelanggan kedaluwarsa telah dipindahkan ke tabel arsip.',
        );
      } else {
        L.i(
          'Hasil pengecekan bersih. Tidak ditemukan data pelanggan yang memenuhi kriteria kedaluwarsa saat ini.',
        );
      }

      L.i(
        'Seluruh rangkaian proses pengecekan langganan kedaluwarsa telah diselesaikan dengan sukses.',
      );
    } catch (e, s) {
      L.e(
        'Terjadi kesalahan fatal selama proses pengolahan data kedaluwarsa! Error: $e $s',
      );
    }
  }
}
