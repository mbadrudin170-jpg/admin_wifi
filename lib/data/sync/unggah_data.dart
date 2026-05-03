// path: lib/data/sync/unggah_data.dart
// diubah: Menambahkan parameter boolean untuk kontrol timestamp di fungsi generik.
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

class LayananUnggahData {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SyncManager _syncManager = SyncManager();

  // untuk mengunggah semua data yang belum sinkron ke Firebase secara paralel.
  Future<void> unggahSemuaData() async {
    final waktuSinkronisasiTerakhir = await _syncManager.getLastSyncTimestamp();
    developer.log(
      'Memulai unggah massal dengan waktu sinkronisasi terakhir: $waktuSinkronisasiTerakhir',
      name: 'UnggahDataService',
    );

    final List<Future<void>> daftarUnggah = [
      unggahDataGenerik<DompetModel>(
        'dompet',
        'dompet',
        DompetModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<KategoriModel>(
        'kategori',
        'kategori',
        KategoriModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<KritikSaranModel>(
        'kritik_saran',
        'kritik_saran',
        KritikSaranModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<PaketModel>(
        'paket',
        'paket',
        PaketModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<PelangganAktifModel>(
        'pelanggan_aktif',
        'pelanggan_aktif',
        PelangganAktifModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<PelangganModel>(
        'pelanggan',
        'pelanggan',
        PelangganModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<PesananModel>(
        'pesanan',
        'pesan',
        PesananModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<RiwayatLanggananModel>(
        'riwayat_langganan',
        'riwayat_langganan',
        RiwayatLanggananModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<TransaksiModel>(
        'transaksi',
        'transaksi',
        TransaksiModel.fromMap,
        (m) => m.toMap(),
        waktuSinkronisasiTerakhir,
      ),
    ];

    try {
      await Future.wait(daftarUnggah);
      final waktuSelesai = DateTime.now();
      await _syncManager.setLastSyncTimestamp(waktuSelesai);
      developer.log(
        'Unggah massal selesai. Timestamp diperbarui ke: $waktuSelesai',
        name: 'UnggahDataService',
      );
    } catch (e, s) {
      developer.log(
        'Gagal selama unggah massal. Timestamp tidak diperbarui.',
        name: 'UnggahDataService.Error',
        error: e,
        stackTrace: s,
      );
    }
  }

  // --- FUNGSI UNGGAH SPESIFIK ---

  // diubah: Menambahkan perbaruiTimestamp: true
  Future<void> unggahDataDompet() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<DompetModel>(
      'dompet',
      'dompet',
      DompetModel.fromMap,
      (m) => m.toMap(),
      waktu,
      perbaruiTimestamp: true,
    );
  }

  // diubah: Menambahkan perbaruiTimestamp: true
  Future<void> unggahDataKategori() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<KategoriModel>(
      'kategori',
      'kategori',
      KategoriModel.fromMap,
      (m) => m.toMap(),
      waktu,
      perbaruiTimestamp: true,
    );
  }

  // diubah: Menambahkan perbaruiTimestamp: true
  Future<void> unggahDataKritikSaran() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<KritikSaranModel>(
      'kritik_saran',
      'kritik_saran',
      KritikSaranModel.fromMap,
      (m) => m.toMap(),
      waktu,
      perbaruiTimestamp: true,
    );
  }

  // diubah: Menambahkan perbaruiTimestamp: true
  Future<void> unggahDataPaket() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<PaketModel>(
      'paket',
      'paket',
      PaketModel.fromMap,
      (m) => m.toMap(),
      waktu,
      perbaruiTimestamp: true,
    );
  }

  // diubah: Menambahkan perbaruiTimestamp: true
  Future<void> unggahDataPelangganAktif() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<PelangganAktifModel>(
      'pelanggan_aktif',
      'pelanggan_aktif',
      PelangganAktifModel.fromMap,
      (m) => m.toMap(),
      waktu,
      perbaruiTimestamp: true,
    );
  }

  // diubah: Menambahkan perbaruiTimestamp: true
  Future<void> unggahDataPelanggan() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<PelangganModel>(
      'pelanggan',
      'pelanggan',
      PelangganModel.fromMap,
      (m) => m.toMap(),
      waktu,
      perbaruiTimestamp: true,
    );
  }

  // diubah: Menambahkan perbaruiTimestamp: true
  Future<void> unggahDataPesanan() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<PesananModel>(
      'pesanan',
      'pesan',
      PesananModel.fromMap,
      (m) => m.toMap(),
      waktu,
      perbaruiTimestamp: true,
    );
  }

  // diubah: Menambahkan perbaruiTimestamp: true
  Future<void> unggahDataRiwayatLangganan() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<RiwayatLanggananModel>(
      'riwayat_langganan',
      'riwayat_langganan',
      RiwayatLanggananModel.fromMap,
      (m) => m.toMap(),
      waktu,
      perbaruiTimestamp: true,
    );
  }

  // diubah: Menambahkan perbaruiTimestamp: true
  Future<void> unggahDataTransaksi() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<TransaksiModel>(
      'transaksi',
      'transaksi',
      TransaksiModel.fromMap,
      (m) => m.toMap(),
      waktu,
      perbaruiTimestamp: true,
    );
  }

  // diubah: Menambahkan parameter {bool perbaruiTimestamp = false}
  Future<void> unggahDataGenerik<T>(
    String namaTabel,
    String namaKoleksi,
    T Function(Map<String, dynamic>) fromMap,
    Map<String, dynamic> Function(T) toMap,
    DateTime waktuSinkronisasiTerakhir, {
    bool perbaruiTimestamp = false,
  }) async {
    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> dataUntukDiunggah = await db.query(
        namaTabel,
        where: 'diperbarui > ?',
        whereArgs: [waktuSinkronisasiTerakhir.toIso8601String()],
      );

      if (dataUntukDiunggah.isEmpty) {
        return;
      }

      final batchFirestore = _firestore.batch();
      int itemsToCommit = 0;

      for (final map in dataUntukDiunggah) {
        final T data = fromMap(map);
        final model = data as dynamic;
        final dataUnggah = toMap(data);

        final docRef = _firestore.collection(namaKoleksi).doc(model.id);
        batchFirestore.set(docRef, dataUnggah, SetOptions(merge: true));
        itemsToCommit++;
      }

      if (itemsToCommit > 0) {
        await batchFirestore.commit();
        developer.log(
          'Batch unggah berhasil untuk tabel: $namaTabel ($itemsToCommit item)',
          name: 'UnggahDataService',
        );

        // ditambah: Logika untuk memperbarui timestamp jika diminta.
        if (perbaruiTimestamp) {
          final waktuSelesai = DateTime.now();
          await _syncManager.setLastSyncTimestamp(waktuSelesai);
          developer.log(
            'Timestamp diperbarui setelah unggah $namaTabel ke: $waktuSelesai',
            name: 'UnggahDataService',
          );
        }
      }
    } catch (e, s) {
      developer.log(
        'Gagal mengunggah data untuk tabel: $namaTabel',
        name: 'UnggahDataService.Error',
        error: e,
        stackTrace: s,
      );
      // diubah: Menggunakan rethrow untuk mempertahankan stack trace asli.
      rethrow;
    }
  }
}
