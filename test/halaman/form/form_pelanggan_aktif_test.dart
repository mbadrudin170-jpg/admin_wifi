// path: test/halaman/form/form_pelanggan_aktif_test.dart

import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/halaman/form/form_pelanggan_aktif.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:admin_wifi/enum/status_pembayaran_enum.dart';
import 'package:admin_wifi/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'form_pelanggan_aktif_test.mocks.dart';

@GenerateMocks([
  PelangganOperasi,
  PaketOperasi,
  PelangganAktifOperasi,
  TransaksiOperasi,
  DompetOperasi,
  KategoriOperasi,
])
void main() {
  initializeDateFormatting('id_ID', null);
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late MockPelangganOperasi mockPelangganOperasi;
  late MockPaketOperasi mockPaketOperasi;
  late MockPelangganAktifOperasi mockPelangganAktifOperasi;
  late MockTransaksiOperasi mockTransaksiOperasi;
  late MockDompetOperasi mockDompetOperasi;
  late MockKategoriOperasi mockKategoriOperasi;

  final pelangganDummy = <PelangganModel>[
    PelangganModel(
      id: 'p1',
      nama: 'Pelanggan A',
      telepon: '08123',
      alamat: 'Alamat A',
      password: 'pass',
      diperbarui: DateTime.now(),
    ),
  ];

  final paketDummy = <PaketModel>[
    PaketModel(
      id: 'pkt1',
      nama: 'Paket 1 Jam',
      harga: 5000,
      durasi: 1,
      tipe: TipeDurasi.jam,
      poinPenukaran: 0,
      poinHadiah: 10,
    ),
  ];

  final dompetDummy = <DompetModel>[
    DompetModel(
      id: 'd1',
      namaDompet: 'Dompet Utama',
      saldo: 100000,
      isDeleted: false,
    ),
  ];

  final kategoriDummy = <KategoriModel>[
    KategoriModel(
      id: 'k1',
      nama: 'Aktivasi Paket',
      tipe: TipeKategori.pemasukan,
      isDeleted: false,
    ),
  ];

  final pelangganAktifDummy = PelangganAktifModel(
    id: 'pa-dummy',
    idPelanggan: 'p1',
    idPaket: 'pkt1',
    tanggalMulai: DateTime.now(),
    tanggalBerakhir: DateTime.now().add(const Duration(hours: 1)),
    status: StatusPembayaranEnum.lunas,
  );

  Future<void> pumpForm(
    WidgetTester tester, {
    PelangganAktifModel? pelangganAktif,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FormPelangganAktif(
            pelangganAktif: pelangganAktif,
            pelangganOperasi: mockPelangganOperasi,
            paketOperasi: mockPaketOperasi,
            pelangganAktifOperasi: mockPelangganAktifOperasi,
            transaksiOperasi: mockTransaksiOperasi,
            dompetOperasi: mockDompetOperasi,
            kategoriOperasi: mockKategoriOperasi,
          ),
        ),
      ),
    );
  }

  setUp(() {
    mockPelangganOperasi = MockPelangganOperasi();
    mockPaketOperasi = MockPaketOperasi();
    mockPelangganAktifOperasi = MockPelangganAktifOperasi();
    mockTransaksiOperasi = MockTransaksiOperasi();
    mockDompetOperasi = MockDompetOperasi();
    mockKategoriOperasi = MockKategoriOperasi();

    when(
      mockPelangganOperasi.getPelanggan(),
    ).thenAnswer((_) async => pelangganDummy);

    when(mockPaketOperasi.getPaket()).thenAnswer((_) async => paketDummy);

    when(mockDompetOperasi.getDompet()).thenAnswer((_) async => dompetDummy);

    when(
      mockKategoriOperasi.getKategori(),
    ).thenAnswer((_) async => kategoriDummy);

    when(mockTransaksiOperasi.getTotalPoin(any)).thenAnswer((_) async => 1000);

    when(
      mockPelangganAktifOperasi.createPelangganAktif(any),
    ).thenAnswer((_) async => pelangganAktifDummy);

    when(
      mockPelangganAktifOperasi.updatePelangganAktif(any),
    ).thenAnswer((_) async => pelangganAktifDummy);

    when(mockTransaksiOperasi.tambahTransaksi(any)).thenAnswer((_) async => 1);
  });

  testWidgets('simpan sukses (lunas)', (tester) async {
    await pumpForm(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('pelanggan_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pelanggan A').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('paket_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paket 1 Jam').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    verify(mockPelangganAktifOperasi.createPelangganAktif(any)).called(1);
  });

  testWidgets('simpan gagal karena poin tidak cukup', (tester) async {
    when(mockTransaksiOperasi.getTotalPoin(any)).thenAnswer((_) async => 0);

    await pumpForm(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('pelanggan_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pelanggan A').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('paket_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paket 1 Jam').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    verifyNever(mockPelangganAktifOperasi.createPelangganAktif(any));
    verifyNever(mockTransaksiOperasi.tambahTransaksi(any));
  });

  testWidgets('edit mode sukses', (tester) async {
    await pumpForm(tester, pelangganAktif: pelangganAktifDummy);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    verify(mockPelangganAktifOperasi.updatePelangganAktif(any)).called(1);
  });
}
