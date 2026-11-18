// path: lib/data/sync/unggah_data.dart

import 'package:admin_wifi/db/sqflite.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:admin_wifi/model/kritik_saran_model.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:admin_wifi/model/pengaturan_model.dart';
import 'package:admin_wifi/model/pesanan_model.dart';
import 'package:admin_wifi/model/sub_kategori_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
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
       _syncManager = syncManager ?? SyncManager() {
    L.i(
      'LayananUnggahData instance dibuat. '
      'Menggunakan DatabaseHelper: ${_dbHelper.hashCode}, '
      'FirebaseFirestore: ${_firestore.hashCode}, '
      'SyncManager: ${_syncManager.hashCode}',
    );
  }

  Future<void> unggahSemuaData() async {
    L.i('========================================');
    L.i('MEMULAI PROSES UNGGAH SEMUA DATA KE FIREBASE');
    L.i(
      'Proses ini akan mengunggah 11 jenis data (tabel) dari SQLite lokal ke Firestore.',
    );
    L.i('========================================');

    L.i(
      'Menyiapkan daftar Future untuk semua fungsi unggah spesifik. '
      'Semua fungsi akan dijalankan secara paralel menggunakan Future.wait.',
    );

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

    L.i(
      'Total ${daftarUnggah.length} fungsi unggah spesifik telah disiapkan dan siap dieksekusi secara paralel.',
    );

    try {
      L.i(
        'Menjalankan semua fungsi unggah secara paralel menggunakan Future.wait. '
        'Semua proses unggah akan berjalan bersamaan untuk efisiensi waktu.',
      );
      await Future.wait(daftarUnggah);
      L.i('========================================');
      L.i('PROSES UNGGAH SEMUA DATA SELESAI DENGAN SUKSES');
      L.i('Semua 11 jenis data berhasil diunggah ke Firestore tanpa error.');
      L.i('========================================');
    } catch (e, s) {
      L.e(
        'Gagal selama proses unggah massal ke Firestore. '
        'Satu atau lebih fungsi unggah spesifik mengalami kegagalan. '
        'Proses unggah tidak dapat diselesaikan sepenuhnya. '
        'Error ini akan dilempar ulang ke service layer untuk penanganan lebih lanjut. Error: $e $s',
      );
      rethrow;
    }
  }

  // --- FUNGSI UNGGAH SPESIFIK (POLA UJI COBA) ---

  Future<void> unggahDataDompet() async {
    L.i(
      'Memulai proses unggah data dompet. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i(
        'Waktu sinkronisasi terakhir untuk dompet: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<DompetModel>(
        'dompet',
        'dompet',
        DompetModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      L.i('Proses unggah data dompet selesai dengan sukses.');
    } catch (e, s) {
      L.e(
        'Gagal mengunggah data dompet. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore. Error: $e $s',
      );
      rethrow;
    }
  }

  Future<void> unggahDataKategori() async {
    L.i(
      'Memulai proses unggah data kategori. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i(
        'Waktu sinkronisasi terakhir untuk kategori: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<KategoriModel>(
        'kategori',
        'kategori',
        KategoriModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      L.i('Proses unggah data kategori selesai dengan sukses.');
    } catch (e, s) {
      L.e(
        'Gagal mengunggah data kategori. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore. Error: $e $s',
      );
      rethrow;
    }
  }

  Future<void> unggahDataKritikSaran() async {
    L.i(
      'Memulai proses unggah data kritik_saran. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i(
        'Waktu sinkronisasi terakhir untuk kritik_saran: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<KritikSaranModel>(
        'kritik_saran',
        'kritik_saran',
        KritikSaranModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      L.i('Proses unggah data kritik_saran selesai dengan sukses.');
    } catch (e, s) {
      L.e(
        'Gagal mengunggah data kritik_saran. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore. Error: $e $s',
      );
      rethrow;
    }
  }

  Future<void> unggahDataPaket() async {
    L.i(
      'Memulai proses unggah data paket. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i(
        'Waktu sinkronisasi terakhir untuk paket: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<PaketModel>(
        'paket',
        'paket',
        PaketModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      L.i('Proses unggah data paket selesai dengan sukses.');
    } catch (e, s) {
      L.e(
        'Gagal mengunggah data paket. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore. Error: $e $s',
      );
      rethrow;
    }
  }

  Future<void> unggahDataPelangganAktif() async {
    L.i(
      'Memulai proses unggah data pelanggan_aktif. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i(
        'Waktu sinkronisasi terakhir untuk pelanggan_aktif: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<PelangganAktifModel>(
        'pelanggan_aktif',
        'pelanggan_aktif',
        PelangganAktifModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      L.i('Proses unggah data pelanggan_aktif selesai dengan sukses.');
    } catch (e, s) {
      L.e(
        'Gagal mengunggah data pelanggan_aktif. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore. Error: $e $s',
      );
      rethrow;
    }
  }

  Future<void> unggahDataPelanggan() async {
    L.i(
      'Memulai proses unggah data pelanggan. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i(
        'Waktu sinkronisasi terakhir untuk pelanggan: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<PelangganModel>(
        'pelanggan',
        'pelanggan',
        PelangganModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      L.i('Proses unggah data pelanggan selesai dengan sukses.');
    } catch (e, s) {
      L.e(
        'Gagal mengunggah data pelanggan. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore. Error: $e $s',
      );
      rethrow;
    }
  }

  Future<void> unggahDataPesanan() async {
    L.i(
      'Memulai proses unggah data pesanan. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i(
        'Waktu sinkronisasi terakhir untuk pesanan: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<PesananModel>(
        'pesanan',
        'pesan',
        PesananModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      L.i('Proses unggah data pesanan selesai dengan sukses.');
    } catch (e, s) {
      L.e(
        'Gagal mengunggah data pesanan. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore. Error: $e $s',
      );
      rethrow;
    }
  }

  Future<void> unggahDataTransaksi() async {
    L.i(
      'Memulai proses unggah data transaksi. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i(
        'Waktu sinkronisasi terakhir untuk transaksi: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<TransaksiModel>(
        'transaksi',
        'transaksi',
        TransaksiModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      L.i('Proses unggah data transaksi selesai dengan sukses.');
    } catch (e, s) {
      L.e(
        'Gagal mengunggah data transaksi. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore. Error: $e $s',
      );
      rethrow;
    }
  }

  Future<void> unggahDataSubKategori() async {
    L.i(
      'Memulai proses unggah data sub_kategori. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i(
        'Waktu sinkronisasi terakhir untuk sub_kategori: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<SubKategoriModel>(
        'sub_kategori',
        'sub_kategori',
        SubKategoriModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      L.i('Proses unggah data sub_kategori selesai dengan sukses.');
    } catch (e, s) {
      L.e(
        'Gagal mengunggah data sub_kategori. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore. Error: $e $s',
      );
      rethrow;
    }
  }

  Future<void> unggahDataPengaturan() async {
    L.i(
      'Memulai proses unggah data pengaturan. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i(
        'Waktu sinkronisasi terakhir untuk pengaturan: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<PengaturanModel>(
        'pengaturan',
        'pengaturan',
        PengaturanModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      L.i('Proses unggah data pengaturan selesai dengan sukses.');
    } catch (e, s) {
      L.e(
        'Gagal mengunggah data pengaturan. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore. Error: $e $s',
      );
      rethrow;
    }
  }

  Future<void> unggahDataVersiApkUser() async {
    L.i(
      'Memulai proses unggah data versi_apk_user. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      L.i(
        'Waktu sinkronisasi terakhir untuk versi_apk_user: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<VersiApkUserModel>(
        'versi_apk_user',
        'versi_apk_user',
        VersiApkUserModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      L.i('Proses unggah data versi_apk_user selesai dengan sukses.');
    } catch (e, s) {
      L.e(
        'Gagal mengunggah data versi_apk_user. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore. Error: $e $s',
      );
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
    L.i('========================================');
    L.i('MEMULAI UNGGAH DATA GENERIK');
    L.i('Tabel SQLite sumber: $namaTabel');
    L.i('Koleksi Firestore tujuan: $namaKoleksi');
    L.i(
      'Waktu sinkronisasi terakhir: ${waktuSinkronisasiTerakhir.toIso8601String()}',
    );
    L.i('Tipe data generik: $T');
    L.i('========================================');

    try {
      L.i('Mendapatkan instance database SQLite dari DatabaseHelper.');
      final db = await _dbHelper.database;
      L.i('Instance database berhasil didapatkan.');

      L.i(
        'Melakukan query pada tabel $namaTabel dengan kondisi: '
        'diperbarui > ${waktuSinkronisasiTerakhir.toIso8601String()}. '
        'Hanya data yang diupdate setelah waktu sinkronisasi terakhir yang akan diambil.',
      );

      final dataUntukDiunggah = await db.query(
        namaTabel,
        where: 'diperbarui > ?',
        whereArgs: [waktuSinkronisasiTerakhir.toIso8601String()],
      );

      L.i(
        'Query selesai. Jumlah data yang ditemukan untuk diunggah: ${dataUntukDiunggah.length} baris dari tabel $namaTabel.',
      );

      if (dataUntukDiunggah.isEmpty) {
        L.i(
          'Tabel $namaTabel sudah sinkron dengan Firestore. '
          'Tidak ada data baru atau yang diperbarui sejak ${waktuSinkronisasiTerakhir.toIso8601String()}. '
          'Proses unggah untuk tabel ini dilewati.',
        );
        return;
      }

      L.i(
        'Terdapat ${dataUntukDiunggah.length} data yang perlu diunggah dari tabel $namaTabel. '
        'Membuat Firestore batch operation untuk mengunggah data secara atomik.',
      );

      final batchFirestore = _firestore.batch();
      L.i('Firestore batch berhasil dibuat.');

      int counterSukses = 0;
      int counterError = 0;

      for (int i = 0; i < dataUntukDiunggah.length; i++) {
        final map = dataUntukDiunggah[i];
        L.i(
          'Memproses data ke-${i + 1}/${dataUntukDiunggah.length} dari tabel $namaTabel.',
        );

        try {
          L.i(
            'Mengkonversi data SQLite menjadi model $T menggunakan fungsi fromSqlite.',
          );
          final T data = fromSqlite(map);
          final model = data as dynamic;
          L.i(
            'Konversi berhasil. ID data: ${model.id}. '
            'Membuat referensi dokumen Firestore pada koleksi $namaKoleksi dengan ID ${model.id}.',
          );

          L.i('Membuat referensi dokumen Firestore: $namaKoleksi/${model.id}.');
          final docRef = _firestore.collection(namaKoleksi).doc(model.id);

          L.i(
            'Mengkonversi model menjadi Map<String, dynamic> menggunakan fungsi toFirebase.',
          );
          final firebaseData = toFirebase(data);
          L.i(
            'Konversi ke format Firestore berhasil. '
            'Jumlah field yang akan diunggah: ${firebaseData.length}.',
          );

          L.i(
            'Menambahkan operasi set dengan merge:true ke batch Firestore untuk dokumen $namaKoleksi/${model.id}. '
            'Merge:true akan menggabungkan data baru dengan data yang sudah ada tanpa menghapus field lain.',
          );
          batchFirestore.set(docRef, firebaseData, SetOptions(merge: true));

          counterSukses++;
          L.i(
            'Data ke-${i + 1} (ID: ${model.id}) berhasil ditambahkan ke batch Firestore.',
          );
        } catch (e) {
          counterError++;
          L.w(
            'Gagal memproses data ke-${i + 1} dari tabel $namaTabel. '
            'Data ini akan dilewati dan tidak dimasukkan ke batch. '
            'Error: $e. '
            'Data SQLite: $map',
          );
        }
      }

      L.i(
        'Semua data selesai diproses. '
        'Total: ${dataUntukDiunggah.length} data, '
        'Sukses ditambahkan ke batch: $counterSukses, '
        'Gagal: $counterError.',
      );

      if (counterSukses > 0) {
        L.i(
          'Melakukan commit batch Firestore. '
          'Mengirim $counterSukses dokumen ke koleksi $namaKoleksi secara atomik.',
        );
        await batchFirestore.commit();
        L.i(
          'Batch commit berhasil. '
          '$counterSukses dokumen dari tabel $namaTabel berhasil diunggah ke Firestore koleksi $namaKoleksi.',
        );
      } else {
        L.w(
          'Tidak ada data yang berhasil diproses untuk tabel $namaTabel. '
          'Batch commit tidak dilakukan karena tidak ada data valid untuk diunggah.',
        );
      }

      L.i('========================================');
      L.i('PROSES UNGGAH DATA GENERIK SELESAI');
      L.i('Tabel: $namaTabel -> Koleksi: $namaKoleksi');
      L.i('Total data diunggah: $counterSukses dokumen');
      L.i('========================================');
    } catch (e, s) {
      L.e(
        'Gagal mengunggah data untuk tabel $namaTabel ke koleksi Firestore $namaKoleksi. '
        'Proses unggah data generik mengalami kegagalan. '
        'Kemungkinan penyebab: koneksi database SQLite terputus, '
        'koneksi Firestore gagal, data corrupt, atau format data tidak sesuai. '
        'Error ini akan dilempar ulang ke fungsi pemanggil. Error: $e $s',
      );
      rethrow;
    }
  }
}
