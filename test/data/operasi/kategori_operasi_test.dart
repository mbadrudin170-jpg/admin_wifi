// path: test/data/operasi/kategori_operasi_test.dart
// diubah: Menyesuaikan pemanggilan fromMap menjadi fromSqlite

import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/db/sqflite.dart';
import 'package:admin_wifi/fitur/kategori/model/kategori_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

void main() {
  // Inisialisasi sqflite_common_ffi untuk pengujian di desktop
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('KategoriOperasi Tests', () {
    late KategoriOperasi kategoriOperasi;
    late Database db;

    // Fungsi helper untuk membersihkan dan menyiapkan database sebelum setiap tes
    setUp(() async {
      // Menggunakan database in-memory
      db = await DatabaseHelper.instance.database;
      await db.delete('kategori'); // Hapus semua data sebelumnya
      kategoriOperasi = KategoriOperasi();
    });

    test(
      '1. createKategori harus berhasil menambahkan kategori baru',
      () async {
        final kategori = KategoriModel(
          id: const Uuid().v4(),
          nama: 'Test Pemasukan',
          tipe: TipeKategori.pemasukan,
        );

        final kategoriBaru = await kategoriOperasi.createKategori(kategori);

        // Verifikasi
        final hasil = await kategoriOperasi.getKategori();
        expect(hasil.length, 1);
        expect(hasil.first.nama, 'Test Pemasukan');
        expect(hasil.first.id, kategoriBaru.id);
        expect(hasil.first.diperbarui, isNotNull);
      },
    );

    test('2. getKategori harus mengembalikan daftar kategori', () async {
      await kategoriOperasi.createKategori(
        KategoriModel(
          id: const Uuid().v4(),
          nama: 'Kategori 1',
          tipe: TipeKategori.pemasukan,
        ),
      );
      await kategoriOperasi.createKategori(
        KategoriModel(
          id: const Uuid().v4(),
          nama: 'Kategori 2',
          tipe: TipeKategori.pengeluaran,
        ),
      );

      final hasil = await kategoriOperasi.getKategori();
      expect(hasil.length, 2);
    });

    test('3. getKategoriByTipe harus memfilter berdasarkan tipe', () async {
      await kategoriOperasi.createKategori(
        KategoriModel(
          id: const Uuid().v4(),
          nama: 'Pemasukan 1',
          tipe: TipeKategori.pemasukan,
        ),
      );
      await kategoriOperasi.createKategori(
        KategoriModel(
          id: const Uuid().v4(),
          nama: 'Pengeluaran 1',
          tipe: TipeKategori.pengeluaran,
        ),
      );

      final hasil = await kategoriOperasi.getKategoriByTipe(
        TipeKategori.pemasukan,
      );
      expect(hasil.length, 1);
      expect(hasil.first.nama, 'Pemasukan 1');
    });

    test('4. update harus memperbarui data kategori', () async {
      final kategoriAwal = await kategoriOperasi.createKategori(
        KategoriModel(
          id: const Uuid().v4(),
          nama: 'Nama Lama',
          tipe: TipeKategori.pemasukan,
        ),
      );

      final kategoriUpdate = kategoriAwal.copyWith(nama: 'Nama Baru');
      await kategoriOperasi.update(kategoriUpdate);

      final hasilDb = await db.query(
        'kategori',
        where: 'id = ?',
        whereArgs: [kategoriAwal.id],
      );
      // diubah: Menggunakan fromSqlite
      final kategoriDariDb = KategoriModel.fromSqlite(hasilDb.first);

      expect(kategoriDariDb.nama, 'Nama Baru');
      // Pastikan timestamp 'diperbarui' juga berubah
      expect(kategoriDariDb.diperbarui, isNot(equals(kategoriAwal.diperbarui)));
    });

    test('5. delete harus menghapus kategori', () async {
      final kategori = await kategoriOperasi.createKategori(
        KategoriModel(
          id: const Uuid().v4(),
          nama: 'Untuk Dihapus',
          tipe: TipeKategori.pemasukan,
        ),
      );

      await kategoriOperasi.delete(kategori.id);

      final hasil = await kategoriOperasi.getKategori();
      expect(hasil.isEmpty, isTrue);
    });

    test('6. sisipkanAtauPerbaruiBatch harus melakukan upsert', () async {
      // Buat data awal
      final kategoriAwal = await kategoriOperasi.createKategori(
        KategoriModel(id: '1', nama: 'Awal', tipe: TipeKategori.pemasukan),
      );

      final List<KategoriModel> batch = [
        // Update data yang ada
        kategoriAwal.copyWith(nama: 'Update'),
        // Tambah data baru
        KategoriModel(id: '2', nama: 'Baru', tipe: TipeKategori.pengeluaran),
      ];

      await kategoriOperasi.sisipkanAtauPerbaruiBatch(batch);

      final hasil = await kategoriOperasi.getKategori();
      expect(hasil.length, 2);
      expect(hasil.firstWhere((k) => k.id == '1').nama, 'Update');
      expect(hasil.firstWhere((k) => k.id == '2').nama, 'Baru');
    });

    test(
      '7. getPerubahan harus mengembalikan data setelah timestamp',
      () async {
        final waktuSekarang = DateTime.now();
        // diubah: Jeda diperpanjang untuk memastikan timestamp berbeda
        await Future.delayed(const Duration(milliseconds: 50));

        await kategoriOperasi.createKategori(
          KategoriModel(
            id: const Uuid().v4(),
            nama: 'Perubahan 1',
            tipe: TipeKategori.pemasukan,
          ),
        );

        final hasil = await kategoriOperasi.getPerubahan(waktuSekarang);
        expect(
          hasil.length,
          1,
          reason:
              'Seharusnya ada 1 perubahan yang terdeteksi setelah jeda waktu.',
        );
        expect(hasil.first.nama, 'Perubahan 1');
      },
    );
  });
}
