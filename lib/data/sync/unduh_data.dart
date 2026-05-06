// path: lib/data/sync/unduh_data.dart

import 'dart:developer' as developer;

import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/kritik_saran_operasi.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/pesanan_operasi.dart';
// ditambahkan: import untuk model dan operasi pengaturan
import 'package:admin_wifi/data/operasi/pengaturan_operasi.dart';
import 'package:admin_wifi/data/operasi/riwayat_langganan_operasi.dart';
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
import 'package:admin_wifi/model/riwayat_langganan_model.dart';
import 'package:admin_wifi/model/sub_kategori_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LayananUnduhData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  final SubKategoriOperasi _subKategoriOperasi = SubKategoriOperasi();
  final VersiApkUserOperasi _versiApkUserOperasi = VersiApkUserOperasi();
  // ditambahkan: instance untuk operasi pengaturan
  final PengaturanOperasi _pengaturanOperasi = PengaturanOperasi();

  // diubah: Fungsi ini sekarang memanggil fungsi unduh spesifik, termasuk pengaturan.
  Future<void> unduhSemuaData() async {
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
        unduhDataSubKategori(),
        unduhDataVersiApkUser(),
        // ditambahkan: Panggilan untuk mengunduh pengaturan
        unduhDataPengaturan(),
      ]);
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

  // ditambahkan: Fungsi untuk mengunduh data Pengaturan.
  Future<void> unduhDataPengaturan() async {
    try {
      final doc = await _firestore
          .collection('pengaturan')
          .doc('default')
          .get();
      if (doc.exists && doc.data() != null) {
        final pengaturan = PengaturanModel.fromMap(doc.data()!);
        await _pengaturanOperasi.simpanAtauPerbaruiPengaturan(pengaturan);
      }
    } catch (e, s) {
      developer.log(
        'Gagal unduh data pengaturan',
        name: 'LayananUnduhData.Pengaturan',
        error: e,
        stackTrace: s,
      );
      // Tidak melempar rethrow agar proses sinkronisasi lain bisa lanjut
    }
  }

  Future<void> unduhDataDompet() async {
    await sinkronisasiKoleksi<DompetModel>(
      namaKoleksi: 'dompet',
      fromMap: (map) => DompetModel.fromMap(map),
      operasiBatch: (data) => _dompetOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataKategori() async {
    await sinkronisasiKoleksi<KategoriModel>(
      namaKoleksi: 'kategori',
      fromMap: (map) => KategoriModel.fromMap(map),
      operasiBatch: (data) => _kategoriOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataPaket() async {
    await sinkronisasiKoleksi<PaketModel>(
      namaKoleksi: 'paket',
      fromMap: (map) => PaketModel.fromMap(map),
      operasiBatch: (data) => _paketOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataPelanggan() async {
    await sinkronisasiKoleksi<PelangganModel>(
      namaKoleksi: 'pelanggan',
      fromMap: (map) => PelangganModel.fromMap(map),
      operasiBatch: (data) => _pelangganOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataPelangganAktif() async {
    await sinkronisasiKoleksi<PelangganAktifModel>(
      namaKoleksi: 'pelanggan_aktif',
      fromMap: (map) => PelangganAktifModel.fromMap(map),
      operasiBatch: (data) =>
          _pelangganAktifOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataTransaksi() async {
    await sinkronisasiKoleksi<TransaksiModel>(
      namaKoleksi: 'transaksi',
      fromMap: (map) => TransaksiModel.fromMap(map),
      operasiBatch: (data) => _transaksiOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataRiwayatLangganan() async {
    await sinkronisasiKoleksi<RiwayatLanggananModel>(
      namaKoleksi: 'riwayat_langganan',
      fromMap: (map) => RiwayatLanggananModel.fromMap(map),
      operasiBatch: (data) =>
          _riwayatLanggananOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataKritikSaran() async {
    await sinkronisasiKoleksi<KritikSaranModel>(
      namaKoleksi: 'kritik_saran',
      fromMap: (map) => KritikSaranModel.fromMap(map),
      operasiBatch: (data) =>
          _kritikSaranOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataPesanan() async {
    await sinkronisasiKoleksi<PesananModel>(
      namaKoleksi: 'pesan',
      fromMap: (map) => PesananModel.fromMap(map),
      operasiBatch: (data) => _pesanOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataSubKategori() async {
    await sinkronisasiKoleksi<SubKategoriModel>(
      namaKoleksi: 'sub_kategori',
      fromMap: (map) => SubKategoriModel.fromMap(map),
      operasiBatch: (data) =>
          _subKategoriOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataVersiApkUser() async {
    await sinkronisasiKoleksi<VersiApkUserModel>(
      namaKoleksi: 'versi_apk_user',
      fromMap: (map) => VersiApkUserModel.fromMap(map),
      operasiBatch: (data) =>
          _versiApkUserOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  // --- FUNGSI GENERIK (PUBLIK) ---

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
