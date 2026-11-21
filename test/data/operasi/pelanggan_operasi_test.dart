// path: test/data/operasi/pelanggan_operasi_test.dart
// diubah: Menggunakan PelangganNotifier alih-alih PelangganOperasi

import 'package:admin_wifi/fitur/pelanggan/notifier/pelanggan_notifier.dart';
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:admin_wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('PelangganNotifier Tests', () {
    late Database db;
    final uuid = const Uuid();

    setUp(() async {
      db = await DatabaseHelper.instance.database;
      await db.delete('pelanggan');
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

    test('1. tambah harus menyimpan data baru', () async {
      final model = buatModel();
      await pelangganNotifierGlobal.tambah(model);

      final hasil = await pelangganNotifierGlobal.getPelanggan();
      expect(hasil.length, 1);
      expect(hasil.first.id, model.id);
      expect(hasil.first.nama, 'Pelanggan Test');
    });

    test(
      '2. getPelanggan harus mengembalikan semua pelanggan (non-arsip)',
      () async {
        final pelangganAktif = buatModel(nama: 'Aktif');
        final pelangganArsip = buatModel(
          nama: 'Arsip',
        ).copyWith(diarsipkan: DateTime.now());

        await pelangganNotifierGlobal.tambah(pelangganAktif);
        await pelangganNotifierGlobal.tambah(pelangganArsip);

        final hasil = await pelangganNotifierGlobal.getPelanggan();
        expect(hasil.length, 1);
        expect(hasil.first.nama, 'Aktif');
      },
    );

    test(
      '3. getAllPelanggan harus mengembalikan semua pelanggan termasuk arsip',
      () async {
        await pelangganNotifierGlobal.tambah(buatModel(nama: 'Aktif'));
        await pelangganNotifierGlobal.tambah(
          buatModel(nama: 'Arsip').copyWith(diarsipkan: DateTime.now()),
        );

        final hasil = await pelangganNotifierGlobal.getAllPelanggan();
        expect(hasil.length, 2);
      },
    );

    test(
      '4. getPelangganById harus mengembalikan pelanggan yang benar',
      () async {
        final model = buatModel();
        await pelangganNotifierGlobal.tambah(model);

        final hasil = await pelangganNotifierGlobal.getPelangganById(model.id);
        expect(hasil, isNotNull);
        expect(hasil!.nama, model.nama);
      },
    );

    test('5. ubah harus memperbarui data', () async {
      final modelAwal = buatModel();
      await pelangganNotifierGlobal.tambah(modelAwal);

      final modelUpdate = modelAwal.copyWith(
        nama: 'Nama Baru',
        telepon: '089876543210',
      );
      await pelangganNotifierGlobal.ubah(modelUpdate);

      final hasil = await pelangganNotifierGlobal.getPelangganById(
        modelAwal.id,
      );
      expect(hasil!.nama, 'Nama Baru');
      expect(hasil.telepon, '089876543210');
    });

    test('6. hapus (soft delete) harus mengubah status isDeleted', () async {
      final model = buatModel();
      await pelangganNotifierGlobal.tambah(model);

      await pelangganNotifierGlobal.hapus(model.id, softDelete: true);

      // getPelanggan seharusnya tidak mengembalikan yg soft-deleted
      final hasil = await pelangganNotifierGlobal.getPelanggan();
      expect(hasil.isEmpty, isTrue);

      // Cek langsung ke DB
      final dbData = await db.query(
        'pelanggan',
        where: 'id = ?',
        whereArgs: [model.id],
      );
      // diubah: Menggunakan fromSqlite
      final pelangganDariDb = PelangganModel.fromSqlite(dbData.first);
      expect(pelangganDariDb.isDeleted, isTrue);
    });

    test('7. hapus (hard delete) harus menghapus data', () async {
      final model = buatModel();
      await pelangganNotifierGlobal.tambah(model);

      await pelangganNotifierGlobal.hapus(model.id, softDelete: false);

      final hasil = await pelangganNotifierGlobal.getAllPelanggan();
      expect(hasil.isEmpty, isTrue);
    });

    test('8. tambahBatch harus melakukan upsert data', () async {
      final modelAwal = buatModel(id: 'id-tetap');
      await pelangganNotifierGlobal.tambah(modelAwal);

      final batch = [
        modelAwal.copyWith(nama: 'Nama Updated'), // Update
        buatModel(id: 'id-baru', nama: 'Pelanggan Baru'), // Insert
      ];

      await pelangganNotifierGlobal.tambahBatch(batch);
      final hasil = await pelangganNotifierGlobal.getAllPelanggan();
      expect(hasil.length, 2);

      final updatedItem = hasil.firstWhere((p) => p.id == 'id-tetap');
      expect(updatedItem.nama, 'Nama Updated');

      final newItem = hasil.firstWhere((p) => p.id == 'id-baru');
      expect(newItem.nama, 'Pelanggan Baru');
    });

    test(
      '9. getPerubahan harus mengembalikan data setelah timestamp',
      () async {
        final waktuAmbil = DateTime.now();
        await Future.delayed(const Duration(milliseconds: 50));

        final modelBaru = buatModel();
        await pelangganNotifierGlobal.tambah(modelBaru);

        final perubahan = await pelangganNotifierGlobal.getPerubahan(
          waktuAmbil,
        );

        expect(perubahan.length, 1);
        expect(perubahan.first.id, modelBaru.id);
      },
    );
  });
}
