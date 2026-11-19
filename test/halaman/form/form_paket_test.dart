// path: test/halaman/form/form_paket_test.dart
// diubah: Menghapus pengujian untuk field `jumlahPoin` yang sudah tidak ada dan menambahkan pengujian untuk `poinHadiah` dan `poinPenukaran`.

import 'package:admin_wifi/fitur/paket/notifier/paket_notifier.dart';
import 'package:admin_wifi/fitur/paket/screens/form_paket.dart';
import 'package:admin_wifi/fitur/paket/model/paket_model.dart';
import 'package:admin_wifi/fitur/paket/state/paket_state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common/sqlite_api.dart' as sqlite_api;

import '../../mocks.dart';

// [Mocks and helper classes remain the same]
class MockDatabaseException implements sqlite_api.DatabaseException {
  final String message;
  @override
  final dynamic result;

  MockDatabaseException(this.message, {this.result});

  factory MockDatabaseException.uniqueConstraint() {
    return MockDatabaseException(
      'DatabaseException(SQLiteException: UNIQUE constraint failed: paket.nama (code 1555))',
    );
  }

  @override
  bool isUniqueConstraintError([String? field]) {
    return message.contains('UNIQUE constraint failed');
  }

  @override
  bool isDuplicateColumnError([String? field]) => false;

  @override
  bool isNoSuchTableError([String? table]) => false;

  @override
  bool isNotNullConstraintError([String? field]) => false;

  @override
  bool isSyntaxError() => false;

  @override
  int? getResultCode() => null;

  @override
  bool isDatabaseClosedError() => false;

  @override
  bool isOpenFailedError() => false;

  @override
  bool isReadOnlyError() => false;
}

class FakePaketNotifier extends PaketNotifier {
  FakePaketNotifier(this.mockPaketOperasi);

  final MockPaketOperasi mockPaketOperasi;

  @override
  Future<PaketState> build() async => const PaketState();

  @override
  Future<void> tambah(PaketModel model) async {
    await mockPaketOperasi.createPaket(model);
  }

  @override
  Future<void> ubah(PaketModel model) async {
    await mockPaketOperasi.updatePaket(model);
  }
}

void main() {
  late MockPaketOperasi mockPaketOperasi;
  late FakePaketNotifier fakePaketNotifier;

  // diubah: paketDummy diperbarui untuk menggunakan field poin yang relevan.
  final paketDummy = PaketModel(
    id: 'paket-123',
    nama: 'Paket Hemat',
    harga: 50000,
    durasi: 7,
    tipe: TipeDurasi.hari,
    poinHadiah: 150,
    poinPenukaran: 20,
    isPublic: true,
  );

  Widget buildFormPaket({PaketModel? paket}) {
    return ProviderScope(
      overrides: [paketProvider.overrideWith(() => fakePaketNotifier)],
      child: MaterialApp(home: FormPaket(paket: paket)),
    );
  }

  setUp(() {
    mockPaketOperasi = MockPaketOperasi();
    fakePaketNotifier = FakePaketNotifier(mockPaketOperasi);
    registerFallbackValue(paketDummy);
  });

  group('FormPaket - Inisialisasi', () {
    testWidgets(
      'Mode tambah: field kosong dan AppBar menampilkan "Tambah Paket"',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildFormPaket());
        expect(find.text('Tambah Paket'), findsOneWidget);
        final textFields = tester.widgetList<TextFormField>(
          find.byType(TextFormField),
        );
        for (final field in textFields) {
          expect(field.controller?.text, isEmpty);
        }
      },
    );

    testWidgets('Mode edit: field terisi sesuai data paket yang diberikan', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildFormPaket(paket: paketDummy));
      expect(find.text('Edit Paket'), findsOneWidget);
      expect(find.text('Paket Hemat'), findsOneWidget);
      expect(find.text('50000'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      // diubah: Pengujian untuk `jumlahPoin` yang sudah legacy dihapus.
      // ditambahkan: Pengujian untuk field `poinHadiah` dan `poinPenukaran`.
      expect(find.text('150'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);

      final switchTile = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switchTile.value, isTrue);
    });
  });

  group('FormPaket - Validasi', () {
    testWidgets('Validasi gagal jika Nama Paket kosong', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildFormPaket());
      await tester.ensureVisible(find.text('Simpan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
      expect(find.text('Nama paket tidak boleh kosong'), findsOneWidget);
    });
  });

  group('FormPaket - Simpan Data', () {
    testWidgets('Panggil createPaket saat mode tambah dan tampilkan SnackBar', (
      WidgetTester tester,
    ) async {
      when(
        () => mockPaketOperasi.createPaket(any()),
      ).thenAnswer((_) async => paketDummy);

      await tester.pumpWidget(buildFormPaket());

      await tester.enterText(find.byType(TextFormField).at(0), 'Paket Baru');
      await tester.enterText(find.byType(TextFormField).at(1), '10000');
      await tester.enterText(find.byType(TextFormField).at(2), '1');
      await tester.enterText(
        find.byType(TextFormField).at(3),
        '50',
      ); // Poin Hadiah
      await tester.enterText(
        find.byType(TextFormField).at(4),
        '10',
      ); // Poin Penukaran

      await tester.ensureVisible(find.text('Simpan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      verify(() => mockPaketOperasi.createPaket(any())).called(1);
      expect(find.text('Data paket berhasil disimpan!'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('Panggil updatePaket saat mode edit dan tampilkan SnackBar', (
      WidgetTester tester,
    ) async {
      when(
        () => mockPaketOperasi.updatePaket(any()),
      ).thenAnswer((_) async => Future.value());

      await tester.pumpWidget(buildFormPaket(paket: paketDummy));

      await tester.enterText(find.byType(TextFormField).at(0), 'Nama Baru');

      await tester.ensureVisible(find.text('Simpan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      verify(() => mockPaketOperasi.updatePaket(any())).called(1);
      expect(find.text('Data paket berhasil diperbarui!'), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });

  group('FormPaket - Error Handling', () {
    testWidgets(
      'Menampilkan pesan "Nama paket sudah ada" saat unique constraint error',
      (WidgetTester tester) async {
        when(
          () => mockPaketOperasi.createPaket(any()),
        ).thenThrow(MockDatabaseException.uniqueConstraint());

        await tester.pumpWidget(buildFormPaket());

        await tester.enterText(find.byType(TextFormField).at(0), 'Nama Sama');
        await tester.enterText(find.byType(TextFormField).at(1), '10000');
        await tester.enterText(find.byType(TextFormField).at(2), '1');
        await tester.enterText(find.byType(TextFormField).at(3), '50');
        await tester.enterText(find.byType(TextFormField).at(4), '10');

        await tester.ensureVisible(find.text('Simpan'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Simpan'));
        await tester.pumpAndSettle();

        expect(
          find.text('Nama paket sudah ada. Harap gunakan nama lain.'),
          findsOneWidget,
        );
      },
    );
  });
}
