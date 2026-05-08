// path: lib/data/sync/unggah_data.dart
// diubah: Mengganti pemanggilan .toFirestore() menjadi .toFirebase() untuk DompetModel.

import 'dart:developer' as developer;
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:admin_wifi/model/kritik_saran_model.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:admin_wifi/model/pengaturan_model.dart';
import 'package:admin_wifi/model/pesanan_model.dart';
import 'package:admin_wifi/model/riwayat_langganan_model.dart';
import 'package:admin_wifi/model/sub_kategori_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LayananUnggahData {
  final DatabaseHelper _dbHelper;
  final FirebaseFirestore _firestore;
  final SyncManager _syncManager;

  LayananUnggahData({
    DatabaseHelper? dbHelper,
    FirebaseFirestore? firestore,
    SyncManager? syncManager,
  }) : _dbHelper = dbHelper ?? DatabaseHelper.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _syncManager = syncManager ?? SyncManager();

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
        (m) => m.toFirebase(), // diperbaiki
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<KategoriModel>(
        'kategori',
        'kategori',
        KategoriModel.fromMap,
        (m) => m.toMapForFirebase(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<KritikSaranModel>(
        'kritik_saran',
        'kritik_saran',
        KritikSaranModel.fromMap,
        (m) => m.toMapForFirebase(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<PaketModel>(
        'paket',
        'paket',
        PaketModel.fromMap,
        (m) => m.toMapForFirebase(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<PelangganAktifModel>(
        'pelanggan_aktif',
        'pelanggan_aktif',
        PelangganAktifModel.fromMap,
        (m) => m.toMapForFirebase(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<PelangganModel>(
        'pelanggan',
        'pelanggan',
        PelangganModel.fromMap,
        (m) => m.toMapForFirebase(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<PesananModel>(
        'pesanan',
        'pesan',
        PesananModel.fromMap,
        (m) => m.toMapForFirebase(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<RiwayatLanggananModel>(
        'riwayat_langganan',
        'riwayat_langganan',
        RiwayatLanggananModel.fromMap,
        (m) => m.toMapForFirebase(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<TransaksiModel>(
        'transaksi',
        'transaksi',
        TransaksiModel.fromMap,
        (m) => m.toMapForFirebase(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<SubKategoriModel>(
        'sub_kategori',
        'sub_kategori',
        SubKategoriModel.fromMap,
        (m) => m.toMapForFirebase(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<VersiApkUserModel>(
        'versi_apk_user',
        'versi_apk_user',
        VersiApkUserModel.fromMap,
        (m) => m.toMapForFirebase(),
        waktuSinkronisasiTerakhir,
      ),
      unggahDataGenerik<PengaturanModel>(
        'pengaturan',
        'pengaturan',
        PengaturanModel.fromMap,
        (m) => m.toMapForFirebase(),
        waktuSinkronisasiTerakhir,
      ),
    ];

    try {
      await Future.wait(daftarUnggah);
      final waktuSelesai = DateTime.now();
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

  Future<void> unggahDataDompet() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<DompetModel>(
      'dompet',
      'dompet',
      DompetModel.fromMap,
      (m) => m.toFirebase(), // diperbaiki
      waktu,
    );
  }

  Future<void> unggahDataKategori() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<KategoriModel>(
      'kategori',
      'kategori',
      KategoriModel.fromMap,
      (m) => m.toMapForFirebase(),
      waktu,
    );
  }

  Future<void> unggahDataKritikSaran() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<KritikSaranModel>(
      'kritik_saran',
      'kritik_saran',
      KritikSaranModel.fromMap,
      (m) => m.toMapForFirebase(),
      waktu,
    );
  }

  Future<void> unggahDataPaket() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<PaketModel>(
      'paket',
      'paket',
      PaketModel.fromMap,
      (m) => m.toMapForFirebase(),
      waktu,
    );
  }

  Future<void> unggahDataPelangganAktif() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<PelangganAktifModel>(
      'pelanggan_aktif',
      'pelanggan_aktif',
      PelangganAktifModel.fromMap,
      (m) => m.toMapForFirebase(),
      waktu,
    );
  }

  Future<void> unggahDataPelanggan() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<PelangganModel>(
      'pelanggan',
      'pelanggan',
      PelangganModel.fromMap,
      (m) => m.toMapForFirebase(),
      waktu,
    );
  }

  Future<void> unggahDataPesanan() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<PesananModel>(
      'pesanan',
      'pesan',
      PesananModel.fromMap,
      (m) => m.toMapForFirebase(),
      waktu,
    );
  }

  Future<void> unggahDataRiwayatLangganan() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<RiwayatLanggananModel>(
      'riwayat_langganan',
      'riwayat_langganan',
      RiwayatLanggananModel.fromMap,
      (m) => m.toMapForFirebase(),
      waktu,
    );
  }

  Future<void> unggahDataTransaksi() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<TransaksiModel>(
      'transaksi',
      'transaksi',
      TransaksiModel.fromMap,
      (m) => m.toMapForFirebase(),
      waktu,
    );
  }

  Future<void> unggahDataSubKategori() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<SubKategoriModel>(
      'sub_kategori',
      'sub_kategori',
      SubKategoriModel.fromMap,
      (m) => m.toMapForFirebase(),
      waktu,
    );
  }

  Future<void> unggahDataPengaturan() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<PengaturanModel>(
      'pengaturan',
      'pengaturan',
      PengaturanModel.fromMap,
      (m) => m.toMapForFirebase(),
      waktu,
    );
  }

  Future<void> unggahDataVersiApkUser() async {
    final waktu = await _syncManager.getLastSyncTimestamp();
    await unggahDataGenerik<VersiApkUserModel>(
      'versi_apk_user',
      'versi_apk_user',
      VersiApkUserModel.fromMap,
      (m) => m.toMapForFirebase(),
      waktu,
    );
  }

  Future<void> unggahDataGenerik<T>(
    String namaTabel,
    String namaKoleksi,
    T Function(Map<String, dynamic>) fromMap,
    Map<String, dynamic> Function(T) toMapForFirebase,
    DateTime waktuSinkronisasiTerakhir,
  ) async {
    try {
      final db = await _dbHelper.database;

      List<Map<String, dynamic>> dataUntukDiunggah;
      if (namaTabel == 'pengaturan') {
        dataUntukDiunggah = await db.query(namaTabel);
      } else {
        dataUntukDiunggah = await db.query(
          namaTabel,
          where: 'diperbarui > ?',
          whereArgs: [waktuSinkronisasiTerakhir.toIso8601String()],
        );
      }

      if (dataUntukDiunggah.isEmpty) {
        return;
      }

      final batchFirestore = _firestore.batch();
      int itemsToCommit = 0;

      for (final map in dataUntukDiunggah) {
        final T data = fromMap(map);
        final model = data as dynamic;

        String idDokumen;
        if (namaTabel == 'pengaturan') {
          idDokumen = 'konfigurasi_global';
        } else {
          idDokumen = model.id;
        }

        final dataUnggah = toMapForFirebase(data);
        final docRef = _firestore.collection(namaKoleksi).doc(idDokumen);
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
      rethrow;
    }
  }
}
