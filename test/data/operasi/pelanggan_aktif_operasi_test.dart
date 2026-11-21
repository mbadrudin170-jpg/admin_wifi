// path: test/data/operasi/pelanggan_aktif_operasi_test.dart
// diubah: Menggunakan PenggunaAktifNotifier alih-alih PelangganAktifOperasi
// Catatan: NotifikasiServis dibuat internal di notifier, jadi pengujian berfokus pada operasi DB (bukan verifikasi panggilan notifikasi mock).

import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:admin_wifi/enum/status_pembayaran_enum.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/notifer/pengguna_aktif_notifier.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('PenggunaAktifNotifier Tests', () {
    late Database db;
    final uuid = const Uuid();

    setUp(() async {
      db = await DatabaseHelper.instance.database;
      await db.delete('pelanggan_aktif');
      await db.delete('paket');
      await db.delete('pelanggan');
    });

    PelangganAktifModel buatModel({
      String id = '',
      String idPelanggan = 'pelanggan_1',
      String idPaket = 'paket_1',
      bool kadaluarsa = false,
    }) {
      return PelangganAktifModel(
        id: id.isEmpty ? uuid.v4() : id,
        idPelanggan: idPelanggan,
        idPaket: idPaket,
        tanggalMulai: kadaluarsa
            ? DateTime.now().subtract(const Duration(days: 40))
            : DateTime.now(),
        tanggalBerakhir: kadaluarsa
            ? DateTime.now().subtract(const Duration(days: 1))
            : DateTime.now().add(const Duration(days: 30)),
        status: StatusPembayaranEnum.lunas,
      );
    }

    test('1. tambah harus menyimpan data dan mengembalikan model', () async {
      final model = buatModel();
      final hasil = await penggunaAktifNotifierGlobal.tambah(model);

      expect(hasil.id, isNotEmpty);
      expect(hasil.idPelanggan, 'pelanggan_1');

      final diDb = await penggunaAktifNotifierGlobal.ambilSatuPelangganAktif(
        hasil.id,
      );
      expect(diDb, isNotNull);
      expect(diDb!.idPelanggan, 'pelanggan_1');
    });

    test('2. arsipkanPelangganAktif harus mengarsipkan data', () async {
      await penggunaAktifNotifierGlobal.tambah(buatModel(id: 'arsip-1'));

      await penggunaAktifNotifierGlobal.arsipkanPelangganAktif('arsip-1');

      final dbData = await db.query(
        'pelanggan_aktif',
        where: 'id = ?',
        whereArgs: ['arsip-1'],
      );
      expect(dbData.isNotEmpty, isTrue);
      final diDb = PelangganAktifModel.fromSqlite(dbData.first);
      expect(diDb.isDeleted, isTrue);
    });

    test(
      '3. arsipkanPelangganKadaluarsa harus memproses dengan benar',
      () async {
        await penggunaAktifNotifierGlobal.tambah(
          buatModel(
            id: 'kad-1',
            idPelanggan: 'p1',
            idPaket: 'paket_1',
            kadaluarsa: true,
          ),
        );
        await penggunaAktifNotifierGlobal.tambah(
          buatModel(
            id: 'aktif-1',
            idPelanggan: 'p2',
            idPaket: 'paket_2',
            kadaluarsa: false,
          ),
        );

        final result = await penggunaAktifNotifierGlobal
            .arsipkanPelangganKadaluarsa();
        expect(result, 1);
      },
    );
  });
}
