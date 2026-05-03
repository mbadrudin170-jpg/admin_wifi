// path: lib/data/sync/unggah_data.dart
// diubah: file dirombak untuk menjadi lebih efisien dengan pengecekan timestamp dan hanya melakukan unggah data.
import 'dart:developer' as developer;
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:admin_wifi/model/kritik_saran_model.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:admin_wifi/model/pesanan_model.dart';
import 'package:admin_wifi/model/riwayat_langganan_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// untuk mengelola proses pengunggahan data dari database lokal ke Firebase.
class UnggahDataService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SyncManager _syncManager = SyncManager();

  // untuk mengunggah semua data yang belum sinkron ke Firebase secara paralel.
  Future<void> unggahSemuaData() async {
    final waktuSinkronisasiTerakhir = await _syncManager.getLastSyncTimestamp();
    developer.log(
      'Memulai unggah dengan waktu sinkronisasi terakhir: $waktuSinkronisasiTerakhir',
      name: 'UnggahDataService',
    );

    final List<Future<void>> daftarUnggah = [
      _unggahDataGenerik<DompetModel>(
        'dompet',
        'dompet',
        DompetModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
      _unggahDataGenerik<KategoriModel>(
        'kategori',
        'kategori',
        KategoriModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
      _unggahDataGenerik<KritikSaranModel>(
        'kritik_saran',
        'kritik_saran',
        KritikSaranModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
      _unggahDataGenerik<PaketModel>(
        'paket',
        'paket',
        PaketModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
      _unggahDataGenerik<PelangganAktifModel>(
        'pelanggan_aktif',
        'pelanggan_aktif',
        PelangganAktifModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
      _unggahDataGenerik<PelangganModel>(
        'pelanggan',
        'pelanggan',
        PelangganModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
      _unggahDataGenerik<PesananModel>(
        'pesanan',
        'pesan',
        PesananModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
      _unggahDataGenerik<RiwayatLanggananModel>(
        'riwayat_langganan',
        'riwayat_langganan',
        RiwayatLanggananModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
      _unggahDataGenerik<TransaksiModel>(
        'transaksi',
        'transaksi',
        TransaksiModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
    ];

    await Future.wait(daftarUnggah);
    developer.log('Semua proses unggah selesai.', name: 'UnggahDataService');
  }

  // diubah: logika disederhanakan untuk HANYA mengunggah SEMUA field data berdasarkan timestamp.
  // fungsi generik untuk mengunggah data dari satu tabel.
  Future<void> _unggahDataGenerik<T>(
    String namaTabel,
    String namaKoleksi,
    T Function(Map<String, dynamic>) fromMap,
    Map<String, dynamic> Function(T) toMap,
    DateTime waktuSinkronisasiTerakhir,
  ) async {
    try {
      final db = await _dbHelper.database;

      // 1. Ambil semua data yang diperbarui (dibuat atau diubah) setelah sinkronisasi terakhir.
      final List<Map<String, dynamic>> dataUntukDiunggah = await db.query(
        namaTabel,
        where: 'diperbarui > ?',
        whereArgs: [waktuSinkronisasiTerakhir.toIso8601String()],
      );

      if (dataUntukDiunggah.isEmpty) {
        // Tidak ada data baru atau yang diperbarui untuk diunggah.
        return;
      }

      final batchFirestore = _firestore.batch();
      int itemsToCommit = 0;

      // 2. Proses semua data sebagai operasi 'set' (upsert) dan unggah semua field.
      for (final map in dataUntukDiunggah) {
        final T data = fromMap(map);
        final model = data as dynamic; // Untuk akses 'id'
        final dataUnggah = toMap(
          data,
        ); // Konversi ke map, SEMUA field akan masuk.

        final docRef = _firestore.collection(namaKoleksi).doc(model.id);

        // Gunakan set dengan merge:true untuk create/update (upsert).
        // Ini akan membuat dokumen jika belum ada, atau memperbaruinya jika sudah ada.
        batchFirestore.set(docRef, dataUnggah, SetOptions(merge: true));
        itemsToCommit++;
      }

      if (itemsToCommit > 0) {
        await batchFirestore.commit();
        developer.log(
          'Batch unggah berhasil untuk tabel: $namaTabel ($itemsToCommit item)',
          name: 'UnggahDataService',
        );
      }
    } catch (e, s) {
      developer.log(
        'Gagal mengunggah data untuk tabel: $namaTabel',
        name: 'UnggahDataService.Error',
        error: e,
        stackTrace: s,
      );
    }
  }
}
