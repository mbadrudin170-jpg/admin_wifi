// path: test/data/operasi/versi_apk_user_operasi_test.dart

import 'dart:async';

import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/data/sync/unggah_data.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:admin_wifi/services/cek_koneksi_internet.dart';
import 'package:admin_wifi/utils/sync_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import 'versi_apk_user_operasi_test.mocks.dart';

// Helper untuk menginisialisasi database untuk testing
Future<Database> _initTestDatabase() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  await db.execute(DatabaseHelper.tabelVersiApkUser);
  return db;
}

// Helper untuk membuat instance VersiApkUserModel baru untuk tes
VersiApkUserModel _buatModel({
  String? id,
  String versi = '1.0.0',
  Map<String, int> nomorBuildTerbaru = const {'universal': 1},
  bool isDeleted = false,
  DateTime? diperbarui,
}) {
  return VersiApkUserModel(
    id: id ?? const Uuid().v4(),
    versiTerbaru: versi,
    catatanRilis: 'Catatan rilis untuk $versi',
    nomorBuildTerbaru: nomorBuildTerbaru,
    tautanUnduhan: {'universal': 'http://example.com/$versi.apk'},
    youtubeTutorial: 'http://youtube.com/watch?v=$versi',
    wajibUpdate: false,
    diperbarui: diperbarui ?? DateTime.now(),
    isDeleted: isDeleted,
    diarsipkan: isDeleted ? DateTime.now() : null,
  );
}

@GenerateMocks([LayananUnggahData, KoneksiInternetService, SyncManager])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Database db;
  late VersiApkUserOperasi operasi;
  late MockLayananUnggahData mockLayananUnggah;
  late MockKoneksiInternetService mockKoneksi;
  late MockSyncManager mockSyncManager;
  late DatabaseHelper dbHelperMock;

  setUpAll(() async {
    db = await _initTestDatabase();
    dbHelperMock = DatabaseHelper.instance;
    dbHelperMock.database = Future.value(db);

    mockLayananUnggah = MockLayananUnggahData();
    mockKoneksi = MockKoneksiInternetService();
    mockSyncManager = MockSyncManager();

    // diubah: Injeksi dependensi mock melalui konstruktor
    operasi = VersiApkUserOperasi(
      dbHelper: dbHelperMock,
      koneksiService: mockKoneksi,
      unggahService: mockLayananUnggah,
      syncManager: mockSyncManager,
    );
  });

  setUp(() async {
    await db.delete('versi_apk_user');
    reset(mockLayananUnggah);
    reset(mockKoneksi);
    reset(mockSyncManager);

    // ditambah: Menambahkan stub default untuk semua tes.
    // Mengasumsikan offline by default untuk menghindari pemanggilan service yang tidak perlu.
    // Tes yang butuh online bisa override ini secara spesifik.
    when(mockKoneksi.cekKoneksi()).thenAnswer((_) async => false);
  });

  tearDownAll(() async {
    await db.close();
  });

  group('VersiApkUserOperasi Tests', () {
    group('Saat Database Kosong', () {
      test('ambilSemuaVersiApkAktif harus mengembalikan list kosong', () async {
        final hasil = await operasi.ambilSemuaVersiApkAktif();
        expect(hasil, isEmpty);
      });

      test('ambilSemuaVersiApk harus mengembalikan list kosong', () async {
        final hasil = await operasi.ambilSemuaVersiApk();
        expect(hasil, isEmpty);
      });

      test('ambilVersiApkById harus mengembalikan null', () async {
        final hasil = await operasi.ambilVersiApkById('id-tidak-ada');
        expect(hasil, isNull);
      });
      test('ambilVersiApkTerbaru harus mengembalikan null', () async {
        final hasil = await operasi.ambilVersiApkTerbaru();
        expect(hasil, isNull);
      });
    });

    group('Operasi CRUD Dasar', () {
      test(
        'tambahVersiApkUser harus berhasil menyimpan data, dan melakukan sinkronisasi saat online',
        () async {
          // Atur kondisi: online (override default)
          when(mockKoneksi.cekKoneksi()).thenAnswer((_) async => true);
          when(
            mockLayananUnggah.unggahDataVersiApkUser(),
          ).thenAnswer((_) async => Future.value());
          when(
            mockSyncManager.setLastSyncTimestamp(any),
          ).thenAnswer((_) async => Future.value());

          final modelBaru = _buatModel(versi: '1.0.1');
          await operasi.tambahVersiApkUser(modelBaru);

          // Verifikasi: data tersimpan di lokal
          final hasil = await operasi.ambilVersiApkById(modelBaru.id);
          expect(hasil, isNotNull);
          expect(hasil!.id, modelBaru.id);

          // Verifikasi: sinkronisasi dipanggil
          verify(mockKoneksi.cekKoneksi()).called(1);
          verify(mockLayananUnggah.unggahDataVersiApkUser()).called(1);
          verify(mockSyncManager.setLastSyncTimestamp(any)).called(1);
        },
      );

      test(
        'tambahVersiApkUser harus berhasil menyimpan data, dan TIDAK melakukan sinkronisasi saat offline',
        () async {
          // Atur kondisi: offline (menggunakan default dari setUp)

          final modelBaru = _buatModel(versi: '1.0.2');
          await operasi.tambahVersiApkUser(modelBaru);

          // Verifikasi: data tersimpan di lokal
          final hasil = await operasi.ambilVersiApkById(modelBaru.id);
          expect(hasil, isNotNull);

          // Verifikasi: sinkronisasi TIDAK dipanggil
          verify(mockKoneksi.cekKoneksi()).called(1);
          verifyNever(mockLayananUnggah.unggahDataVersiApkUser());
          verifyNever(mockSyncManager.setLastSyncTimestamp(any));
        },
      );

      test(
        'tambahVersiApkUser harus menyimpan data saat timeout, tapi tidak update timestamp',
        () async {
          // Atur kondisi: online, tapi unggah timeout
          when(mockKoneksi.cekKoneksi()).thenAnswer((_) async => true);
          when(mockLayananUnggah.unggahDataVersiApkUser()).thenAnswer((
            _,
          ) async {
            await Future.delayed(
              const Duration(milliseconds: 100),
            ); // Sedikit delay untuk simulasi
            throw TimeoutException('Timeout');
          });

          final modelBaru = _buatModel(versi: '1.0.3');
          await operasi.tambahVersiApkUser(modelBaru);

          // Verifikasi: data tersimpan di lokal
          final hasil = await operasi.ambilVersiApkById(modelBaru.id);
          expect(hasil, isNotNull);

          // Verifikasi: unggah dipanggil, tapi setLastSyncTimestamp tidak
          verify(mockKoneksi.cekKoneksi()).called(1);
          verify(mockLayananUnggah.unggahDataVersiApkUser()).called(1);
          verifyNever(mockSyncManager.setLastSyncTimestamp(any));
        },
      );

      test('perbaruiVersiApkUser harus berhasil mengubah data', () async {
        final modelAwal = _buatModel(versi: '2.0.0');
        await operasi.tambahVersiApkUser(modelAwal);

        final modelUpdate = modelAwal.copyWith(
          catatanRilis: 'Catatan Rilis Diperbarui',
        );
        await operasi.perbaruiVersiApkUser(modelUpdate);

        final hasil = await operasi.ambilVersiApkById(modelAwal.id);
        expect(hasil, isNotNull);
        expect(hasil!.id, modelAwal.id);
        expect(hasil.catatanRilis, 'Catatan Rilis Diperbarui');
      });

      test(
        'arsipkanVersiApkUser harus merubah data di id yang diberikan agar isDeleted menjadi 1, diarsipkan dan diperbarui ke DateTime.now()',
        () async {
          final model = _buatModel(versi: '3.0.0');
          await operasi.tambahVersiApkUser(model);

          final timestampAwal = model.diperbarui!;

          await Future.delayed(const Duration(milliseconds: 10));

          await operasi.arsipkanVersiApkUser(model.id);

          final hasilDb = await db.query(
            'versi_apk_user',
            where: 'id = ?',
            whereArgs: [model.id],
          );
          final dataMap = hasilDb.first;
          final timestampDiarsipkan = DateTime.parse(
            dataMap['diarsipkan'] as String,
          );
          final timestampDiperbarui = DateTime.parse(
            dataMap['diperbarui'] as String,
          );

          expect(dataMap['isDeleted'], 1);
          expect(dataMap['diarsipkan'], isNotNull);
          expect(dataMap['diperbarui'], isNotNull);
          expect(timestampDiarsipkan.isAfter(timestampAwal), isTrue);
          expect(timestampDiperbarui.isAfter(timestampAwal), isTrue);

          final hasilAmbil = await operasi.ambilVersiApkById(model.id);
          expect(hasilAmbil, isNull);
        },
      );
    });

    group('Fungsi Pengambilan (Fetch)', () {
      group('ambilVersiApkTerbaru', () {
        test(
          'harus mengembalikan null jika hanya ada data yang diarsip',
          () async {
            final modelDiarsip = _buatModel(
              versi: '5.0.0',
              diperbarui: DateTime.now(),
            );
            await operasi.tambahVersiApkUser(modelDiarsip);
            await operasi.arsipkanVersiApkUser(modelDiarsip.id);

            final hasil = await operasi.ambilVersiApkTerbaru();
            expect(hasil, isNull);
          },
        );

        // diubah: Hanya isi tes ini yang diubah sesuai aturan baru
        test(
          'harus mengambil data yang hanya kolom build nya lebih tinggi dari data yang ada dan tidak diarsip',
          () async {
            // 1. SETUP: Buat skenario di mana hanya build number yang relevan
            final buildRendahTanggalBaru = _buatModel(
              versi: '2.0.0', // Versi sama untuk semua
              nomorBuildTerbaru: {'universal': 5},
              diperbarui: DateTime.now(),
            );

            final buildTinggiTanggalLama = _buatModel(
              versi: '2.0.0', // Versi sama untuk semua
              nomorBuildTerbaru: {'universal': 10},
              diperbarui: DateTime.now().subtract(const Duration(days: 2)),
            );

            final buildPalingTinggiDiarsip = _buatModel(
              versi: '2.0.0', // Versi sama untuk semua
              nomorBuildTerbaru: {'universal': 15},
              diperbarui: DateTime.now(),
              isDeleted: true,
            );

            await db.insert(
              'versi_apk_user',
              buildRendahTanggalBaru.toMapForSqlite(),
            );
            await db.insert(
              'versi_apk_user',
              buildTinggiTanggalLama.toMapForSqlite(),
            );
            await db.insert(
              'versi_apk_user',
              buildPalingTinggiDiarsip.toMapForSqlite(),
            );

            // 2. ACT: Panggil fungsi yang diuji
            final hasil = await operasi.ambilVersiApkTerbaru();

            // 3. ASSERT: Verifikasi hasilnya harus yang build 10
            expect(hasil, isNotNull);
            expect(hasil!.nomorBuildTerbaru['universal'], 10);
            expect(hasil.isDeleted, isFalse);
          },
        );
      });

      group('dengan data awal', () {
        setUp(() async {
          await operasi.tambahVersiApkUser(
            _buatModel(versi: '1.0.0', diperbarui: DateTime(2023, 1, 1)),
          );
          await operasi.tambahVersiApkUser(
            _buatModel(versi: '2.0.0', diperbarui: DateTime(2023, 1, 3)),
          );
          final modelDiarsip = _buatModel(
            versi: '0.9.0',
            diperbarui: DateTime(2023, 1, 2),
          );
          await operasi.tambahVersiApkUser(modelDiarsip);
          await operasi.arsipkanVersiApkUser(modelDiarsip.id);
        });

        test(
          'ambilSemuaVersiApkAktif hanya mengembalikan data yang isDeleted nya 0',
          () async {
            final hasilModel = await operasi.ambilSemuaVersiApkAktif();
            expect(hasilModel.length, 2);

            for (final model in hasilModel) {
              expect(model.isDeleted, isFalse);
            }
          },
        );

        test(
          'ambilSemuaVersiApk harus mengembalikan semua data (aktif dan diarsip)',
          () async {
            final hasil = await operasi.ambilSemuaVersiApk();
            expect(hasil.length, 3);
          },
        );

        test(
          'ambilSemuaVersiApkAktif harus mengembalikan data terurut dari yang terbaru (berdasarkan tanggal)',
          () async {
            final hasil = await operasi.ambilSemuaVersiApkAktif();
            expect(hasil.first.versiTerbaru, '2.0.0');
            expect(hasil.last.versiTerbaru, '1.0.0');
          },
        );
      });
    });

    group('Operasi Batch', () {
      test(
        'sisipkanAtauPerbaruiBatch harus memasukkan beberapa data baru',
        () async {
          final batchList = [_buatModel(versi: 'B1'), _buatModel(versi: 'B2')];
          await operasi.sisipkanAtauPerbaruiBatch(batchList);
          final hasil = await operasi.ambilSemuaVersiApk();
          expect(hasil.length, 2);
        },
      );

      test(
        'sisipkanAtauPerbaruiBatch harus memperbarui data yang ada',
        () async {
          final modelAwal = _buatModel(versi: 'C1');
          await operasi.tambahVersiApkUser(modelAwal);

          final modelUpdate = modelAwal.copyWith(catatanRilis: "batch update");
          final batchList = [modelUpdate, _buatModel(versi: 'C2')];
          await operasi.sisipkanAtauPerbaruiBatch(batchList);

          final hasil = await operasi.ambilSemuaVersiApk();
          expect(hasil.length, 2);
          final itemDiperbarui = hasil.firstWhere(
            (item) => item.id == modelAwal.id,
          );
          expect(itemDiperbarui.catatanRilis, "batch update");
        },
      );
    });
  });
}
