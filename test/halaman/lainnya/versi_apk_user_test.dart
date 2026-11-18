// path: test/halaman/lainnya/versi_apk_user_test.dart
// diubah: keseluruhan file untuk memperbaiki logika mock, interaksi UI, dan validasi pengujian.
// ditambahkan: `ensureVisible` untuk memastikan tombol terlihat sebelum ditekan.
// ditambahkan: Memperbarui catatan rilis di pengujian edit untuk validasi yang akurat.
// diperbaiki: Kompatibilitas dengan model VersiApkUserModel terbaru (ArsitekturApkEnum)

import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/fitur/versi_apk_user/screens/detail_versi_apk_user.dart';
import 'package:admin_wifi/fitur/versi_apk_user/screens/form_versi_apk_user.dart';
import 'package:admin_wifi/fitur/versi_apk_user/screens/versi_apk_user.dart';
import 'package:admin_wifi/fitur/versi_apk_user/model/versi_apk_user_model.dart';
import 'package:admin_wifi/enum/arsitektur_apk_enum.dart'; // ✅ Tambahan import
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import 'versi_apk_user_test.mocks.dart';

// ✅ DIPERBAIKI: Fungsi helper menggunakan ArsitekturApkEnum sebagai key
VersiApkUserModel _buatModel({
  String? id,
  String versi = '1.0.0',
  int buildNumber = 1,
  DateTime? diperbarui,
}) {
  return VersiApkUserModel(
    id: id ?? const Uuid().v4(),
    versiTerbaru: versi,
    nomorBuildTerbaru: {
      ArsitekturApkEnum.universal: buildNumber, // ✅ Gunakan enum
      ArsitekturApkEnum.bit_32: 0,
      ArsitekturApkEnum.bit_64: 0,
    },
    catatanRilis: 'Rilis $versi build $buildNumber',
    diperbarui: diperbarui ?? DateTime.now(),
  );
}

@GenerateMocks([VersiApkUserOperasi])
void main() {
  late MockVersiApkUserOperasi mockOperasi;
  late List<VersiApkUserModel> dataLokal;

  // Inisialisasi mock dan data sebelum setiap tes
  setUp(() {
    mockOperasi = MockVersiApkUserOperasi();
    dataLokal = [
      _buatModel(
        id: 'id-10',
        versi: '1.2.0',
        buildNumber: 10,
        diperbarui: DateTime(2023, 10, 1),
      ),
      _buatModel(
        id: 'id-5',
        versi: '1.0.0',
        buildNumber: 5,
        diperbarui: DateTime(2023, 5, 1),
      ),
    ];

    // Konfigurasi mock untuk `ambilSemuaVersiApkAktif`
    when(mockOperasi.ambilSemuaVersiApkAktif()).thenAnswer((_) async {
      return List<VersiApkUserModel>.from(dataLokal);
    });

    // Konfigurasi mock untuk `arsipkanVersiApkUser`
    when(mockOperasi.arsipkanVersiApkUser(any)).thenAnswer((invocation) async {
      final id = invocation.positionalArguments.first;
      dataLokal.removeWhere((item) => item.id == id);
    });

    // Konfigurasi mock untuk `perbaruiVersiApkUser`
    when(mockOperasi.perbaruiVersiApkUser(any)).thenAnswer((invocation) async {
      final versiDiperbarui =
          invocation.positionalArguments.first as VersiApkUserModel;
      final index = dataLokal.indexWhere((v) => v.id == versiDiperbarui.id);
      if (index != -1) {
        dataLokal[index] = versiDiperbarui;
      }
    });

    // Konfigurasi mock untuk `tambahVersiApkUser`
    when(mockOperasi.tambahVersiApkUser(any)).thenAnswer((invocation) async {
      final versiBaru =
          invocation.positionalArguments.first as VersiApkUserModel;
      dataLokal.add(versiBaru);
    });

    // Konfigurasi mock untuk `ambilVersiApkTerbaru` untuk halaman tambah
    when(mockOperasi.ambilVersiApkTerbaru()).thenAnswer((_) async {
      if (dataLokal.isEmpty) return null;
      dataLokal.sort((a, b) => b.diperbarui!.compareTo(a.diperbarui!));
      return dataLokal.first;
    });
  });

  // ✅ DIPERBAIKI: Widget builder dengan rute yang tepat
  Widget buatWidgetYangDiuji() => MaterialApp(
    home: VersiApkUserPage(operasi: mockOperasi),
    routes: {
      // Rute tidak diperlukan karena navigasi menggunakan MaterialPageRoute langsung
    },
  );

  group('Pengujian Lengkap Halaman VersiApkUserPage', () {
    testWidgets('1. Menampilkan data & urutan default (terbaru) dengan benar', (
      tester,
    ) async {
      await tester.pumpWidget(buatWidgetYangDiuji());
      await tester.pumpAndSettle();

      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      expect(listTiles, hasLength(2));
      // ✅ Data teratas harus yang terbaru (build 10)
      expect((listTiles.first.title as Text).data, contains('Build: 10'));
    });

    testWidgets('2. Fitur urutkan (Build Terbaru & Terlama) berfungsi', (
      tester,
    ) async {
      await tester.pumpWidget(buatWidgetYangDiuji());
      await tester.pumpAndSettle();

      // Urutan awal: 1.2.0 (10), 1.0.0 (5)
      var listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      expect((listTiles.first.title as Text).data, contains('Build: 10'));

      // Buka dialog urutkan
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // Pilih urutan build terlama ke terbaru
      await tester.tap(find.text('Build (Terlama ke Terbaru)'));
      await tester.pumpAndSettle();

      // Tekan OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verifikasi urutan baru: 1.0.0 (5), 1.2.0 (10)
      listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      expect((listTiles.first.title as Text).data, contains('Build: 5'));
    });

    testWidgets('3. Navigasi ke halaman detail saat item ditekan', (
      tester,
    ) async {
      await tester.pumpWidget(buatWidgetYangDiuji());
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Build: 10'));
      await tester.pumpAndSettle();

      expect(find.byType(DetailVersiApkUser), findsOneWidget);
    });

    testWidgets('4. Alur arsip menghapus item dari UI secara langsung', (
      tester,
    ) async {
      await tester.pumpWidget(buatWidgetYangDiuji());
      await tester.pumpAndSettle();

      // Tekan lama untuk memunculkan opsi
      await tester.longPress(find.textContaining('Build: 10'));
      await tester.pumpAndSettle();
      // Pilih opsi 'Arsipkan'
      await tester.tap(find.text('Arsipkan'));
      await tester.pumpAndSettle();
      // Konfirmasi di dialog
      await tester.tap(find.widgetWithText(TextButton, 'Arsipkan'));
      await tester.pumpAndSettle();

      // Verifikasi bahwa operasi dipanggil dan UI diperbarui
      verify(mockOperasi.arsipkanVersiApkUser('id-10')).called(1);
      expect(find.textContaining('Build: 10'), findsNothing);
      expect(find.byType(ListTile), findsOneWidget); // Harusnya sisa 1 item
    });

    testWidgets('5. Alur edit memperbarui UI tanpa reload', (tester) async {
      await tester.pumpWidget(buatWidgetYangDiuji());
      await tester.pumpAndSettle();

      // Buka menu opsi dan pilih 'Edit'
      await tester.longPress(find.textContaining('Build: 10'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Pastikan halaman form muncul
      expect(find.byType(FormVersiApkUser), findsOneWidget);

      // Ubah teks di form
      await tester.enterText(
        find.widgetWithText(TextFormField, '1.2.0'),
        '1.2.1',
      );
      // Update juga catatan rilis agar konsisten
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Rilis 1.2.0 build 10'),
        'Rilis 1.2.1 build 10',
      );
      await tester.pump();

      // Pastikan tombol 'Simpan' terlihat sebelum menekannya
      await tester.ensureVisible(find.text('Simpan'));
      await tester.pumpAndSettle();

      // Simpan form
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      // Konfirmasi di dialog
      await tester.tap(find.widgetWithText(TextButton, 'Ya'));
      await tester.pumpAndSettle();

      // Verifikasi bahwa UI di halaman daftar diperbarui
      expect(find.textContaining('Versi: 1.2.1'), findsOneWidget);
      expect(find.text('Rilis 1.2.1 build 10'), findsOneWidget);
      expect(find.textContaining('1.2.0'), findsNothing);

      // Verifikasi bahwa data tidak di-fetch ulang
      verify(mockOperasi.ambilSemuaVersiApkAktif()).called(1);
      verify(mockOperasi.perbaruiVersiApkUser(any)).called(1);
    });

    testWidgets('6. Alur tambah memperbarui UI tanpa reload', (tester) async {
      await tester.pumpWidget(buatWidgetYangDiuji());
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(2));

      // Tekan tombol tambah
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Pastikan halaman form muncul
      expect(find.byType(FormVersiApkUser), findsOneWidget);

      // Isi form
      await tester.enterText(
        find.widgetWithText(TextFormField, '1.2.0'),
        '2.0.0',
      );
      await tester.enterText(find.widgetWithText(TextFormField, '11'), '20');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Catatan Rilis'),
        'Rilis Baru',
      );
      await tester.pump();

      // Pastikan tombol 'Simpan' terlihat sebelum menekannya
      await tester.ensureVisible(find.text('Simpan'));
      await tester.pumpAndSettle();

      // Simpan form
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      // Konfirmasi di dialog
      await tester.tap(find.widgetWithText(TextButton, 'Ya'));
      await tester.pumpAndSettle();

      // Verifikasi UI diperbarui di halaman daftar
      expect(find.text('Rilis Baru'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));

      // Verifikasi bahwa data tidak di-fetch ulang
      verify(mockOperasi.ambilSemuaVersiApkAktif()).called(1);
      verify(mockOperasi.tambahVersiApkUser(any)).called(1);
    });
  });
}
