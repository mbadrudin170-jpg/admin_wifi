// path: lib/data/operasi/operasi_dasar.dart

import 'package:admin_wifi/debug/log.dart'; // Menggunakan logger kustom
import 'package:admin_wifi/data/operasi/status_unggah_operasi.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:sqflite/sqflite.dart';

/// Kelas ini adalah PUSAT KONTROL untuk semua operasi tulis (write) ke database.
/// Tujuannya adalah untuk memastikan bahwa setiap kali ada perubahan data,
/// bendera `perlu_unggah` diatur menjadi `true`.
class OperasiDasar {
  final _dbHelper = DatabaseHelper.instance;
  final _statusUnggahOperasi = StatusUnggahOperasi();

  // Nama file untuk kepentingan logging
  final String _fileName = 'operasi_dasar.dart';

  // Fungsi generik untuk menjalankan operasi tulis di dalam transaksi.
  Future<T> _jalankanDalamTransaksi<T>(
    Future<T> Function(Transaction) aksi,
  ) async {
    Log.info(
      'Memulai proses transaksi database - file: $_fileName, method: _jalankanDalamTransaksi',
    );

    try {
      Log.info(
        'Mendapatkan koneksi database untuk transaksi - file: $_fileName, method: _jalankanDalamTransaksi',
      );
      final db = await _dbHelper.database;

      Log.info(
        'Membuka transaksi database baru - file: $_fileName, method: _jalankanDalamTransaksi',
      );
      return await db.transaction((txn) async {
        Log.info(
          'Transaksi berhasil dibuka - file: $_fileName, method: _jalankanDalamTransaksi',
        );

        Log.info(
          'Menandai bahwa ada perubahan data yang perlu diunggah - file: $_fileName, method: _jalankanDalamTransaksi',
        );
        await _statusUnggahOperasi.setPerluUnggah(true, transaction: txn);

        Log.info(
          'Menjalankan operasi aksi dalam transaksi - file: $_fileName, method: _jalankanDalamTransaksi',
        );
        final result = await aksi(txn);

        Log.info(
          'Operasi aksi berhasil dijalankan, transaksi akan di-commit - file: $_fileName, method: _jalankanDalamTransaksi',
        );
        return result;
      });
    } catch (e, stackTrace) {
      Log.error(
        'Gagal menjalankan transaksi database - file: $_fileName, method: _jalankanDalamTransaksi, error: $e',
        error: e,
        stackTrace: stackTrace,
        name: _fileName,
      );
      rethrow;
    }
  }

  /// Menjalankan blok operasi kustom yang kompleks di dalam sebuah transaksi yang dikelola.
  /// Ini memastikan bahwa `perlu_unggah` diatur secara otomatis.
  /// Gunakan ini untuk operasi yang lebih dari sekadar sisipkan/perbarui/hapus tunggal.
  Future<T> jalankanOperasiKompleks<T>(
    Future<T> Function(Transaction txn) aksiKustom,
  ) async {
    Log.info(
      'Mendelegasikan eksekusi transaksi kompleks ke pembungkus internal - file: $_fileName, method: jalankanOperasiKompleks',
    );
    // Memanggil metode private yang sudah ada untuk menjalankan transaksi
    return await _jalankanDalamTransaksi(aksiKustom);
  }

  /// Menyisipkan satu baris data ke dalam tabel.
  Future<void> sisipkan(String tabel, Map<String, dynamic> data) async {
    Log.info(
      'Memulai proses penyisipan data tunggal - file: $_fileName, method: sisipkan, tabel: $tabel',
    );
    Log.info(
      'Data yang akan disisipkan: $data - file: $_fileName, method: sisipkan, tabel: $tabel',
    );

    try {
      Log.info(
        'Memvalidasi data sebelum penyisipan - file: $_fileName, method: sisipkan, tabel: $tabel, jumlahField: ${data.length}',
      );

      await _jalankanDalamTransaksi((txn) async {
        Log.info(
          'Menjalankan operasi INSERT dalam transaksi - file: $_fileName, method: sisipkan, tabel: $tabel',
        );
        final result = await txn.insert(
          tabel,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        Log.info(
          'Operasi INSERT berhasil dijalankan - file: $_fileName, method: sisipkan, tabel: $tabel, resultRowId: $result',
        );
        return result;
      });

      Log.info(
        'Data berhasil disisipkan ke tabel: $tabel - file: $_fileName, method: sisipkan, waktu: ${DateTime.now()}',
      );
    } catch (e, s) {
      Log.error(
        'Gagal menyisipkan data ke tabel: $tabel - file: $_fileName, method: sisipkan, data: $data, error: $e',
        error: e,
        stackTrace: s,
        name: _fileName,
      );
      rethrow;
    }
  }

  /// Memperbarui satu baris data di dalam tabel.
  Future<void> perbarui(
    String tabel,
    Map<String, dynamic> data,
    String id,
  ) async {
    Log.info(
      'Memulai proses pembaruan data tunggal - file: $_fileName, method: perbarui, tabel: $tabel, id: $id',
    );
    Log.info(
      'Data yang akan diperbarui: $data - file: $_fileName, method: perbarui, tabel: $tabel, id: $id',
    );

    try {
      Log.info(
        'Memvalidasi data dan ID sebelum pembaruan - file: $_fileName, method: perbarui, tabel: $tabel, id: $id, jumlahField: ${data.length}',
      );

      await _jalankanDalamTransaksi((txn) async {
        Log.info(
          'Menjalankan operasi UPDATE dalam transaksi - file: $_fileName, method: perbarui, tabel: $tabel, id: $id',
        );
        final rowsAffected = await txn.update(
          tabel,
          data,
          where: 'id = ?',
          whereArgs: [id],
        );
        Log.info(
          'Operasi UPDATE berhasil dijalankan - file: $_fileName, method: perbarui, tabel: $tabel, id: $id, rowsAffected: $rowsAffected',
        );

        if (rowsAffected == 0) {
          Log.warning(
            'Tidak ada data yang diperbarui - file: $_fileName, method: perbarui, tabel: $tabel, id: $id, kemungkinan id tidak ditemukan',
          );
        }
        return rowsAffected;
      });

      Log.info(
        'Data di tabel $tabel dengan id=$id berhasil diperbarui - file: $_fileName, method: perbarui, waktu: ${DateTime.now()}',
      );
    } catch (e, s) {
      Log.error(
        'Gagal memperbarui data di tabel: $tabel - file: $_fileName, method: perbarui, id: $id, data: $data, error: $e',
        error: e,
        stackTrace: s,
        name: _fileName,
      );
      rethrow;
    }
  }

  /// Menghapus (atau mengarsipkan) satu baris data.
  Future<void> hapus(String tabel, String id) async {
    Log.info(
      'Memulai proses penghapusan data tunggal - file: $_fileName, method: hapus, tabel: $tabel, id: $id',
    );

    try {
      Log.info(
        'Memvalidasi ID sebelum penghapusan - file: $_fileName, method: hapus, tabel: $tabel, id: $id',
      );

      await _jalankanDalamTransaksi((txn) async {
        Log.info(
          'Menjalankan operasi DELETE dalam transaksi - file: $_fileName, method: hapus, tabel: $tabel, id: $id',
        );
        final rowsDeleted = await txn.delete(
          tabel,
          where: 'id = ?',
          whereArgs: [id],
        );
        Log.info(
          'Operasi DELETE berhasil dijalankan - file: $_fileName, method: hapus, tabel: $tabel, id: $id, rowsDeleted: $rowsDeleted',
        );

        if (rowsDeleted == 0) {
          Log.warning(
            'Tidak ada data yang dihapus - file: $_fileName, method: hapus, tabel: $tabel, id: $id, kemungkinan id tidak ditemukan',
          );
        }
        return rowsDeleted;
      });

      Log.info(
        'Data dengan id=$id dari tabel $tabel berhasil dihapus - file: $_fileName, method: hapus, waktu: ${DateTime.now()}',
      );
    } catch (e, s) {
      Log.error(
        'Gagal menghapus data di tabel: $tabel - file: $_fileName, method: hapus, id: $id, error: $e',
        error: e,
        stackTrace: s,
        name: _fileName,
      );
      rethrow;
    }
  }

  /// Metode batch untuk menyisipkan atau memperbarui banyak data sekaligus.
  /// Ini jauh lebih efisien daripada melakukan loop dan memanggil `sisipkan` berulang kali.
  Future<void> sisipkanAtauPerbaruiBatch(
    String tabel,
    List<Map<String, dynamic>> daftarData,
  ) async {
    Log.info(
      'Memulai proses batch insert/update - file: $_fileName, method: sisipkanAtauPerbaruiBatch, tabel: $tabel',
    );
    Log.info(
      'Jumlah data yang akan diproses: ${daftarData.length} item - file: $_fileName, method: sisipkanAtauPerbaruiBatch, tabel: $tabel',
    );

    if (daftarData.isEmpty) {
      Log.warning(
        'Daftar data kosong, tidak ada yang perlu diproses - file: $_fileName, method: sisipkanAtauPerbaruiBatch, tabel: $tabel',
      );
      return;
    }

    try {
      Log.info(
        'Memvalidasi daftar data sebelum batch processing - file: $_fileName, method: sisipkanAtauPerbaruiBatch, tabel: $tabel, totalData: ${daftarData.length}',
      );

      await _jalankanDalamTransaksi((txn) async {
        Log.info(
          'Membuat batch operation dalam transaksi - file: $_fileName, method: sisipkanAtauPerbaruiBatch, tabel: $tabel',
        );
        final batch = txn.batch();

        int validDataCount = 0;
        for (int i = 0; i < daftarData.length; i++) {
          final data = daftarData[i];
          if (data.isNotEmpty) {
            batch.insert(
              tabel,
              data,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            validDataCount++;
            if (i % 10 == 0 && i > 0) {
              // Log setiap 10 data untuk tracking progress
              Log.info(
                'Progress batch: $i/${daftarData.length} data diproses - file: $_fileName, method: sisipkanAtauPerbaruiBatch, tabel: $tabel',
              );
            }
          } else {
            Log.warning(
              'Data ke-$i kosong, dilewati - file: $_fileName, method: sisipkanAtauPerbaruiBatch, tabel: $tabel',
            );
          }
        }

        Log.info(
          'Batch operation siap dengan $validDataCount data valid - file: $_fileName, method: sisipkanAtauPerbaruiBatch, tabel: $tabel',
        );

        Log.info(
          'Melakukan commit batch operation - file: $_fileName, method: sisipkanAtauPerbaruiBatch, tabel: $tabel',
        );
        await batch.commit(noResult: true);
        Log.info(
          'Batch operation berhasil di-commit - file: $_fileName, method: sisipkanAtauPerbaruiBatch, tabel: $tabel',
        );
      });

      Log.info(
        '${daftarData.length} item berhasil di-batch insert/update ke tabel: $tabel - file: $_fileName, method: sisipkanAtauPerbaruiBatch, waktu: ${DateTime.now()}',
      );
    } catch (e, s) {
      Log.error(
        'Gagal melakukan batch insert/update ke tabel: $tabel - file: $_fileName, method: sisipkanAtauPerbaruiBatch, jumlahData: ${daftarData.length}, error: $e',
        error: e,
        stackTrace: s,
        name: _fileName,
      );
      rethrow;
    }
  }
}
