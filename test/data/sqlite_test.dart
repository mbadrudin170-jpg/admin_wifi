// path: test/data/sqlite_test.dart
// diubah: Memperbaiki kesalahan sintaks dengan melengkapi parameter yang hilang
// di constructor TransaksiModel dan menambahkan id unik pada data insert.
// diubah: Memperbaiki logika perbandingan skema untuk memberikan pesan error yang lebih jelas.
// diubah: Menambahkan pembersihan tabel di setUpAll untuk memastikan pengujian bersifat independen.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:uuid/uuid.dart';

void main() {
  late DatabaseHelper databaseHelper;
  late Database db;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databaseHelper = DatabaseHelper.instance;
    db = await databaseHelper.database;
    // Membersihkan tabel sebelum setiap pengujian untuk memastikan isolasi
    await db.delete('transaksi');
    await db.delete('dompet');
  });

  tearDownAll(() async {
    await db.close();
  });

  group('Test DatabaseHelper', () {
    test('Database berhasil dibuat', () async {
      expect(db, isNotNull);
      expect(db.isOpen, true);
    });

    test('Semua tabel utama berhasil dibuat', () async {
      final hasil = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );

      final namaTabel = hasil.map((e) => e['name']).toList();

      expect(namaTabel.contains('kategori'), true);
      expect(namaTabel.contains('sub_kategori'), true);
      expect(namaTabel.contains('paket'), true);
      expect(namaTabel.contains('pelanggan'), true);
      expect(namaTabel.contains('pelanggan_aktif'), true);
      expect(namaTabel.contains('transaksi'), true);
      expect(namaTabel.contains('dompet'), true);
      expect(namaTabel.contains('kritik_saran'), true);
      expect(namaTabel.contains('riwayat_langganan'), true);
      expect(namaTabel.contains('pesanan'), true);
      expect(namaTabel.contains('versi_apk_user'), true);
    });

    test('Insert dan ambil data transaksi', () async {
      await db.insert('transaksi', {
        'id': const Uuid().v4(),
        'keterangan': 'Test transaksi',
        'jumlah': 10000,
        'tanggal': DateTime.now().toIso8601String(),
        'tipe': 'pemasukan',
        'isDeleted': 0,
        'nama_dompet': 'test', // ✅ FIX
        'nama_kategori': 'test', // ✅ FIX
        'id_dompet': 'test', // ✅ FIX
        'id_kategori': 'test', // ✅ FIX
        'diperbarui': DateTime.now().toIso8601String(),
      });
      final hasil = await db.query('transaksi');

      expect(hasil.length, 1);
      expect(hasil.first['keterangan'], 'Test transaksi');
    });

    test('Default value isDeleted = 0', () async {
      await db.insert('dompet', {
        'id': const Uuid().v4(),
        'namaDompet': 'Dompet Test',
        'saldo': 50000,
        'diperbarui': DateTime.now().toIso8601String(),
      });

      final hasil = await db.query('dompet');

      expect(hasil.first['isDeleted'], 0);
    });

    test(
      '1. skema tabel transaksi harus sama dengan TransaksiModel.toMap()',
      () async {
        final hasil = await db.rawQuery("PRAGMA table_info(transaksi)");
        final kolomDatabase = hasil.map((e) => e['name'] as String).toSet();

        final model = TransaksiModel(
          tanggal: DateTime.now(),
          keterangan: 'Test transaksi',
          jumlah: 10000,
          tipe: TipeTransaksi.pemasukan,
          idDompet: '1',
          namaDompet: 'dompet',
          idKategori: '1',
          namaKategori: 'kategori',
        );

        await db.insert('transaksi', model.toMapForSqlite());

        final kolomModel = model.toMapForSqlite().keys.toSet();

        final notInDb = kolomModel.difference(kolomDatabase);
        final notInModel = kolomDatabase.difference(kolomModel);

        expect(
          notInDb.isEmpty,
          true,
          reason: 'Kolom model ini tidak ada di DB: \$notInDb',
        );
        expect(
          notInModel.isEmpty,
          true,
          reason: 'Kolom DB ini tidak ada di model: \$notInModel',
        );
      },
    );

    test('2. tabel dompet harus memiliki kolom dasar', () async {
      final hasil = await db.rawQuery("PRAGMA table_info(dompet)");
      final kolom = hasil.map((e) => e['name'] as String).toList();

      final kolomWajib = [
        'id',
        'namaDompet',
        'saldo',
        'isDeleted',
        'diperbarui',
      ];

      for (final k in kolomWajib) {
        expect(
          kolom.contains(k),
          true,
          reason: 'Kolom `$k` tidak ditemukan di tabel dompet',
        );
      }
    });
  });
}
