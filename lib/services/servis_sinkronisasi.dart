// path: lib/services/servis_sinkronisasi.dart
// diubah: Mengalihkan fungsi layanan ini untuk fokus hanya pada proses unduh data.
import 'dart:async';
import 'dart:developer' as developer;

import 'package:admin_wifi/data/sync/unduh_data.dart';
import 'package:admin_wifi/services/cek_koneksi_internet.dart';
import 'package:admin_wifi/utils/sync_manager.dart';

/// [SinkronisasiService] bertanggung jawab untuk mengelola proses MENGUNDUH
/// pembaruan dari server, baik secara manual maupun otomatis.
class SinkronisasiService {
  final KoneksiInternetService _koneksiInternetService;
  // dihapus: Dependensi ke layanan unggah data telah dihapus.
  final LayananUnduhData _unduhData;
  final SyncManager _syncManager;

  Timer? _syncTimer;
  final _syncStatusController = StreamController<bool>.broadcast();

  /// Stream yang menandakan apakah proses unduh sedang berlangsung.
  Stream<bool> get isDownloading => _syncStatusController.stream;

  SinkronisasiService({
    KoneksiInternetService? koneksiInternetService,
    LayananUnduhData? unduhData,
    SyncManager? syncManager,
  })  : _koneksiInternetService =
            koneksiInternetService ?? KoneksiInternetService(),
        _unduhData = unduhData ?? LayananUnduhData(),
        _syncManager = syncManager ?? SyncManager();

  /// Memulai proses unduh data dari server.
  Future<void> jalankanProsesUnduh() async {
    // diubah: Menambahkan kurung kurawal untuk mematuhi aturan lint.
    if (_syncStatusController.isClosed || _syncStatusController.isPaused) {
      return;
    }
    _syncStatusController.add(true);
    developer.log('Memulai proses unduh data...', name: 'SinkronisasiService');

    final isConnected = await _koneksiInternetService.cekKoneksi();
    if (!isConnected) {
      developer.log(
        'Proses unduh gagal: Tidak ada koneksi internet.',
        name: 'SinkronisasiService',
      );
      _syncStatusController.add(false);
      return;
    }

    try {
      // diubah: Hanya logika unduh yang dijalankan.
      await _unduhData.unduhSemuaData();

      final newSyncTime = DateTime.now();
      await _syncManager.setLastSyncTimestamp(newSyncTime);
      developer.log(
        'Proses unduh berhasil. Waktu sinkronisasi terakhir diperbarui ke: $newSyncTime',
        name: 'SinkronisasiService',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Terjadi kesalahan selama proses unduh data.',
        name: 'SinkronisasiService.Error',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      if (!_syncStatusController.isClosed) {
        _syncStatusController.add(false);
      }
    }
  }

  /// Memulai unduh otomatis berdasarkan interval yang ditentukan.
  void mulaiUnduhOtomatis({required Duration interval}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (timer) async {
      developer.log(
        'Memulai unduh otomatis terjadwal.',
        name: 'SinkronisasiService',
      );
      // diubah: Memanggil metode proses unduh yang baru.
      await jalankanProsesUnduh();
    });
    developer.log(
      'Unduh data otomatis dijadwalkan setiap ${interval.inMinutes} menit.',
      name: 'SinkronisasiService',
    );
  }

  /// Menghentikan unduh otomatis.
  void hentikanUnduhOtomatis() {
    _syncTimer?.cancel();
    _syncTimer = null;
    developer.log(
      'Unduh data otomatis dihentikan.',
      name: 'SinkronisasiService',
    );
  }

  /// Membersihkan resource saat service tidak lagi digunakan.
  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
  }
}
