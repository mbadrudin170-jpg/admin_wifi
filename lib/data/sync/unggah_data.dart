// path: lib/data/sync/unggah_data.dart

import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:admin_wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:admin_wifi/fitur/kritik_saran/model/kritik_saran_model.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/fitur/pengaturan/model/pengaturan_model.dart';
import 'package:admin_wifi/fitur/pesanan/model/pesanan_model.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/fitur/versi_apk_user/model/versi_apk_user_model.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_global_saya/src/utils/l.dart';

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
    } catch (e, s) {
      L.e('Gagal mengunggah semua data ke Firestore. Error: $e $s');
      rethrow;
    }
  }

  Future<void> unggahDataDompet() async {
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i('waktuSinkronisasiDompet=${waktu.toIso8601String()}');
      await unggahDataGenerik<DompetModel>(
        'dompet',
        'dompet',
        DompetModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
    } catch (e, s) {
      L.e('Gagal mengunggah data dompet. Error: $e $s');
      rethrow;
    }
  }

  Future<void> unggahDataKategori() async {
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i('waktuSinkronisasiKategori=${waktu.toIso8601String()}');
      await unggahDataGenerik<KategoriModel>(
        'kategori',
        'kategori',
        KategoriModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
    } catch (e, s) {
      L.e('Gagal mengunggah data kategori. Error: $e $s');
      rethrow;
    }
  }

  Future<void> unggahDataKritikSaran() async {
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i('waktuSinkronisasiKritikSaran=${waktu.toIso8601String()}');
      await unggahDataGenerik<KritikSaranModel>(
        'kritik_saran',
        'kritik_saran',
        KritikSaranModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
    } catch (e, s) {
      L.e('Gagal mengunggah data kritik_saran. Error: $e $s');
      rethrow;
    }
  }

  Future<void> unggahDataPaket() async {
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i('waktuSinkronisasiPaket=${waktu.toIso8601String()}');
      await unggahDataGenerik<PaketModel>(
        'paket',
        'paket',
        PaketModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
    } catch (e, s) {
      L.e('Gagal mengunggah data paket. Error: $e $s');
      rethrow;
    }
  }

  Future<void> unggahDataPelangganAktif() async {
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i('waktuSinkronisasiPelangganAktif=${waktu.toIso8601String()}');
      await unggahDataGenerik<PelangganAktifModel>(
        'pelanggan_aktif',
        'pelanggan_aktif',
        PelangganAktifModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
    } catch (e, s) {
      L.e('Gagal mengunggah data pelanggan_aktif. Error: $e $s');
      rethrow;
    }
  }

  Future<void> unggahDataPelanggan() async {
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i('waktuSinkronisasiPelanggan=${waktu.toIso8601String()}');
      await unggahDataGenerik<PelangganModel>(
        'pelanggan',
        'pelanggan',
        PelangganModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
    } catch (e, s) {
      L.e('Gagal mengunggah data pelanggan. Error: $e $s');
      rethrow;
    }
  }

  Future<void> unggahDataPesanan() async {
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i('waktuSinkronisasiPesanan=${waktu.toIso8601String()}');
      await unggahDataGenerik<PesananModel>(
        'pesanan',
        'pesan',
        PesananModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
    } catch (e, s) {
      L.e('Gagal mengunggah data pesanan. Error: $e $s');
      rethrow;
    }
  }

  Future<void> unggahDataTransaksi() async {
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i('waktuSinkronisasiTransaksi=${waktu.toIso8601String()}');
      await unggahDataGenerik<TransaksiModel>(
        'transaksi',
        'transaksi',
        TransaksiModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
    } catch (e, s) {
      L.e('Gagal mengunggah data transaksi. Error: $e $s');
      rethrow;
    }
  }

  Future<void> unggahDataSubKategori() async {
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i('waktuSinkronisasiSubKategori=${waktu.toIso8601String()}');
      await unggahDataGenerik<SubKategoriModel>(
        'sub_kategori',
        'sub_kategori',
        SubKategoriModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
    } catch (e, s) {
      L.e('Gagal mengunggah data sub_kategori. Error: $e $s');
      rethrow;
    }
  }

  Future<void> unggahDataPengaturan() async {
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i('waktuSinkronisasiPengaturan=${waktu.toIso8601String()}');
      await unggahDataGenerik<PengaturanModel>(
        'pengaturan',
        'pengaturan',
        PengaturanModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
    } catch (e, s) {
      L.e('Gagal mengunggah data pengaturan. Error: $e $s');
      rethrow;
    }
  }

  Future<void> unggahDataVersiApkUser() async {
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i('waktuSinkronisasiVersiApkUser=${waktu.toIso8601String()}');
      await unggahDataGenerik<VersiApkUserModel>(
        'versi_apk_user',
        'versi_apk_user',
        VersiApkUserModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
    } catch (e, s) {
      L.e('Gagal mengunggah data versi_apk_user. Error: $e $s');
      rethrow;
    }
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
        return;
      }

      final batchFirestore = _firestore.batch();

      int counterSukses = 0;
      int counterError = 0;

      for (int i = 0; i < dataUntukDiunggah.length; i++) {
        final map = dataUntukDiunggah[i];

        try {
          final T data = fromSqlite(map);
          final model = data as dynamic;

          final docRef = _firestore.collection(namaKoleksi).doc(model.id);

          final firebaseData = toFirebase(data);

          batchFirestore.set(docRef, firebaseData, SetOptions(merge: true));

          counterSukses++;
        } catch (e) {
          counterError++;
          L.w(
            'Gagal memproses data ke-${i + 1} tabel $namaTabel. Error: $e. Data: $map',
          );
        }
      }

      L.i(
        'unggahDataGenerik $namaTabel: total=${dataUntukDiunggah.length}, sukses=$counterSukses, gagal=$counterError',
      );

      if (counterSukses > 0) {
        await batchFirestore.commit();
      }
    } catch (e, s) {
      L.e(
        'Gagal mengunggah data $namaTabel ke koleksi $namaKoleksi. Error: $e $s',
      );
      rethrow;
    }
  }
}
