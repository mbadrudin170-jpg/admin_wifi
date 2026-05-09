// path: test/halaman/tab/transaksi_test.dart
// diubah: Menghapus parameter namaDompet dan namaKategori yang sudah usang dari fungsi helper.

import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/halaman/tab/transaksi.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';

import 'transaksi_test.mocks.dart';

TransaksiModel buatTransaksi({
  required String id,
  required String keterangan,
  required double jumlah,
  required TipeTransaksi tipe,
  required DateTime tanggal,
}) {
  return TransaksiModel(
    id: id,
    keterangan: keterangan,
    jumlah: jumlah,
    tipe: tipe,
    idDompet: 'dompet-1',
    idKategori: 'kat-1',
    tanggal: tanggal,
  );
}

@GenerateNiceMocks([
  MockSpec<TransaksiOperasi>(),
  MockSpec<NavigatorObserver>(),
])
void main() {
  late MockTransaksiOperasi mockTransaksiOperasi;
  late MockNavigatorObserver mockNavigatorObserver;

  final pemasukan1 = buatTransaksi(
    id: '1',
    keterangan: 'Gaji Mei',
    jumlah: 100000,
    tipe: TipeTransaksi.pemasukan,
    tanggal: DateTime(2026, 5, 5, 9, 0),
  );
  final pengeluaran1 = buatTransaksi(
    id: '2',
    keterangan: 'Beli Kopi',
    jumlah: 25000,
    tipe: TipeTransaksi.pengeluaran,
    tanggal: DateTime(2026, 5, 5, 15, 30),
  );
  final pemasukan2 = buatTransaksi(
    id: '3',
    keterangan: 'Bonus Proyek',
    jumlah: 75000,
    tipe: TipeTransaksi.pemasukan,
    tanggal: DateTime(2026, 5, 6, 11, 0),
  );

  final semuaTransaksi = [pemasukan1, pengeluaran1, pemasukan2];

  setUpAll(() {
    initializeDateFormatting('id_ID');
  });

  setUp(() {
    mockTransaksiOperasi = MockTransaksiOperasi();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Future<void> pumpTransaksiPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TransaksiPage(transaksiOperasi: mockTransaksiOperasi),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('TransaksiPage Widget Tests', () {
    testWidgets('menampilkan CircularProgressIndicator saat loading', (
      tester,
    ) async {
      when(mockTransaksiOperasi.ambilSemuaTransaksi()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return [];
      });
      when(mockTransaksiOperasi.getTotalPemasukan()).thenAnswer((_) async => 0);
      when(
        mockTransaksiOperasi.getTotalPengeluaran(),
      ).thenAnswer((_) async => 0);
      when(mockTransaksiOperasi.getNetTotal()).thenAnswer((_) async => 0);

      await pumpTransaksiPage(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('menampilkan pesan error saat terjadi kegagalan', (
      tester,
    ) async {
      when(
        mockTransaksiOperasi.ambilSemuaTransaksi(),
      ).thenThrow(Exception('Database Error'));
      when(mockTransaksiOperasi.getTotalPemasukan()).thenAnswer((_) async => 0);
      when(
        mockTransaksiOperasi.getTotalPengeluaran(),
      ).thenAnswer((_) async => 0);
      when(mockTransaksiOperasi.getNetTotal()).thenAnswer((_) async => 0);

      await pumpTransaksiPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('Error: Exception: Database Error'), findsOneWidget);
    });

    testWidgets('menampilkan pesan saat tidak ada transaksi', (tester) async {
      when(
        mockTransaksiOperasi.ambilSemuaTransaksi(),
      ).thenAnswer((_) async => []);
      when(mockTransaksiOperasi.getTotalPemasukan()).thenAnswer((_) async => 0);
      when(
        mockTransaksiOperasi.getTotalPengeluaran(),
      ).thenAnswer((_) async => 0);
      when(mockTransaksiOperasi.getNetTotal()).thenAnswer((_) async => 0);

      await pumpTransaksiPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada transaksi ditemukan.'), findsOneWidget);
    });

    testWidgets(
      'menampilkan data ringkasan dan daftar transaksi dengan benar saat sukses',
      (tester) async {
        when(
          mockTransaksiOperasi.ambilSemuaTransaksi(),
        ).thenAnswer((_) async => semuaTransaksi);
        when(
          mockTransaksiOperasi.getTotalPemasukan(),
        ).thenAnswer((_) async => 175000);
        when(
          mockTransaksiOperasi.getTotalPengeluaran(),
        ).thenAnswer((_) async => 25000);
        when(
          mockTransaksiOperasi.getNetTotal(),
        ).thenAnswer((_) async => 150000);

        await pumpTransaksiPage(tester);
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('Pemasukan')), findsOneWidget);
        expect(find.byKey(const ValueKey('Pengeluaran')), findsOneWidget);
        expect(find.byKey(const ValueKey('Total')), findsOneWidget);

        final item1Finder = find.byKey(const ValueKey('3'));
        expect(item1Finder, findsOneWidget);
        expect(
          find.descendant(of: item1Finder, matching: find.text('Bonus Proyek')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: item1Finder, matching: find.text('Rp 75.000')),
          findsOneWidget,
        );

        final item2Finder = find.byKey(const ValueKey('1'));
        expect(item2Finder, findsOneWidget);
        expect(
          find.descendant(of: item2Finder, matching: find.text('Gaji Mei')),
          findsOneWidget,
        );

        final item3Finder = find.byKey(const ValueKey('2'));
        expect(item3Finder, findsOneWidget);
        expect(
          find.descendant(of: item3Finder, matching: find.text('Beli Kopi')),
          findsOneWidget,
        );
      },
    );

    testWidgets('menavigasi ke DetailTransaksiPage saat item di-tap', (
      tester,
    ) async {
      when(
        mockTransaksiOperasi.ambilSemuaTransaksi(),
      ).thenAnswer((_) async => semuaTransaksi);
      when(
        mockTransaksiOperasi.getTotalPemasukan(),
      ).thenAnswer((_) async => 175000);
      when(
        mockTransaksiOperasi.getTotalPengeluaran(),
      ).thenAnswer((_) async => 25000);
      when(mockTransaksiOperasi.getNetTotal()).thenAnswer((_) async => 150000);

      await pumpTransaksiPage(tester);
      await tester.pumpAndSettle();

      clearInteractions(mockNavigatorObserver);

      final itemToTap = find.byKey(const ValueKey('2'));
      expect(itemToTap, findsOneWidget);
      await tester.tap(itemToTap);
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any)).called(1);
    });
  });
}
