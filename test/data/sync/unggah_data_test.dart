// path: test/data/sync/unggah_data_test.dart
// diperbaiki: Mengganti pemanggilan toFirestore menjadi toFirebase untuk DompetModel.

import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/data/sync/unggah_data.dart';
import 'package:admin_wifi/model/dompet_model.dart';
import 'package:admin_wifi/model/kritik_saran_model.dart';
import 'package:admin_wifi/model/pengaturan_model.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'unggah_data_test.mocks.dart';

@GenerateMocks([DatabaseHelper, SyncManager])
void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('LayananUnggahData Test', () {
    late MockDatabaseHelper mockDbHelper;
    late FakeFirebaseFirestore mockFirestore;
    late MockSyncManager mockSyncManager;
    late LayananUnggahData layananUnggahData;
    late Database db;

    setUp(() async {
      mockDbHelper = MockDatabaseHelper();
      mockFirestore = FakeFirebaseFirestore();
      mockSyncManager = MockSyncManager();

      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      when(mockDbHelper.database).thenAnswer((_) async => db);

      layananUnggahData = LayananUnggahData(
        dbHelper: mockDbHelper,
        firestore: mockFirestore,
        syncManager: mockSyncManager,
      );
    });

    tearDown(() async {
      await db.close();
    });

    group('Model dengan filter (`dompet`)', () {
      setUp(() async {
        await db.execute('''
          CREATE TABLE dompet (
            id TEXT PRIMARY KEY,
            namaDompet TEXT,
            saldo REAL,
            diperbarui TEXT,
            isDeleted INTEGER,
            diarsipkan TEXT
          )
        ''');
      });

      test(
        'harus mengunggah data dengan isDeleted=0 dan mengubahnya jadi boolean false',
        () async {
          final lastSyncTime = DateTime(2023, 1, 1);
          when(
            mockSyncManager.getLastSyncTimestamp(),
          ).thenAnswer((_) async => lastSyncTime);

          // Data di database lokal disimpan sebagai integer
          final dompet = DompetModel(
            id: 'd1',
            namaDompet: 'Utama',
            saldo: 1000,
            diperbarui: DateTime(2023, 1, 2),
            isDeleted: false,
          );
          
          await db.insert('dompet', dompet.toSqlite());

          await layananUnggahData.unggahDataGenerik<DompetModel>(
            'dompet',
            'dompet_col',
            DompetModel.fromMap,
            (m) => m.toFirebase(), // diperbaiki
            lastSyncTime,
          );

          final snapshot = await mockFirestore
              .collection('dompet_col')
              .doc('d1')
              .get();
          expect(snapshot.exists, isTrue);
          expect(snapshot.data()?['namaDompet'], 'Utama');
          // Verifikasi di Firestore menjadi boolean false
          expect(snapshot.data()?['isDeleted'], isA<bool>());
          expect(snapshot.data()?['isDeleted'], isFalse);
        },
      );
    });

    // ... (sisa pengujian tidak berubah)
    group('Model tanpa filter (`kritik_saran`)', () {
      setUp(() async {
        await db.execute('''
          CREATE TABLE kritik_saran (
            id TEXT PRIMARY KEY,
            isi TEXT,
            tanggal TEXT,
            userId TEXT,
            diperbarui TEXT
          )
        ''');
      });

      test('harus tetap mengunggah data baru', () async {
        final lastSyncTime = DateTime(2023, 1, 1);
        final newTimestamp = DateTime(2023, 1, 2);
        when(
          mockSyncManager.getLastSyncTimestamp(),
        ).thenAnswer((_) async => lastSyncTime);

        final kritikBaru = KritikSaranModel(
          id: 'ks1',
          isi: 'Sangat bagus!',
          tanggal: DateTime.now(),
          userId: 'user123',
          diperbarui: newTimestamp,
        );
        await db.insert('kritik_saran', kritikBaru.toMapForSqlite());

        await layananUnggahData.unggahDataGenerik<KritikSaranModel>(
          'kritik_saran',
          'kritik_saran_col',
          KritikSaranModel.fromMap,
          (m) => m.toMapForFirebase(),
          lastSyncTime,
        );

        final snapshot = await mockFirestore
            .collection('kritik_saran_col')
            .doc('ks1')
            .get();
        expect(snapshot.exists, isTrue);
        expect(snapshot.data()?['isi'], 'Sangat bagus!');
        expect(snapshot.data()?['userId'], 'user123');
      });
    });

    group('Model khusus (`pengaturan`)', () {
      setUp(() async {
        await db.execute('''
              CREATE TABLE pengaturan (
                interval_sinkronisasi_otomatis INTEGER,
                hapus_otomatis_data_arsip INTEGER,
                mode_pemeliharaan INTEGER,
                info_pemeliharaan TEXT,
                diperbarui TEXT
              )
            ''');
      });

      test(
        'harus selalu mengunggah data pengaturan, mengabaikan timestamp',
        () async {
          final lastSyncTime = DateTime(2024, 1, 1);
          when(
            mockSyncManager.getLastSyncTimestamp(),
          ).thenAnswer((_) async => lastSyncTime);

          final pengaturan = PengaturanModel(
            intervalSinkronisasiOtomatis: 30,
            hapusOtomatisDataArsip: 90,
            modePemeliharaan: false,
            infoPemeliharaan: 'Normal',
            diperbarui: DateTime(2023, 1, 1),
          );
          await db.insert('pengaturan', pengaturan.toMapForSqlite());

          await layananUnggahData.unggahDataGenerik<PengaturanModel>(
            'pengaturan',
            'pengaturan_col',
            PengaturanModel.fromMap,
            (m) => m.toMapForFirebase(),
            lastSyncTime,
          );

          final snapshot = await mockFirestore
              .collection('pengaturan_col')
              .doc('konfigurasi_global')
              .get();
          expect(snapshot.exists, isTrue);
          expect(snapshot.data()?['info_pemeliharaan'], 'Normal');
        },
      );
    });
  });
}
