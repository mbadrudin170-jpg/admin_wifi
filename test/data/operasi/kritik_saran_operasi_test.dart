// path: test/data/operasi/kritik_saran_operasi_test.dart
// diubah: Menggunakan KritikSaranNotifier alih-alih KritikSaranOperasi
import 'package:admin_wifi/fitur/kritik_saran/notifier/kritik_saran_notifier.dart';
import 'package:admin_wifi/db/sqlite/sqflite.dart';
import 'package:admin_wifi/fitur/kritik_saran/model/kritik_saran_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('KritikSaranNotifier Tests', () {
    late Database db;
    final uuid = const Uuid();

    setUp(() async {
      db = await DatabaseHelper.instance.database;
      await db.delete('kritik_saran');
    });

    KritikSaranModel buatModel({
      String? id,
      String isi = 'Ini adalah kritik dan saran.',
      String userId = 'user-test-123',
    }) {
      return KritikSaranModel(
        id: id ?? uuid.v4(),
        isi: isi,
        userId: userId,
        tanggal: DateTime.now(),
        diperbarui: DateTime.now(),
      );
    }

    test('1. createKritikSaran harus menyimpan data baru', () async {
      final model = buatModel();
      await kritikSaranNotifierGlobal.createKritikSaran(model);

      final hasil = await kritikSaranNotifierGlobal.getKritikSaran();
      expect(hasil.length, 1);
      expect(hasil.first.id, model.id);
      expect(hasil.first.isi, 'Ini adalah kritik dan saran.');
    });

    test(
      '2. getKritikSaran harus mengembalikan data terurut tanggal DESC',
      () async {
        final modelLama = buatModel(
          userId: 'user-lama',
        ).copyWith(tanggal: DateTime.now().subtract(const Duration(days: 1)));
        final modelBaru = buatModel(userId: 'user-baru');

        await kritikSaranNotifierGlobal.createKritikSaran(modelLama);
        await kritikSaranNotifierGlobal.createKritikSaran(modelBaru);

        final hasil = await kritikSaranNotifierGlobal.getKritikSaran();
        expect(hasil.length, 2);
        expect(hasil.first.userId, 'user-baru'); // Terbaru di atas
        expect(hasil.last.userId, 'user-lama');
      },
    );

    test('3. hapusKritikSaran harus menghapus data', () async {
      final model = buatModel();
      await kritikSaranNotifierGlobal.createKritikSaran(model);

      await kritikSaranNotifierGlobal.hapusKritikSaran(model.id);

      final hasil = await kritikSaranNotifierGlobal.getKritikSaran();
      expect(hasil.isEmpty, isTrue);
    });

    test('4. getPerubahan harus mengambil data setelah timestamp', () async {
      final waktuAmbil = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 20));

      final modelBaru = buatModel(userId: 'user-perubahan');
      await kritikSaranNotifierGlobal.createKritikSaran(modelBaru);

      final perubahan = await kritikSaranNotifierGlobal.getPerubahan(waktuAmbil);

      expect(perubahan.length, 1);
      expect(perubahan.first.id, modelBaru.id);
    });

    test(
      '5. sisipkanAtauPerbaruiBatch harus melakukan upsert dengan benar',
      () async {
        final modelAwal = buatModel(id: 'id-tetap');
        await kritikSaranNotifierGlobal.createKritikSaran(modelAwal);

        final batch = [
          modelAwal.copyWith(isi: 'Isi sudah diupdate'), // Update
          buatModel(id: 'id-baru'), // Insert
        ];

        await kritikSaranNotifierGlobal.sisipkanAtauPerbaruiBatch(batch);
        final hasil = await kritikSaranNotifierGlobal.getKritikSaran();
        expect(hasil.length, 2);

        final updatedItem = hasil.firstWhere((k) => k.id == 'id-tetap');
        expect(updatedItem.isi, 'Isi sudah diupdate');

        final newItem = hasil.firstWhere((k) => k.id == 'id-baru');
        expect(newItem, isNotNull);
      },
    );
  });
}
