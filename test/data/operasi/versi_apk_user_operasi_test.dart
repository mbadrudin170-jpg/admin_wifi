// path: test/data/operasi/versi_apk_user_operasi_test.dart
// diubah: Memperbaiki path import dan nama enum yang salah.

import 'dart:async';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/data/sqlite.dart';
// diubah: Menggunakan path dan nama enum yang benar.
import 'package:admin_wifi/enum/arsitektur_apk_enum.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/test_helpers.mocks.dart';

VersiApkUserModel _buatModel({
  String? id,
  String versi = '1.0.0',
  // diubah: Menggunakan enum yang benar.
  Map<ArsitekturApkEnum, int> nomorBuildTerbaru = const {
    ArsitekturApkEnum.universal: 1
  },
  bool isDeleted = false,
  DateTime? diperbarui,
}) {
  return VersiApkUserModel(
    id: id ?? const Uuid().v4(),
    versiTerbaru: versi,
    catatanRilis: 'Catatan rilis untuk $versi',
    nomorBuildTerbaru: nomorBuildTerbaru,
    tautanUnduhan: {
      // diubah: Menggunakan enum yang benar.
      ArsitekturApkEnum.universal: 'http://example.com/$versi.apk'
    },
    youtubeTutorial: 'http://youtube.com/watch?v=$versi',
    wajibUpdate: false,
    diperbarui: diperbarui ?? DateTime.now(),
    isDeleted: isDeleted,
    diarsipkan: isDeleted ? DateTime.now() : null,
  );
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late VersiApkUserOperasi operasi;
  late MockLayananUnggahData mockLayananUnggah;
  late MockKoneksiInternetService mockKoneksi;
  late MockSyncManager mockSyncManager;

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    await DatabaseHelper.instance.createTables(db);
    DatabaseHelper.instance.stubDb(db);

    mockLayananUnggah = MockLayananUnggahData();
    mockKoneksi = MockKoneksiInternetService();
    mockSyncManager = MockSyncManager();

    operasi = VersiApkUserOperasi(
      dbHelper: DatabaseHelper.instance,
      koneksiService: mockKoneksi,
      unggahService: mockLayananUnggah,
      syncManager: mockSyncManager,
    );

    when(mockKoneksi.cekKoneksi()).thenAnswer((_) async => false);
  });

  tearDown(() async {
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
          when(mockKoneksi.cekKoneksi()).thenAnswer((_) async => true);
          when(mockLayananUnggah.unggahDataVersiApkUser()).thenAnswer((_) async => Future.value());
          when(mockSyncManager.setLastSyncTimestamp(any)).thenAnswer((_) async => Future.value());

          final modelBaru = _buatModel(versi: '1.0.1');
          await operasi.tambahVersiApkUser(modelBaru);

          final hasil = await operasi.ambilVersiApkById(modelBaru.id);
          expect(hasil, isNotNull);
          expect(hasil!.id, modelBaru.id);

          verify(mockKoneksi.cekKoneksi()).called(1);
          verify(mockLayananUnggah.unggahDataVersiApkUser()).called(1);
          verify(mockSyncManager.setLastSyncTimestamp(any)).called(1);
        },
      );

      test(
        'tambahVersiApkUser harus berhasil menyimpan data, dan TIDAK melakukan sinkronisasi saat offline',
        () async {
          final modelBaru = _buatModel(versi: '1.0.2');
          await operasi.tambahVersiApkUser(modelBaru);

          final hasil = await operasi.ambilVersiApkById(modelBaru.id);
          expect(hasil, isNotNull);

          verify(mockKoneksi.cekKoneksi()).called(1);
          verifyNever(mockLayananUnggah.unggahDataVersiApkUser());
          verifyNever(mockSyncManager.setLastSyncTimestamp(any));
        },
      );

      test(
        'tambahVersiApkUser harus menyimpan data saat timeout, tapi tidak update timestamp',
        () async {
          when(mockKoneksi.cekKoneksi()).thenAnswer((_) async => true);
          when(mockLayananUnggah.unggahDataVersiApkUser()).thenAnswer((_) async {
            throw TimeoutException('Timeout');
          });

          final modelBaru = _buatModel(versi: '1.0.3');
          await operasi.tambahVersiApkUser(modelBaru);

          final hasil = await operasi.ambilVersiApkById(modelBaru.id);
          expect(hasil, isNotNull);

          verify(mockKoneksi.cekKoneksi()).called(1);
          verify(mockLayananUnggah.unggahDataVersiApkUser()).called(1);
          verifyNever(mockSyncManager.setLastSyncTimestamp(any));
        },
      );

      test('perbaruiVersiApkUser harus berhasil mengubah data', () async {
        final modelAwal = _buatModel(versi: '2.0.0');
        await operasi.tambahVersiApkUser(modelAwal);

        final modelUpdate = modelAwal.copyWith(catatanRilis: 'Catatan Rilis Diperbarui');
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

          final hasilDb = await db.query('versi_apk_user', where: 'id = ?', whereArgs: [model.id]);
          final dataMap = hasilDb.first;
          final timestampDiarsipkan = DateTime.parse(dataMap['diarsipkan'] as String);
          final timestampDiperbarui = DateTime.parse(dataMap['diperbarui'] as String);

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
        test('harus mengembalikan null jika hanya ada data yang diarsip', () async {
          final modelDiarsip = _buatModel(versi: '5.0.0', diperbarui: DateTime.now());
          await operasi.tambahVersiApkUser(modelDiarsip);
          await operasi.arsipkanVersiApkUser(modelDiarsip.id);

          final hasil = await operasi.ambilVersiApkTerbaru();
          expect(hasil, isNull);
        });

        test(
          'harus mengambil data yang hanya kolom build nya lebih tinggi dari data yang ada dan tidak diarsip',
          () async {
            // diubah: Menggunakan enum yang benar.
            final buildRendahTanggalBaru = _buatModel(versi: '2.0.0', nomorBuildTerbaru: {ArsitekturApkEnum.universal: 5}, diperbarui: DateTime.now());
            final buildTinggiTanggalLama = _buatModel(versi: '2.0.0', nomorBuildTerbaru: {ArsitekturApkEnum.universal: 10}, diperbarui: DateTime.now().subtract(const Duration(days: 2)));
            final buildPalingTinggiDiarsip = _buatModel(versi: '2.0.0', nomorBuildTerbaru: {ArsitekturApkEnum.universal: 15}, diperbarui: DateTime.now(), isDeleted: true);

            await db.insert('versi_apk_user', buildRendahTanggalBaru.toSqlite());
            await db.insert('versi_apk_user', buildTinggiTanggalLama.toSqlite());
            await db.insert('versi_apk_user', buildPalingTinggiDiarsip.toSqlite());

            final hasil = await operasi.ambilVersiApkTerbaru();

            expect(hasil, isNotNull);
            // diubah: Menggunakan enum yang benar.
            expect(hasil!.nomorBuildTerbaru[ArsitekturApkEnum.universal], 10);
            expect(hasil.isDeleted, isFalse);
          },
        );
      });

      group('dengan data awal', () {
        setUp(() async {
          await operasi.tambahVersiApkUser(_buatModel(versi: '1.0.0', diperbarui: DateTime(2023, 1, 1)));
          await operasi.tambahVersiApkUser(_buatModel(versi: '2.0.0', diperbarui: DateTime(2023, 1, 3)));
          final modelDiarsip = _buatModel(versi: '0.9.0', diperbarui: DateTime(2023, 1, 2));
          await operasi.tambahVersiApkUser(modelDiarsip);
          await operasi.arsipkanVersiApkUser(modelDiarsip.id);
        });

        test('ambilSemuaVersiApkAktif hanya mengembalikan data yang isDeleted nya 0', () async {
          final hasilModel = await operasi.ambilSemuaVersiApkAktif();
          expect(hasilModel.length, 2);

          for (final model in hasilModel) {
            expect(model.isDeleted, isFalse);
          }
        });

        test('ambilSemuaVersiApk harus mengembalikan semua data (aktif dan diarsip)', () async {
          final hasil = await operasi.ambilSemuaVersiApk();
          expect(hasil.length, 3);
        });

        test('ambilSemuaVersiApkAktif harus mengembalikan data terurut dari yang terbaru (berdasarkan tanggal)', () async {
          final hasil = await operasi.ambilSemuaVersiApkAktif();
          expect(hasil.first.versiTerbaru, '2.0.0');
          expect(hasil.last.versiTerbaru, '1.0.0');
        });
      });
    });

    group('Operasi Batch', () {
      test('sisipkanAtauPerbaruiBatch harus memasukkan beberapa data baru', () async {
        final batchList = [_buatModel(versi: 'B1'), _buatModel(versi: 'B2')];
        await operasi.sisipkanAtauPerbaruiBatch(batchList);
        final hasil = await operasi.ambilSemuaVersiApk();
        expect(hasil.length, 2);
      });

      test('sisipkanAtauPerbaruiBatch harus memperbarui data yang ada', () async {
        final modelAwal = _buatModel(versi: 'C1');
        await operasi.tambahVersiApkUser(modelAwal);

        final modelUpdate = modelAwal.copyWith(catatanRilis: "batch update");
        final batchList = [modelUpdate, _buatModel(versi: 'C2')];
        await operasi.sisipkanAtauPerbaruiBatch(batchList);

        final hasil = await operasi.ambilSemuaVersiApk();
        expect(hasil.length, 2);
        final itemDiperbarui = hasil.firstWhere((item) => item.id == modelAwal.id);
        expect(itemDiperbarui.catatanRilis, "batch update");
      });
    });
  });
}
