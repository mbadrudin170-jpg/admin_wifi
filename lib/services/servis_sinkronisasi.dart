// path: lib/services/servis_sinkronisasi.dart

import 'dart:async';
import 'dart:developer' as developer;

import 'package:admin_wifi/data/sync/unggah_selektif_service.dart';
// ditambah: Mengimpor layanan koneksi internet yang terpusat.
import 'package:admin_wifi/services/cek_koneksi_internet.dart';

/// [SinkronisasiService] bertanggung jawab untuk mengelola proses sinkronisasi
/// data secara keseluruhan, baik mengunggah perubahan lokal maupun mengunduh
/// pembaruan dari server.
class SinkronisasiService {
  final UnggahSelektifService _unggahService;
  // diubah: Menggunakan KoneksiInternetService sebagai sumber tunggal pengecekan koneksi.
  final KoneksiInternetService _koneksiInternetService;
  // final UnduhSinkronisasiService _unduhService; // Akan ditambahkan nanti

  // Timer untuk sinkronisasi otomatis
  Timer? _syncTimer;

  // StreamController untuk memberi tahu status sinkronisasi
  final _syncStatusController = StreamController<bool>.broadcast();
  Stream<bool> get isSyncing => _syncStatusController.stream;

  // diubah: Konstruktor diperbarui untuk menggunakan KoneksiInternetService.
  SinkronisasiService({
    UnggahSelektifService? unggahService,
    KoneksiInternetService? koneksiInternetService,
    // UnduhSinkronisasiService? unduhService,
  })  : _unggahService = unggahService ?? UnggahSelektifService(),
        _koneksiInternetService = koneksiInternetService ?? KoneksiInternetService();
        // _unduhService = unduhService ?? UnduhSinkronisasiService(),

  /// Memulai proses sinkronisasi manual.
  ///
  /// Akan memeriksa konektivitas internet sebelum menjalankan proses unggah dan unduh.
  Future<void> sinkronkan() async {
    _syncStatusController.add(true);
    developer.log('Memulai sinkronisasi manual.', name: 'SinkronisasiService');

    // diubah: Pengecekan koneksi sekarang memanggil layanan terpusat.
    final isConnected = await _koneksiInternetService.cekKoneksi();
    if (!isConnected) {
      developer.log('Sinkronisasi gagal: Tidak ada koneksi internet.', name: 'SinkronisasiService');
      _syncStatusController.add(false);
      return;
    }

    try {
      // 1. Unggah perubahan lokal terlebih dahulu
      await _unggahService.unggahPerubahanTertunda();

      // 2. Unduh perubahan dari server (akan diimplementasikan)
      // await _unduhService.unduhSemuaPerubahan();

      developer.log('Sinkronisasi manual berhasil diselesaikan.', name: 'SinkronisasiService');
    } catch (e, stackTrace) {
      developer.log(
        'Terjadi kesalahan selama sinkronisasi manual.',
        name: 'SinkronisasiService',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _syncStatusController.add(false);
    }
  }

  /// Memulai sinkronisasi otomatis berdasarkan interval yang ditentukan.
  void mulaiSinkronisasiOtomatis({required Duration interval}) {
    // Hentikan timer yang ada jika ada
    _syncTimer?.cancel();

    // Mulai timer baru
    _syncTimer = Timer.periodic(interval, (timer) async {
      developer.log('Memulai sinkronisasi otomatis terjadwal.', name: 'SinkronisasiService');
      await sinkronkan();
    });

    developer.log('Sinkronisasi otomatis dijadwalkan setiap ${interval.inMinutes} menit.', name: 'SinkronisasiService');
  }

  /// Menghentikan sinkronisasi otomatis.
  void hentikanSinkronisasiOtomatis() {
    _syncTimer?.cancel();
    _syncTimer = null;
    developer.log('Sinkronisasi otomatis dihentikan.', name: 'SinkronisasiService');
  }

  // dihapus: Metode _isConnected() telah dihapus karena fungsinya digantikan oleh KoneksiInternetService.

  /// Membersihkan resource saat service tidak lagi digunakan.
  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
  }
}
