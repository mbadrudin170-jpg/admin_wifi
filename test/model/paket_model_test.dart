// path: test/model/paket_model_test.dart
// diubah: Mengganti paket.toMap() menjadi paket.toMapForSqlite() di dalam test.
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_wifi/model/paket_model.dart';

void main() {
  group('PaketModel', () {
    // 1. Tes Pembuatan Objek dan Nilai Default
    test('Objek PaketModel dapat dibuat dengan nilai default yang benar', () {
      // Arrange: Buat objek hanya dengan properti yang wajib diisi
      final paket = PaketModel(
        nama: 'Paket Dasar',
        harga: 10000,
        durasi: 1,
        tipe: TipeDurasi.hari,
      );

      // Assert: Periksa nilai-nilai defaultnya
      expect(paket.id, isNotNull); // ID harus dibuat secara otomatis
      expect(paket.id, isA<String>());
      expect(paket.jumlahPoin, 0); // Jumlah poin harus default ke 0
      expect(paket.isDeleted, false); // isDeleted harus default ke false
      expect(paket.diarsipkan, isNull);
    });

    // 2. Tes Metode copyWith
    test('Metode copyWith harus membuat salinan dengan nilai yang diperbarui', () {
      // Arrange: Buat objek awal
      final paketAwal = PaketModel(
        id: 'id-awal',
        nama: 'Paket Lama',
        harga: 5000,
        durasi: 2,
        tipe: TipeDurasi.jam,
        jumlahPoin: 10,
      );

      // Act: Buat salinan dengan beberapa properti yang diubah
      final paketDiperbarui = paketAwal.copyWith(
        nama: 'Paket Baru',
        jumlahPoin: 25,
      );

      // Assert: Periksa apakah properti yang diubah sudah benar
      expect(paketDiperbarui.id, paketAwal.id); // ID tidak boleh berubah
      expect(paketDiperbarui.nama, 'Paket Baru');
      expect(paketDiperbarui.harga, paketAwal.harga); // Harga tidak boleh berubah
      expect(paketDiperbarui.jumlahPoin, 25);
    });

    // 3. Tes Konversi toMapForSqlite
    test('Metode toMapForSqlite harus mengonversi objek ke Map dengan benar untuk SQLite', () {
      // Arrange: Buat objek
      final now = DateTime.now();
      final paket = PaketModel(
        id: 'id-test',
        nama: 'Paket Promo',
        harga: 25000,
        durasi: 7,
        tipe: TipeDurasi.hari,
        jumlahPoin: 50,
        diperbarui: now,
        isDeleted: true,
      );

      // Act: Konversi ke map
      final map = paket.toMapForSqlite(); // diubah: dari toMap() ke toMapForSqlite()

      // Assert: Periksa setiap field di dalam map
      expect(map['id'], 'id-test');
      expect(map['nama'], 'Paket Promo');
      expect(map['harga'], 25000);
      expect(map['durasi'], 7);
      expect(map['tipe'], 'hari'); // Enum harus menjadi string
      expect(map['jumlahPoin'], 50); // Properti baru harus ada
      expect(map['diperbarui'], now.toIso8601String());
      expect(map['isDeleted'], 1); // Boolean harus menjadi integer untuk SQLite
    });

    // 4. Tes Konversi fromMap
    test('Metode fromMap harus membuat objek dari Map dengan benar', () {
      // Arrange: Buat map yang merepresentasikan data dari database
      final nowString = DateTime.now().toIso8601String();
      final map = {
        'id': 'id-dari-db',
        'nama': 'Paket Premium',
        'harga': 50000,
        'durasi': 30,
        'tipe': 'bulan',
        'jumlahPoin': 100, // Properti baru dari DB
        'diperbarui': nowString,
        'isDeleted': 1, // data dari sqlite/firestore
      };

      // Act: Konversi dari map ke objek
      final paket = PaketModel.fromMap(map);

      // Assert: Periksa properti objek hasil konversi
      expect(paket.id, 'id-dari-db');
      expect(paket.nama, 'Paket Premium');
      expect(paket.tipe, TipeDurasi.bulan);
      expect(paket.jumlahPoin, 100);
      expect(paket.diperbarui, DateTime.parse(nowString));
      expect(paket.isDeleted, true);
    });

    // 5. Tes Konversi fromMap dengan data lama (tanpa jumlahPoin)
    test('Metode fromMap harus handle jika field jumlahPoin tidak ada', () {
      // Arrange: Buat map yang tidak memiliki field 'jumlahPoin'
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
      final paket = PaketModel.fromMap(map);

      // Assert: Pastikan jumlahPoin diberi nilai default 0
      expect(paket.jumlahPoin, 0);
    });

    // ditambahkan: tes untuk memastikan isDeleted adalah boolean untuk Firebase
    test('saat unggah data ke firebase isDeleted harus boolean (true)', () {
      // Arrange
      final paket = PaketModel(
        nama: 'Paket Firebase',
        harga: 100,
        durasi: 1,
        tipe: TipeDurasi.hari,
        isDeleted: true,
      );

      // Act
      final hasil = paket.toMapForFirebase();

      // Assert
      expect(hasil['isDeleted'], isA<bool>());
      expect(hasil['isDeleted'], true);
    });

    // ditambahkan: tes untuk memastikan isDeleted adalah boolean untuk Firebase
    test('saat unggah data ke firebase isDeleted harus boolean (false)', () {
      // Arrange
      final paket = PaketModel(
        nama: 'Paket Firebase',
        harga: 100,
        durasi: 1,
        tipe: TipeDurasi.hari,
        isDeleted: false,
      );

      // Act
      final hasil = paket.toMapForFirebase();

      // Assert
      expect(hasil['isDeleted'], isA<bool>());
      expect(hasil['isDeleted'], false);
    });
  });
}
