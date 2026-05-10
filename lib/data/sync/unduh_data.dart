// path: lib/data/sync/unduh_data.dart

import 'dart:developer' as developer;

import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/kritik_saran_operasi.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/pesanan_operasi.dart';
import 'package:admin_wifi/data/operasi/pengaturan_operasi.dart';
import 'package:admin_wifi/data/operasi/sub_kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:admin_wifi/model/kritik_saran_model.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:admin_wifi/model/pesanan_model.dart';
import 'package:admin_wifi/model/pengaturan_model.dart';
import 'package:admin_wifi/model/sub_kategori_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LayananUnduhData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SyncManager _syncManager = SyncManager();

  final DompetOperasi _dompetOperasi = DompetOperasi();
  final KategoriOperasi _kategoriOperasi = KategoriOperasi();
  final PaketOperasi _paketOperasi = PaketOperasi();
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();
  final PelangganAktifOperasi _pelangganAktifOperasi = PelangganAktifOperasi();
  final TransaksiOperasi _transaksiOperasi = TransaksiOperasi();
  final KritikSaranOperasi _kritikSaranOperasi = KritikSaranOperasi();
  final PesananOperasi _pesanOperasi = PesananOperasi();
  final SubKategoriOperasi _subKategoriOperasi = SubKategoriOperasi();
  final VersiApkUserOperasi _versiApkUserOperasi = VersiApkUserOperasi();
  final PengaturanOperasi _pengaturanOperasi = PengaturanOperasi();

  Future<void> unduhSemuaData() async {
    developer.log(
      '🚀 Memulai unduh data inkremental dari Firebase...',
      name: 'SYNC.IncrementalDownload',
    );
    final stopwatch = Stopwatch()..start();

    try {
      // diubah: Memanggil fungsi unduh spesifik tanpa parameter.
      await Future.wait([
        unduhDataPengaturan(),
        unduhDataDompet(),
        unduhDataKategori(),
        unduhDataPaket(),
        unduhDataPelanggan(),
        unduhDataPelangganAktif(),
        unduhDataTransaksi(),
        unduhDataKritikSaran(),
        unduhDataPesanan(),
        unduhDataSubKategori(),
        unduhDataVersiApkUser(),
      ]);

      // dihapus: baris ini sudah ada di PengecekanWaktuSyncService

      stopwatch.stop();
      developer.log(
        '✅ Unduh inkremental selesai dalam ${stopwatch.elapsed.inSeconds} detik',
        name: 'SYNC.IncrementalDownload',
      );
    } catch (e, s) {
      developer.log(
        '❌ Gagal melakukan unduh inkremental',
        name: 'SYNC.IncrementalDownload',
        error: e,
        stackTrace: s,
        level: 1000,
      );
      rethrow;
    }
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unduhDataPengaturan() async {
    final waktuUnduhTerakhir = await _syncManager.getTerakhirUnduh();
    try {
      developer.log('📡 Mengunduh: Pengaturan', name: 'SYNC.Pengaturan');
      final docRef = _firestore.collection('pengaturan').doc('default');
      final doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final waktuPembaruanServer = (data['diperbarui'] as Timestamp).toDate();

        if (waktuPembaruanServer.isAfter(waktuUnduhTerakhir)) {
          final pengaturan = PengaturanModel.fromFirebase(data);
          await _pengaturanOperasi.simpanAtauPerbaruiPengaturan(pengaturan);
          developer.log(
            '✅ Pengaturan default berhasil diperbarui karena lebih baru.',
            name: 'SYNC.Pengaturan',
          );
        } else {
          developer.log(
            '👍 Pengaturan default sudah sinkron.',
            name: 'SYNC.Pengaturan',
          );
        }
      } else {
        developer.log(
          '⚠️ Dokumen pengaturan tidak ditemukan di Firebase',
          name: 'SYNC.Pengaturan',
        );
      }
    } catch (e, s) {
      developer.log(
        '❌ Gagal unduh data pengaturan',
        name: 'SYNC.Pengaturan',
        error: e,
        stackTrace: s,
      );
    }
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unduhDataDompet() async {
    final waktuUnduhTerakhir = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<DompetModel>(
      namaKoleksi: 'dompet',
      waktuUnduhTerakhir: waktuUnduhTerakhir,
      fromFirebase: (id, map) => DompetModel.fromFirebase(id, map),
      operasiBatch: (data) => _dompetOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unduhDataKategori() async {
    final waktuUnduhTerakhir = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<KategoriModel>(
      namaKoleksi: 'kategori',
      waktuUnduhTerakhir: waktuUnduhTerakhir,
      fromFirebase: (id, map) => KategoriModel.fromFirebase(id, map),
      operasiBatch: (data) => _kategoriOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unduhDataPaket() async {
    final waktuUnduhTerakhir = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PaketModel>(
      namaKoleksi: 'paket',
      waktuUnduhTerakhir: waktuUnduhTerakhir,
      fromFirebase: (id, map) => PaketModel.fromFirebase(id, map),
      operasiBatch: (data) => _paketOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unduhDataPelanggan() async {
    final waktuUnduhTerakhir = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PelangganModel>(
      namaKoleksi: 'pelanggan',
      waktuUnduhTerakhir: waktuUnduhTerakhir,
      fromFirebase: (id, map) => PelangganModel.fromFirebase(id, map),
      operasiBatch: (data) => _pelangganOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unduhDataPelangganAktif() async {
    final waktuUnduhTerakhir = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PelangganAktifModel>(
      namaKoleksi: 'pelanggan_aktif',
      waktuUnduhTerakhir: waktuUnduhTerakhir,
      fromFirebase: (id, map) => PelangganAktifModel.fromFirebase(id, map),
      operasiBatch: (data) =>
          _pelangganAktifOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unduhDataTransaksi() async {
    final waktuUnduhTerakhir = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<TransaksiModel>(
      namaKoleksi: 'transaksi',
      waktuUnduhTerakhir: waktuUnduhTerakhir,
      fromFirebase: (id, map) => TransaksiModel.fromFirebase(id, map),
      operasiBatch: (data) => _transaksiOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unduhDataKritikSaran() async {
    final waktuUnduhTerakhir = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<KritikSaranModel>(
      namaKoleksi: 'kritik_saran',
      waktuUnduhTerakhir: waktuUnduhTerakhir,
      fromFirebase: (id, map) => KritikSaranModel.fromFirebase(id, map),
      operasiBatch: (data) =>
          _kritikSaranOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unduhDataPesanan() async {
    final waktuUnduhTerakhir = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PesananModel>(
      namaKoleksi: 'pesan',
      waktuUnduhTerakhir: waktuUnduhTerakhir,
      fromFirebase: (id, map) => PesananModel.fromFirebase(id, map),
      operasiBatch: (data) => _pesanOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unduhDataSubKategori() async {
    final waktuUnduhTerakhir = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<SubKategoriModel>(
      namaKoleksi: 'sub_kategori',
      waktuUnduhTerakhir: waktuUnduhTerakhir,
      fromFirebase: (id, map) => SubKategoriModel.fromFirebase(id, map),
      operasiBatch: (data) =>
          _subKategoriOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // diubah: Tidak menerima parameter, mengambil waktu sendiri.
  Future<void> unduhDataVersiApkUser() async {
    final waktuUnduhTerakhir = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<VersiApkUserModel>(
      namaKoleksi: 'versi_apk_user',
      waktuUnduhTerakhir: waktuUnduhTerakhir,
      fromFirebase: (id, map) => VersiApkUserModel.fromFirebase(id, map),
      operasiBatch: (data) =>
          _versiApkUserOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> sinkronisasiKoleksi<T>({
    required String namaKoleksi,
    required DateTime waktuUnduhTerakhir,
    required T Function(String id, Map<String, dynamic> data) fromFirebase,
    required Future<void> Function(List<T>) operasiBatch,
  }) async {
    try {
      developer.log(
        '📡 Mengunduh koleksi: [$namaKoleksi]',
        name: 'SYNC.Koleksi',
      );

      final snapshot = await _firestore
          .collection(namaKoleksi)
          .where('diperbarui', isGreaterThan: waktuUnduhTerakhir)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final dataList = snapshot.docs
            .map((doc) => fromFirebase(doc.id, doc.data()))
            .toList();

        developer.log(
          '💾 Menyimpan ${dataList.length} item baru ke database lokal untuk [$namaKoleksi]',
          name: 'SYNC.Koleksi',
        );
        await operasiBatch(dataList);
        developer.log(
          '✅ Koleksi [$namaKoleksi] berhasil disinkronkan.',
          name: 'SYNC.Koleksi',
        );
      } else {
        developer.log(
          '👍 Koleksi [$namaKoleksi] sudah sinkron. Tidak ada data baru.',
          name: 'SYNC.Koleksi',
        );
      }
    } catch (e, s) {
      developer.log(
        '❌ Error sinkronisasi koleksi: $namaKoleksi',
        name: 'SYNC.Koleksi',
        error: e,
        stackTrace: s,
      );
    }
  }
}
