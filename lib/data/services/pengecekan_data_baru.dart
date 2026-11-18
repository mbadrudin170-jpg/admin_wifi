// path: lib/data/services/pengecekan_data_baru.dart
import 'package:admin_wifi/data/operasi/operasi.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_global_saya/src/utils/l.dart';

class PengecekanDataBaruService {
  final FirebaseFirestore _firestore;
  final SyncManager _syncManager;
  final StatusUnggahOperasi _statusUnggahOperasi;

  PengecekanDataBaruService({
    FirebaseFirestore? firestore,
    SyncManager? syncManager,
    StatusUnggahOperasi? statusUnggahOperasi,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _syncManager = syncManager ?? SyncManager(),
       _statusUnggahOperasi = statusUnggahOperasi ?? StatusUnggahOperasi() {
    L.i(
      'Inisialisasi PengecekanDataBaruService berhasil. Komponen FirebaseFirestore untuk akses cloud, SyncManager untuk manajemen waktu lokal, dan StatusUnggahOperasi untuk akses bendera SQLite telah siap digunakan.',
    );
  }

  Future<bool> apakahSqliteAdaDataBaru() async {
    L.i(
      'Memulai prosedur pengecekan data lokal di SQLite. Sistem akan memverifikasi apakah ada perubahan data yang belum diunggah ke server.',
    );

    try {
      L.i(
        'Mengakses StatusUnggahOperasi untuk membaca nilai dari kolom perlu_unggah di database internal. Ini adalah indikator utama apakah aplikasi memiliki payload baru.',
      );
      final bool hasil = await _statusUnggahOperasi.getPerluUnggah();

      if (hasil) {
        L.i(
          'Hasil pengecekan SQLite: Ditemukan bendera perlu_unggah bernilai TRUE. Aplikasi memiliki data baru yang harus segera disinkronisasikan ke server.',
        );
      } else {
        L.i(
          'Hasil pengecekan SQLite: Bendera perlu_unggah bernilai FALSE. Tidak ada perubahan data lokal yang memerlukan tindakan pengunggahan saat ini.',
        );
      }
      return hasil;
    } catch (e, s) {
      L.e(
        'Gagal melakukan pengecekan status perlu_unggah pada SQLite. Terjadi kesalahan pada query database atau akses file database lokal terhambat. Error: $e $s',
      );
      return false;
    }
  }

  Future<bool> apakahFirebaseAdaDataBaru({
    required String namaKoleksi,
    required String idDokumen,
  }) async {
    L.i(
      'Memulai prosedur pembandingan timestamp server. Lokasi target koleksi: "$namaKoleksi", dokumen: "$idDokumen". Prosedur ini akan menentukan apakah aplikasi perlu mengunduh data terbaru.',
    );

    try {
      L.i(
        'Mengambil metadata waktu unduhan terakhir dari penyimpanan preferensi lokal melalui SyncManager.',
      );
      final DateTime waktuLokal = await _syncManager.getTerakhirUnduh();
      L.i('Timestamp unduhan lokal terakhir yang tercatat adalah: $waktuLokal');

      L.i(
        'Membangun referensi dokumen Firestore dan memulai permintaan pengambilan data langsung dari server cloud (Source.server).',
      );
      final DocumentReference docRef = _firestore
          .collection(namaKoleksi)
          .doc(idDokumen);
      final DocumentSnapshot docSnapshot = await docRef.get(
        const GetOptions(source: Source.server),
      );

      if (docSnapshot.exists && docSnapshot.data() != null) {
        L.i(
          'Dokumen status ditemukan di server. Melakukan ekstraksi payload data untuk mencari field pembanding.',
        );
        final data = docSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey('diperbarui')) {
          L.i(
            'Field "diperbarui" ditemukan pada dokumen server. Mengonversi tipe data Timestamp Firestore ke objek DateTime Dart.',
          );
          final DateTime waktuServer = (data['diperbarui'] as Timestamp)
              .toDate();
          L.i('Waktu pembaruan di server adalah: $waktuServer');

          final bool isAfter = waktuServer.isAfter(waktuLokal);
          if (isAfter) {
            L.i(
              'Kesimpulan: Waktu server ($waktuServer) lebih baru daripada waktu lokal ($waktuLokal). PENGUNDUHAN DATA DIPERLUKAN untuk menjaga aktualitas data.',
            );
          } else {
            L.i(
              'Kesimpulan: Waktu server tidak lebih baru daripada waktu lokal. Data aplikasi saat ini sudah sinkron dengan versi terbaru di server.',
            );
          }
          return isAfter;
        } else {
          L.w(
            'Struktur data dokumen di server tidak sesuai standar. Field "diperbarui" tidak ditemukan. Sistem mengasumsikan tidak ada pembaruan untuk menghindari pengunduhan yang tidak perlu.',
          );
          return false;
        }
      } else {
        L.w(
          'Dokumen target "$idDokumen" tidak tersedia di koleksi "$namaKoleksi" pada server Firebase. Pastikan dokumen status global telah dibuat di konsol Firebase.',
        );
        return false;
      }
    } catch (e, s) {
      L.e(
        'Terjadi kegagalan saat proses pembandingan waktu server dan lokal. Masalah mungkin terletak pada koneksi jaringan atau hak akses (Security Rules) Firebase Firestore. Error: $e $s',
      );
      return false;
    }
  }
}
