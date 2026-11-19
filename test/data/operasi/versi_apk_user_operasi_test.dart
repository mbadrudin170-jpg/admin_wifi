// path: test/data/operasi/versi_apk_user_operasi_test.dart

import 'package:admin_wifi/data/operasi/operasi_dasar.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:admin_wifi/fitur/versi_apk_user/model/versi_apk_user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import 'versi_apk_user_operasi_test.mocks.dart';

@GenerateMocks([OperasiDasar])
VersiApkUserModel _buatModel({
  String? id,
  String versi = '1.0.0',
  bool isDeleted = false,
  DateTime? diperbarui,
}) {
  return VersiApkUserModel(
    id: id ?? const Uuid().v4(),
    versiTerbaru: versi,
    catatanRilis: 'Catatan rilis untuk $versi',
    diperbarui: diperbarui ?? DateTime.now(),
    isDeleted: isDeleted,
  );
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late VersiApkUserOperasi operasi;
  late MockOperasiDasar mockOperasiDasar;

  Future<void> sisipkanDataManual(VersiApkUserModel model) async {
    await db.insert(
      'versi_apk_user',
      model.toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    // diubah: Argumen kedua (version) ditambahkan sesuai definisi fungsi
    await DatabaseHelper.instance.createTables(db, 1);
    // diubah: stubDb() dihapus karena tidak ada di DatabaseHelper

    mockOperasiDasar = MockOperasiDasar();
    operasi = VersiApkUserOperasi(operasi: mockOperasiDasar);
  });

  tearDown(() async {
    await db.close();
  });

  group('VersiApkUserOperasi Tests', () {
    group('Operasi Tulis (Write)', () {
      test(
        'tambahVersiApkUser harus memanggil _operasi.sisipkan dengan benar',
        () async {
          final modelBaru = _buatModel(versi: '1.0.1');
          when(
            mockOperasiDasar.sisipkan(any, any),
          ).thenAnswer((_) async => Future.value());

          await operasi.tambahVersiApkUser(modelBaru);

          // diubah: Menggunakan toSqlite() agar konsisten dengan implementasi
          verify(
            mockOperasiDasar.sisipkan('versi_apk_user', modelBaru.toSqlite()),
          ).called(1);
        },
      );

      test(
        'perbaruiVersiApkUser harus memanggil _operasi.perbarui dengan benar',
        () async {
          final model = _buatModel(versi: '1.0.2');
          when(
            mockOperasiDasar.perbarui(any, any, any),
          ).thenAnswer((_) async => Future.value());

          await operasi.perbaruiVersiApkUser(model);

          verify(
            mockOperasiDasar.perbarui(
              'versi_apk_user',
              model.toSqlite(),
              model.id,
            ),
          ).called(1);
        },
      );

      test(
        'arsipkanVersiApkUser harus memanggil _operasi.perbarui dengan isDeleted=true',
        () async {
          final model = _buatModel(
            id: 'test-id',
            versi: '1.0.3',
            isDeleted: false,
          );
          await sisipkanDataManual(model); // Masukkan data awal ke DB

          when(
            mockOperasiDasar.perbarui(any, any, any),
          ).thenAnswer((_) async => Future.value());

          await operasi.arsipkanVersiApkUser(model.id);

          // Verifikasi bahwa `perbarui` dipanggil dengan data yang memiliki isDeleted = true
          final captured =
              verify(
                    mockOperasiDasar.perbarui(
                      'versi_apk_user',
                      captureAny,
                      model.id,
                    ),
                  ).captured.single
                  as Map<String, dynamic>;

          expect(captured['isDeleted'], 1);
        },
      );
    });

    group('Operasi Baca (Read)', () {
      test(
        'ambilSemuaVersiApkAktif harus mengembalikan list kosong saat DB kosong',
        () async {
          final hasil = await operasi.ambilSemuaVersiApkAktif();
          expect(hasil, isEmpty);
        },
      );

      test(
        'ambilSemuaVersiApkAktif harus mengembalikan data yang tidak dihapus',
        () async {
          final modelAktif1 = _buatModel(versi: '2.0.0', isDeleted: false);
          final modelAktif2 = _buatModel(versi: '2.0.1', isDeleted: false);
          final modelDihapus = _buatModel(versi: '2.0.2', isDeleted: true);
          await sisipkanDataManual(modelAktif1);
          await sisipkanDataManual(modelAktif2);
          await sisipkanDataManual(modelDihapus);

          final hasil = await operasi.ambilSemuaVersiApkAktif();

          expect(hasil.length, 2);
          expect(hasil.any((m) => m.id == modelAktif1.id), isTrue);
          expect(hasil.any((m) => m.id == modelAktif2.id), isTrue);
        },
      );

      test(
        'ambilVersiApkTerbaru harus mengembalikan versi terbaru yang aktif',
        () async {
          final modelLama = _buatModel(
            versi: '3.0.0',
            diperbarui: DateTime(2023),
          );
          final modelBaru = _buatModel(
            versi: '3.0.1',
            diperbarui: DateTime(2024),
          );
          final modelDihapus = _buatModel(
            versi: '3.0.2',
            diperbarui: DateTime(2025),
            isDeleted: true,
          );
          await sisipkanDataManual(modelLama);
          await sisipkanDataManual(modelBaru);
          await sisipkanDataManual(modelDihapus);

          final hasil = await operasi.ambilVersiApkTerbaru();

          expect(hasil, isNotNull);
          expect(hasil!.id, modelBaru.id);
        },
      );

      test('ambilVersiApkById harus mengembalikan model yang benar', () async {
        final model = _buatModel(id: 'cari-id', versi: '4.0.0');
        await sisipkanDataManual(model);

        final hasil = await operasi.ambilVersiApkById('cari-id');

        expect(hasil, isNotNull);
        expect(hasil!.id, 'cari-id');
      });
    });
  });
}
