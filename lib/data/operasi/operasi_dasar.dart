// path: lib/data/operasi/operasi_dasar.dart

import 'package:admin_wifi/debug/log.dart';
import 'package:admin_wifi/data/operasi/status_unggah_operasi.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:sqflite/sqflite.dart';

/// Kelas ini adalah PUSAT KONTROL untuk semua operasi tulis (write) ke database.
class OperasiDasar {
  final _dbHelper = DatabaseHelper.instance;
  final _statusUnggahOperasi = StatusUnggahOperasi();

  // Fungsi generik untuk menjalankan operasi tulis di dalam transaksi.
  Future<T> _jalankanDalamTransaksi<T>(
    Future<T> Function(Transaction) aksi,
  ) async {
    Log.info('Memulai transaksi database');

    try {
      final db = await _dbHelper.database;

      return await db.transaction((txn) async {
        Log.info('Transaksi dibuka, menandai status "perlu_unggah"');

        await _statusUnggahOperasi.setPerluUnggah(true, transaction: txn);

        Log.info('Menjalankan aksi operasi dalam transaksi');
        final result = await aksi(txn);

        Log.info('Aksi berhasil, transaksi akan di-commit');
        return result;
      });
    } catch (e, stackTrace) {
      Log.error(
        'Gagal menjalankan transaksi database',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Menjalankan blok operasi kustom yang kompleks.
  Future<T> jalankanOperasiKompleks<T>(
    Future<T> Function(Transaction txn) aksiKustom,
  ) async {
    Log.info('Mendelegasikan eksekusi transaksi kompleks');
    return await _jalankanDalamTransaksi(aksiKustom);
  }

  /// Menyisipkan satu baris data ke dalam tabel.
  Future<void> sisipkan(String tabel, Map<String, dynamic> data) async {
    Log.info('Memulai penyisipan data ke tabel: $tabel', data);

    try {
      await _jalankanDalamTransaksi((txn) async {
        final result = await txn.insert(
          tabel,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        Log.info('INSERT berhasil', {'rowId': result, 'tabel': tabel});
        return result;
      });
    } catch (e, s) {
      Log.error(
        'Gagal menyisipkan data ke tabel: $tabel',
        error: e,
        stackTrace: s,
        data: data,
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
    Log.info('Memulai pembaruan data di tabel: $tabel', {
      'id': id,
      'data': data,
    });

    try {
      await _jalankanDalamTransaksi((txn) async {
        final rowsAffected = await txn.update(
          tabel,
          data,
          where: 'id = ?',
          whereArgs: [id],
        );

        if (rowsAffected == 0) {
          Log.warning(
            'Update selesai tapi tidak ada baris yang berubah (ID tidak ditemukan)',
            {'id': id, 'tabel': tabel},
          );
        } else {
          Log.info('UPDATE berhasil', {'rowsAffected': rowsAffected, 'id': id});
        }
        return rowsAffected;
      });
    } catch (e, s) {
      Log.error(
        'Gagal memperbarui data di tabel: $tabel',
        error: e,
        stackTrace: s,
        data: {'id': id, 'payload': data},
      );
      rethrow;
    }
  }

  /// Menghapus (atau mengarsipkan) satu baris data.
  Future<void> hapus(String tabel, String id) async {
    Log.info('Memulai penghapusan data', {'tabel': tabel, 'id': id});

    try {
      await _jalankanDalamTransaksi((txn) async {
        final rowsDeleted = await txn.delete(
          tabel,
          where: 'id = ?',
          whereArgs: [id],
        );

        if (rowsDeleted == 0) {
          Log.warning('Delete selesai tapi tidak ada data yang terhapus', {
            'id': id,
            'tabel': tabel,
          });
        } else {
          Log.info('DELETE berhasil', {'rowsDeleted': rowsDeleted, 'id': id});
        }
        return rowsDeleted;
      });
    } catch (e, s) {
      Log.error(
        'Gagal menghapus data di tabel: $tabel',
        error: e,
        stackTrace: s,
        data: {'id': id},
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
      Log.warning('Daftar data batch kosong, operasi dibatalkan', {
        'tabel': tabel,
      });
      return;
    }

    Log.info('Memulai batch operation', {
      'tabel': tabel,
      'totalItem': daftarData.length,
    });

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
              Log.info(
                'Batch progress: $i/${daftarData.length} item diproses...',
              );
            }
          }
        }

        Log.info('Melakukan commit batch...', {'validCount': validCount});
        await batch.commit(noResult: true);
        Log.info('Batch operation sukses');
      });
    } catch (e, s) {
      Log.error(
        'Gagal melakukan batch operation di tabel: $tabel',
        error: e,
        stackTrace: s,
        data: {'totalItem': daftarData.length},
      );
      rethrow;
    }
  }
}
