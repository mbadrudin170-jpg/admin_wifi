// path: lib/data/operasi/operasi_dasar.dart

import 'package:admin_wifi/data/operasi/status_unggah_operasi.dart';
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:share_global_saya/src/utils/l.dart';
import 'package:sqflite/sqflite.dart';

/// Kelas ini adalah PUSAT KONTROL untuk semua operasi tulis (write) ke database.
class OperasiDasar {
  final _dbHelper = DatabaseHelper.instance;
  final _statusUnggahOperasi = StatusUnggahOperasi();

  // Fungsi generik untuk menjalankan operasi tulis di dalam transaksi.
  Future<T> _jalankanDalamTransaksi<T>(
    Future<T> Function(Transaction) aksi,
  ) async {
    L.i('[TRANSAKSI DIMULAI] Memulai proses eksekusi dalam wrapper transaksi.');

    try {
      L.i('[TRANSAKSI] Mengambil instance database dari DatabaseHelper.');
      final db = await _dbHelper.database;
      L.i(
        '[TRANSAKSI] Instance database berhasil didapatkan. Tipe: ${db.runtimeType}',
      );

      L.i(
        '[TRANSAKSI] Memanggil db.transaction() untuk memulai blok transaksi.',
      );
      return await db.transaction((txn) async {
        L.i(
          '[TRANSAKSI AKTIF] Blok transaksi telah dimulai. Instance Transaction: ${txn.runtimeType}',
        );

        try {
          L.i('[TRANSAKSI AKTIF] Menandai status `perlu_unggah` menjadi TRUE.');
          await _statusUnggahOperasi.setPerluUnggah(true, transaction: txn);
          L.i('[TRANSAKSI AKTIF] Status `perlu_unggah` berhasil ditandai.');

          L.i(
            '[TRANSAKSI AKTIF] Mengeksekusi aksi utama (callback) yang diberikan.',
          );
          final result = await aksi(txn);
          L.i(
            '[TRANSAKSI AKTIF] Aksi utama berhasil dieksekusi. Hasil: ${result.runtimeType}',
          );

          L.i(
            '[TRANSAKSI COMMIT] Transaksi akan di-commit karena semua langkah berhasil.',
          );
          return result;
        } catch (e, stackTrace) {
          L.e(
            '[TRANSAKSI GAGAL DI DALAM] Terjadi error saat menjalankan aksi di dalam blok transaksi. Error: $e $stackTrace',
          );
          // Penting: Rethrow agar transaksi di-rollback oleh sqflite
          rethrow;
        }
      });
    } catch (e, stackTrace) {
      L.e(
        '[TRANSAKSI GAGAL DI LUAR] Gagal saat memulai atau menyelesaikan transaksi. Error: $e $stackTrace',
      );
      rethrow;
    }
  }

  /// Menjalankan blok operasi kustom yang kompleks.
  Future<T> jalankanOperasiKompleks<T>(
    Future<T> Function(Transaction txn) aksiKustom,
  ) async {
    L.i('Mendelegasikan eksekusi transaksi kompleks');
    return await _jalankanDalamTransaksi(aksiKustom);
  }

  /// Menyisipkan satu baris data ke dalam tabel.
  Future<void> sisipkan(String tabel, Map<String, dynamic> data) async {
    L.i('Memulai penyisipan data ke tabel: $tabel Data: $data');

    try {
      await _jalankanDalamTransaksi((txn) async {
        final result = await txn.insert(
          tabel,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        L.i("INSERT berhasil Data: ${{'rowId': result, 'tabel': tabel}}");
        return result;
      });
    } catch (e, s) {
      L.e('Gagal menyisipkan data ke tabel: $tabel Error: $e $s Data: $data');
      rethrow;
    }
  }

  /// Memperbarui satu baris data di dalam tabel.
  Future<void> perbarui(
    String tabel,
    Map<String, dynamic> data,
    String id,
  ) async {
    L.i(
      "Memulai pembaruan data di tabel: $tabel Data: ${{'id': id, 'data': data}}",
    );

    try {
      await _jalankanDalamTransaksi((txn) async {
        final rowsAffected = await txn.update(
          tabel,
          data,
          where: 'id = ?',
          whereArgs: [id],
        );

        if (rowsAffected == 0) {
          L.w(
            "Update selesai tapi tidak ada baris yang berubah (ID tidak ditemukan) Data: ${{'id': id, 'tabel': tabel}}",
          );
        } else {
          L.i(
            "UPDATE berhasil Data: ${{'rowsAffected': rowsAffected, 'id': id}}",
          );
        }
        return rowsAffected;
      });
    } catch (e, s) {
      L.e(
        "Gagal memperbarui data di tabel: $tabel Error: $e $s Data: ${{'id': id, 'payload': data}}",
      );
      rethrow;
    }
  }

  /// Menghapus (atau mengarsipkan) satu baris data.
  Future<void> hapus(String tabel, String id) async {
    L.i("Memulai penghapusan data Data: ${{'tabel': tabel, 'id': id}}");

    try {
      await _jalankanDalamTransaksi((txn) async {
        final rowsDeleted = await txn.delete(
          tabel,
          where: 'id = ?',
          whereArgs: [id],
        );

        if (rowsDeleted == 0) {
          L.w(
            "Delete selesai tapi tidak ada data yang terhapus Data: ${{'id': id, 'tabel': tabel}}",
          );
        } else {
          L.i(
            "DELETE berhasil Data: ${{'rowsDeleted': rowsDeleted, 'id': id}}",
          );
        }
        return rowsDeleted;
      });
    } catch (e, s) {
      L.e(
        "Gagal menghapus data di tabel: $tabel Error: $e $s Data: ${{'id': id}}",
      );
      rethrow;
    }
  }

  /// Metode batch untuk menyisipkan atau memperbarui banyak data sekaligus.
  Future<void> sisipkanAtauPerbaruiBatch(
    String tabel,
    List<Map<String, dynamic>> daftarData,
  ) async {
    if (daftarData.isEmpty) {
      L.w(
        "Daftar data batch kosong, operasi dibatalkan Data: ${{'tabel': tabel}}",
      );
      return;
    }

    L.i(
      "Memulai batch operation Data: ${{'tabel': tabel, 'totalItem': daftarData.length}}",
    );

    try {
      await _jalankanDalamTransaksi((txn) async {
        final batch = txn.batch();
        int validCount = 0;

        for (int i = 0; i < daftarData.length; i++) {
          final data = daftarData[i];
          if (data.isNotEmpty) {
            batch.insert(
              tabel,
              data,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            validCount++;

            // Log progress setiap 10 data agar konsol tidak spamming tapi tetap informatif
            if (i % 10 == 0 && i > 0) {
              L.i('Batch progress: $i/${daftarData.length} item diproses...');
            }
          }
        }

        L.i("Melakukan commit batch... Data: ${{'validCount': validCount}}");
        await batch.commit(noResult: true);
        L.i('Batch operation sukses');
      });
    } catch (e, s) {
      L.e(
        "Gagal melakukan batch operation di tabel: $tabel Error: $e $s Data: ${{'totalItem': daftarData.length}}",
      );
      rethrow;
    }
  }
}
