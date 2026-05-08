// path: test/halaman/form/form_paket_test.dart
// File test untuk halaman form_paket.dart
// diubah: Menerapkan Dependency Injection untuk menguji penanganan error.
// diperbaiki: Menggunakan mock exception class yang benar untuk mensimulasikan error database.
// diperbaiki: Menambahkan implementasi getResultCode yang hilang pada MockDatabaseException.
// diperbaiki: Menggunakan alur pump() yang benar untuk menguji SnackBar sebelum navigasi.

import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/halaman/form/form_paket.dart';
import 'package:admin_wifi/model/paket_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';

import 'form_paket_test.mocks.dart';

// ditambahkan: Kelas mock untuk mensimulasikan DatabaseException
class MockDatabaseException implements DatabaseException {
  @override
  bool isUniqueConstraintError([String? field]) => true;

  @override
  int? getResultCode() => null; // ditambahkan: Implementasi yang hilang

  @override
  dynamic get result => null;

  @override
  String toString() => 'MockDatabaseException: Unique constraint failed';

  @override
  bool isDuplicateColumnError([String? field]) => false;

  @override
  bool isNoSuchTableError([String? table]) => false;

  @override
  bool isNotNullConstraintError([String? field]) => false;

  @override
  bool isSyntaxError() => false;

  @override
  bool isReadOnlyError() => false;

  @override
  bool isDatabaseClosedError() => false;

  @override
  bool isCorruptError() => false;

  @override
  bool isForeignkeyConstraintError([String? field]) => false;

  @override
  bool isOpenFailedError() => false;
}

@GenerateMocks([PaketOperasi])
void main() {
  late MockPaketOperasi mockPaketOperasi;

  final paketDummy = PaketModel(
    id: 'paket-123',
    nama: 'Paket Hemat',
    harga: 50000,
    durasi: 7,
    tipe: TipeDurasi.hari,
    poinHadiah: 100,
    poinPenukaran: 50,
    isPublic: true,
  );

  Widget buildFormPaket({PaketModel? paket}) {
    return MaterialApp(
      home: FormPaket(paket: paket, paketOperasi: mockPaketOperasi),
    );
  }

  setUp(() {
    mockPaketOperasi = MockPaketOperasi();
  });

  group('FormPaket - Inisialisasi', () {
    testWidgets(
      'Mode tambah: field kosong dan AppBar menampilkan "Tambah Paket"',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildFormPaket());
        expect(find.text('Tambah Paket'), findsOneWidget);
        final textFields =
            tester.widgetList<TextFormField>(find.byType(TextFormField));
        for (final field in textFields) {
          expect(field.controller?.text, isEmpty);
        }
      },
    );

    testWidgets(
      'Mode edit: field terisi sesuai data paket yang diberikan',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildFormPaket(paket: paketDummy));
        expect(find.text('Edit Paket'), findsOneWidget);
        expect(find.text('Paket Hemat'), findsOneWidget);
        expect(find.text('50000'), findsOneWidget);
        expect(find.text('7'), findsOneWidget);
        expect(find.text('100'), findsOneWidget);
        expect(find.text('50'), findsOneWidget);
        final switchTile =
            tester.widget<SwitchListTile>(find.byType(SwitchListTile));
        expect(switchTile.value, isTrue);
      },
    );
  });

  group('FormPaket - Validasi', () {
    testWidgets(
      'Validasi gagal jika Nama Paket kosong',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildFormPaket());
        await tester.tap(find.text('Simpan'));
        await tester.pumpAndSettle();
        expect(find.text('Nama paket tidak boleh kosong'), findsOneWidget);
      },
    );
  });

  group('FormPaket - Simpan Data', () {
    testWidgets(
      'Panggil createPaket saat mode tambah dan tampilkan SnackBar',
      (WidgetTester tester) async {
        when(mockPaketOperasi.createPaket(any)).thenAnswer((_) async => '1');

        await tester.pumpWidget(buildFormPaket());

        await tester.enterText(find.byType(TextFormField).at(0), 'Paket Baru');
        await tester.enterText(find.byType(TextFormField).at(1), '10000');
        await tester.enterText(find.byType(TextFormField).at(2), '1');

        await tester.tap(find.text('Simpan'));
        await tester.pump(); // Maju 1 frame untuk menampilkan SnackBar

        verify(mockPaketOperasi.createPaket(any)).called(1);
        expect(find.text('Data paket berhasil disimpan!'), findsOneWidget);

        await tester.pumpAndSettle(); // Selesaikan animasi navigasi
      },
    );

    testWidgets(
      'Panggil updatePaket saat mode edit dan tampilkan SnackBar',
      (WidgetTester tester) async {
        when(mockPaketOperasi.updatePaket(any)).thenAnswer((_) async {});

        await tester.pumpWidget(buildFormPaket(paket: paketDummy));

        await tester.enterText(find.byType(TextFormField).at(0), 'Nama Baru');

        await tester.tap(find.text('Simpan'));
        await tester.pump(); // Maju 1 frame untuk menampilkan SnackBar

        verify(mockPaketOperasi.updatePaket(any)).called(1);
        expect(find.text('Data paket berhasil diperbarui!'), findsOneWidget);

        await tester.pumpAndSettle(); // Selesaikan animasi navigasi
      },
    );
  });

  group('FormPaket - Error Handling', () {
    testWidgets(
      'Menampilkan pesan "Nama paket sudah ada" saat unique constraint error',
      (WidgetTester tester) async {
        when(mockPaketOperasi.createPaket(any))
            .thenThrow(MockDatabaseException());

        await tester.pumpWidget(buildFormPaket());

        await tester.enterText(find.byType(TextFormField).at(0), 'Nama Sama');
        await tester.enterText(find.byType(TextFormField).at(1), '10000');
        await tester.enterText(find.byType(TextFormField).at(2), '1');

        await tester.tap(find.text('Simpan'));
        await tester.pumpAndSettle();

        expect(find.text('Nama paket sudah ada. Harap gunakan nama lain.'),
            findsOneWidget);
      },
    );
  });
}
