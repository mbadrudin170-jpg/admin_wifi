// path: lib/data/sync/unduh_data.dart

import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/kritik_saran_operasi.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/pengaturan_operasi.dart';
import 'package:admin_wifi/data/operasi/pesanan_operasi.dart';
import 'package:admin_wifi/data/operasi/sub_kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:admin_wifi/fitur/kritik_saran/model/kritik_saran_model.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/fitur/pengaturan/model/pengaturan_model.dart';
import 'package:admin_wifi/fitur/pesanan/model/pesanan_model.dart';
import 'package:admin_wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/versi_apk_user/model/versi_apk_user_model.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_global_saya/src/utils/l.dart';

class LayananUnduhData {
  final FirebaseFirestore _firestore;
  final SyncManager _syncManager;

  // Operasi
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

  LayananUnduhData({FirebaseFirestore? firestore, SyncManager? syncManager})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _syncManager = syncManager ?? SyncManager() {
    L.i(
      'LayananUnduhData berhasil diinisialisasi. Seluruh operasi database lokal dan referensi FirebaseFirestore telah siap digunakan untuk sinkronisasi masuk.',
    );
  }

  Future<void> unduhSemuaData() async {
    L.i(
      'Memulai prosedur orkestrasi unduh data massal. Sistem akan menjalankan permintaan paralel untuk 11 kategori data berbeda guna mempercepat proses sinkronisasi.',
    );
    final stopwatch = Stopwatch()..start();

    try {
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

      stopwatch.stop();
      L.i(
        'Prosedur unduh data massal selesai sepenuhnya. Total durasi eksekusi: ${stopwatch.elapsed.inMilliseconds} ms. Seluruh data lokal kini sinkron dengan server.',
      );
    } catch (e, s) {
      L.e(
        'Kegagalan kritis terdeteksi selama prosedur unduh massal. Salah satu atau lebih permintaan paralel gagal diselesaikan. Error: $e $s',
      );
      rethrow;
    }
  }

  Future<void> unduhDataPengaturan() async {
    L.i('Memulai pengecekan sinkronisasi untuk koleksi: [PENGATURAN]');
    try {
      final waktuUnduhTerakhir = await _syncManager.getTerakhirUnduh();
      L.i('Timestamp sinkronisasi lokal terakhir: $waktuUnduhTerakhir');

      final docRef = _firestore.collection('pengaturan').doc('default');
      final doc = await docRef.get(const GetOptions(source: Source.server));

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('diperbarui')) {
          final dynamic fieldValue = data['diperbarui'];
          L.i(
            'Mendapatkan metadata "diperbarui" dari server. Tipe data terdeteksi: ${fieldValue.runtimeType}',
          );

          if (fieldValue is! Timestamp) {
            L.e(
              'Inkompatibilitas Tipe Data: Field "diperbarui" di Firestore adalah ${fieldValue.runtimeType}, namun sistem mengharapkan Timestamp. Sinkronisasi dibatalkan untuk mencegah crash.',
            );
            return;
          }

          final waktuPembaruanServer = (fieldValue).toDate();
          L.i('Waktu modifikasi server: $waktuPembaruanServer');

          if (waktuPembaruanServer.isAfter(waktuUnduhTerakhir)) {
            L.i(
              'Data server lebih baru. Memulai pembaruan database SQLite untuk model PengaturanModel.',
            );
            final pengaturan = PengaturanModel.fromFirebase(data);
            await _pengaturanOperasi.simpanAtauPerbaruiPengaturan(pengaturan);
            L.i('Update Pengaturan lokal berhasil disimpan.');
          } else {
            L.i(
              'Data pengaturan lokal sudah sesuai dengan versi server terbaru.',
            );
          }
        } else {
          L.w(
            'Dokumen pengaturan ditemukan, namun tidak memiliki field "diperbarui". Melewati pengecekan waktu.',
          );
        }
      } else {
        L.w(
          'Dokumen "pengaturan/default" tidak ditemukan di server Firestore.',
        );
      }
    } catch (e, s) {
      L.e('Terjadi kesalahan saat sinkronisasi data Pengaturan. Error: $e $s');
    }
  }

  // Wrapper untuk Koleksi Lainnya
  Future<void> unduhDataDompet() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<DompetModel>(
      namaKoleksi: 'dompet',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => DompetModel.fromFirebase(id, map),
      operasiBatch: (data) => _dompetOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataKategori() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<KategoriModel>(
      namaKoleksi: 'kategori',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => KategoriModel.fromFirebase(id, map),
      operasiBatch: (data) => _kategoriOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataPaket() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PaketModel>(
      namaKoleksi: 'paket',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => PaketModel.fromFirebase(id, map),
      operasiBatch: (data) => _paketOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataPelanggan() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PelangganModel>(
      namaKoleksi: 'pelanggan',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => PelangganModel.fromFirebase(id, map),
      operasiBatch: (data) => _pelangganOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataPelangganAktif() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PelangganAktifModel>(
      namaKoleksi: 'pelanggan_aktif',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => PelangganAktifModel.fromFirebase(id, map),
      operasiBatch: (data) =>
          _pelangganAktifOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataTransaksi() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<TransaksiModel>(
      namaKoleksi: 'transaksi',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => TransaksiModel.fromFirebase(id, map),
      operasiBatch: (data) => _transaksiOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataKritikSaran() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<KritikSaranModel>(
      namaKoleksi: 'kritik_saran',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => KritikSaranModel.fromFirebase(id, map),
      operasiBatch: (data) =>
          _kritikSaranOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataPesanan() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<PesananModel>(
      namaKoleksi: 'pesan',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => PesananModel.fromFirebase(id, map),
      operasiBatch: (data) => _pesanOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataSubKategori() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<SubKategoriModel>(
      namaKoleksi: 'sub_kategori',
      waktuUnduhTerakhir: waktu,
      fromFirebase: (id, map) => SubKategoriModel.fromFirebase(id, map),
      operasiBatch: (data) =>
          _subKategoriOperasi.sisipkanAtauPerbaruiBatch(data),
    );
  }

  Future<void> unduhDataVersiApkUser() async {
    final waktu = await _syncManager.getTerakhirUnduh();
    await sinkronisasiKoleksi<VersiApkUserModel>(
      namaKoleksi: 'versi_apk_user',
      waktuUnduhTerakhir: waktu,
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
    L.i(
      'Sinkronisasi Koleksi: Memeriksa [$namaKoleksi] untuk data baru sejak $waktuUnduhTerakhir.',
    );
    try {
      final snapshot = await _firestore
          .collection(namaKoleksi)
          .where('diperbarui', isGreaterThan: waktuUnduhTerakhir)
          .get(const GetOptions(source: Source.server));

      if (snapshot.docs.isNotEmpty) {
        L.i(
          'Ditemukan ${snapshot.docs.length} dokumen baru/diperbarui di koleksi [$namaKoleksi]. Memulai parsing data.',
        );

        final List<T> dataList = [];
        for (final doc in snapshot.docs) {
          try {
            final diperbaruiField = doc.data()['diperbarui'];

            // Diagnosis Tipe Data Per Dokumen
            L.i(
              'Analisis Dokumen: ID: ${doc.id} | Tipe Field "diperbarui": ${diperbaruiField?.runtimeType ?? "NULL"}',
            );

            dataList.add(fromFirebase(doc.id, doc.data()));
          } catch (e, s) {
            if (e.toString().contains('_CastError') || e is TypeError) {
              L.e(
                'KESALAHAN KONVERSI: Field "diperbarui" pada dokumen ${doc.id} bukan tipe Timestamp. Mohon jalankan MigrasiTimestamp untuk koleksi ini. Error: Data RAW: ${doc.data()} $s',
              );
            } else {
              L.e(
                'Gagal memproses dokumen individual dengan ID: ${doc.id} Error: $e $s',
              );
            }
          }
        }

        if (dataList.isNotEmpty) {
          L.i(
            'Mengirim ${dataList.length} item valid ke operasi batch database lokal.',
          );
          await operasiBatch(dataList);
          L.i('Sinkronisasi masuk untuk [$namaKoleksi] berhasil diselesaikan.');
        } else {
          L.w(
            'Pengecekan selesai: Tidak ada data valid yang dapat disimpan ke lokal dari [$namaKoleksi].',
          );
        }
      } else {
        L.i(
          'Hasil Pengecekan: Koleksi [$namaKoleksi] sudah sinkron dengan server.',
        );
      }
    } catch (e, s) {
      L.e(
        'Kegagalan pada prosedur sinkronisasi koleksi: $namaKoleksi Error: $e $s',
      );
    }
  }
}
