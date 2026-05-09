// path: test/halaman/form/form_versi_apk_user_test.dart

import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/halaman/form/form_versi_apk_user.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:admin_wifi/enum/enum.dart';

import 'form_versi_apk_user_test.mocks.dart';

// ✅ DIPERBAIKI: Gunakan ArsitekturApkEnum sebagai key
final dataUntukEdit = VersiApkUserModel(
  id: 'id-edit',
  versiTerbaru: '1.5.0',
  nomorBuildTerbaru: {
    ArsitekturApkEnum.universal: 15,
    ArsitekturApkEnum.bit_32: 1532,
    ArsitekturApkEnum.bit_64: 1564,
  },
  tautanUnduhan: {
    ArsitekturApkEnum.universal: 'link_universal_lama',
    ArsitekturApkEnum.bit_32: 'link_32_lama',
    ArsitekturApkEnum.bit_64: 'link_64_lama',
  },
  catatanRilis: 'Catatan rilis lama',
  wajibUpdate: false,
  youtubeTutorial: 'youtube.com/lama',
);

// ✅ DIPERBAIKI: Gunakan ArsitekturApkEnum sebagai key
final dataVersiTerakhir = VersiApkUserModel(
  id: 'id-terakhir',
  versiTerbaru: '1.9.9',
  nomorBuildTerbaru: {
    ArsitekturApkEnum.universal: 25,
    ArsitekturApkEnum.bit_32: 0,
    ArsitekturApkEnum.bit_64: 0,
  },
  tautanUnduhan: {
    ArsitekturApkEnum.universal: '',
    ArsitekturApkEnum.bit_32: '',
    ArsitekturApkEnum.bit_64: '',
  },
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
    when(
      mockOperasi.ambilVersiApkTerbaru(),
    ).thenAnswer((_) async => dataVersiTerakhir);
  });

  Widget buatWidgetYangDiuji({VersiApkUserModel? dataEdit}) => MaterialApp(
    home: FormVersiApkUser(operasi: mockOperasi, versiApkUser: dataEdit),
    navigatorObservers: [mockObserver],
  );

  group('Pengujian FormVersiApkUser dengan Dialog Konfirmasi', () {
    testWidgets(
      '1. Mode Tambah: Harus memuat data dari `ambilVersiApkTerbaru` dengan build +1',
      (tester) async {
        await tester.pumpWidget(buatWidgetYangDiuji());
        await tester.pumpAndSettle();

        // Verifikasi API dipanggil
        verify(mockOperasi.ambilVersiApkTerbaru()).called(1);

        // Verifikasi field terisi dari data versi terakhir
        expect(find.widgetWithText(TextFormField, '1.9.9'), findsOneWidget);

        // ✅ Build universal harus 26 (25 + 1)
        expect(find.widgetWithText(TextFormField, '26'), findsOneWidget);
      },
    );

    testWidgets('2. Mode Edit: Harus mengisi semua field dari data yang ada', (
      tester,
    ) async {
      await tester.pumpWidget(buatWidgetYangDiuji(dataEdit: dataUntukEdit));
      await tester.pumpAndSettle();

      // Verifikasi API tidak dipanggil di mode edit
      verifyNever(mockOperasi.ambilVersiApkTerbaru());

      // Verifikasi semua field terisi dengan benar
      expect(find.widgetWithText(TextFormField, '1.5.0'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '15'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '1532'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '1564'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'link_universal_lama'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, 'link_32_lama'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, 'link_64_lama'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, 'Catatan rilis lama'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, 'youtube.com/lama'),
        findsOneWidget,
      );
    });

    testWidgets('3. Simpan (Mode Edit): Konfirmasi `Ya` harus menyimpan data', (
      tester,
    ) async {
      await tester.pumpWidget(buatWidgetYangDiuji(dataEdit: dataUntukEdit));
      await tester.pumpAndSettle();

      // Ubah nilai build universal
      await tester.enterText(find.widgetWithText(TextFormField, '15'), '16');
      await tester.pump();

      // Tekan tombol Simpan
      final saveButton = find.widgetWithText(ElevatedButton, 'Simpan');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verifikasi dialog konfirmasi muncul
      expect(
        find.text('Apakah semua data yang Anda masukkan sudah benar?'),
        findsOneWidget,
      );

      // Konfirmasi Ya
      await tester.tap(find.widgetWithText(TextButton, 'Ya'));
      await tester.pumpAndSettle();

      // ✅ DIPERBAIKI: Verifikasi captured dengan ArsitekturApkEnum
      final captured = verify(
        mockOperasi.perbaruiVersiApkUser(captureAny),
      ).captured;
      expect(captured.first.nomorBuildTerbaru[ArsitekturApkEnum.universal], 16);

      // Verifikasi navigasi pop (dialog + form)
      verify(mockObserver.didPop(any, any)).called(2);
    });

    testWidgets(
      '4. Simpan (Mode Tambah): Konfirmasi `Ya` harus menyimpan data',
      (tester) async {
        await tester.pumpWidget(buatWidgetYangDiuji());
        await tester.pumpAndSettle();

        // Ubah versi
        await tester.enterText(
          find.widgetWithText(TextFormField, '1.9.9'),
          '2.0.0',
        );
        // Isi field Catatan Rilis yang wajib
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Catatan Rilis'),
          'Rilis baru!',
        );
        await tester.pump();

        // Tekan tombol Simpan
        final saveButton = find.widgetWithText(ElevatedButton, 'Simpan');
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Verifikasi dialog konfirmasi muncul
        expect(
          find.text('Apakah semua data yang Anda masukkan sudah benar?'),
          findsOneWidget,
        );

        // Konfirmasi Ya
        await tester.tap(find.widgetWithText(TextButton, 'Ya'));
        await tester.pumpAndSettle();

        // Verifikasi data tersimpan
        final captured = verify(
          mockOperasi.tambahVersiApkUser(captureAny),
        ).captured;
        expect(captured.first.versiTerbaru, '2.0.0');
        expect(captured.first.catatanRilis, 'Rilis baru!');

        // ✅ DIPERBAIKI: Verifikasi build universal adalah 26 (25 + 1)
        expect(
          captured.first.nomorBuildTerbaru[ArsitekturApkEnum.universal],
          26,
        );

        // Verifikasi navigasi pop (dialog + form)
        verify(mockObserver.didPop(any, any)).called(2);
      },
    );

    testWidgets('5. Simpan: Konfirmasi `Tidak` tidak boleh menyimpan data', (
      tester,
    ) async {
      await tester.pumpWidget(buatWidgetYangDiuji(dataEdit: dataUntukEdit));
      await tester.pumpAndSettle();

      // Tekan tombol Simpan tanpa ubah data
      final saveButton = find.widgetWithText(ElevatedButton, 'Simpan');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Konfirmasi Tidak
      await tester.tap(find.widgetWithText(TextButton, 'Tidak'));
      await tester.pumpAndSettle();

      // Verifikasi tidak ada operasi yang dipanggil
      verifyNever(mockOperasi.perbaruiVersiApkUser(any));
      verifyNever(mockOperasi.tambahVersiApkUser(any));

      // Verifikasi hanya dialog yang di-pop
      verify(mockObserver.didPop(any, any)).called(1);
    });

    testWidgets('6. UI: Tombol simpan harus ada di bawah form', (tester) async {
      await tester.pumpWidget(buatWidgetYangDiuji());
      await tester.pumpAndSettle();

      // Verifikasi tombol Simpan ada dan terlihat
      final saveButton = find.widgetWithText(ElevatedButton, 'Simpan');
      await tester.ensureVisible(saveButton);
      expect(saveButton, findsOneWidget);

      // Verifikasi tidak ada tombol simpan di AppBar
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.save),
        ),
        findsNothing,
      );
    });
  });
}
