// path: test/halaman/detail/detail_dompet_test.dart
// diubah: Menambahkan fakeAsync untuk mengatasi masalah Timer yang masih tertunda.

import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/halaman/detail/detail_dompet.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/transaksi_model.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'detail_dompet_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<TransaksiOperasi>(),
  MockSpec<DompetOperasi>(),
  MockSpec<NavigatorObserver>(),
])
void main() {
  late MockTransaksiOperasi mockTransaksiOperasi;
  late MockDompetOperasi mockDompetOperasi;
  late MockNavigatorObserver mockNavigatorObserver;

  final dompet = DompetModel(
    id: '1',
    namaDompet: 'Dompet Utama',
    saldo: 125000,
  );
  final transaksiList = [
    TransaksiModel(
      id: 't1',
      keterangan: 'Gaji',
      jumlah: 100000,
      tipe: TipeTransaksi.pemasukan,
      idDompet: '1',
      tanggal: DateTime(2023, 1, 1),
      idKategori: '',
    ),
    TransaksiModel(
      id: 't2',
      keterangan: 'Beli Kopi',
      jumlah: 25000,
      tipe: TipeTransaksi.pengeluaran,
      idDompet: '1',
      tanggal: DateTime(2023, 1, 2),
      idKategori: '',
      isDeleted: false,
    ),
  ];

  setUpAll(() {
    initializeDateFormatting('id_ID', null);
  });

  setUp(() {
    mockTransaksiOperasi = MockTransaksiOperasi();
    mockDompetOperasi = MockDompetOperasi();
    mockNavigatorObserver = MockNavigatorObserver();

    when(
      mockTransaksiOperasi.ambilTransaksiByDompetId(any),
    ).thenAnswer((_) async => transaksiList);
    when(mockDompetOperasi.getDompetById(any)).thenAnswer((_) async => dompet);
  });

  Future<void> pumpDetailDompet(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DetailDompet(
          dompet: dompet,
          transaksiOperasi: mockTransaksiOperasi,
          dompetOperasi: mockDompetOperasi,
        ),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
    await tester.pumpAndSettle();
  }

  group('DetailDompet Widget Test', () {
    group('1. Ringkasan Saldo Dompet', () {
      testWidgets(
        '1.1 menampilkan total saldo pemasukan',
        (WidgetTester tester) async {
          await pumpDetailDompet(tester);
          expect(find.byKey(const Key('totalPemasukan')), findsOneWidget);
          expect(find.text('Rp 100.000'), findsWidgets);
        },
      );
      testWidgets(
        '1.2 menampilkan total saldo pengeluaran',
        (WidgetTester tester) async {
          await pumpDetailDompet(tester);
          expect(find.byKey(const Key('totalPengeluaran')), findsOneWidget);
          expect(find.text('Rp 25.000'), findsWidgets);
        },
      );
      testWidgets(
        '1.3 menampilkan total saldo',
        (WidgetTester tester) async {
          await pumpDetailDompet(tester);
          expect(find.byKey(const Key('totalSaldo')), findsOneWidget);
          expect(find.text('Rp 125.000'), findsWidgets);
        },
      );
    });

    testWidgets('2. Harus menampilkan data dompet awal dengan benar', (
      WidgetTester tester,
    ) async {
      await pumpDetailDompet(tester);
      final appBarFinder = find.byKey(const Key('appBar'));
      expect(
        find.descendant(of: appBarFinder, matching: find.text('Dompet Utama')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('totalSaldo')), findsOneWidget);
    });

    testWidgets('3. Harus menampilkan tombol edit dan bisa ditekan', (
      WidgetTester tester,
    ) async {
      await pumpDetailDompet(tester);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      verify(mockNavigatorObserver.didPush(any, any));
    });

    testWidgets('4. Harus tetap stabil saat navigasi edit dipanggil', (
      WidgetTester tester,
    ) async {
      await pumpDetailDompet(tester);
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      verify(mockNavigatorObserver.didPush(any, any));
    });
  });

  group('Riwayat transaksi dompet', () {
    testWidgets('5. harus menampilkan riwayat transaksi', (
      WidgetTester tester,
    ) async {
      await pumpDetailDompet(tester);
      expect(find.text('Gaji'), findsOneWidget);
      expect(find.text('Beli Kopi'), findsOneWidget);
    });

    testWidgets(
      '6. harus menuju ke halaman detail transaksi saat item ditekan',
      (WidgetTester tester) async {
        await pumpDetailDompet(tester);
        await tester.tap(find.text('Gaji'));
        await tester.pumpAndSettle();
        verify(mockNavigatorObserver.didPush(any, any));
      },
    );

    testWidgets('7. harus menampilkan dialog saat item ditekan lama', (
      WidgetTester tester,
    ) async {
      await pumpDetailDompet(tester);
      await tester.longPress(find.text('Beli Kopi'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
    });

    group('Dialog Opsi', () {
      testWidgets('8. tombol hapus harus memanggil fungsi arsipkanTransaksi', (
        WidgetTester tester,
      ) {
        fakeAsync((async) async {
          when(
            mockTransaksiOperasi.arsipkanTransaksi('t2'),
          ).thenAnswer((_) async {});

          await pumpDetailDompet(tester);
          expect(
            find.text('Beli Kopi'),
            findsOneWidget,
          );

          await tester.longPress(find.text('Beli Kopi'));
          await tester.pumpAndSettle();
          expect(find.byType(AlertDialog), findsOneWidget);

          when(
            mockTransaksiOperasi.ambilTransaksiByDompetId('1'),
          ).thenAnswer((_) async => [transaksiList[0]]);
          when(mockDompetOperasi.getDompetById('1')).thenAnswer(
            (_) async =>
                DompetModel(id: '1', namaDompet: 'Dompet Utama', saldo: 100000),
          );

          await tester.tap(find.text('Hapus'));
          await tester.pumpAndSettle();

          async.flushMicrotasks();

          verify(mockTransaksiOperasi.arsipkanTransaksi('t2')).called(1);
          expect(
            find.byType(AlertDialog),
            findsNothing,
          );
          expect(
            find.text('Beli Kopi'),
            findsNothing,
          );

          final totalSaldoTextWidget = tester.widget<Text>(
            find.byKey(const Key('totalSaldo')),
          );
          expect(
            totalSaldoTextWidget.data,
            'Rp 100.000',
          );
        });
      });
    });
  });
}
