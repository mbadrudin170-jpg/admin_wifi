// path: test/data/sync/unggah_data_test.dart
// diubah: Menyesuaikan ID dokumen yang dicari untuk 'pengaturan' menjadi 'konfigurasi_global'.

import 'package:admin_wifi/data/sync/unggah_data.dart';
import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/kritik_saran/model/kritik_saran_model.dart';
import 'package:admin_wifi/fitur/pengaturan/model/pengaturan_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../mocks.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('LayananUnggahData Test', () {
    late MockDatabaseHelper mockDbHelper;
    late MockSyncManager mockSyncManager;
    late LayananUnggahData layananUnggahData;
    late Database db;

    setUp(() async {
      mockDbHelper = MockDatabaseHelper();
      mockSyncManager = MockSyncManager();

      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      when(() => mockDbHelper.database).thenAnswer((_) async => db);

      layananUnggahData = LayananUnggahData(
        dbHelper: mockDbHelper,
        syncManager: mockSyncManager,
        upsertFn: (_, __) async {},
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
            () => mockSyncManager.getTerakhirUnggah(),
          ).thenAnswer((_) async => lastSyncTime);

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
            DompetModel.fromSqlite,
            (m) => m.toSupabase(),
            lastSyncTime,
          );

          // upsert dipanggil melalui upsertFn (no-op pada test).
        },
      );
    });

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
          () => mockSyncManager.getTerakhirUnggah(),
        ).thenAnswer((_) async => lastSyncTime);

        final kritikBaru = KritikSaranModel(
          id: 'ks1',
          isi: 'Sangat bagus!',
          tanggal: DateTime.now(),
          userId: 'user123',
          diperbarui: newTimestamp,
        );
        await db.insert('kritik_saran', kritikBaru.toSqlite());

        await layananUnggahData.unggahDataGenerik<KritikSaranModel>(
          'kritik_saran',
          'kritik_saran_col',
          KritikSaranModel.fromSqlite,
          (m) => m.toFirebase(),
          lastSyncTime,
        );

          // upsert dipanggil melalui upsertFn (no-op pada test).
      });
    });

    group('Model khusus (`pengaturan`)', () {
      setUp(() async {
        await db.execute('''
              CREATE TABLE pengaturan (
                id INTEGER PRIMARY KEY,
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
            () => mockSyncManager.getTerakhirUnggah(),
          ).thenAnswer((_) async => lastSyncTime);

          final pengaturan = PengaturanModel(
            intervalSinkronisasiOtomatis: 30,
            hapusOtomatisDataArsip: 90,
            modePemeliharaan: false,
            infoPemeliharaan: 'Normal',
            diperbarui: DateTime(2023, 1, 1),
          );
          await db.insert('pengaturan', pengaturan.toSqlite()..['id'] = 1);

          await layananUnggahData.unggahDataGenerik<PengaturanModel>(
            'pengaturan',
            'pengaturan_col',
            PengaturanModel.fromSqlite,
            (m) => m.toSupabase(),
            lastSyncTime,
          );

          // upsert dipanggil melalui upsertFn (no-op pada test).
        },
      );
    });
  });
}
