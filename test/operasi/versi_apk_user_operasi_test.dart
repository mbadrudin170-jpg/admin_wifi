// path: test/operasi/versi_apk_user_operasi_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:admin_wifi/data/operasi/versi_apk_user_operasi.dart';
import 'package:admin_wifi/model/versi_apk_user_model.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:uuid/uuid.dart';

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
  bool isDeleted = false,
  DateTime? diperbarui,
}) {
  return VersiApkUserModel(
    id: id ?? Uuid().v4(),
    versiTerbaru: versi,
    catatanRilis: 'Catatan rilis untuk $versi',
    nomorBuildTerbaru: {'universal': 1},
    tautanUnduhan: {'universal': 'http://example.com/$versi.apk'},
    youtubeTutorial: 'http://youtube.com/watch?v=$versi',
    wajibUpdate: false,
    diperbarui: diperbarui ?? DateTime.now(),
    isDeleted: isDeleted,
    diarsipkan: isDeleted ? DateTime.now() : null,
  );
}

void main() {
  late Database db;
  late VersiApkUserOperasi operasi;

  setUpAll(() async {
    db = await _initTestDatabase();
    DatabaseHelper.instance.database = Future.value(db);
    operasi = VersiApkUserOperasi();
  });

  setUp(() async {
    await db.delete('versi_apk_user');
  });

  tearDownAll(() async {
    await db.close();
  });

  group('VersiApkUserOperasi Tests', () {
    group('Saat Database Kosong', () {
      // diubah: Tes disesuaikan karena `ambilVersiApkUser` tidak ada.
      // Cukup tes bahwa `ambilSemuaVersiApkAktif` mengembalikan list kosong.
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
    });

    group('Operasi CRUD Dasar', () {
      test('tambahVersiApkUser harus berhasil menyimpan data baru', () async {
        final modelBaru = _buatModel(versi: '1.0.1');
        await operasi.tambahVersiApkUser(modelBaru);

        // diubah: verifikasi dengan ambilVersiApkById untuk kepastian
        final hasil = await operasi.ambilVersiApkById(modelBaru.id);
        expect(hasil, isNotNull);
        expect(hasil!.id, modelBaru.id);
        expect(hasil.versiTerbaru, '1.0.1');
      });

      test('perbaruiVersiApkUser harus berhasil mengubah data', () async {
        final modelAwal = _buatModel(versi: '2.0.0');
        await operasi.tambahVersiApkUser(modelAwal);

        final modelUpdate = modelAwal.copyWith(
          catatanRilis: 'Catatan Rilis Diperbarui',
        );
        await operasi.perbaruiVersiApkUser(modelUpdate);

        // diubah: verifikasi dengan ambilVersiApkById untuk kepastian
        final hasil = await operasi.ambilVersiApkById(modelAwal.id);
        expect(hasil, isNotNull);
        expect(hasil!.id, modelAwal.id);
        expect(hasil.catatanRilis, 'Catatan Rilis Diperbarui');
      });

      test('arsipkanVersiApkUser harus melakukan soft delete', () async {
        final model = _buatModel(versi: '3.0.0');
        await operasi.tambahVersiApkUser(model);
        await operasi.arsipkanVersiApkUser(model.id);

        // Verifikasi langsung ke DB
        final hasilDb = await db.query(
          'versi_apk_user',
          where: 'id = ?',
          whereArgs: [model.id],
        );
        expect(hasilDb.first['isDeleted'], 1);
        expect(hasilDb.first['diarsipkan'], isNotNull);

        // Verifikasi bahwa data tidak muncul di pengambilan data aktif
        final hasilAmbil = await operasi.ambilVersiApkById(model.id);
        expect(hasilAmbil, isNull);

        // Verifikasi bahwa data masih ada jika `termasukDihapus` true
        final hasilAmbilDihapus = await operasi.ambilVersiApkById(
          model.id,
          termasukDihapus: true,
        );
        expect(hasilAmbilDihapus, isNotNull);
      });
    });

    group('Fungsi Pengambilan (Fetch)', () {
      setUp(() async {
        await operasi.tambahVersiApkUser(
          _buatModel(versi: '1.0.0', diperbarui: DateTime(2023, 1, 1)),
        ); // aktif
        await operasi.tambahVersiApkUser(
          _buatModel(versi: '2.0.0', diperbarui: DateTime(2023, 1, 3)),
        ); // aktif, terbaru
        final modelDiarsip = _buatModel(
          versi: '0.9.0',
          diperbarui: DateTime(2023, 1, 2),
        );
        await operasi.tambahVersiApkUser(modelDiarsip);
        await operasi.arsipkanVersiApkUser(modelDiarsip.id);
      });

      test(
        'ambilSemuaVersiApkAktif hanya mengembalikan data yang tidak diarsip',
        () async {
          final hasil = await operasi.ambilSemuaVersiApkAktif();
          expect(hasil.length, 2);
          expect(hasil.every((item) => !item.isDeleted), isTrue);
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
        'ambilSemuaVersiApkAktif harus mengembalikan data terurut dari yang terbaru',
        () async {
          final hasil = await operasi.ambilSemuaVersiApkAktif();
          expect(hasil.first.versiTerbaru, '2.0.0');
          expect(hasil.last.versiTerbaru, '1.0.0');
        },
      );
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
