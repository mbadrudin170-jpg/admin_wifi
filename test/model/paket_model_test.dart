// path: test/model/paket_model_test.dart
// diubah: Menyesuaikan file test dengan menghapus `jumlahPoin` dan menambahkan `poinHadiah` serta `poinPenukaran`.

import 'package:flutter_test/flutter_test.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';

void main() {
  group('PaketModel', () {
    // 1. Tes Pembuatan Objek dan Nilai Default
    test('Objek PaketModel dapat dibuat dengan nilai default yang benar', () {
      // Arrange: Buat objek hanya dengan properti yang wajib diisi
      final paket = PaketModel(
        id: 'paket-dasar-123',
        nama: 'Paket Dasar',
        harga: 10000,
        durasi: 1,
        tipe: TipeDurasi.hari,
      );

      // Assert: Periksa nilai-nilai defaultnya
      expect(paket.id, 'paket-dasar-123');
      // dihapus: expect(paket.jumlahPoin, 0);
      // ditambah: Memeriksa nilai default untuk field poin yang baru.
      expect(paket.poinHadiah, 0);
      expect(paket.poinPenukaran, 0);
      expect(paket.isPublic, true);
      expect(paket.isDeleted, false);
      expect(paket.diarsipkan, isNull);
    });

    // 2. Tes Metode copyWith
    test(
      'Metode copyWith harus membuat salinan dengan nilai yang diperbarui',
      () {
        // Arrange: Buat objek awal
        final paketAwal = PaketModel(
          id: 'id-awal',
          nama: 'Paket Lama',
          harga: 5000,
          durasi: 2,
          tipe: TipeDurasi.jam,
          poinHadiah: 10, // diubah: dari jumlahPoin
          poinPenukaran: 5,
        );

        // Act: Buat salinan dengan beberapa properti yang diubah
        final paketDiperbarui = paketAwal.copyWith(
          nama: 'Paket Baru',
          poinHadiah: 25, // diubah: dari jumlahPoin
        );

        // Assert: Periksa apakah properti yang diubah sudah benar
        expect(paketDiperbarui.id, paketAwal.id); // ID tidak boleh berubah
        expect(paketDiperbarui.nama, 'Paket Baru');
        expect(
          paketDiperbarui.harga,
          paketAwal.harga,
        ); // Harga tidak boleh berubah
        expect(paketDiperbarui.poinHadiah, 25); // diubah: dari jumlahPoin
        expect(
          paketDiperbarui.poinPenukaran,
          paketAwal.poinPenukaran,
        ); // Pastikan yang lain tidak berubah
      },
    );

    // 3. Tes Konversi toSqlite
    test(
      'Metode toSqlite harus mengonversi objek ke Map dengan benar untuk SQLite',
      () {
        // Arrange: Buat objek
        final now = DateTime.now();
        final paket = PaketModel(
          id: 'id-test',
          nama: 'Paket Promo',
          harga: 25000,
          durasi: 7,
          tipe: TipeDurasi.hari,
          poinHadiah: 50,
          poinPenukaran: 20,
          isPublic: false,
          diperbarui: now,
          isDeleted: true,
        );

        // Act: Konversi ke map
        final map = paket.toSqlite();

        // Assert: Periksa setiap field di dalam map
        expect(map['id'], 'id-test');
        expect(map['nama'], 'Paket Promo');
        expect(map['harga'], 25000);
        expect(map['durasi'], 7);
        expect(map['tipe'], 'hari');
        // dihapus: expect(map['jumlahPoin'], 50);
        // ditambah: Memeriksa field poin yang baru.
        expect(map['poin_hadiah'], 50);
        expect(map['poin_penukaran'], 20);
        expect(map['isPublic'], 0);
        expect(map['diperbarui'], now.toIso8601String());
        expect(map['isDeleted'], 1);
      },
    );

    // 4. Tes Konversi fromSqlite
    test('Metode fromSqlite harus membuat objek dari Map dengan benar', () {
      // Arrange: Buat map yang merepresentasikan data dari database
      final nowString = DateTime.now().toIso8601String();
      final map = {
        'id': 'id-dari-db',
        'nama': 'Paket Premium',
        'harga': 50000,
        'durasi': 30,
        'tipe': 'bulan',
        // dihapus: 'jumlahPoin': 100,
        // ditambah: field poin yang baru.
        'poin_hadiah': 100,
        'poin_penukaran': 50,
        'isPublic': 1,
        'diperbarui': nowString,
        'isDeleted': 1,
      };

      // Act: Konversi dari map ke objek
      final paket = PaketModel.fromSqlite(map);

      // Assert: Periksa properti objek hasil konversi
      expect(paket.id, 'id-dari-db');
      expect(paket.nama, 'Paket Premium');
      expect(paket.tipe, TipeDurasi.bulan);
      // dihapus: expect(paket.jumlahPoin, 100);
      // ditambah: Memeriksa field poin yang baru.
      expect(paket.poinHadiah, 100);
      expect(paket.poinPenukaran, 50);
      expect(paket.isPublic, true);
      expect(paket.diperbarui, DateTime.parse(nowString));
      expect(paket.isDeleted, true);
    });

    // 5. Tes Konversi fromSqlite dengan data lama (tanpa field poin)
    test('Metode fromSqlite harus handle jika field poin tidak ada', () {
      // Arrange: Buat map yang tidak memiliki field poin
      final map = {
        'id': 'id-data-lama',
        'nama': 'Paket Old',
        'harga': 1000,
        'durasi': 60,
        'tipe': 'menit',
        'diperbarui': DateTime.now().toIso8601String(),
        'isDeleted': 0,
      };

      // Act: Konversi dari map ke objek
      final paket = PaketModel.fromSqlite(map);

      // Assert: Pastikan field poin diberi nilai default 0
      // dihapus: expect(paket.jumlahPoin, 0);
      // ditambah: Memeriksa field poin yang baru.
      expect(paket.poinHadiah, 0);
      expect(paket.poinPenukaran, 0);
    });

    // Tes ini tetap relevan
    test('saat unggah data ke firebase isDeleted harus boolean (true)', () {
      // Arrange
      final paket = PaketModel(
        id: 'paket-firebase-true',
        nama: 'Paket Firebase',
        harga: 100,
        durasi: 1,
        tipe: TipeDurasi.hari,
        isDeleted: true,
      );

      // Act
      final hasil = paket.toFirebase();

      // Assert
      expect(hasil['isDeleted'], isA<bool>());
      expect(hasil['isDeleted'], true);
    });

    // Tes ini juga tetap relevan
    test('saat unggah data ke firebase isDeleted harus boolean (false)', () {
      // Arrange
      final paket = PaketModel(
        id: 'paket-firebase-false',
        nama: 'Paket Firebase',
        harga: 100,
        durasi: 1,
        tipe: TipeDurasi.hari,
        isDeleted: false,
      );

      // Act
      final hasil = paket.toFirebase();

      // Assert
      expect(hasil['isDeleted'], isA<bool>());
      expect(hasil['isDeleted'], false);
    });
  });
}
