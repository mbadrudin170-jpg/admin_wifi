// path: test/data/operasi/pelanggan_aktif_operasi_test.dart
// diperbaiki: Menggunakan ID yang benar saat memanggil arsipkanPelangganAktif.
// diubah: Mengganti .toMap() menjadi .toMapForSqlite() untuk PaketModel.

import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:admin_wifi/enum/enum.dart';
import 'package:admin_wifi/enum/status_pembayaran_enum.dart';
import 'package:admin_wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../mocks.dart';

void main() {
  late PelangganAktifOperasi operasi;
  late Database db;
  late MockNotifikasiServis mockNotifikasiServis;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    registerFallbackValue(DateTime.now());
  });

  setUp(() async {
    db = await DatabaseHelper.instance.database;
    mockNotifikasiServis = MockNotifikasiServis();
    operasi = PelangganAktifOperasi(notifikasiServis: mockNotifikasiServis);

    when(
      () => mockNotifikasiServis.batalNotifikasi(any()),
    ).thenAnswer((_) async {});

    when(
      () => mockNotifikasiServis.jadwalNotifikasi(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        jadwal: any(named: 'jadwal'),
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
      // Implementasi menjadwalkan 3 notifikasi: H-3, H-1, dan tepat waktu.
      verify(
        () => mockNotifikasiServis.jadwalNotifikasi(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          jadwal: any(named: 'jadwal'),
        ),
      ).called(3);
    });

    test('arsipkanPelangganAktif harus membatalkan notifikasi', () async {
      // diperbaiki: simpan model yang dibuat untuk mendapatkan ID-nya
      final modelDibuat = await operasi.createPelangganAktif(buatModel());
      // Reset interaksi mock agar verifikasi hanya menghitung aksi arsip.
      clearInteractions(mockNotifikasiServis);
      // diperbaiki: gunakan ID yang valid, bukan 'any'
      await operasi.arsipkanPelangganAktif(modelDibuat.id);

      // Implementasi membatalkan 3 notifikasi (H-3, H-1, tepat waktu).
      verify(() => mockNotifikasiServis.batalNotifikasi(any())).called(3);
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

      // Reset interaksi mock agar verifikasi hanya menghitung aksi arsip kadaluarsa.
      clearInteractions(mockNotifikasiServis);

      final result = await operasi.arsipkanPelangganKadaluarsa();

      expect(result, 1);

      // Implementasi membatalkan 3 notifikasi untuk pelanggan kadaluarsa yang diarsip.
      verify(() => mockNotifikasiServis.batalNotifikasi(any())).called(3);
    });
  });
}
