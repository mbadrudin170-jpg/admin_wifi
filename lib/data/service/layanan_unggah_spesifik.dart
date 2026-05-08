// path: lib/data/service/layanan_unggah_spesifik.dart
// diubah: Kelas ini sekarang menangani unggahan spesifik dan sinkronisasi tabel penuh.
import 'dart:developer' as developer;

import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/enum/nama_tabel_enum.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:admin_wifi/model/status_unggah_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LayananUnggahSpesifik {
  final DatabaseHelper _dbHelper;
  final FirebaseFirestore _firestore;

  LayananUnggahSpesifik({
    DatabaseHelper? dbHelper,
    FirebaseFirestore? firestore,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Metode publik utama untuk memproses instruksi unggah.
  /// - Jika `ids` ada, unggah item spesifik.
  /// - Jika `ids` kosong, unggah seluruh tabel.
  Future<void> prosesStatusUnggah(StatusUnggahModel instruksi) async {
    // Hanya proses jika statusnya true.
    if (!instruksi.status) {
      developer.log(
        'Instruksi unggah dilewati karena status false untuk tabel: ${instruksi.tabel.name}',
        name: 'LayananUnggahSpesifik',
      );
      return;
    }

    final String logMessage = instruksi.ids.isEmpty
        ? 'Memulai sinkronisasi penuh untuk tabel ${instruksi.tabel.name}'
        : 'Memulai unggah spesifik untuk ${instruksi.ids.length} item dari tabel ${instruksi.tabel.name}';
    developer.log(logMessage, name: 'LayananUnggahSpesifik');

    // Menggunakan switch untuk menentukan tipe data dan koleksi yang benar.
    switch (instruksi.tabel) {
      case NamaTabel.pelanggan:
        await _unggahItemGenerik<PelangganModel>(
          namaTabel: 'pelanggan',
          namaKoleksi: 'pelanggan',
          ids: instruksi.ids,
          fromSqlite: PelangganModel.fromSqlite,
          toFirebase: (m) => m.toFirebase(),
        );
        break;
      case NamaTabel.paket:
        await _unggahItemGenerik<PaketModel>(
          namaTabel: 'paket',
          namaKoleksi: 'paket',
          ids: instruksi.ids,
          fromSqlite: PaketModel.fromSqlite,
          toFirebase: (m) => m.toFirebase(),
        );
        break;
      // PENTING: Tambahkan case untuk tabel lain di sini di masa depan.
      default:
        developer.log(
          'Logika unggah tidak didefinisikan untuk tabel: ${instruksi.tabel.name}',
          name: 'LayananUnggahSpesifik.Error',
        );
    }
  }

  /// Fungsi generik internal yang menangani logika unggah.
  /// Jika `ids` kosong, ia akan mengunggah semua item dari `namaTabel`.
  /// Jika `ids` berisi nilai, ia hanya akan mengunggah item-item tersebut.
  Future<void> _unggahItemGenerik<T>({
    required String namaTabel,
    required String namaKoleksi,
    required List<String> ids,
    required T Function(Map<String, dynamic>) fromSqlite,
    required Map<String, dynamic> Function(T) toFirebase,
  }) async {
    try {
      final db = await _dbHelper.database;
      List<Map<String, dynamic>> dataLokal;

      if (ids.isEmpty) {
        // Kasus 1: `ids` kosong. Ambil semua data dari tabel.
        dataLokal = await db.query(namaTabel);
        developer.log('Mengambil semua data (${dataLokal.length} item) dari tabel $namaTabel untuk sinkronisasi penuh.', name: 'LayananUnggahSpesifik');
      } else {
        // Kasus 2: `ids` berisi ID spesifik. Ambil hanya data tersebut.
        final placeholders = List.filled(ids.length, '?').join(',');
        dataLokal = await db.query(
          namaTabel,
          where: 'id IN ($placeholders)',
          whereArgs: ids,
        );
         developer.log('Mengambil ${dataLokal.length} item spesifik dari tabel $namaTabel.', name: 'LayananUnggahSpesifik');
      }

      if (dataLokal.isEmpty) {
        developer.log(
          'Tidak ada data yang perlu diunggah dari tabel $namaTabel.',
          name: 'LayananUnggahSpesifik.Info',
        );
        return;
      }

      WriteBatch batch = _firestore.batch();
      int itemCount = 0;

      for (final map in dataLokal) {
        final T model = fromSqlite(map);
        // Asumsi semua model yang relevan memiliki properti `id`
        final String docId = (model as dynamic).id;
        final dataUnggah = toFirebase(model);

        final docRef = _firestore.collection(namaKoleksi).doc(docId);
        batch.set(docRef, dataUnggah, SetOptions(merge: true));
        itemCount++;
        
        // Batas penulisan batch Firestore adalah 500. Lakukan commit jika mendekati batas.
        if(itemCount % 499 == 0) {
            await batch.commit();
            developer.log('Melakukan commit batch parsial ($itemCount) untuk $namaTabel', name: 'LayananUnggahSpesifik');
            // Mulai batch baru setelah commit
            batch = _firestore.batch();
        }
      }

      // Commit sisa item dalam batch terakhir
      await batch.commit();
      developer.log(
        'Batch unggah berhasil untuk total ${dataLokal.length} item dari tabel: $namaTabel',
        name: 'LayananUnggahSpesifik',
      );
    } catch (e, s) {
      developer.log(
        'Gagal selama unggah untuk tabel: $namaTabel',
        name: 'LayananUnggahSpesifik.Error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}
