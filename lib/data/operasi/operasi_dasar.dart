// path: lib/data/operasi/operasi_dasar.dart

import 'dart:developer' as developer;
import 'package:admin_wifi/data/operasi/status_unggah_operasi.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:sqflite/sqflite.dart';

/// Kelas ini adalah PUSAT KONTROL untuk semua operasi tulis (write) ke database.
/// Tujuannya adalah untuk memastikan bahwa setiap kali ada perubahan data,
/// bendera `perlu_unggah` diatur menjadi `true`.
class OperasiDasar {
  final _dbHelper = DatabaseHelper.instance;
  final _statusUnggahOperasi = StatusUnggahOperasi();

  // Fungsi generik untuk menjalankan operasi tulis di dalam transaksi.
  Future<T> _jalankanDalamTransaksi<T>(Future<T> Function(Transaction) aksi) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      // Tandai bahwa ada perubahan data yang perlu diunggah.
      await _statusUnggahOperasi.setPerluUnggah(true, transaction: txn);
      // Jalankan operasi tulis yang sebenarnya.
      return await aksi(txn);
    });
  }

  /// Menyisipkan satu baris data ke dalam tabel.
  Future<void> sisipkan(String tabel, Map<String, dynamic> data) async {
    try {
      await _jalankanDalamTransaksi((txn) async {
        await txn.insert(tabel, data, conflictAlgorithm: ConflictAlgorithm.replace);
      });
       developer.log('✅ Data berhasil disisipkan ke tabel: $tabel', name: 'OperasiDasar.sisipkan');
    } catch (e, s) {
       developer.log('❌ Gagal menyisipkan data ke tabel: $tabel', error: e, stackTrace: s, name: 'OperasiDasar.sisipkan');
       rethrow;
    }
  }

  /// Memperbarui satu baris data di dalam tabel.
  Future<void> perbarui(String tabel, Map<String, dynamic> data, String id) async {
    try {
      await _jalankanDalamTransaksi((txn) async {
        await txn.update(tabel, data, where: 'id = ?', whereArgs: [id]);
      });
      developer.log('✅ Data di tabel $tabel dengan id=$id berhasil diperbarui', name: 'OperasiDasar.perbarui');
    } catch (e, s) {
      developer.log('❌ Gagal memperbarui data di tabel: $tabel', error: e, stackTrace: s, name: 'OperasiDasar.perbarui');
      rethrow;
    }
  }

  /// Menghapus (atau mengarsipkan) satu baris data.
  Future<void> hapus(String tabel, String id) async {
     try {
      await _jalankanDalamTransaksi((txn) async {
        await txn.delete(tabel, where: 'id = ?', whereArgs: [id]);
      });
       developer.log('✅ Data dengan id=$id dari tabel $tabel berhasil dihapus', name: 'OperasiDasar.hapus');
    } catch (e, s) {
       developer.log('❌ Gagal menghapus data di tabel: $tabel', error: e, stackTrace: s, name: 'OperasiDasar.hapus');
       rethrow;
    }
  }

  // ditambah: Metode batch untuk menyisipkan atau memperbarui banyak data sekaligus.
  // Ini jauh lebih efisien daripada melakukan loop dan memanggil `sisipkan` berulang kali.
  Future<void> sisipkanAtauPerbaruiBatch(String tabel, List<Map<String, dynamic>> daftarData) async {
    if (daftarData.isEmpty) return;

    try {
      await _jalankanDalamTransaksi((txn) async {
        final batch = txn.batch();
        for (final data in daftarData) {
          batch.insert(tabel, data, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
      });
      developer.log('✅ ${daftarData.length} item berhasil di-batch insert/update ke tabel: $tabel', name: 'OperasiDasar.batch');
    } catch (e, s) {
      developer.log('❌ Gagal melakukan batch insert/update ke tabel: $tabel', error: e, stackTrace: s, name: 'OperasiDasar.batch');
      rethrow;
    }
  }
}
