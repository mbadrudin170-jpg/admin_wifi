// path: test/halaman/form/form_versi_apk_user_test.dart

import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/halaman/form/form_versi_apk_user.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'form_versi_apk_user_test.mocks.dart';

// Data untuk mode Edit
final dataUntukEdit = VersiApkUserModel(
  id: 'id-edit',
  versiTerbaru: '1.5.0',
  nomorBuildTerbaru: {
    'universal': 15,
    'bit_32': 1532,
    'bit_64': 1564,
  },
  tautanUnduhan: {
    'universal': 'link_universal_lama',
    'bit_32': 'link_32_lama',
    'bit_64': 'link_64_lama',
  },
  catatanRilis: 'Catatan rilis lama',
  wajibUpdate: false,
  youtubeTutorial: 'youtube.com/lama',
);

// Data yang dikembalikan saat form 'Tambah' dibuka
final dataVersiTerakhir = VersiApkUserModel(
  id: 'id-terakhir',
  versiTerbaru: '1.9.9',
  nomorBuildTerbaru: {'universal': 25},
  tautanUnduhan: {},
  catatanRilis: 'Terbaru',
);

@GenerateNiceMocks([
  MockSpec<VersiApkUserOperasi>(),
  MockSpec<NavigatorObserver>(),
])
void main() {
  late MockVersiApkUserOperasi mockOperasi;
  late MockNavigatorObserver mockObserver;

  setUp(() {
    mockOperasi = MockVersiApkUserOperasi();
    mockObserver = MockNavigatorObserver();

    // Stub default untuk pemanggilan API
    when(mockOperasi.perbaruiVersiApkUser(any)).thenAnswer((_) async {});
    when(mockOperasi.tambahVersiApkUser(any)).thenAnswer((_) async {});

    // Stub untuk memuat data di mode 'Tambah'
    when(mockOperasi.ambilVersiApkTerbaru())
        .thenAnswer((_) async => dataVersiTerakhir);
  });

  Widget buatWidgetYangDiuji({VersiApkUserModel? dataEdit}) => MaterialApp(
        home: FormVersiApkUser(
          operasi: mockOperasi,
          versiApkUser: dataEdit,
        ),
        navigatorObservers: [mockObserver],
      );

  group('Pengujian FormVersiApkUser dengan Dialog Konfirmasi', () {
    testWidgets('1. Mode Tambah: Harus memuat data dari `ambilVersiApkTerbaru`',
        (tester) async {
      await tester.pumpWidget(buatWidgetYangDiuji());
      await tester.pumpAndSettle(); // Tunggu loading selesai

      verify(mockOperasi.ambilVersiApkTerbaru()).called(1);
      expect(find.widgetWithText(TextFormField, '1.9.9'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '26'), findsOneWidget);
    });

    testWidgets('2. Mode Edit: Harus mengisi semua field dari data yang ada',
        (tester) async {
      await tester.pumpWidget(buatWidgetYangDiuji(dataEdit: dataUntukEdit));
      await tester.pumpAndSettle();

      verifyNever(mockOperasi.ambilVersiApkTerbaru());

      expect(find.widgetWithText(TextFormField, '1.5.0'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '15'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '1532'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '1564'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'link_universal_lama'),
          findsOneWidget);
      expect(
          find.widgetWithText(TextFormField, 'link_32_lama'), findsOneWidget);
      expect(
          find.widgetWithText(TextFormField, 'link_64_lama'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Catatan rilis lama'),
          findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'youtube.com/lama'),
          findsOneWidget);
    });

    testWidgets('3. Simpan (Mode Edit): Konfirmasi `Ya` harus menyimpan data',
        (tester) async {
      await tester.pumpWidget(buatWidgetYangDiuji(dataEdit: dataUntukEdit));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, '15'), '16');
      
      // diubah: Scroll ke tombol sebelum menekannya
      final saveButton = find.widgetWithText(ElevatedButton, 'Simpan');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle(); // Munculkan dialog

      // Konfirmasi dialog
      expect(find.text('Apakah semua data yang Anda masukkan sudah benar?'),
          findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Ya'));
      await tester.pumpAndSettle(); // Selesaikan proses simpan

      final captured =
          verify(mockOperasi.perbaruiVersiApkUser(captureAny)).captured;
      expect(captured.first.nomorBuildTerbaru['universal'], 16);
      verify(mockObserver.didPop(any, any)).called(1);
    });

    testWidgets('4. Simpan (Mode Tambah): Konfirmasi `Ya` harus menyimpan data',
        (tester) async {
      await tester.pumpWidget(buatWidgetYangDiuji());
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, '1.9.9'), '2.0.0');
      
      // diubah: Scroll ke tombol sebelum menekannya
      final saveButton = find.widgetWithText(ElevatedButton, 'Simpan');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Ya'));
      await tester.pumpAndSettle();

      final captured =
          verify(mockOperasi.tambahVersiApkUser(captureAny)).captured;
      expect(captured.first.versiTerbaru, '2.0.0');
      verify(mockObserver.didPop(any, any)).called(1);
    });

    testWidgets('5. Simpan: Konfirmasi `Tidak` tidak boleh menyimpan data',
        (tester) async {
      await tester.pumpWidget(buatWidgetYangDiuji(dataEdit: dataUntukEdit));
      await tester.pumpAndSettle();

      // diubah: Scroll ke tombol sebelum menekannya
      final saveButton = find.widgetWithText(ElevatedButton, 'Simpan');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Tolak konfirmasi
      await tester.tap(find.widgetWithText(TextButton, 'Tidak'));
      await tester.pumpAndSettle();

      // Verifikasi tidak ada data yang disimpan
      verifyNever(mockOperasi.perbaruiVersiApkUser(any));
      verifyNever(mockOperasi.tambahVersiApkUser(any));
      // Verifikasi navigator tidak di-pop
      verifyNever(mockObserver.didPop(any, any));
    });

    testWidgets('6. UI: Tombol simpan harus ada di bawah form', (tester) async {
      await tester.pumpWidget(buatWidgetYangDiuji());
      
      final saveButton = find.widgetWithText(ElevatedButton, 'Simpan');
      // diubah: Scroll untuk memastikan tombol terlihat
      await tester.ensureVisible(saveButton);
      expect(saveButton, findsOneWidget);

      // Pastikan tidak ada tombol simpan di AppBar
      expect(
          find.descendant(
              of: find.byType(AppBar),
              matching: find.byIcon(Icons.save)),
          findsNothing);
    });
  });
}
