// path: lib/data/services/pengecekan_waktu_sync_services.dart

import 'dart:developer' as developer;

import 'package:admin_wifi/data/services/pengecekan_data_baru.dart'; // diubah: impor ke file yang benar
import 'package:admin_wifi/data/sync/unduh_data.dart';
import 'package:admin_wifi/data/sync/unggah_data.dart';
import 'package:admin_wifi/utils/sync_manager.dart';

class PengecekanWaktuSyncService {
  final SyncManager _syncManager;
  final LayananUnggahData _layananUnggah;
  final LayananUnduhData _layananUnduh;
  final PengecekanDataBaruService _pengecekanDataBaru;

  // dihapus: dependensi ke DatabaseHelper karena logikanya sudah dipindahkan
  PengecekanWaktuSyncService({
    SyncManager? syncManager,
    LayananUnggahData? layananUnggah,
    LayananUnduhData? layananUnduh,
    PengecekanDataBaruService? pengecekanDataBaru,
  }) : _syncManager = syncManager ?? SyncManager(),
       _layananUnggah = layananUnggah ?? LayananUnggahData(),
       _layananUnduh = layananUnduh ?? LayananUnduhData(),
       _pengecekanDataBaru = pengecekanDataBaru ?? PengecekanDataBaruService() {
    developer.log(
      'PengecekanWaktuSyncService berhasil diinisialisasi dengan SyncManager, LayananUnggahData, LayananUnduhData, dan PengecekanDataBaruService',
      name: 'PengecekanWaktuSyncService-Constructor 🚀',
    );
  }

  Future<void> jalankanPengecekanDanSinkronisasi() async {
    developer.log(
      'Memulai alur pengecekan sinkronisasi...',
      name: 'PengecekanWaktuSync',
    );

    developer.log(
      'Memulai alur pengecekan dan sinkronisasi lengkap (Unggah + Unduh)',
      name: 'PengecekanWaktuSyncService-jalankanPengecekanDanSinkronisasi ℹ️',
    );

    await _cekDanJalankanUnggah();

    developer.log(
      'Proses unggah selesai, melanjutkan ke proses unduh',
      name: 'PengecekanWaktuSyncService-jalankanPengecekanDanSinkronisasi 🔄',
    );

    await _cekDanJalankanUnduh();

    developer.log(
      'Alur pengecekan sinkronisasi selesai.',
      name: 'PengecekanWaktuSync',
    );

    developer.log(
      'Alur pengecekan dan sinkronisasi lengkap berhasil diselesaikan',
      name: 'PengecekanWaktuSyncService-jalankanPengecekanDanSinkronisasi ✅',
    );
  }

  Future<void> _cekDanJalankanUnggah() async {
    developer.log(
      'Memulai proses pengecekan dan unggah data lokal',
      name: 'PengecekanWaktuSyncService-_cekDanJalankanUnggah ℹ️',
    );

    try {
      developer.log(
        'Mengecek data lokal untuk diunggah...',
        name: 'PengecekanWaktuSync.Unggah',
      );

      developer.log(
        'Memanggil PengecekanDataBaruService.apakahSqliteAdaDataBaru() untuk mengecek perubahan lokal',
        name: 'PengecekanWaktuSyncService-_cekDanJalankanUnggah 🔄',
      );

      // diubah: Memanggil metode dari layanan yang didedikasikan
      final apakahAdaDataUntukDiunggah = await _pengecekanDataBaru
          .apakahSqliteAdaDataBaru();

      developer.log(
        'Hasil pengecekan data lokal: ${apakahAdaDataUntukDiunggah ? "Ada data untuk diunggah" : "Tidak ada data untuk diunggah"}',
        name: 'PengecekanWaktuSyncService-_cekDanJalankanUnggah 📝',
      );

      if (apakahAdaDataUntukDiunggah) {
        developer.log(
          'Perubahan lokal terdeteksi, menjalankan proses unggah...',
          name: 'PengecekanWaktuSync.Unggah',
        );

        developer.log(
          'Memulai proses unggah semua data ke server',
          name: 'PengecekanWaktuSyncService-_cekDanJalankanUnggah 🔄',
        );

        await _layananUnggah.unggahSemuaData();

        developer.log(
          'Proses unggah selesai, memperbarui waktu unggah terakhir',
          name: 'PengecekanWaktuSyncService-_cekDanJalankanUnggah ✅',
        );

        final waktuSekarang = DateTime.now();
        await _syncManager.setTerakhirUnggah(waktuSekarang);

        developer.log(
          'Waktu unggah terakhir berhasil diperbarui: $waktuSekarang',
          name: 'PengecekanWaktuSyncService-_cekDanJalankanUnggah ✅',
        );
      } else {
        developer.log(
          'Tidak ada data lokal baru untuk diunggah.',
          name: 'PengecekanWaktuSync.Unggah',
        );

        developer.log(
          'Tidak ada perubahan lokal, melewati proses unggah',
          name: 'PengecekanWaktuSyncService-_cekDanJalankanUnggah ℹ️',
        );
      }
    } catch (e, s) {
      developer.log(
        'Gagal dalam alur pengecekan unggah.',
        name: 'PengecekanWaktuSync.Unggah.Error',
        error: e,
        stackTrace: s,
      );

      developer.log(
        'Error saat pengecekan atau proses unggah: $e',
        name: 'PengecekanWaktuSyncService-_cekDanJalankanUnggah ❌',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> _cekDanJalankanUnduh() async {
    developer.log(
      'Memulai proses pengecekan dan unduh data dari server',
      name: 'PengecekanWaktuSyncService-_cekDanJalankanUnduh ℹ️',
    );

    try {
      developer.log(
        'Mengecek data baru di server untuk diunduh...',
        name: 'PengecekanWaktuSync.Unduh',
      );

      developer.log(
        'Memanggil PengecekanDataBaruService.apakahFirebaseAdaDataBaru() untuk mengecek data server',
        name: 'PengecekanWaktuSyncService-_cekDanJalankanUnduh 🔄',
      );

      // diubah: Memanggil metode yang lebih spesifik dari layanan yang didedikasikan
      final apakahAdaDataBaruDiServer = await _pengecekanDataBaru
          .apakahFirebaseAdaDataBaru(
            namaKoleksi: 'status',
            idDokumen: 'global',
          );

      developer.log(
        'Hasil pengecekan data server: ${apakahAdaDataBaruDiServer ? "Ada data baru untuk diunduh" : "Data sudah sinkron"}',
        name: 'PengecekanWaktuSyncService-_cekDanJalankanUnduh 📝',
      );

      if (apakahAdaDataBaruDiServer) {
        developer.log(
          'Data baru di server terdeteksi, menjalankan proses unduh...',
          name: 'PengecekanWaktuSync.Unduh',
        );

        developer.log(
          'Memulai proses unduh semua data dari server',
          name: 'PengecekanWaktuSyncService-_cekDanJalankanUnduh 🔄',
        );

        await _layananUnduh.unduhSemuaData();

        developer.log(
          'Proses unduh selesai, memperbarui waktu unduh terakhir',
          name: 'PengecekanWaktuSyncService-_cekDanJalankanUnduh ✅',
        );

        final waktuSekarang = DateTime.now();
        await _syncManager.setTerakhirUnduh(waktuSekarang);

        developer.log(
          'Waktu unduh terakhir berhasil diperbarui: $waktuSekarang',
          name: 'PengecekanWaktuSyncService-_cekDanJalankanUnduh ✅',
        );
      } else {
        developer.log(
          'Data lokal sudah sinkron dengan server.',
          name: 'PengecekanWaktuSync.Unduh',
        );

        developer.log(
          'Tidak ada data baru di server, melewati proses unduh',
          name: 'PengecekanWaktuSyncService-_cekDanJalankanUnduh ℹ️',
        );
      }
    } catch (e, s) {
      developer.log(
        'Gagal dalam alur pengecekan unduh.',
        name: 'PengecekanWaktuSync.Unduh.Error',
        error: e,
        stackTrace: s,
      );

      developer.log(
        'Error saat pengecekan atau proses unduh: $e',
        name: 'PengecekanWaktuSyncService-_cekDanJalankanUnduh ❌',
        error: e,
        stackTrace: s,
      );
    }
  }

  // dihapus: Fungsi helper _apakahAdaPerubahanLokal telah dipindahkan ke PengecekanDataBaruService.
}
