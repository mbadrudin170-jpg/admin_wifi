// path: lib/server/migrasi_timestamp.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_wifi/debug/log.dart';

class MigrasiTimestamp {
  /// Mengonversi field 'diperbarui' dari String (ISO8601) menjadi Firestore Timestamp.
  /// Digunakan untuk memperbaiki kompatibilitas data lama di server.
  static Future<void> migrasiStringKeTimestamp(String namaKoleksi) async {
    Log.info('Memulai prosedur migrasi data tipe String ke Timestamp untuk koleksi: [$namaKoleksi].');

    final firestore = FirebaseFirestore.instance;
    final koleksiRef = firestore.collection(namaKoleksi);

    try {
      Log.info('Mengambil seluruh snapshot dokumen dari server Firestore...');
      final snapshot = await koleksiRef.get();
      
      if (snapshot.docs.isEmpty) {
        Log.info('Migrasi dibatalkan: Koleksi [$namaKoleksi] tidak memiliki dokumen untuk diproses.');
        return;
      }

      Log.info('Analisis Dokumen: Ditemukan total ${snapshot.docs.length} dokumen. Memulai iterasi pemeriksaan tipe data.');

      final batch = firestore.batch();
      int dokumenDiproses = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        
        // Memeriksa apakah field ada dan bertipe String
        if (data.containsKey('diperbarui') && data['diperbarui'] is String) {
          final String tanggalString = data['diperbarui'];
          try {
            Log.info('Memproses Dokumen [${doc.id}]: Mengonversi "$tanggalString"');
            
            final tanggalDateTime = DateTime.parse(tanggalString);
            final tanggalTimestamp = Timestamp.fromDate(tanggalDateTime);

            batch.update(doc.reference, {'diperbarui': tanggalTimestamp});
            dokumenDiproses++;

          } catch (e) {
            Log.warning('Kegagalan Parsing Tanggal: Dokumen [${doc.id}] memiliki string yang tidak valid: "$tanggalString". Detail: $e');
          }
        } else if (data.containsKey('diperbarui') && data['diperbarui'] is Timestamp) {
          Log.info('Dilewati: Dokumen [${doc.id}] sudah menggunakan tipe data Timestamp.');
        } else {
          Log.warning('Dilewati: Dokumen [${doc.id}] tidak memiliki field "diperbarui" atau tipe data tidak dikenal.');
        }
      }

      if (dokumenDiproses > 0) {
        Log.info('Mengirimkan (Commit) perubahan batch sebanyak $dokumenDiproses dokumen ke server...');
        await batch.commit();
        Log.info('MIGRASI SUKSES: $dokumenDiproses dokumen pada [$namaKoleksi] telah diperbarui ke format Timestamp Firestore.');
      } else {
        Log.info('Selesai: Tidak ada dokumen di [$namaKoleksi] yang memerlukan konversi tipe data.');
      }

    } catch (e, s) {
      Log.error('KESALAHAN FATAL: Gagal menjalankan prosedur migrasi pada koleksi [$namaKoleksi]. Proses dihentikan.', 
          error: e, stackTrace: s);
    }
  }
}