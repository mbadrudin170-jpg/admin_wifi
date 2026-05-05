// path: test/operasi/pelanggan_operasi_test.dart
// diubah: Menyesuaikan dengan PelangganModel terbaru (telepon bukan nomorTelepon)
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('PelangganOperasi Tests', () {
    late PelangganOperasi operasi;
    late Database db;
    final uuid = const Uuid();

    setUp(() async {
      db = await DatabaseHelper.instance.database;
      await db.delete('pelanggan');
      operasi = PelangganOperasi();
    });

    PelangganModel buatModel({
      String? id,
      String nama = 'Pelanggan Test',
      String telepon = '081234567890',
      String alamat = 'Jl. Ujicoba No. 123',
      String password = '123456',
    }) {
      return PelangganModel(
        id: id ?? uuid.v4(),
        nama: nama,
        telepon: telepon,
        alamat: alamat,
        password: password,
        diperbarui: DateTime.now(),
      );
    }

    test('1. createPelanggan harus menyimpan data baru', () async {
      final model = buatModel();
      await operasi.createPelanggan(model);

      final hasil = await operasi.getPelanggan();
      expect(hasil.length, 1);
      expect(hasil.first.id, model.id);
      expect(hasil.first.nama, 'Pelanggan Test');
    });

    test('2. getPelanggan harus mengembalikan semua pelanggan (non-arsip)', () async {
      final pelangganAktif = buatModel(nama: 'Aktif');
      final pelangganArsip = buatModel(nama: 'Arsip').copyWith(diarsipkan: DateTime.now());

      await operasi.createPelanggan(pelangganAktif);
      await operasi.createPelanggan(pelangganArsip);

      final hasil = await operasi.getPelanggan();
      expect(hasil.length, 1);
      expect(hasil.first.nama, 'Aktif');
    });

    test('3. getAllPelanggan harus mengembalikan semua pelanggan termasuk arsip', () async {
      await operasi.createPelanggan(buatModel(nama: 'Aktif'));
      await operasi.createPelanggan(buatModel(nama: 'Arsip').copyWith(diarsipkan: DateTime.now()));

      final hasil = await operasi.getAllPelanggan();
      expect(hasil.length, 2);
    });

    test('4. getPelangganById harus mengembalikan pelanggan yang benar', () async {
      final model = buatModel();
      await operasi.createPelanggan(model);

      final hasil = await operasi.getPelangganById(model.id);
      expect(hasil, isNotNull);
      expect(hasil!.nama, model.nama);
    });

    test('5. updatePelanggan harus memperbarui data', () async {
      final modelAwal = buatModel();
      await operasi.createPelanggan(modelAwal);

      final modelUpdate = modelAwal.copyWith(nama: 'Nama Baru', telepon: '089876543210');
      await operasi.updatePelanggan(modelUpdate);

      final hasil = await operasi.getPelangganById(modelAwal.id);
      expect(hasil!.nama, 'Nama Baru');
      expect(hasil.telepon, '089876543210');
    });

    test('6. deletePelanggan (soft delete) harus mengubah status isDeleted', () async {
      final model = buatModel();
      await operasi.createPelanggan(model);

      await operasi.deletePelanggan(model.id, softDelete: true);

      // getPelanggan seharusnya tidak mengembalikan yg soft-deleted
      final hasil = await operasi.getPelanggan();
      expect(hasil.isEmpty, isTrue);

      // Cek langsung ke DB
      final dbData = await db.query('pelanggan', where: 'id = ?', whereArgs: [model.id]);
      final pelangganDariDb = PelangganModel.fromMap(dbData.first);
      expect(pelangganDariDb.isDeleted, isTrue);
    });

    test('7. deletePelanggan (hard delete) harus menghapus data', () async {
      final model = buatModel();
      await operasi.createPelanggan(model);

      await operasi.deletePelanggan(model.id, softDelete: false);

      final hasil = await operasi.getAllPelanggan();
      expect(hasil.isEmpty, isTrue);
    });

     test('8. sisipkanAtauPerbaruiBatch harus melakukan upsert data', () async {
      final modelAwal = buatModel(id: 'id-tetap');
      await operasi.createPelanggan(modelAwal);

      final batch = [
        modelAwal.copyWith(nama: 'Nama Updated'), // Update
        buatModel(id: 'id-baru', nama: 'Pelanggan Baru'), // Insert
      ];

      await operasi.sisipkanAtauPerbaruiBatch(batch);
      final hasil = await operasi.getAllPelanggan();
      expect(hasil.length, 2);

      final updatedItem = hasil.firstWhere((p) => p.id == 'id-tetap');
      expect(updatedItem.nama, 'Nama Updated');

      final newItem = hasil.firstWhere((p) => p.id == 'id-baru');
      expect(newItem.nama, 'Pelanggan Baru');
    });

    test('9. getPerubahan harus mengembalikan data setelah timestamp', () async {
      final waktuAmbil = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 50));

      final modelBaru = buatModel();
      await operasi.createPelanggan(modelBaru);

      final perubahan = await operasi.getPerubahan(waktuAmbil);

      expect(perubahan.length, 1);
      expect(perubahan.first.id, modelBaru.id);
    });

  });
}
