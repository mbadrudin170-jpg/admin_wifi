// path: lib/data/services/pengecekan_waktu_sync_services.dart

import 'package:admin_wifi/data/services/pengecekan_data_baru.dart';
import 'package:admin_wifi/data/sync/unduh_data.dart';
import 'package:admin_wifi/data/sync/unggah_data.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:share_global_saya/src/utils/l.dart';

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
  }) : _syncManager = syncManager ?? SyncManager(),
       _layananUnggah = layananUnggah ?? LayananUnggahData(),
       _layananUnduh = layananUnduh ?? LayananUnduhData(),
       _pengecekanDataBaru = pengecekanDataBaru ?? PengecekanDataBaruService() {
    L.i(
      'Inisialisasi PengecekanWaktuSyncService berhasil. Seluruh dependensi utama seperti SyncManager (pengelola status), LayananUnggah (pengiriman data), LayananUnduh (penerimaan data), dan PengecekanDataBaruService (detektor perubahan) telah disuntikkan ke dalam sistem dan siap digunakan.',
    );
  }

  Future<bool> jalankanPengecekanDanSinkronisasi() async {
    L.i(
      'Memulai siklus orkestrasi sinkronisasi global. Prosedur ini akan menjalankan dua fase utama secara berurutan: Fase Sinkronisasi Keluar (Upload) untuk memastikan data lokal terkirim ke cloud, kemudian Fase Sinkronisasi Masuk (Download) untuk memastikan data lokal tetap aktual dengan cloud.',
    );

    L.i(
      'Memasuki Fase Pertama: Memulai prosedur pemeriksaan data lokal yang perlu diunggah.',
    );
    final bool unggahOk = await _cekDanJalankanUnggah();

    L.i(
      'Fase Pertama (Unggah) telah diselesaikan atau dilewati. Melanjutkan ke Fase Kedua: Memulai prosedur pemeriksaan pembaruan data di server cloud.',
    );

    final bool unduhOk = await _cekDanJalankanUnduh();

    L.i(
      'Seluruh siklus jalankanPengecekanDanSinkronisasi() telah berakhir. Status sinkronisasi lokal dan server kini seharusnya berada dalam kondisi konsisten.',
    );

    return unggahOk && unduhOk;
  }

  Future<bool> _cekDanJalankanUnggah() async {
    L.i(
      'Menjalankan fungsi internal _cekDanJalankanUnggah(). Sistem akan melakukan inspeksi pada database SQLite lokal untuk mendeteksi adanya entri data baru atau perubahan yang belum ditandai sebagai tersinkronisasi.',
    );

    try {
      L.i(
        'Memanggil method apakahSqliteAdaDataBaru() dari PengecekanDataBaruService. Melakukan query pengecekan flag sinkronisasi pada tabel-tabel terkait di database lokal.',
      );

      final bool apakahAdaDataUntukDiunggah = await _pengecekanDataBaru
          .apakahSqliteAdaDataBaru();

      if (apakahAdaDataUntukDiunggah) {
        L.i(
          'Deteksi Berhasil: Ditemukan data baru di penyimpanan lokal yang memerlukan sinkronisasi ke cloud. Mempersiapkan pemanggilan LayananUnggahData untuk memproses migrasi data.',
        );

        L.i(
          'Memulai eksekusi unggahSemuaData(). Seluruh payload data lokal akan dikonversi dan dikirim melalui protokol API/Firestore.',
        );
        await _layananUnggah.unggahSemuaData();

        L.i(
          'Eksekusi unggahSemuaData() selesai tanpa kendala. Langkah selanjutnya adalah memperbarui metadata waktu sinkronisasi agar sistem tidak mengunggah data yang sama pada siklus berikutnya.',
        );

        final waktuSekarang = DateTime.now();
        await _syncManager.setTerakhirUnggah(waktuSekarang);

        L.i(
          'Metadata sinkronisasi berhasil diperbarui. Waktu terakhir unggah (last_upload_timestamp) kini disetel pada: $waktuSekarang.',
        );
      } else {
        L.i(
          'Hasil Pengecekan: Tidak ditemukan record baru atau perubahan data pada database SQLite lokal. Melewati fase pengungahan untuk menghemat bandwidth dan sumber daya sistem.',
        );
      }
      return true;
    } catch (e, s) {
      L.e(
        'Kegagalan Operasional: Terjadi kesalahan fatal selama fase pengecekan atau pengungahan data lokal ke server. Proses sinkronisasi keluar dihentikan secara paksa untuk mencegah korupsi data. Error: $e $s',
      );
      return false;
    }
  }

  Future<bool> _cekDanJalankanUnduh() async {
    L.i(
      'Menjalankan fungsi internal _cekDanJalankanUnduh(). Sistem akan melakukan handshake dengan Firebase Firestore untuk memeriksa apakah ada pembaruan data dari admin atau user lain yang perlu diterapkan di database lokal.',
    );

    try {
      L.i(
        'Mengirim permintaan pengecekan ke Firebase melalui apakahFirebaseAdaDataBaru() pada koleksi: "data_baru", dokumen: "global". Mencari perbedaan timestamp antara server dan lokal.',
      );

      final bool apakahAdaDataBaruDiServer = await _pengecekanDataBaru
          .apakahFirebaseAdaDataBaru(
            namaKoleksi: 'data_baru',
            idDokumen: 'global',
          );

      if (apakahAdaDataBaruDiServer) {
        L.i(
          'Deteksi Server: Server cloud memiliki data yang lebih baru dibandingkan database lokal. Menginisiasi proses pengunduhan data secara menyeluruh.',
        );

        L.i(
          'Memulai eksekusi unduhSemuaData(). Mengambil snapshot terbaru dari Firestore dan memperbarui record SQLite lokal secara atomik.',
        );
        await _layananUnduh.unduhSemuaData();

        L.i(
          'Eksekusi unduhSemuaData() telah berhasil. Menginstruksikan SyncManager untuk memperbarui catatan waktu sinkronisasi masuk terakhir.',
        );

        final waktuSekarang = DateTime.now();
        await _syncManager.setTerakhirUnduh(waktuSekarang);

        L.i(
          'Sinkronisasi masuk selesai. Metadata last_download_timestamp telah diperbarui menjadi: $waktuSekarang. Data lokal kini identik dengan data server.',
        );
      } else {
        L.i(
          'Hasil Pengecekan Server: Cloud tidak memiliki pembaruan data (data lokal sudah up-to-date). Menghentikan fase pengunduhan untuk efisiensi.',
        );
      }
      return true;
    } catch (e, s) {
      L.e(
        'Kegagalan Operasional: Terjadi error saat mencoba mengambil atau memproses data baru dari server cloud ke penyimpanan lokal. Error: $e $s',
      );
      return false;
    }
  }
}
