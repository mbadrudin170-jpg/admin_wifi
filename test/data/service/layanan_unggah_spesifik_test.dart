// path: test/data/service/layanan_unggah_spesifik_test.dart
// ditambah: Unit test komprehensif untuk LayananUnggahSpesifik.
import 'package:admin_wifi/data/service/layanan_unggah_spesifik.dart';
import 'package:admin_wifi/model/enum/nama_tabel_enum.dart';
import 'package:admin_wifi/model/pelanggan_model.dart';
import 'package:admin_wifi/model/status_unggah_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helpers/test_helpers.mocks.dart';

void main() {
  // Deklarasi variabel mock dan service
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionRef;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockWriteBatch mockWriteBatch;
  late LayananUnggahSpesifik layananUnggah;

  // Inisialisasi mock sebelum setiap tes
  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    mockFirestore = MockFirebaseFirestore();
    mockCollectionRef = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockWriteBatch = MockWriteBatch();

    // Inisialisasi layanan dengan dependensi mock
    layananUnggah = LayananUnggahSpesifik(
      dbHelper: mockDbHelper,
      firestore: mockFirestore,
    );

    // Konfigurasi perilaku default untuk mock
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
    when(mockFirestore.collection(any)).thenReturn(mockCollectionRef);
    when(mockCollectionRef.doc(any)).thenReturn(mockDocRef);
    when(mockFirestore.batch()).thenReturn(mockWriteBatch);
  });

  // Contoh data pelanggan untuk pengujian
  final pelanggan1 = PelangganModel(
    id: 'id-1',
    nama: 'Pelanggan Satu',
    telepon: '081234567890',
    alamat: 'Alamat 1',
    password: 'password123',
    diperbarui: DateTime.now(),
  );
  final pelanggan2 = PelangganModel(
    id: 'id-2',
    nama: 'Pelanggan Dua',
    telepon: '089876543210',
    alamat: 'Alamat 2',
    password: 'password456',
    diperbarui: DateTime.now(),
  );
  final List<Map<String, dynamic>> daftarPelangganMap = [
    pelanggan1.toMapForSqlite(),
    pelanggan2.toMapForSqlite(),
  ];

  group('LayananUnggahSpesifik', () {
    test(
      'Harus mengunggah item spesifik jika status true dan ids tidak kosong',
      () async {
        // ARRANGE
        final instruksi = StatusUnggahModel(
          tabel: NamaTabel.pelanggan,
          status: true,
          ids: ['id-1'],
        );
        // Hanya kembalikan data untuk 'id-1'
        when(mockDatabase.query(
          'pelanggan',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenAnswer((_) async => [daftarPelangganMap.first]);

        // ACT
        await layananUnggah.prosesStatusUnggah(instruksi);

        // ASSERT
        // Verifikasi query ke DB dengan `where` clause yang benar
        verify(mockDatabase.query(
          'pelanggan',
          where: 'id IN (?)',
          whereArgs: ['id-1'],
        ));
        // Verifikasi bahwa hanya satu item yang di-set di batch
        verify(mockWriteBatch.set(
          mockDocRef,
          any,
          any,
        )).called(1);
        // Verifikasi batch di-commit
        verify(mockWriteBatch.commit());
      },
    );

    test(
      'Harus mengunggah SEMUA item jika status true dan ids kosong',
      () async {
        // ARRANGE
        final instruksi = StatusUnggahModel(
          tabel: NamaTabel.pelanggan,
          status: true,
          ids: [], // ids kosong menandakan sync seluruh tabel
        );
        // Kembalikan semua data pelanggan saat query tanpa `where`
        when(mockDatabase.query('pelanggan'))
            .thenAnswer((_) async => daftarPelangganMap);

        // ACT
        await layananUnggah.prosesStatusUnggah(instruksi);

        // ASSERT
        // Verifikasi query ke DB tanpa `where` clause
        verify(mockDatabase.query('pelanggan'));
        // Verifikasi bahwa kedua item di-set di batch
        verify(mockWriteBatch.set(
          mockDocRef,
          any,
          any,
        )).called(2);
        // Verifikasi batch di-commit
        verify(mockWriteBatch.commit());
      },
    );

    test(
      'Tidak boleh melakukan apa-apa jika status false',
      () async {
        // ARRANGE
        final instruksi = StatusUnggahModel(
          tabel: NamaTabel.pelanggan,
          status: false,
          ids: ['id-1'],
        );

        // ACT
        await layananUnggah.prosesStatusUnggah(instruksi);

        // ASSERT
        // Verifikasi tidak ada interaksi sama sekali dengan database atau firestore
        verifyNever(mockDbHelper.database);
        verifyNever(mockFirestore.batch());
        verifyNever(mockWriteBatch.commit());
      },
    );

    test(
      'Tidak boleh melakukan unggah jika query lokal tidak menemukan data',
      () async {
        // ARRANGE
        final instruksi = StatusUnggahModel(
          tabel: NamaTabel.pelanggan,
          status: true,
          ids: ['id-yang-tidak-ada'],
        );
        // Konfigurasi mock DB untuk mengembalikan list kosong
        when(mockDatabase.query(
          'pelanggan',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenAnswer((_) async => []);

        // ACT
        await layananUnggah.prosesStatusUnggah(instruksi);

        // ASSERT
        // Verifikasi bahwa query ke DB tetap dijalankan
        verify(mockDatabase.query(
          'pelanggan',
          where: 'id IN (?)',
          whereArgs: ['id-yang-tidak-ada'],
        ));
        // Verifikasi TIDAK ADA commit yang terjadi karena tidak ada data
        verifyNever(mockWriteBatch.commit());
      },
    );
  });
}
