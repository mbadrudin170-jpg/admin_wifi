// path: test/halaman/form/form_pelanggan_aktif_test.dart
// diubah: Mengelompokkan semua tes ke dalam grup yang logis untuk meningkatkan keterbacaan.
// diubah: Memperbarui tes untuk menguji fungsi top-level `hitungTanggalBerakhir` secara langsung.
// diubah: Memperbaiki tipe data yang dikembalikan oleh mock tambahTransaksi.

import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/halaman/form/form_pelanggan_aktif.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/enum/status_pembayaran.dart';
import 'package:admin_wifi/model/kategori_model.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:admin_wifi/model/pelanggan_aktif_model.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:jiffy/jiffy.dart';

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
    status: StatusPembayaran.lunas,
  );

  Future<void> pumpForm(
    WidgetTester tester, {
    PelangganAktifModel? pelangganAktif,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FormPelangganAktif(
          pelangganAktif: pelangganAktif,
          pelangganOperasi: mockPelangganOperasi,
          paketOperasi: mockPaketOperasi,
          pelangganAktifOperasi: mockPelangganAktifOperasi,
          transaksiOperasi: mockTransaksiOperasi,
          dompetOperasi: mockDompetOperasi,
          kategoriOperasi: mockKategoriOperasi,
        ),
      ),
    );
  }

  group('FormPelangganAktif', () {
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

      // diubah: Mengubah tipe kembalian menjadi Future<int> agar sesuai dengan signature baru.
      when(
        mockTransaksiOperasi.tambahTransaksi(any),
      ).thenAnswer((_) async => 1);
    });

    group('Inisialisasi & Tampilan Awal', () {
      testWidgets('load form sukses', (tester) async {
        await pumpForm(tester);
        await tester.pumpAndSettle();

        expect(find.byType(Form), findsOneWidget);
        expect(find.byKey(const Key('pelanggan_dropdown')), findsOneWidget);
        expect(find.byKey(const Key('paket_dropdown')), findsOneWidget);
      });
    });

    group('Simpan & Validasi', () {
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

        await tester.ensureVisible(find.text('Simpan'));
        await tester.tap(find.text('Simpan'));

        await tester.pump(const Duration(milliseconds: 300));

        expect(find.textContaining('berhasil'), findsOneWidget);

        await tester.pumpAndSettle();

        verify(mockPelangganAktifOperasi.createPelangganAktif(any)).called(1);
        verify(mockTransaksiOperasi.tambahTransaksi(any)).called(1);
      });

      testWidgets('simpan gagal karena poin tidak cukup', (tester) async {
        when(mockPaketOperasi.getPaket()).thenAnswer(
          (_) async => [paketDummy.first.copyWith(poinPenukaran: 500)],
        );
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

        final switchFinder = find.byType(Switch);
        await tester.ensureVisible(switchFinder);
        await tester.pumpAndSettle();

        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        final simpanButtonFinder = find.text('Simpan');
        await tester.ensureVisible(simpanButtonFinder);
        await tester.pumpAndSettle();

        await tester.tap(simpanButtonFinder);
        await tester.pump();

        expect(find.textContaining('Poin tidak cukup'), findsOneWidget);

        verifyNever(mockPelangganAktifOperasi.createPelangganAktif(any));
      });

      testWidgets(
        'poin dihasilkan harus sesuai poin hadiah paket, saat _gunakanPoin false',
        (tester) async {
          when(
            mockPaketOperasi.getPaket(),
          ).thenAnswer((_) async => [paketDummy.first.copyWith(poinHadiah: 15)]);

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

          await tester.ensureVisible(find.text('Simpan'));
          await tester.tap(find.text('Simpan'));
          await tester.pumpAndSettle();

          final verifikasi = verify(
            mockTransaksiOperasi.tambahTransaksi(captureAny),
          );
          verifikasi.called(1);

          final transaksiYangTersimpan = verifikasi.captured.first;

          expect(transaksiYangTersimpan.poinYangDihasilkan, 15);
        },
      );
    });

    group('Mode Edit', () {
      testWidgets('edit mode sukses', (tester) async {
        final editData = PelangganAktifModel(
          id: 'edit1',
          idPelanggan: 'p1',
          idPaket: 'pkt1',
          tanggalMulai: DateTime.now(),
          tanggalBerakhir: DateTime.now().add(const Duration(hours: 1)),
          status: StatusPembayaran.lunas,
        );

        await pumpForm(tester, pelangganAktif: editData);
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Simpan'));
        await tester.tap(find.text('Simpan'));

        await tester.pump(const Duration(milliseconds: 300));

        expect(find.textContaining('diperbarui'), findsOneWidget);

        await tester.pumpAndSettle();

        verify(mockPelangganAktifOperasi.updatePelangganAktif(any)).called(1);
      });
    });

    group('UI & Logika Poin', () {
      int hitungSisaPoinTest(int saldo, int poinDipakai) {
        return (saldo - poinDipakai).clamp(0, 999999999);
      }

      testWidgets(
        'label poin - ketika poin dipakai label poin harus menampilkan label poin dipakai',
        (tester) async {
          when(mockPaketOperasi.getPaket()).thenAnswer(
            (_) async => [paketDummy.first.copyWith(poinPenukaran: 500)],
          );

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

          await tester.ensureVisible(find.byType(Switch));
          await tester.tap(find.byType(Switch));
          await tester.pumpAndSettle();

          expect(find.textContaining('Poin dipakai: 500'), findsOneWidget);
        },
      );

      testWidgets(
        'label poin - _digunakan : false label poin harus menampilan poin',
        (tester) async {
          when(
            mockTransaksiOperasi.getTotalPoin(any),
          ).thenAnswer((_) async => 1000);
          await pumpForm(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('pelanggan_dropdown')));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Pelanggan A').first);
          await tester.pumpAndSettle();

          expect(find.textContaining('Sisa poin: 1000'), findsOneWidget);
        },
      );

      testWidgets(
        'label poin - setelah poin dipakai, sisa poin harus diperbarui',
        (tester) async {
          when(
            mockTransaksiOperasi.getTotalPoin(any),
          ).thenAnswer((_) async => 1000);
          when(mockPaketOperasi.getPaket()).thenAnswer(
            (_) async => [paketDummy.first.copyWith(poinPenukaran: 500)],
          );

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

          expect(find.text('Sisa poin: 1000'), findsOneWidget);

          await tester.ensureVisible(find.byType(Switch));
          await tester.tap(find.byType(Switch));
          await tester.pumpAndSettle();

          expect(find.text('Sisa poin: 500'), findsOneWidget);

          expect(find.text('Sisa poin: 1000'), findsNothing);
        },
      );

      test('hitung sisa poin clamp tidak boleh negatif', () {
        expect(hitungSisaPoinTest(100, 50), 50);
        expect(hitungSisaPoinTest(50, 100), 0);
      });
    });
  });

  group('Logika Murni - Perhitungan Tanggal Berakhir', () {
    test('harus benar untuk TipeDurasi.HARI', () {
      final startDate = DateTime(2024, 7, 20, 10, 0);
      final paket = PaketModel(
          id: 'd', nama: 'd', harga: 1, durasi: 5, tipe: TipeDurasi.hari);
      final expectedDate = DateTime(2024, 7, 25, 10, 0);

      final result = hitungTanggalBerakhir(startDate, paket);
      expect(result, expectedDate);
    });

    test('harus benar untuk TipeDurasi.BULAN', () {
      final startDate = DateTime(2024, 7, 20, 10, 0);
      final paket = PaketModel(
          id: 'd', nama: 'd', harga: 1, durasi: 2, tipe: TipeDurasi.bulan);
      final expectedDate = Jiffy.parseFromDateTime(startDate).add(months: 2).dateTime;

      final result = hitungTanggalBerakhir(startDate, paket);
      expect(result, expectedDate);
    });

    test('harus benar untuk TipeDurasi.MENIT', () {
      final startDate = DateTime(2024, 7, 20, 10, 0);
      final paket = PaketModel(
          id: 'd', nama: 'd', harga: 1, durasi: 30, tipe: TipeDurasi.menit);
      final expectedDate = DateTime(2024, 7, 20, 10, 30);

      final result = hitungTanggalBerakhir(startDate, paket);
      expect(result, expectedDate);
    });

    test('harus benar untuk TipeDurasi.JAM', () {
      final startDate = DateTime(2024, 7, 20, 10, 0);
      final paket = PaketModel(
          id: 'd', nama: 'd', harga: 1, durasi: 3, tipe: TipeDurasi.jam);
      final expectedDate = DateTime(2024, 7, 20, 13, 0);

      final result = hitungTanggalBerakhir(startDate, paket);
      expect(result, expectedDate);
    });
  });
}
