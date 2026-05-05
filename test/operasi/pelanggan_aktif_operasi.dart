// path: test/operasi/pelanggan_aktif_operasi.dart

// @file: pelanggan_aktif_operasi_test.dart
// @description: Unit test untuk PelangganAktifOperasi (sinkron model terbaru)

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/model/enum/status_pembayaran.dart';

void main() {
  late PelangganAktifOperasi operasi;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final db = await DatabaseHelper.instance.database;

    await db.delete('pelanggan_aktif');

    operasi = PelangganAktifOperasi();
  });

  group('PelangganAktifOperasi Test (Model Sinkron)', () {
    PelangganAktifModel buatModel() {
      return PelangganAktifModel(
        idPelanggan: 'pelanggan_1',
        idPaket: 'paket_1',
        tanggalMulai: DateTime.now(),
        tanggalBerakhir: DateTime.now().add(const Duration(days: 30)),
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

      final result = await operasi.ambilSatuPelangganAktif(model.id);

      expect(result?.isDeleted, true);
      expect(result?.diarsipkan != null, true);
    });

    test('hapusSemuaPelangganAktif -> tabel kosong', () async {
      await operasi.createPelangganAktif(buatModel());

      await operasi.hapusSemuaPelangganAktif();

      final list = await operasi.ambilSemuaPelangganAktif();

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
      final expired = PelangganAktifModel(
        idPelanggan: '1',
        idPaket: '1',
        tanggalMulai: DateTime.now().subtract(const Duration(days: 40)),
        tanggalBerakhir: DateTime.now().subtract(const Duration(days: 1)),
        status: StatusPembayaran.lunas,
      );

      final active = PelangganAktifModel(
        idPelanggan: '2',
        idPaket: '2',
        tanggalMulai: DateTime.now(),
        tanggalBerakhir: DateTime.now().add(const Duration(days: 10)),
        status: StatusPembayaran.lunas,
      );

      await operasi.createPelangganAktif(expired);
      await operasi.createPelangganAktif(active);

      final result = await operasi.arsipkanPelangganKadaluarsa();

      expect(result, 1);
    });
  });
}
