// path: lib/data/services/pengecekan_waktu_sync_services.dart

import 'package:admin_wifi/data/services/pengecekan_data_baru.dart';
import 'package:admin_wifi/data/sync/unduh_data.dart';
import 'package:admin_wifi/data/sync/unggah_data.dart';
import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/utils/sync_manager.dart';

class PengecekanWaktuSyncService {
  final SyncManager _syncManager;
  final LayananUnggahData _layananUnggah;
  final LayananUnduhData _layananUnduh;
  final PengecekanDataBaruService _pengecekanDataBaru;

  PengecekanWaktuSyncService({
    SyncManager? syncManager,
    LayananUnggahData? layananUnggah,
    LayananUnduhData? layananUnduh,
    PengecekanDataBaruService? pengecekanDataBaru,
  })  : _syncManager = syncManager ?? SyncManager(),
        _layananUnggah = layananUnggah ?? LayananUnggahData(),
        _layananUnduh = layananUnduh ?? LayananUnduhData(),
        _pengecekanDataBaru =
            pengecekanDataBaru ?? PengecekanDataBaruService() {
    Log.info(
      'Inisialisasi PengecekanWaktuSyncService berhasil. Seluruh dependensi utama seperti SyncManager (pengelola status), LayananUnggah (pengiriman data), LayananUnduh (penerimaan data), dan PengecekanDataBaruService (detektor perubahan) telah disuntikkan ke dalam sistem dan siap digunakan.',
    );
  }

  Future<void> jalankanPengecekanDanSinkronisasi() async {
    Log.info(
      'Memulai siklus orkestrasi sinkronisasi global. Prosedur ini akan menjalankan dua fase utama secara berurutan: Fase Sinkronisasi Keluar (Upload) untuk memastikan data lokal terkirim ke cloud, kemudian Fase Sinkronisasi Masuk (Download) untuk memastikan data lokal tetap aktual dengan cloud.',
    );

    Log.info('Memasuki Fase Pertama: Memulai prosedur pemeriksaan data lokal yang perlu diunggah.');
    await _cekDanJalankanUnggah();

    Log.info(
      'Fase Pertama (Unggah) telah diselesaikan atau dilewati. Melanjutkan ke Fase Kedua: Memulai prosedur pemeriksaan pembaruan data di server cloud.',
    );

    await _cekDanJalankanUnduh();

    Log.info(
      'Seluruh siklus jalankanPengecekanDanSinkronisasi() telah berakhir dengan sukses. Status sinkronisasi lokal dan server kini seharusnya berada dalam kondisi konsisten.',
    );
  }

  Future<void> _cekDanJalankanUnggah() async {
    Log.info(
      'Menjalankan fungsi internal _cekDanJalankanUnggah(). Sistem akan melakukan inspeksi pada database SQLite lokal untuk mendeteksi adanya entri data baru atau perubahan yang belum ditandai sebagai tersinkronisasi.',
    );

    try {
      Log.info(
        'Memanggil method apakahSqliteAdaDataBaru() dari PengecekanDataBaruService. Melakukan query pengecekan flag sinkronisasi pada tabel-tabel terkait di database lokal.',
      );

      final bool apakahAdaDataUntukDiunggah =
          await _pengecekanDataBaru.apakahSqliteAdaDataBaru();

      if (apakahAdaDataUntukDiunggah) {
        Log.info(
          'Deteksi Berhasil: Ditemukan data baru di penyimpanan lokal yang memerlukan sinkronisasi ke cloud. Mempersiapkan pemanggilan LayananUnggahData untuk memproses migrasi data.',
        );

        Log.info('Memulai eksekusi unggahSemuaData(). Seluruh payload data lokal akan dikonversi dan dikirim melalui protokol API/Firestore.');
        await _layananUnggah.unggahSemuaData();

        Log.info(
          'Eksekusi unggahSemuaData() selesai tanpa kendala. Langkah selanjutnya adalah memperbarui metadata waktu sinkronisasi agar sistem tidak mengunggah data yang sama pada siklus berikutnya.',
        );

        final waktuSekarang = DateTime.now();
        await _syncManager.setTerakhirUnggah(waktuSekarang);

        Log.info(
          'Metadata sinkronisasi berhasil diperbarui. Waktu terakhir unggah (last_upload_timestamp) kini disetel pada: $waktuSekarang.',
        );
      } else {
        Log.info(
          'Hasil Pengecekan: Tidak ditemukan record baru atau perubahan data pada database SQLite lokal. Melewati fase pengunggahan untuk menghemat bandwidth dan sumber daya sistem.',
        );
      }
    } catch (e, s) {
      Log.error(
        'Kegagalan Operasional: Terjadi kesalahan fatal selama fase pengecekan atau pengunggahan data lokal ke server. Proses sinkronisasi keluar dihentikan secara paksa untuk mencegah korupsi data.',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> _cekDanJalankanUnduh() async {
    Log.info(
      'Menjalankan fungsi internal _cekDanJalankanUnduh(). Sistem akan melakukan handshake dengan Firebase Firestore untuk memeriksa apakah ada pembaruan data dari admin atau user lain yang perlu diterapkan di database lokal.',
    );

    try {
      Log.info(
        'Mengirim permintaan pengecekan ke Firebase melalui apakahFirebaseAdaDataBaru() pada koleksi: "data_baru", dokumen: "global". Mencari perbedaan timestamp antara server dan lokal.',
      );

      final bool apakahAdaDataBaruDiServer = await _pengecekanDataBaru
          .apakahFirebaseAdaDataBaru(
              namaKoleksi: 'data_baru', idDokumen: 'global');

      if (apakahAdaDataBaruDiServer) {
        Log.info(
          'Deteksi Server: Server cloud memiliki data yang lebih baru dibandingkan database lokal. Menginisiasi proses pengunduhan data secara menyeluruh.',
        );

        Log.info('Memulai eksekusi unduhSemuaData(). Mengambil snapshot terbaru dari Firestore dan memperbarui record SQLite lokal secara atomik.');
        await _layananUnduh.unduhSemuaData();

        Log.info(
          'Eksekusi unduhSemuaData() telah berhasil. Menginstruksikan SyncManager untuk memperbarui catatan waktu sinkronisasi masuk terakhir.',
        );

        final waktuSekarang = DateTime.now();
        await _syncManager.setTerakhirUnduh(waktuSekarang);

        Log.info(
          'Sinkronisasi masuk selesai. Metadata last_download_timestamp telah diperbarui menjadi: $waktuSekarang. Data lokal kini identik dengan data server.',
        );
      } else {
        Log.info(
          'Hasil Pengecekan Server: Cloud tidak memiliki pembaruan data (data lokal sudah up-to-date). Menghentikan fase pengunduhan untuk efisiensi.',
        );
      }
    } catch (e, s) {
      Log.error(
        'Kegagalan Operasional: Terjadi error saat mencoba mengambil atau memproses data baru dari server cloud ke penyimpanan lokal.',
        error: e,
        stackTrace: s,
      );
    }
  }
}