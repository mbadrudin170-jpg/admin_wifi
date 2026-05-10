// path: lib/data/operasi/pengaturan_operasi.dart
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/pengaturan_model.dart';
import 'package:admin_wifi/debug/log.dart'; // Import log custom
import 'package:admin_wifi/data/operasi/operasi_dasar.dart'; // Import OperasiDasar

// Kelas untuk operasi database terkait tabel `pengaturan`.
class PengaturanOperasi {
  final _namaTabel = 'pengaturan';
  final OperasiDasar _operasiDasar = OperasiDasar(); // Instance OperasiDasar

  // Mengambil data pengaturan dari database.
  Future<PengaturanModel> getPengaturan() async {
    try {
      Log.info(
        'Memulai proses pengambilan data pengaturan dari database - method: getPengaturan, tabel: $_namaTabel',
      );

      final db = await DatabaseHelper.instance.database;
      Log.info(
        'Berhasil mendapatkan koneksi database - method: getPengaturan',
      );

      // Mengambil baris pertama karena hanya ada satu baris konfigurasi.
      Log.info(
        'Menjalankan query SELECT untuk mengambil data pengaturan dengan limit 1 - method: getPengaturan, tabel: $_namaTabel',
      );
      final hasil = await db.query(_namaTabel, limit: 1);

      if (hasil.isNotEmpty) {
        Log.info(
          'Data pengaturan berhasil ditemukan di database - method: getPengaturan, jumlahBaris: ${hasil.length}',
        );
        Log.info(
          'Memproses konversi data SQLite ke PengaturanModel - method: getPengaturan',
        );
        return PengaturanModel.fromSqlite(hasil.first);
      } else {
        Log.warning(
          'Tidak ditemukan data pengaturan di database - method: getPengaturan, kondisi: hasil kosong, akan membuat pengaturan default',
        );

        // Jika belum ada, buat pengaturan default
        Log.info(
          'Membuat instance PengaturanModel default - method: getPengaturan',
        );
        final pengaturanDefault = PengaturanModel();

        Log.info(
          'Menyimpan pengaturan default ke database menggunakan OperasiDasar - method: getPengaturan',
        );
        await simpanAtauPerbaruiPengaturan(pengaturanDefault);

        Log.info(
          'Berhasil membuat dan menyimpan pengaturan default - method: getPengaturan',
        );
        return pengaturanDefault;
      }
    } catch (e, stackTrace) {
      Log.error(
        'Gagal mengambil data pengaturan dari database - method: getPengaturan, tabel: $_namaTabel, error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      // Mengembalikan model default jika terjadi error
      Log.warning(
        'Mengembalikan PengaturanModel default sebagai fallback karena terjadi error - method: getPengaturan',
      );
      return PengaturanModel();
    }
  }

  // Menyimpan atau memperbarui data pengaturan menggunakan OperasiDasar.
  Future<void> simpanAtauPerbaruiPengaturan(PengaturanModel pengaturan) async {
    try {
      Log.info(
        'Memulai proses penyimpanan atau pembaruan data pengaturan menggunakan OperasiDasar - method: simpanAtauPerbaruiPengaturan, tabel: $_namaTabel',
      );
      Log.info(
        'Validasi data pengaturan yang akan disimpan - method: simpanAtauPerbaruiPengaturan',
      );

      // Konversi model ke Map untuk operasi database
      final dataPengaturan = pengaturan.toSqlite();
      Log.info(
        'Data pengaturan berhasil dikonversi ke format SQLite - method: simpanAtauPerbaruiPengaturan',
      );

      // Karena tabel pengaturan hanya memiliki 1 baris, kita perlu:
      // 1. Hapus data yang ada (jika ada)
      // 2. Insert data baru
      
      Log.info(
        'Mendapatkan koneksi database untuk operasi hapus dan insert - method: simpanAtauPerbaruiPengaturan',
      );
      final db = await DatabaseHelper.instance.database;
      
      // Jalankan operasi dalam transaksi menggunakan OperasiDasar
      Log.info(
        'Memulai transaksi database menggunakan OperasiDasar - method: simpanAtauPerbaruiPengaturan',
      );
      
      // Cek apakah data sudah ada
      Log.info(
        'Memeriksa apakah data pengaturan sudah ada di database - method: simpanAtauPerbaruiPengaturan',
      );
      final existingData = await db.query(_namaTabel, limit: 1);
      
      if (existingData.isNotEmpty) {
        // Jika data sudah ada, hapus terlebih dahulu menggunakan OperasiDasar
        Log.info(
          'Data pengaturan sudah ada, akan menghapus data lama - method: simpanAtauPerbaruiPengaturan',
        );
        
        // Ambil ID dari data yang ada
        final existingId = existingData.first['id'].toString();
        Log.info(
          'ID data pengaturan yang akan dihapus: $existingId - method: simpanAtauPerbaruiPengaturan',
        );
        
        await _operasiDasar.hapus(_namaTabel, existingId);
        Log.info(
          'Data pengaturan lama berhasil dihapus menggunakan OperasiDasar.hapus - method: simpanAtauPerbaruiPengaturan',
        );
      } else {
        Log.info(
          'Belum ada data pengaturan, akan langsung melakukan insert - method: simpanAtauPerbaruiPengaturan',
        );
      }
      
      // Insert data baru menggunakan OperasiDasar
      Log.info(
        'Menyisipkan data pengaturan baru menggunakan OperasiDasar.sisipkan - method: simpanAtauPerbaruiPengaturan',
      );
      await _operasiDasar.sisipkan(_namaTabel, dataPengaturan);
      
      Log.info(
        'Data pengaturan baru berhasil disisipkan menggunakan OperasiDasar - method: simpanAtauPerbaruiPengaturan',
      );
      Log.info(
        'Pengaturan berhasil disimpan/diperbarui menggunakan OperasiDasar - method: simpanAtauPerbaruiPengaturan, waktu: ${DateTime.now()}',
      );
      
    } catch (e, stackTrace) {
      Log.error(
        'Gagal menyimpan atau memperbarui data pengaturan menggunakan OperasiDasar - method: simpanAtauPerbaruiPengaturan, tabel: $_namaTabel, error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  // Method alternatif: Menggunakan batch operation dari OperasiDasar untuk efisiensi
  Future<void> simpanAtauPerbaruiPengaturanDenganBatch(PengaturanModel pengaturan) async {
    try {
      Log.info(
        'Memulai proses penyimpanan dengan batch operation menggunakan OperasiDasar - method: simpanAtauPerbaruiPengaturanDenganBatch, tabel: $_namaTabel',
      );
      
      final dataPengaturan = pengaturan.toSqlite();
      Log.info(
        'Data pengaturan siap untuk batch operation - method: simpanAtauPerbaruiPengaturanDenganBatch',
      );
      
      // Menggunakan method sisipkanAtauPerbaruiBatch yang sudah ada di OperasiDasar
      Log.info(
        'Menggunakan OperasiDasar.sisipkanAtauPerbaruiBatch untuk batch operation - method: simpanAtauPerbaruiPengaturanDenganBatch',
      );
      await _operasiDasar.sisipkanAtauPerbaruiBatch(_namaTabel, [dataPengaturan]);
      
      Log.info(
        'Batch operation berhasil menyimpan data pengaturan - method: simpanAtauPerbaruiPengaturanDenganBatch, waktu: ${DateTime.now()}',
      );
      
    } catch (e, stackTrace) {
      Log.error(
        'Gagal menyimpan pengaturan dengan batch operation - method: simpanAtauPerbaruiPengaturanDenganBatch, error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}