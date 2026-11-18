// path: test/data/operasi/pelanggan_aktif_operasi_test.dart
// diperbaiki: Menggunakan ID yang benar saat memanggil arsipkanPelangganAktif.
// diubah: Mengganti .toMap() menjadi .toMapForSqlite() untuk PaketModel.

import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/enum/status_pembayaran_enum.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/services/notifikasi/notifikasi_servis.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:admin_wifi/enum/enum.dart';

import 'pelanggan_aktif_operasi_test.mocks.dart';

@GenerateMocks([NotifikasiServis])
void main() {
  late PelangganAktifOperasi operasi;
  late Database db;
  late MockNotifikasiServis mockNotifikasiServis;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await DatabaseHelper.instance.database;
    mockNotifikasiServis = MockNotifikasiServis();
    operasi = PelangganAktifOperasi(notifikasiServis: mockNotifikasiServis);

    when(mockNotifikasiServis.batalNotifikasi(any)).thenAnswer((_) async {});
    when(
      mockNotifikasiServis.jadwalNotifikasi(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        jadwal: anyNamed('jadwal'),
      ),
    ).thenAnswer((_) async {});

    await db.delete('pelanggan_aktif');
    await db.delete('paket');
    await db.delete('pelanggan');
  });

  group('PelangganAktifOperasi Tests', () {
    PelangganAktifModel buatModel({
      String idPelanggan = 'pelanggan_1',
      String idPaket = 'paket_1',
      bool kadaluarsa = false,
    }) {
      return PelangganAktifModel(
        id: '', // id kosong: PelangganAktifOperasi mengisi UUID sendiri
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

    test('createPelangganAktif harus menjadwalkan notifikasi', () async {
      await operasi.createPelangganAktif(buatModel());
      verify(
        mockNotifikasiServis.jadwalNotifikasi(
          id: anyNamed('id'),
          title: anyNamed('title'),
          body: anyNamed('body'),
          jadwal: anyNamed('jadwal'),
        ),
      ).called(2);
    });

    test('arsipkanPelangganAktif harus membatalkan notifikasi', () async {
      // diperbaiki: simpan model yang dibuat untuk mendapatkan ID-nya
      final modelDibuat = await operasi.createPelangganAktif(buatModel());
      // diperbaiki: gunakan ID yang valid, bukan 'any'
      await operasi.arsipkanPelangganAktif(modelDibuat.id);

      // Harusnya 4 kali, 2 dari create, 2 dari arsip
      verify(mockNotifikasiServis.batalNotifikasi(any)).called(4);
    });

    test('arsipkanPelangganKadaluarsa harus memproses dengan benar', () async {
      // diubah: Menggunakan toMapForSqlite()
      await db.insert(
        'paket',
        PaketModel(
          id: 'paket_1',
          nama: 'P1',
          harga: 1,
          durasi: 1,
          tipe: TipeDurasi.bulan,
        ).toSqlite(),
      );
      await db.insert(
        'paket',
        PaketModel(
          id: 'paket_2',
          nama: 'P2',
          harga: 1,
          durasi: 1,
          tipe: TipeDurasi.bulan,
        ).toSqlite(),
      );
      await db.insert('pelanggan', {
        'id': 'p1',
        'nama': 'Test1',
        'telepon': '123',
        'alamat': 'a',
        'password': 'p',
        'mac_address': 'm',
      });
      await db.insert('pelanggan', {
        'id': 'p2',
        'nama': 'Test2',
        'telepon': '123',
        'alamat': 'a',
        'password': 'p',
        'mac_address': 'm',
      });

      await operasi.createPelangganAktif(
        buatModel(idPelanggan: 'p1', idPaket: 'paket_1', kadaluarsa: true),
      );
      await operasi.createPelangganAktif(
        buatModel(idPelanggan: 'p2', idPaket: 'paket_2', kadaluarsa: false),
      );

      final result = await operasi.arsipkanPelangganKadaluarsa();

      expect(result, 1);

      // Harusnya 6 kali. 2x2 dari create, 2 dari arsip pelanggan kadaluarsa
      verify(mockNotifikasiServis.batalNotifikasi(any)).called(6);
    });
  });
}
