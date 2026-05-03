// path: lib/data/sync/unduh_data.dart
// diubah: Menambahkan fungsi unduh spesifik untuk setiap tabel dan membuat fungsi generik menjadi publik.
import 'dart:developer' as developer;

import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/kritik_saran_operasi.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/pesan_operasi.dart';
import 'package:admin_wifi/data/operasi/riwayat_langganan_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
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

class LayananUnduhData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SyncManager _syncManager = SyncManager();

  final DompetOperasi _dompetOperasi = DompetOperasi();
  final KategoriOperasi _kategoriOperasi = KategoriOperasi();
  final PaketOperasi _paketOperasi = PaketOperasi();
  final PelangganOperasi _pelangganOperasi = PelangganOperasi();
  final PelangganAktifOperasi _pelangganAktifOperasi = PelangganAktifOperasi();
  final TransaksiOperasi _transaksiOperasi = TransaksiOperasi();
  final RiwayatLanggananOperasi _riwayatLanggananOperasi =
      RiwayatLanggananOperasi();
  final KritikSaranOperasi _kritikSaranOperasi = KritikSaranOperasi();
  final PesananOperasi _pesanOperasi = PesananOperasi();

  // diubah: Fungsi ini sekarang memanggil fungsi unduh spesifik.
  Future<void> sinkronisasiAwal() async {
    try {
      await Future.wait([
        unduhDataDompet(),
        unduhDataKategori(),
        unduhDataPaket(),
        unduhDataPelanggan(),
        unduhDataPelangganAktif(),
        unduhDataTransaksi(),
        unduhDataRiwayatLangganan(),
        unduhDataKritikSaran(),
        unduhDataPesanan(),
      ]);

      await _syncManager.setLastSyncTimestamp(DateTime.now());
    } catch (e, s) {
      developer.log(
        'Gagal melakukan sinkronisasi awal',
        name: 'LayananUnduhData',
        error: e,
        stackTrace: s,
        level: 1000,
      );
      rethrow;
    }
  }

  // --- FUNGSI UNDUH SPESIFIK (PUBLIK) ---

  // ditambah: Fungsi untuk mengunduh data Dompet.
  Future<void> unduhDataDompet() async {
    await sinkronisasiKoleksi<DompetModel>(
      namaKoleksi: 'dompet',
      fromMap: (map) => DompetModel.fromMap(map),
      operasiBatch: (data) => _dompetOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // ditambah: Fungsi untuk mengunduh data Kategori.
  Future<void> unduhDataKategori() async {
    await sinkronisasiKoleksi<KategoriModel>(
      namaKoleksi: 'kategori',
      fromMap: (map) => KategoriModel.fromMap(map),
      operasiBatch: (data) => _kategoriOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // ditambah: Fungsi untuk mengunduh data Paket.
  Future<void> unduhDataPaket() async {
    await sinkronisasiKoleksi<PaketModel>(
      namaKoleksi: 'paket',
      fromMap: (map) => PaketModel.fromMap(map),
      operasiBatch: (data) => _paketOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // ditambah: Fungsi untuk mengunduh data Pelanggan.
  Future<void> unduhDataPelanggan() async {
    await sinkronisasiKoleksi<PelangganModel>(
      namaKoleksi: 'pelanggan',
      fromMap: (map) => PelangganModel.fromMap(map),
      operasiBatch: (data) => _pelangganOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // ditambah: Fungsi untuk mengunduh data Pelanggan Aktif.
  Future<void> unduhDataPelangganAktif() async {
    await sinkronisasiKoleksi<PelangganAktifModel>(
      namaKoleksi: 'pelanggan_aktif',
      fromMap: (map) => PelangganAktifModel.fromMap(map),
      operasiBatch: (data) =>
          _pelangganAktifOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // ditambah: Fungsi untuk mengunduh data Transaksi.
  Future<void> unduhDataTransaksi() async {
    await sinkronisasiKoleksi<TransaksiModel>(
      namaKoleksi: 'transaksi',
      fromMap: (map) => TransaksiModel.fromMap(map),
      operasiBatch: (data) => _transaksiOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // ditambah: Fungsi untuk mengunduh data Riwayat Langganan.
  Future<void> unduhDataRiwayatLangganan() async {
    await sinkronisasiKoleksi<RiwayatLanggananModel>(
      namaKoleksi: 'riwayat_langganan',
      fromMap: (map) => RiwayatLanggananModel.fromMap(map),
      operasiBatch: (data) =>
          _riwayatLanggananOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // ditambah: Fungsi untuk mengunduh data Kritik & Saran.
  Future<void> unduhDataKritikSaran() async {
    await sinkronisasiKoleksi<KritikSaranModel>(
      namaKoleksi: 'kritik_saran',
      fromMap: (map) => KritikSaranModel.fromMap(map),
      operasiBatch: (data) =>
          _kritikSaranOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // ditambah: Fungsi untuk mengunduh data Pesanan.
  Future<void> unduhDataPesanan() async {
    await sinkronisasiKoleksi<PesananModel>(
      namaKoleksi: 'pesan',
      fromMap: (map) => PesananModel.fromMap(map),
      operasiBatch: (data) => _pesanOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // --- FUNGSI GENERIK (SEKARANG PUBLIK) ---

  // diubah: Fungsi ini sekarang publik (tanpa '_') untuk fleksibilitas.
  Future<void> sinkronisasiKoleksi<T>({
    required String namaKoleksi,
    required T Function(Map<String, dynamic>) fromMap,
    required Future<void> Function(List<T>) operasiBatch,
  }) async {
    final snapshot = await _firestore.collection(namaKoleksi).get();
    if (snapshot.docs.isNotEmpty) {
      final dataList = snapshot.docs.map((doc) => fromMap(doc.data())).toList();
      await operasiBatch(dataList);
    }
  }
}
