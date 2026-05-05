// path: test/operasi/pelanggan_aktif_operasi_test.dart

// @file: pelanggan_aktif_operasi_test.dart
// @description: Unit test untuk PelangganAktifOperasi (sinkron model terbaru)

import 'package:admin_wifi/model/paket_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/model/enum/status_pembayaran.dart';

void main() {
  late PelangganAktifOperasi operasi;
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Inisialisasi DatabaseHelper untuk lingkungan tes.
    // Ini akan secara otomatis membuat database in-memory dengan skema yang benar.
    db = await DatabaseHelper.instance.database;
    operasi = PelangganAktifOperasi();

    // Membersihkan data dari tabel yang relevan sebelum setiap tes berjalan
    // untuk memastikan isolasi tes.
    await db.delete('pelanggan_aktif');
    await db.delete('paket');
    await db.delete('riwayat_langganan');
    await db.delete('pelanggan');
  });

  tearDown(() async {
    await db.close();
  });

  group('PelangganAktifOperasi Test (Model Sinkron)', () {
    PelangganAktifModel buatModel({
      String idPelanggan = 'pelanggan_1',
      String idPaket = 'paket_1',
      bool kadaluarsa = false,
    }) {
      return PelangganAktifModel(
        idPelanggan: idPelanggan,
        idPaket: idPaket,
        tanggalMulai:
            kadaluarsa ? DateTime.now().subtract(const Duration(days: 40)) : DateTime.now(),
        tanggalBerakhir: kadaluarsa
            ? DateTime.now().subtract(const Duration(days: 1))
            : DateTime.now().add(const Duration(days: 30)),
        status: StatusPembayaran.lunas,
      );
    }

    test('createPelangganAktif -> insert + generate id', () async {
      final model = buatModel();

      final result = await operasi.createPelangganAktif(model);

      expect(result.id.isNotEmpty, true);

      final dbData = await operasi.ambilSatuPelangganAktif(result.id);

      expect(dbData != null, true);
      expect(dbData?.idPelanggan, 'pelanggan_1');
    });

    test('ambilSemuaPelangganAktif -> hanya yang tidak diarsipkan', () async {
      final model = buatModel();

      await operasi.createPelangganAktif(model);

      final list = await operasi.ambilSemuaPelangganAktif();

      expect(list.length, 1);
      expect(list.first.isDeleted, false);
    });

    test('updatePelangganAktif -> update data', () async {
      final model = await operasi.createPelangganAktif(buatModel());

      final updated = model.copyWith(status: StatusPembayaran.belumLunas);

      await operasi.updatePelangganAktif(updated);

      final result = await operasi.ambilSatuPelangganAktif(model.id);

      expect(result?.status, StatusPembayaran.belumLunas);
    });

    test('arsipkanPelangganAktif -> soft delete', () async {
      final model = await operasi.createPelangganAktif(buatModel());

      await operasi.arsipkanPelangganAktif(model.id);

      // diubah: verifikasi langsung ke DB untuk memastikan soft delete
      final rawData = await db.query('pelanggan_aktif', where: 'id = ?', whereArgs: [model.id]);
      
      expect(rawData.first['isDeleted'], 1);
      expect(rawData.first['diarsipkan'] != null, true);

      // verifikasi bahwa data tidak muncul di list aktif
      final list = await operasi.ambilSemuaPelangganAktif();
      expect(list.isEmpty, isTrue);
    });

    test('hapusSemuaPelangganAktif -> tabel kosong', () async {
      await operasi.createPelangganAktif(buatModel());

      await operasi.hapusSemuaPelangganAktif();

      final list = await db.query('pelanggan_aktif');

      expect(list.isEmpty, true);
    });

    test('sisipkanAtauPerbaruiBatch -> insert banyak data', () async {
      final items = [buatModel(), buatModel(), buatModel()];

      await operasi.sisipkanAtauPerbaruiBatch(items);

      final list = await operasi.ambilSemuaPelangganAktif();

      expect(list.length, 3);
    });

    test('arsipkanSemuaPelangganAktif -> semua jadi isDeleted', () async {
      await operasi.createPelangganAktif(buatModel());
      await operasi.createPelangganAktif(buatModel());

      final count = await operasi.arsipkanSemuaPelangganAktif();

      expect(count, 2);

      final list = await operasi.ambilSemuaPelangganAktif();

      expect(list.isEmpty, true);
    });

    test('arsipkanPelangganKadaluarsa -> hanya yang expired', () async {
      // ditambah: siapkan data dependen (paket)
      await db.insert('paket', PaketModel(id: 'paket_1', nama: 'P1', harga: 1, durasi: 1, tipe: TipeDurasi.bulan).toMap());
      await db.insert('paket', PaketModel(id: 'paket_2', nama: 'P2', harga: 1, durasi: 1, tipe: TipeDurasi.bulan).toMap());

      await operasi.createPelangganAktif(buatModel(idPelanggan: 'p1', idPaket: 'paket_1', kadaluarsa: true));
      await operasi.createPelangganAktif(buatModel(idPelanggan: 'p2', idPaket: 'paket_2', kadaluarsa: false));
      
      final result = await operasi.arsipkanPelangganKadaluarsa();
      
      expect(result, 1);
      
      // verifikasi riwayat dibuat
      final riwayat = await db.query('riwayat_langganan');
      expect(riwayat.length, 1);
    });

    // ditambah: group test untuk fungsi hapusPelangganYangDiArsipkan
    group('hapusPelangganYangDiArsipkan', () {
      test('harus menghapus data yang diarsipkan lebih dari 30 hari', () async {
        final now = DateTime.now();
        final model = PelangganAktifModel(
          idPelanggan: 'pelanggan_hapus',
          idPaket: 'paket_hapus',
          tanggalMulai: now,
          tanggalBerakhir: now.add(const Duration(days: 30)),
          status: StatusPembayaran.lunas,
          isDeleted: true, // diarsipkan
          diarsipkan: now.subtract(const Duration(days: 31)), // 31 hari lalu
        );

        final created = await operasi.createPelangganAktif(model);

        await operasi.hapusPelangganYangDiArsipkan();

        final List<Map> maps = await db.query('pelanggan_aktif', where: 'id = ?', whereArgs: [created.id]);
        
        expect(maps.isEmpty, isTrue);
      });

      test('TIDAK boleh menghapus data yang diarsipkan kurang dari 30 hari', () async {
        final now = DateTime.now();
        final model = PelangganAktifModel(
          idPelanggan: 'pelanggan_aman',
          idPaket: 'paket_aman',
          tanggalMulai: now,
          tanggalBerakhir: now.add(const Duration(days: 30)),
          status: StatusPembayaran.lunas,
          isDeleted: true, // diarsipkan
          diarsipkan: now.subtract(const Duration(days: 15)), // 15 hari lalu
        );

        final created = await operasi.createPelangganAktif(model);

        await operasi.hapusPelangganYangDiArsipkan();

        final rawData = await db.query('pelanggan_aktif', where: 'id = ?', whereArgs: [created.id]);
        
        expect(rawData.isNotEmpty, isTrue);
      });
    });
  });
}
