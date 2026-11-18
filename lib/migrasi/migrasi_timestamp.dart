// path: lib/migrasi/migrasi_timestamp.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_global_saya/src/utils/l.dart';

class MigrasiTimestamp {
  /// Memastikan semua field String yang berisi format tanggal (ISO8601)
  /// dalam koleksi dikonversi menjadi tipe Timestamp Firestore.
  ///
  /// Alur kerja:
  /// 1. Ambil semua dokumen dari koleksi
  /// 2. Iterasi setiap field di setiap dokumen
  /// 3. Jika field bertipe String dan bisa diparse sebagai DateTime, konversi ke Timestamp
  /// 4. Field yang sudah Timestamp/null/String non-tanggal dilewati
  /// 5. Gunakan batch write untuk efisiensi (maksimal 500 operasi per batch)
  ///
  /// Parameter:
  /// [namaKoleksi] - Nama koleksi Firestore target (contoh: 'paket', 'pelanggan', 'transaksi')
  static Future<void> migrasiStringKeTimestamp(String namaKoleksi) async {
    L.i(
      'Memulai prosedur migrasi String-ke-Timestamp untuk koleksi: $namaKoleksi',
    );
    L.i(
      'Tujuan: Mengonversi semua field String yang berisi format tanggal ISO8601 menjadi tipe Timestamp Firestore',
    );

    final firestore = FirebaseFirestore.instance;
    final koleksiRef = firestore.collection(namaKoleksi);

    try {
      L.i(
        'Mengambil seluruh snapshot dokumen dari server Firestore untuk koleksi: $namaKoleksi',
      );
      final QuerySnapshot snapshot = await koleksiRef.get();

      final int totalDokumen = snapshot.docs.length;
      L.i('Berhasil mengambil $totalDokumen dokumen dari koleksi $namaKoleksi');

      if (snapshot.docs.isEmpty) {
        L.i(
          'Koleksi $namaKoleksi kosong, tidak ada dokumen yang perlu dimigrasi. Prosedur dihentikan.',
        );
        return;
      }

      WriteBatch batch = firestore.batch();
      int jumlahOperasiBatch = 0;
      int totalFieldDikonversi = 0;
      int totalDokumenDiubah = 0;
      int totalDokumenDilewati = 0;
      int totalErrorKonversi = 0;

      L.i('Memulai iterasi pemeriksaan field di setiap dokumen...');

      for (int i = 0; i < snapshot.docs.length; i++) {
        final DocumentSnapshot doc = snapshot.docs[i];
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        bool dokumenIniDiubah = false;
        int fieldDikonversiDiDokumenIni = 0;

        L.i('Memproses dokumen ke-${i + 1} dari $totalDokumen, ID: ${doc.id}');
        L.i('Jumlah field dalam dokumen ini: ${data.keys.length}');

        for (final String namaField in data.keys) {
          final dynamic nilai = data[namaField];

          // Hanya proses field yang bertipe String
          if (nilai is! String) {
            continue;
          }

          // Coba parsing String sebagai DateTime ISO8601
          try {
            final DateTime hasilParse = DateTime.parse(nilai);

            // Validasi rentang tahun untuk memastikan ini benar-benar tanggal
            if (hasilParse.year < 2000 || hasilParse.year > 2100) {
              L.i(
                'Field [$namaField] memiliki nilai "$nilai" yang terparse sebagai tanggal tetapi tahun ${hasilParse.year} di luar rentang 2000-2100, dilewati',
              );
              continue;
            }

            final Timestamp timestampHasil = Timestamp.fromDate(hasilParse);

            L.i(
              'Field [$namaField]: "$nilai" (String) akan dikonversi menjadi Timestamp(${timestampHasil.toDate().toIso8601String()})',
            );

            batch.update(doc.reference, {namaField: timestampHasil});
            jumlahOperasiBatch++;
            totalFieldDikonversi++;
            fieldDikonversiDiDokumenIni++;
            dokumenIniDiubah = true;

            L.i(
              'Operasi update untuk field [$namaField] ditambahkan ke batch. Total operasi dalam batch saat ini: $jumlahOperasiBatch',
            );

            // Firestore membatasi 500 operasi per batch
            if (jumlahOperasiBatch >= 500) {
              L.i(
                'Batch mencapai batas 500 operasi. Melakukan commit batch ke server Firestore...',
              );
              await batch.commit();
              L.i(
                'Commit batch berhasil. Mereset batch untuk operasi selanjutnya.',
              );

              batch = firestore.batch();
              jumlahOperasiBatch = 0;
            }
          } catch (e) {
            // String tidak valid sebagai DateTime, lewati
            L.i(
              'Field [$namaField] memiliki nilai "$nilai" yang bukan format tanggal ISO8601 valid, dilewati. Error parse: ${e.toString()}',
            );
          }
        }

        if (dokumenIniDiubah) {
          totalDokumenDiubah++;
          L.i(
            'Ringkasan dokumen ${doc.id}: $fieldDikonversiDiDokumenIni field dikonversi, dokumen ditandai untuk diupdate',
          );
        } else {
          totalDokumenDilewati++;
          L.i(
            'Ringkasan dokumen ${doc.id}: tidak ada field String yang perlu dikonversi, dokumen dilewati',
          );
        }
      }

      // Commit sisa operasi batch yang belum dikirim
      if (jumlahOperasiBatch > 0) {
        L.i(
          'Mengirim sisa $jumlahOperasiBatch operasi batch ke server Firestore...',
        );
        await batch.commit();
        L.i('Commit batch terakhir berhasil.');
      } else {
        L.i('Tidak ada sisa operasi batch yang perlu dikirim.');
      }

      L.i('PROSEDUR MIGRASI SELESAI UNTUK KOLEKSI: $namaKoleksi');
      L.i('Total dokumen dalam koleksi: $totalDokumen');
      L.i('Total dokumen yang diubah: $totalDokumenDiubah');
      L.i('Total dokumen yang dilewati: $totalDokumenDilewati');
      L.i(
        'Total field yang dikonversi dari String ke Timestamp: $totalFieldDikonversi',
      );
      L.i('Total error konversi: $totalErrorKonversi');
    } catch (e, s) {
      L.e(
        'Gagal menjalankan prosedur migrasi String-ke-Timestamp untuk koleksi: $namaKoleksi Error: $e $s',
      );
    }
  }
}
