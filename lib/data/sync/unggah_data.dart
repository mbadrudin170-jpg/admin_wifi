// path: lib/data/sync/unggah_data.dart
// diubah: file dirombak untuk menjadi lebih efisien dengan pengecekan timestamp
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
import 'package:admin_wifi/model/enum/sync_status.dart';
import 'package:admin_wifi/utils/sync_manager.dart'; // ditambah: untuk mengakses timestamp
import 'package:cloud_firestore/cloud_firestore.dart';

// untuk mengelola proses pengunggahan data dari database lokal ke Firebase.
class UnggahDataService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SyncManager _syncManager =
      SyncManager(); // ditambah: instance sync manager

  // untuk mengunggah semua data yang belum sinkron ke Firebase secara paralel.
  Future<void> unggahSemuaData() async {
    // ditambah: ambil waktu sinkronisasi terakhir dari SyncManager
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

  // diubah: tambah parameter waktuSinkronisasiTerakhir
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
      final List<Map<String, dynamic>> maps = await db.query(
        namaTabel,
        where: 'sync_status != ?',
        whereArgs: [SyncStatus.synced.name],
      );

      if (maps.isEmpty) {
        return;
      }

      final List<T> daftarData = List.generate(
        maps.length,
        (i) => fromMap(maps[i]),
      );
      final batchFirestore = _firestore.batch();
      final batchLokal = db.batch();
      int itemsToCommit = 0;

      for (final data in daftarData) {
        final model = data as dynamic;
        final docRef = _firestore.collection(namaKoleksi).doc(model.id);

        switch (model.syncStatus) {
          case SyncStatus.write:
            final dataUnggah = toMap(data);
            dataUnggah.remove('sync_status');
            batchFirestore.set(docRef, dataUnggah);
            batchLokal.update(
              namaTabel,
              {'sync_status': SyncStatus.synced.name},
              where: 'id = ?',
              whereArgs: [model.id],
            );
            itemsToCommit++;
            break;

          case SyncStatus.update:
            bool harusDiunggah = false;
            try {
              final waktuDiperbarui = model.diperbarui as DateTime?;
              if (waktuDiperbarui != null &&
                  waktuDiperbarui.isAfter(waktuSinkronisasiTerakhir)) {
                harusDiunggah = true;
              }
            } catch (e) {
              harusDiunggah = true;
            }

            if (harusDiunggah) {
              final dataUnggah = toMap(data);
              dataUnggah.remove('sync_status');
              batchFirestore.update(docRef, dataUnggah);
            }

            // diubah: status lokal selalu diubah ke synced untuk efisiensi
            // agar tidak diperiksa berulang kali pada sinkronisasi berikutnya.
            batchLokal.update(
              namaTabel,
              {'sync_status': SyncStatus.synced.name},
              where: 'id = ?',
              whereArgs: [model.id],
            );
            itemsToCommit++;
            break;

          case SyncStatus.deleted:
            batchFirestore.delete(docRef);
            batchLokal.delete(
              namaTabel,
              where: 'id = ?',
              whereArgs: [model.id],
            );
            itemsToCommit++;
            break;

          case SyncStatus.synced:
            break;
        }
      }

      if (itemsToCommit > 0) {
        await batchFirestore.commit();
        await batchLokal.commit(noResult: true);
        developer.log(
          'Batch commit berhasil untuk tabel: $namaTabel',
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
