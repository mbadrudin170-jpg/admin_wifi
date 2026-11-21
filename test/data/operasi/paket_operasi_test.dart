// path: test/data/operasi/paket_operasi_test.dart
// diubah: Menggunakan PaketNotifier alih-alih PaketOperasi

import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

void main() {
  // Inisialisasi binding untuk pengujian
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('PaketNotifier Tests', () {
    late Database db;
    final uuid = const Uuid();

    setUp(() async {
      db = await DatabaseHelper.instance.database;
      await db.delete('paket');
    });

    PaketModel buatModel(
      String nama,
      int harga,
      TipeDurasi tipe,
      int durasi, {
      String? id,
    }) {
      return PaketModel(
        id: id ?? uuid.v4(),
        nama: nama,
        harga: harga,
        tipe: tipe,
        durasi: durasi,
        diperbarui: DateTime.now(),
      );
    }

    test('1. tambah harus menyimpan data dan mengisi timestamp', () async {
      final model = buatModel('Paket Harian', 10000, TipeDurasi.hari, 1);

      await paketNotifierGlobal.tambah(model);

      final hasil = await paketNotifierGlobal.getPaket();
      expect(hasil.length, 1);
      expect(hasil.first.id, model.id);
      expect(hasil.first.nama, 'Paket Harian');
      expect(hasil.first.diperbarui, isNotNull);
    });

    test(
      '2. getPaket harus mengembalikan data terurut berdasarkan durasi efektif',
      () async {
        // Urutan acak saat pembuatan
        final paketBulan = buatModel('Bulanan', 100000, TipeDurasi.bulan, 1);
        final paketJam = buatModel('Jam', 2000, TipeDurasi.jam, 5);
        final paketHari = buatModel('Harian', 50000, TipeDurasi.hari, 7);

        await paketNotifierGlobal.tambah(paketBulan);
        await paketNotifierGlobal.tambah(paketJam);
        await paketNotifierGlobal.tambah(paketHari);

        final hasil = await paketNotifierGlobal.getPaket();
        expect(hasil.length, 3);
        // Urutan yang benar: jam -> hari -> bulan
        expect(hasil[0].id, paketJam.id);
        expect(hasil[1].id, paketHari.id);
        expect(hasil[2].id, paketBulan.id);
      },
    );

    test('3. getPaketById harus mengembalikan paket yang benar', () async {
      final model = buatModel('Cari Saya', 1, TipeDurasi.hari, 1);
      await paketNotifierGlobal.tambah(model);

      final hasil = paketStateGlobal?.getPaketById(model.id);
      expect(hasil, isNotNull);
      expect(hasil!.nama, 'Cari Saya');
    });

    test('4. ubah harus memperbarui data di database', () async {
      final modelAwal = buatModel('Nama Lama', 100, TipeDurasi.hari, 1);
      await paketNotifierGlobal.tambah(modelAwal);

      final modelUpdate = modelAwal.copyWith(nama: 'Nama Baru', harga: 200);
      await paketNotifierGlobal.ubah(modelUpdate);

      final hasil = paketStateGlobal?.getPaketById(modelAwal.id);
      expect(hasil!.nama, 'Nama Baru');
      expect(hasil.harga, 200);
      expect(hasil.diperbarui, isNot(modelAwal.diperbarui));
    });

    test('5. hapus harus menghapus data dari database', () async {
      final model = buatModel('Akan Dihapus', 1, TipeDurasi.hari, 1);
      await paketNotifierGlobal.tambah(model);

      await paketNotifierGlobal.hapus(model.id);

      final hasil = await paketNotifierGlobal.getPaket();
      expect(hasil.isEmpty, isTrue);
    });

    test('6. hapusSemuaPaket harus mengosongkan tabel', () async {
      await paketNotifierGlobal.tambah(buatModel('A', 1, TipeDurasi.hari, 1));
      await paketNotifierGlobal.tambah(buatModel('B', 1, TipeDurasi.hari, 1));

      await paketNotifierGlobal.hapusSemuaPaket();

      final hasil = await paketNotifierGlobal.getPaket();
      expect(hasil.isEmpty, isTrue);
    });

    test('7. tambahBatch harus melakukan upsert dengan benar', () async {
      final modelAwal = buatModel('Awal', 100, TipeDurasi.hari, 1, id: 'id-1');
      await paketNotifierGlobal.tambah(modelAwal);

      final batch = [
        modelAwal.copyWith(nama: 'Updated'), // Update
        buatModel('Baru', 200, TipeDurasi.bulan, 1, id: 'id-2'), // Insert
      ];

      await paketNotifierGlobal.tambahBatch(batch);

      final hasil = await paketNotifierGlobal.getPaket();
      expect(hasil.length, 2);

      final updatedItem = hasil.firstWhere((p) => p.id == 'id-1');
      expect(updatedItem.nama, 'Updated');

      final newItem = hasil.firstWhere((p) => p.id == 'id-2');
      expect(newItem.nama, 'Baru');
    });

    test('8. getPerubahan harus mengambil data setelah timestamp', () async {
      final waktuAmbil = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 20));

      final modelBaru = buatModel('Paket Baru', 1, TipeDurasi.hari, 1);
      await paketNotifierGlobal.tambah(modelBaru);

      final perubahan = await paketNotifierGlobal.getPerubahan(waktuAmbil);

      expect(perubahan.length, 1);
      expect(perubahan.first.id, modelBaru.id);
    });
  });
}
