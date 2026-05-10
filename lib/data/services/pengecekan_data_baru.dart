// path: lib/data/services/pengecekan_data_baru.dart
import 'dart:developer' as developer;

// ditambah: Impor StatusUnggahOperasi yang baru
import 'package:admin_wifi/data/operasi/operasi.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ditambah: fungsi helper untuk konversi camelCase ke snake_case

/// [PengecekanDataBaruService] menyediakan mekanisme untuk memeriksa
/// apakah ada data baru baik di server (Firebase) maupun di lokal (SQLite).
class PengecekanDataBaruService {
  final FirebaseFirestore _firestore;
  final SyncManager _syncManager;
  // dihapus: _dbHelper tidak lagi dibutuhkan di sini setelah refactor
  // final DatabaseHelper _dbHelper;

  // ditambah: Tambahkan dependensi untuk StatusUnggahOperasi
  final StatusUnggahOperasi _statusUnggahOperasi;

  PengecekanDataBaruService({
    FirebaseFirestore? firestore,
    SyncManager? syncManager,
    // dihapus: dbHelper tidak lagi diinject
    // DatabaseHelper? dbHelper,
    // ditambah: Inject StatusUnggahOperasi
    StatusUnggahOperasi? statusUnggahOperasi,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _syncManager = syncManager ?? SyncManager(),
       // _dbHelper = dbHelper ?? DatabaseHelper.instance,
       _statusUnggahOperasi = statusUnggahOperasi ?? StatusUnggahOperasi() {
    // 🚀 Inisialisasi
    developer.log(
      'PengecekanDataBaruService berhasil diinisialisasi dengan FirebaseFirestore, SyncManager, dan StatusUnggahOperasi',
      name: 'PengecekanDataBaruService-Constructor 🚀',
    );
  }

  /// Memeriksa apakah ada data di SQLite yang 'diperbarui' setelah waktu unggah terakhir.
  /// Berguna untuk memutuskan apakah perlu menjalankan proses UNGGAH.
  // diubah: Seluruh logika di dalam fungsi ini diganti dengan satu panggilan
  // ke _statusUnggahOperasi.apakahPerluUnggah() agar lebih efisien.
  Future<bool> apakahSqliteAdaDataBaru() async {
    developer.log(
      'Memulai pengecekan apakah ada data baru di SQLite yang perlu diunggah',
      name: 'PengecekanDataBaruService-apakahSqliteAdaDataBaru ℹ️',
    );

    developer.log(
      'Memeriksa bendera `perlu_unggah`...',
      name: 'PengecekanDataBaru.SQLite',
    );
    // Cukup panggil fungsi dari StatusUnggahOperasi. Jauh lebih cepat!
    final hasil = await _statusUnggahOperasi.getPerluUnggah();

    developer.log(
      'Hasil pengecekan SQLite: ${hasil ? "Ada data baru yang perlu diunggah" : "Tidak ada data baru untuk diunggah"}',
      name:
          'PengecekanDataBaruService-apakahSqliteAdaDataBaru ${hasil ? "✅" : "ℹ️"}',
    );

    return hasil;
  }

  /// Memeriksa apakah 'diperbarui' di dokumen status global Firebase lebih baru dari unduhan terakhir.
  /// Berguna untuk memutuskan apakah perlu menjalankan proses UNDUH.
  Future<bool> apakahFirebaseAdaDataBaru({
    required String namaKoleksi,
    required String idDokumen,
  }) async {
    developer.log(
      'Memulai pengecekan data baru di Firebase untuk koleksi: $namaKoleksi, dokumen: $idDokumen',
      name: 'PengecekanDataBaruService-apakahFirebaseAdaDataBaru ℹ️',
    );

    try {
      developer.log(
        'Mengambil waktu unduh terakhir dari SyncManager',
        name: 'PengecekanDataBaruService-apakahFirebaseAdaDataBaru 🔄',
      );

      final waktuLokal = await _syncManager.getTerakhirUnduh();

      developer.log(
        'Waktu unduh terakhir (lokal): $waktuLokal',
        name: 'PengecekanDataBaruService-apakahFirebaseAdaDataBaru 📝',
      );

      final docRef = _firestore.collection(namaKoleksi).doc(idDokumen);

      developer.log(
        'Mengambil dokumen dari server: $namaKoleksi/$idDokumen',
        name: 'PengecekanDataBaruService-apakahFirebaseAdaDataBaru 🔄',
      );

      final docSnapshot = await docRef.get(
        const GetOptions(source: Source.server),
      );

      if (docSnapshot.exists &&
          docSnapshot.data() != null &&
          docSnapshot.data()!.containsKey('diperbarui')) {
        final waktuServer = (docSnapshot.data()!['diperbarui'] as Timestamp)
            .toDate();

        developer.log(
          'Waktu server (diperbarui): $waktuServer | Waktu lokal: $waktuLokal',
          name: 'PengecekanDataBaruService-apakahFirebaseAdaDataBaru 📝',
        );

        final isAfter = waktuServer.isAfter(waktuLokal);

        developer.log(
          'Hasil perbandingan Firebase: ${isAfter ? "Data server lebih baru, perlu unduh" : "Data lokal sudah terbaru, tidak perlu unduh"}',
          name:
              'PengecekanDataBaruService-apakahFirebaseAdaDataBaru ${isAfter ? "✅" : "ℹ️"}',
        );

        return isAfter;
      }

      developer.log(
        'Dokumen tidak ditemukan, tidak memiliki data, atau tidak memiliki field diperbarui. Mengembalikan false',
        name: 'PengecekanDataBaruService-apakahFirebaseAdaDataBaru ⚠️',
      );

      return false;
    } catch (e, s) {
      developer.log(
        'Gagal memeriksa data baru di Firebase.',
        name: 'PengecekanDataBaru.Firebase.Error',
        error: e,
        stackTrace: s,
      );

      developer.log(
        'Error saat memeriksa data baru di Firebase: $e | Koleksi: $namaKoleksi | Dokumen: $idDokumen',
        name: 'PengecekanDataBaruService-apakahFirebaseAdaDataBaru ❌',
        error: e,
        stackTrace: s,
      );

      developer.log(
        'Mengembalikan false karena terjadi error saat pengecekan Firebase',
        name: 'PengecekanDataBaruService-apakahFirebaseAdaDataBaru ⚠️',
      );

      return false;
    }
  }
}
