// path: lib/data/operasi/pengaturan_operasi.dart
import 'package:admin_wifi/data/operasi/operasi_dasar.dart'; // Import OperasiDasar
import 'package:admin_wifi/db/sqflite.dart';
import 'package:admin_wifi/model/pengaturan_model.dart';
import 'package:share_global_saya/src/utils/l.dart';

// Kelas untuk operasi database terkait tabel `pengaturan`.
class PengaturanOperasi {
  final _namaTabel = 'pengaturan';
  final OperasiDasar _operasiDasar = OperasiDasar(); // Instance OperasiDasar

  // Mengambil data pengaturan dari database.
  Future<PengaturanModel> getPengaturan() async {
    try {
      L.i(
        'Memulai proses pengambilan data pengaturan dari database - method: getPengaturan, tabel: $_namaTabel',
      );

      final db = await DatabaseHelper.instance.database;
      L.i('Berhasil mendapatkan koneksi database - method: getPengaturan');

      // Mengambil baris pertama karena hanya ada satu baris konfigurasi.
      L.i(
        'Menjalankan query SELECT untuk mengambil data pengaturan dengan limit 1 - method: getPengaturan, tabel: $_namaTabel',
      );
      final hasil = await db.query(_namaTabel, limit: 1);

      if (hasil.isNotEmpty) {
        L.i(
          'Data pengaturan berhasil ditemukan di database - method: getPengaturan, jumlahBaris: ${hasil.length}',
        );
        L.i(
          'Memproses konversi data SQLite ke PengaturanModel - method: getPengaturan',
        );
        return PengaturanModel.fromSqlite(hasil.first);
      } else {
        L.w(
          'Tidak ditemukan data pengaturan di database - method: getPengaturan, kondisi: hasil kosong, akan membuat pengaturan default',
        );

        // Jika belum ada, buat pengaturan default
        L.i('Membuat instance PengaturanModel default - method: getPengaturan');
        final pengaturanDefault = PengaturanModel();

        L.i(
          'Menyimpan pengaturan default ke database menggunakan OperasiDasar - method: getPengaturan',
        );
        await simpanAtauPerbaruiPengaturan(pengaturanDefault);

        L.i(
          'Berhasil membuat dan menyimpan pengaturan default - method: getPengaturan',
        );
        return pengaturanDefault;
      }
    } catch (e, stackTrace) {
      L.e(
        'Gagal mengambil data pengaturan dari database - method: getPengaturan, tabel: $_namaTabel, error: $e Error: $e $stackTrace',
      );
      // Mengembalikan model default jika terjadi error
      L.w(
        'Mengembalikan PengaturanModel default sebagai fallback karena terjadi error - method: getPengaturan',
      );
      return PengaturanModel();
    }
  }

  // Menyimpan atau memperbarui data pengaturan menggunakan OperasiDasar.
  Future<void> simpanAtauPerbaruiPengaturan(PengaturanModel pengaturan) async {
    try {
      L.i(
        'Memulai proses penyimpanan atau pembaruan data pengaturan menggunakan OperasiDasar - method: simpanAtauPerbaruiPengaturan, tabel: $_namaTabel',
      );
      L.i(
        'Validasi data pengaturan yang akan disimpan - method: simpanAtauPerbaruiPengaturan',
      );

      // Konversi model ke Map untuk operasi database
      final dataPengaturan = pengaturan.toSqlite();
      L.i(
        'Data pengaturan berhasil dikonversi ke format SQLite - method: simpanAtauPerbaruiPengaturan',
      );

      // Karena tabel pengaturan hanya memiliki 1 baris, kita perlu:
      // 1. Hapus data yang ada (jika ada)
      // 2. Insert data baru

      L.i(
        'Mendapatkan koneksi database untuk operasi hapus dan insert - method: simpanAtauPerbaruiPengaturan',
      );
      final db = await DatabaseHelper.instance.database;

      // Jalankan operasi dalam transaksi menggunakan OperasiDasar
      L.i(
        'Memulai transaksi database menggunakan OperasiDasar - method: simpanAtauPerbaruiPengaturan',
      );

      // Cek apakah data sudah ada
      L.i(
        'Memeriksa apakah data pengaturan sudah ada di database - method: simpanAtauPerbaruiPengaturan',
      );
      final existingData = await db.query(_namaTabel, limit: 1);

      if (existingData.isNotEmpty) {
        // Jika data sudah ada, hapus terlebih dahulu menggunakan OperasiDasar
        L.i(
          'Data pengaturan sudah ada, akan menghapus data lama - method: simpanAtauPerbaruiPengaturan',
        );

        // Ambil ID dari data yang ada
        final existingId = existingData.first['id'].toString();
        L.i(
          'ID data pengaturan yang akan dihapus: $existingId - method: simpanAtauPerbaruiPengaturan',
        );

        await _operasiDasar.hapus(_namaTabel, existingId);
        L.i(
          'Data pengaturan lama berhasil dihapus menggunakan OperasiDasar.hapus - method: simpanAtauPerbaruiPengaturan',
        );
      } else {
        L.i(
          'Belum ada data pengaturan, akan langsung melakukan insert - method: simpanAtauPerbaruiPengaturan',
        );
      }

      // Insert data baru menggunakan OperasiDasar
      L.i(
        'Menyisipkan data pengaturan baru menggunakan OperasiDasar.sisipkan - method: simpanAtauPerbaruiPengaturan',
      );
      await _operasiDasar.sisipkan(_namaTabel, dataPengaturan);

      L.i(
        'Data pengaturan baru berhasil disisipkan menggunakan OperasiDasar - method: simpanAtauPerbaruiPengaturan',
      );
      L.i(
        'Pengaturan berhasil disimpan/diperbarui menggunakan OperasiDasar - method: simpanAtauPerbaruiPengaturan, waktu: ${DateTime.now()}',
      );
    } catch (e, stackTrace) {
      L.e(
        'Gagal menyimpan atau memperbarui data pengaturan menggunakan OperasiDasar - method: simpanAtauPerbaruiPengaturan, tabel: $_namaTabel, error: $e Error: $e $stackTrace',
      );
      rethrow;
    }
  }

  // Method alternatif: Menggunakan batch operation dari OperasiDasar untuk efisiensi
  Future<void> simpanAtauPerbaruiPengaturanDenganBatch(
    PengaturanModel pengaturan,
  ) async {
    try {
      L.i(
        'Memulai proses penyimpanan dengan batch operation menggunakan OperasiDasar - method: simpanAtauPerbaruiPengaturanDenganBatch, tabel: $_namaTabel',
      );

      final dataPengaturan = pengaturan.toSqlite();
      L.i(
        'Data pengaturan siap untuk batch operation - method: simpanAtauPerbaruiPengaturanDenganBatch',
      );

      // Menggunakan method sisipkanAtauPerbaruiBatch yang sudah ada di OperasiDasar
      L.i(
        'Menggunakan OperasiDasar.sisipkanAtauPerbaruiBatch untuk batch operation - method: simpanAtauPerbaruiPengaturanDenganBatch',
      );
      await _operasiDasar.sisipkanAtauPerbaruiBatch(_namaTabel, [
        dataPengaturan,
      ]);

      L.i(
        'Batch operation berhasil menyimpan data pengaturan - method: simpanAtauPerbaruiPengaturanDenganBatch, waktu: ${DateTime.now()}',
      );
    } catch (e, stackTrace) {
      L.e(
        'Gagal menyimpan pengaturan dengan batch operation - method: simpanAtauPerbaruiPengaturanDenganBatch, error: $e Error: $e $stackTrace',
      );
      rethrow;
    }
  }
}
