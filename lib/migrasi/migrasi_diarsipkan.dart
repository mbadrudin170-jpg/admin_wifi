// path: lib/migrasi/migrasi_diarsipkan.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_global_saya/src/utils/l.dart';

class MigrasiDiarsipkan {
  /// Memastikan semua dokumen dalam koleksi memiliki field 'diarsipkan'.
  /// Jika field tidak ada, akan ditambahkan dengan nilai null.
  /// Jika field ada tetapi dalam format String (ISO8601), akan dikonversi menjadi Timestamp.
  static Future<void> migrasiKolomDiarsipkan(String namaKoleksi) async {
    L.i(
      'Memulai prosedur migrasi kolom "diarsipkan" untuk koleksi: [$namaKoleksi].',
    );

    final firestore = FirebaseFirestore.instance;
    final koleksiRef = firestore.collection(namaKoleksi);

    try {
      L.i('Mengambil seluruh snapshot dokumen dari server Firestore...');
      final snapshot = await koleksiRef.get();

      if (snapshot.docs.isEmpty) {
        L.i('Migrasi dibatalkan: Koleksi [$namaKoleksi] kosong.');
        return;
      }

      L.i(
        'Analisis Dokumen: Ditemukan total ${snapshot.docs.length} dokumen. Memulai iterasi pemeriksaan.',
      );

      final batch = firestore.batch();
      int dokumenDimigrasi = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();

        // Kasus 1: Field 'diarsipkan' tidak ada sama sekali.
        if (!data.containsKey('diarsipkan')) {
          L.i(
            'Memproses Dokumen [${doc.id}]: Menambahkan field "diarsipkan" dengan nilai null.',
          );
          batch.update(doc.reference, {'diarsipkan': null});
          dokumenDimigrasi++;
        }
        // Kasus 2: Field 'diarsipkan' ada dan bertipe String.
        else if (data['diarsipkan'] is String) {
          final String tanggalString = data['diarsipkan'];
          try {
            L.i(
              'Memproses Dokumen [${doc.id}]: Mengonversi "diarsipkan" dari String "$tanggalString" ke Timestamp.',
            );

            final tanggalDateTime = DateTime.parse(tanggalString);
            final tanggalTimestamp = Timestamp.fromDate(tanggalDateTime);

            batch.update(doc.reference, {'diarsipkan': tanggalTimestamp});
            dokumenDimigrasi++;
          } catch (e) {
            L.w(
              'Kegagalan Konversi: Dokumen [${doc.id}] memiliki string "diarsipkan" yang tidak valid: "$tanggalString". Detail: $e',
            );
          }
        }
        // Kasus 3: Field 'diarsipkan' sudah ada dan tipenya benar (Timestamp atau null).
        else if (data['diarsipkan'] is Timestamp ||
            data['diarsipkan'] == null) {
          L.i(
            'Dilewati: Dokumen [${doc.id}] sudah memiliki field "diarsipkan" dengan format yang benar.',
          );
        }
        // Kasus 4: Tipe data tidak dikenal.
        else {
          L.w(
            'Dilewati: Dokumen [${doc.id}] memiliki field "diarsipkan" dengan tipe data tidak dikenal: ${data['diarsipkan'].runtimeType}.',
          );
        }
      }

      if (dokumenDimigrasi > 0) {
        L.i(
          'Mengirimkan (Commit) perubahan batch sebanyak $dokumenDimigrasi dokumen ke server...',
        );
        await batch.commit();
        L.i(
          'MIGRASI SUKSES: $dokumenDimigrasi dokumen pada [$namaKoleksi] telah di-migrasi.',
        );
      } else {
        L.i(
          'Selesai: Tidak ada dokumen di [$namaKoleksi] yang memerlukan migrasi untuk field "diarsipkan".',
        );
      }
    } catch (e, s) {
      L.e(
        'KESALAHAN FATAL: Gagal menjalankan prosedur migrasi "diarsipkan" pada koleksi [$namaKoleksi]. Error: $e $s',
      );
    }
  }
}
