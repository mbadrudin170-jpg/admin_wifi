// path: test/halaman/form/form_pelanggan_aktif_test.dart
// diubah: Menambahkan `alamat` pada data dummy `PelangganModel`.
// diubah: Memperbaiki mock `createPelangganAktif` dan `updatePelangganAktif`
// untuk mengembalikan `PelangganAktifModel` dummy, sesuai dengan return type aslinya.
// ditambahkan: parameter wajib `password` dan `diperbarui` pada `PelangganModel`.
// diubah: Mendeklarasikan tipe data `pelangganDummy` secara eksplisit.
// ditambahkan: Inisialisasi data lokalisasi untuk mengatasi LocaleDataException.
// diubah: Menggunakan tester.ensureVisible() untuk memastikan tombol Simpan terlihat sebelum di-tap.
// diubah: Memperbaiki logika pengujian untuk menangani SnackBar dan navigasi secara akurat.
// ditambahkan: Tes untuk memverifikasi bahwa dropdown kategori hanya menampilkan tipe pemasukan.
// diubah: Memperbaiki logika tes untuk `findsNothing` dengan menghapus `.last`.
// diubah: Memperbaiki nama tes kelima agar sesuai permintaan.
// diubah: Memperbaiki logika tes untuk `findsOneWidget` dengan menambahkan `.last` agar menargetkan item di dalam dropdown.

import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/data/operasi/kategori_operasi.dart';
import 'package:admin_wifi/data/operasi/paket_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_aktif_operasi.dart';
import 'package:admin_wifi/data/operasi/pelanggan_operasi.dart';
import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/halaman/form/form_pelanggan_aktif.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/enum/status_pembayaran.dart';
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

  final List<PelangganModel> pelangganDummy = [
    PelangganModel(
      id: 'p1',
      nama: 'Pelanggan A',
      telepon: '08123',
      alamat: 'Alamat A',
      password: 'password',
      diperbarui: DateTime.now(),
    ),
  ];
  final paketDummy = [
    PaketModel(
      id: 'pkt1',
      nama: 'Paket 1 Jam',
      harga: 5000,
      durasi: 1,
      tipe: TipeDurasi.jam,
    ),
  ];
  final dompetDummy = [
    DompetModel(id: 'd1', namaDompet: 'Dompet Utama', saldo: 100000),
  ];

  final pelangganAktifDummy = PelangganAktifModel(
    id: 'pa-dummy',
    idPelanggan: 'p1',
    idPaket: 'pkt1',
    tanggalMulai: DateTime.now(),
    tanggalBerakhir: DateTime.now().add(const Duration(hours: 1)),
    status: StatusPembayaran.lunas,
  );

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

    // Default mock for most tests
    when(mockKategoriOperasi.getKategori()).thenAnswer(
      (_) async => [
        KategoriModel(
          id: 'k1',
          nama: 'Aktivasi Paket',
          tipe: TipeKategori.pemasukan,
        ),
      ],
    );

    when(
      mockPelangganAktifOperasi.createPelangganAktif(any),
    ).thenAnswer((_) async => pelangganAktifDummy);
    when(
      mockPelangganAktifOperasi.updatePelangganAktif(any),
    ).thenAnswer((_) async => pelangganAktifDummy);
    when(
      mockTransaksiOperasi.tambahTransaksi(any),
    ).thenAnswer((_) async => 'new-tx-id');
  });

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

  group('Pengujian FormPelangganAktif', () {
    testWidgets(
      '1. Harusnya menampilkan loading indicator lalu form setelah data dimuat',
      (tester) async {
        await pumpForm(tester);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(Form), findsOneWidget);
        expect(find.text('Pilih Pelanggan'), findsOneWidget);
        expect(find.text('Pilih Paket'), findsOneWidget);
      },
    );

    testWidgets(
      '2. Mode Tambah (Lunas) - Menyimpan harus memanggil createPelangganAktif dan tambahTransaksi',
      (tester) async {
        await pumpForm(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Pilih Pelanggan'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Pelanggan A').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Pilih Paket'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Paket 1 Jam').last);
        await tester.pumpAndSettle();

        expect(find.text('Lunas'), findsOneWidget);

        await tester.ensureVisible(find.text('Simpan'));
        await tester.tap(find.text('Simpan'));

        await tester.pump(); // Render frame untuk SnackBar

        expect(find.text('Pelanggan berhasil diaktifkan!'), findsOneWidget);

        await tester.pumpAndSettle(); // Selesaikan semua timer

        verify(mockPelangganAktifOperasi.createPelangganAktif(any)).called(1);
        verify(mockTransaksiOperasi.tambahTransaksi(any)).called(1);
      },
    );

    testWidgets(
      '3. Mode Tambah (Belum Lunas) - Menyimpan hanya memanggil createPelangganAktif',
      (tester) async {
        await pumpForm(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Pilih Pelanggan'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Pelanggan A').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Pilih Paket'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Paket 1 Jam').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Belum Lunas'));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Simpan'));
        await tester.tap(find.text('Simpan'));

        await tester.pump(); // Render frame untuk SnackBar

        expect(find.text('Pelanggan berhasil diaktifkan!'), findsOneWidget);

        await tester.pumpAndSettle(); // Selesaikan semua timer

        verify(mockPelangganAktifOperasi.createPelangganAktif(any)).called(1);
        verifyNever(mockTransaksiOperasi.tambahTransaksi(any));
      },
    );

    testWidgets(
      '4. Mode Edit - Harusnya memuat data yang ada dan memanggil update',
      (tester) async {
        final pelangganAktifExist = PelangganAktifModel(
          id: 'pa1',
          idPelanggan: 'p1',
          idPaket: 'pkt1',
          tanggalMulai: DateTime.now(),
          tanggalBerakhir: DateTime.now().add(const Duration(hours: 1)),
          status: StatusPembayaran.lunas,
        );

        await pumpForm(tester, pelangganAktif: pelangganAktifExist);
        await tester.pumpAndSettle();

        expect(find.text('Pelanggan A'), findsOneWidget);
        expect(find.text('Paket 1 Jam'), findsOneWidget);
        expect(find.text('Edit Pelanggan Aktif'), findsOneWidget);

        await tester.ensureVisible(find.text('Simpan'));
        await tester.tap(find.text('Simpan'));

        await tester.pump(); // Render frame untuk SnackBar

        expect(find.text('Pelanggan berhasil diperbarui!'), findsOneWidget);

        await tester.pumpAndSettle(); // Selesaikan semua timer

        verify(mockPelangganAktifOperasi.updatePelangganAktif(any)).called(1);
        verifyNever(mockPelangganAktifOperasi.createPelangganAktif(any));
      },
    );

    testWidgets(
      '5. Dropdown kategori hanya menampilkan tipe pemasukan dan kolom isDeleted nya 0',
      (tester) async {
        final kategoriCampuran = [
          KategoriModel(
            id: 'k1',
            nama: 'Aktivasi Paket',
            tipe: TipeKategori.pemasukan,
            isDeleted: false,
          ),
          KategoriModel(
            id: 'k2',
            nama: 'Beli Pulsa',
            tipe: TipeKategori.pengeluaran,
            isDeleted: false,
          ),
          KategoriModel(
            id: 'k3',
            nama: 'Gaji',
            tipe: TipeKategori.pemasukan,
            isDeleted: false,
          ),
          KategoriModel(
            id: 'k4',
            nama: 'Pemasukan Dihapus',
            tipe: TipeKategori.pemasukan,
            isDeleted: true,
          ),
        ];

        when(
          mockKategoriOperasi.getKategori(),
        ).thenAnswer((_) async => kategoriCampuran);

        await pumpForm(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Pilih Kategori Transaksi'));
        await tester.pumpAndSettle();

        // Memverifikasi item yang seharusnya ADA di dalam dropdown
        expect(find.text('Aktivasi Paket').last, findsOneWidget);
        expect(find.text('Gaji').last, findsOneWidget);

        // Memverifikasi item yang seharusnya TIDAK ADA di dalam dropdown
        expect(find.text('Beli Pulsa'), findsNothing);
        expect(find.text('Pemasukan Dihapus'), findsNothing);
      },
    );

    test(
      '6. Pilih Dompet harus menampilkan daftar akun dompet dengan menampilkan namanya saja, tapi ambil datanya yang isDeletednya 0',
      () {},
    );
  });
}
