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
    developer.log(
      '[SinkronisasiService]-[jalankanProsesUnduh] 🚀 : Memicu proses pengunduhan data dari server...',
      name: 'SinkronisasiService',
    );

    // diubah: Menambahkan kurung kurawal untuk mematuhi aturan lint.
    if (_syncStatusController.isClosed || _syncStatusController.isPaused) {
      developer.log(
        '[SinkronisasiService]-[jalankanProsesUnduh] 🛑 : Gagal memulai. StreamController sudah tertutup atau sedang dalam kondisi pause.',
        name: 'SinkronisasiService',
      );
      return;
    }

    _syncStatusController.add(true);
    developer.log(
      '[SinkronisasiService]-[jalankanProsesUnduh] 🔄 : Mengirim status "Sedang Mengunduh" ke Stream...',
      name: 'SinkronisasiService',
    );

    developer.log(
      '[SinkronisasiService]-[jalankanProsesUnduh] 🌐 : Melakukan verifikasi konektivitas internet...',
      name: 'SinkronisasiService',
    );
    final isConnected = await _koneksiInternetService.cekKoneksi();
    
    if (!isConnected) {
      developer.log(
        '[SinkronisasiService]-[jalankanProsesUnduh] ⚠️ : Proses unduh dibatalkan: Perangkat tidak memiliki akses internet.',
        name: 'SinkronisasiService',
      );
      _syncStatusController.add(false);
      return;
    }

    try {
      developer.log(
        '[SinkronisasiService]-[jalankanProsesUnduh] 📥 : Mengeksekusi LayananUnduhData.unduhSemuaData()...',
        name: 'SinkronisasiService',
      );
      // diubah: Hanya logika unduh yang dijalankan.
      await _unduhData.unduhSemuaData();

      final newSyncTime = DateTime.now();
      developer.log(
        '[SinkronisasiService]-[jalankanProsesUnduh] 💾 : Memperbarui timestamp sinkronisasi terakhir di SyncManager...',
        name: 'SinkronisasiService',
      );
      await _syncManager.setLastSyncTimestamp(newSyncTime);
      
      developer.log(
        '[SinkronisasiService]-[jalankanProsesUnduh] ✅ : Proses unduh berhasil total. Sinkronisasi terakhir: $newSyncTime',
        name: 'SinkronisasiService',
      );
    } catch (e, stackTrace) {
      developer.log(
        '[SinkronisasiService]-[jalankanProsesUnduh] ❌ : Terjadi kesalahan fatal selama siklus pengunduhan data.',
        name: 'SinkronisasiService.Error',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      if (!_syncStatusController.isClosed) {
        developer.log(
          '[SinkronisasiService]-[jalankanProsesUnduh] 🏁 : Siklus selesai. Mengatur status pengunduhan kembali ke "Idle" (false).',
          name: 'SinkronisasiService',
        );
        _syncStatusController.add(false);
      }
    }
  }

  /// Memulai unduh otomatis berdasarkan interval yang ditentukan.
  void mulaiUnduhOtomatis({required Duration interval}) {
    developer.log(
      '[SinkronisasiService]-[mulaiUnduhOtomatis] ⏰ : Mengaktifkan penjadwal otomatis dengan interval ${interval.inMinutes} menit.',
      name: 'SinkronisasiService',
    );
    
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (timer) async {
      developer.log(
        '[SinkronisasiService]-[TimerPeriodic] 📟 : Timer berdetak. Memicu jalankanProsesUnduh() secara otomatis.',
        name: 'SinkronisasiService',
      );
      // diubah: Memanggil metode proses unduh yang baru.
      await jalankanProsesUnduh();
    });
    
    developer.log(
      '[SinkronisasiService]-[mulaiUnduhOtomatis] 📅 : Unduh data otomatis telah dijadwalkan dengan sukses.',
      name: 'SinkronisasiService',
    );
  }

  /// Menghentikan unduh otomatis.
  void hentikanUnduhOtomatis() {
    developer.log(
      '[SinkronisasiService]-[hentikanUnduhOtomatis] ⏹️ : Mematikan timer penjadwal otomatis...',
      name: 'SinkronisasiService',
    );
    _syncTimer?.cancel();
    _syncTimer = null;
    developer.log(
      '[SinkronisasiService]-[hentikanUnduhOtomatis] ✅ : Unduh data otomatis telah dinonaktifkan.',
      name: 'SinkronisasiService',
    );
  }

  /// Membersihkan resource saat service tidak lagi digunakan.
  void dispose() {
    developer.log(
      '[SinkronisasiService]-[dispose] 🧹 : Membersihkan resource service. Menutup timer dan stream controller...',
      name: 'SinkronisasiService',
    );
    _syncTimer?.cancel();
    _syncStatusController.close();
    developer.log(
      '[SinkronisasiService]-[dispose] ✨ : Service berhasil dibersihkan (Disposed).',
      name: 'SinkronisasiService',
    );
  }
}