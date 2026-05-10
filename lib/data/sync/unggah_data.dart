// path: lib/data/sync/unggah_data.dart

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
    developer.log('🚀 Memulai unggah data...', name: 'UnggahData');
    // diubah: Memanggil fungsi spesifik tanpa parameter untuk pengujian.
    final List<Future<void>> daftarUnggah = [
      unggahDataDompet(),
      unggahDataKategori(),
      unggahDataKritikSaran(),
      unggahDataPaket(),
      unggahDataPelangganAktif(),
      unggahDataPelanggan(),
      unggahDataPesanan(),
      unggahDataTransaksi(),
      unggahDataSubKategori(),
      unggahDataVersiApkUser(),
      unggahDataPengaturan(),
    ];

    try {
      await Future.wait(daftarUnggah);
      developer.log('✅ Proses unggah selesai.', name: 'UnggahData');
    } catch (e, s) {
      developer.log(
        'Gagal selama proses unggah massal.',
        name: 'UnggahData.Error',
        error: e,
        stackTrace: s,
      );
      rethrow; // Melempar ulang error agar bisa ditangani oleh service layer
    }
  }

  // --- FUNGSI UNGGAH SPESIFIK (POLA UJI COBA) ---

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unggahDataDompet() async {
    final waktu = await _syncManager.getTerakhirUnggah();
    await unggahDataGenerik<DompetModel>(
      'dompet',
      'dompet',
      DompetModel.fromSqlite,
      (m) => m.toFirebase(),
      waktu,
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unggahDataKategori() async {
    final waktu = await _syncManager.getTerakhirUnggah();
    await unggahDataGenerik<KategoriModel>(
      'kategori',
      'kategori',
      KategoriModel.fromSqlite,
      (m) => m.toFirebase(),
      waktu,
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unggahDataKritikSaran() async {
    final waktu = await _syncManager.getTerakhirUnggah();
    await unggahDataGenerik<KritikSaranModel>(
      'kritik_saran',
      'kritik_saran',
      KritikSaranModel.fromSqlite,
      (m) => m.toFirebase(),
      waktu,
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unggahDataPaket() async {
    final waktu = await _syncManager.getTerakhirUnggah();
    await unggahDataGenerik<PaketModel>(
      'paket',
      'paket',
      PaketModel.fromSqlite,
      (m) => m.toFirebase(),
      waktu,
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unggahDataPelangganAktif() async {
    final waktu = await _syncManager.getTerakhirUnggah();
    await unggahDataGenerik<PelangganAktifModel>(
      'pelanggan_aktif',
      'pelanggan_aktif',
      PelangganAktifModel.fromSqlite,
      (m) => m.toFirebase(),
      waktu,
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unggahDataPelanggan() async {
    final waktu = await _syncManager.getTerakhirUnggah();
    await unggahDataGenerik<PelangganModel>(
      'pelanggan',
      'pelanggan',
      PelangganModel.fromSqlite,
      (m) => m.toFirebase(),
      waktu,
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unggahDataPesanan() async {
    final waktu = await _syncManager.getTerakhirUnggah();
    await unggahDataGenerik<PesananModel>(
      'pesanan',
      'pesan',
      PesananModel.fromSqlite,
      (m) => m.toFirebase(),
      waktu,
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unggahDataTransaksi() async {
    final waktu = await _syncManager.getTerakhirUnggah();
    await unggahDataGenerik<TransaksiModel>(
      'transaksi',
      'transaksi',
      TransaksiModel.fromSqlite,
      (m) => m.toFirebase(),
      waktu,
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unggahDataSubKategori() async {
    final waktu = await _syncManager.getTerakhirUnggah();
    await unggahDataGenerik<SubKategoriModel>(
      'sub_kategori',
      'sub_kategori',
      SubKategoriModel.fromSqlite,
      (m) => m.toFirebase(),
      waktu,
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unggahDataPengaturan() async {
    final waktu = await _syncManager.getTerakhirUnggah();
    await unggahDataGenerik<PengaturanModel>(
      'pengaturan',
      'pengaturan',
      PengaturanModel.fromSqlite,
      (m) => m.toFirebase(),
      waktu,
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unggahDataVersiApkUser() async {
    final waktu = await _syncManager.getTerakhirUnggah();
    await unggahDataGenerik<VersiApkUserModel>(
      'versi_apk_user',
      'versi_apk_user',
      VersiApkUserModel.fromSqlite,
      (m) => m.toFirebase(),
      waktu,
    );
  }

  Future<void> unggahDataGenerik<T>(
    String namaTabel,
    String namaKoleksi,
    T Function(Map<String, dynamic>) fromSqlite,
    Map<String, dynamic> Function(T) toFirebase,
    DateTime waktuSinkronisasiTerakhir,
  ) async {
    try {
      final db = await _dbHelper.database;

      final dataUntukDiunggah = await db.query(
        namaTabel,
        where: 'diperbarui > ?',
        whereArgs: [waktuSinkronisasiTerakhir.toIso8601String()],
      );

      if (dataUntukDiunggah.isEmpty) {
        developer.log(
          '👍 Tabel [$namaTabel] sudah sinkron.',
          name: 'UnggahData.Generik',
        );
        return;
      }

      final batchFirestore = _firestore.batch();

      for (final map in dataUntukDiunggah) {
        final T data = fromSqlite(map);
        final model = data as dynamic;

        final docRef = _firestore.collection(namaKoleksi).doc(model.id);
        batchFirestore.set(docRef, toFirebase(data), SetOptions(merge: true));
      }

      await batchFirestore.commit();
      developer.log(
        '✅ Batch unggah berhasil untuk [$namaTabel] (${dataUntukDiunggah.length} item)',
        name: 'UnggahData.Generik',
      );
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
