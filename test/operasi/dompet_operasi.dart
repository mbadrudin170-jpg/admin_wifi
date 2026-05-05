// path: test/operasi/dompet_operasi.dart
// diubah: Menambahkan lebih banyak kasus pengujian untuk meningkatkan cakupan.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
import 'package:admin_wifi/model/dompet_model.dart';

void main() {
  late DompetOperasi dompetOperasi;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;

    // Pastikan tabel bersih sebelum setiap pengujian
    await db.delete('dompet');

    dompetOperasi = DompetOperasi();
  });

  group('DompetOperasi Test (Peningkatan Cakupan)', () {
    test('1. getDompet harus mengembalikan list kosong saat DB kosong', () async {
      final hasil = await dompetOperasi.getDompet();
      expect(hasil.isEmpty, isTrue);
    });

    test('2. createDompet harus berhasil menyisipkan data', () async {
      final dompet = DompetModel(namaDompet: 'Dompet Utama', saldo: 10000);
      await dompetOperasi.createDompet(dompet);

      final hasil = await dompetOperasi.getDompet();
      expect(hasil.length, 1);
      expect(hasil.first.namaDompet, 'Dompet Utama');
      expect(hasil.first.saldo, 10000);
      expect(hasil.first.id.isNotEmpty, true);
    });
    
    test('3. getDompet harus mengabaikan dompet yang diarsip', () async {
      final dompetAktif = DompetModel(namaDompet: 'Aktif', saldo: 100);
      final dompetArsip = DompetModel(namaDompet: 'Arsip', saldo: 200);

      await dompetOperasi.createDompet(dompetAktif);
      await dompetOperasi.createDompet(dompetArsip);
      await dompetOperasi.arsipkanSatuDompet(dompetArsip.id);

      final hasil = await dompetOperasi.getDompet();
      expect(hasil.length, 1);
      expect(hasil.first.namaDompet, 'Aktif');
    });

    test('4. getDompetById harus mengembalikan null untuk ID yang tidak ada', () async {
      final hasil = await dompetOperasi.getDompetById('id-tidak-ditemukan');
      expect(hasil, isNull);
    });

    test('5. updateDompet harus berhasil memperbarui data', () async {
      final dompet = DompetModel(id: 'id1', namaDompet: 'Lama', saldo: 5000);
      await dompetOperasi.createDompet(dompet);

      // ditambah: Memastikan timestamp diperbarui
      final dompetDariDb = await dompetOperasi.getDompetById(dompet.id);
      await Future.delayed(const Duration(milliseconds: 10));

      final updated = dompet.copyWith(namaDompet: 'Baru', saldo: 20000);
      await dompetOperasi.updateDompet(updated);

      final hasil = await dompetOperasi.getDompetById(dompet.id);
      expect(hasil?.namaDompet, 'Baru');
      expect(hasil?.saldo, 20000);
      expect(hasil?.diperbarui, isNot(dompetDariDb?.diperbarui));
    });

    test('6. arsipkanSatuDompet harus melakukan soft delete', () async {
      final dompet = DompetModel(namaDompet: 'Test', saldo: 1000);
      await dompetOperasi.createDompet(dompet);

      await dompetOperasi.arsipkanSatuDompet(dompet.id);
      final hasil = await dompetOperasi.getDompetById(dompet.id);

      expect(hasil?.isDeleted, true);
      expect(hasil?.diarsipkan, isNotNull);
    });

    test('7. Semua fungsi getTotalSaldo harus mengembalikan 0.0 saat DB kosong', () async {
        final total = await dompetOperasi.getTotalSaldo();
        final totalPositif = await dompetOperasi.getTotalSaldoPositif();
        final totalNegatif = await dompetOperasi.getTotalSaldoNegatif();

        expect(total, 0.0);
        expect(totalPositif, 0.0);
        expect(totalNegatif, 0.0);
    });

    test('8. getTotalSaldo harus menjumlahkan semua saldo dengan benar', () async {
      await dompetOperasi.createDompet(DompetModel(namaDompet: 'A', saldo: 1000));
      await dompetOperasi.createDompet(DompetModel(namaDompet: 'B', saldo: 2000));
      await dompetOperasi.createDompet(DompetModel(namaDompet: 'C', saldo: -500));

      final total = await dompetOperasi.getTotalSaldo();
      expect(total, 2500);
    });

    test('9. getTotalSaldoPositif harus menjumlahkan hanya saldo > 0', () async {
      await dompetOperasi.createDompet(DompetModel(namaDompet: 'A', saldo: 1000));
      await dompetOperasi.createDompet(DompetModel(namaDompet: 'B', saldo: -500));
      await dompetOperasi.createDompet(DompetModel(namaDompet: 'C', saldo: 300));

      final total = await dompetOperasi.getTotalSaldoPositif();
      expect(total, 1300);
    });

    test('10. getTotalSaldoNegatif harus menjumlahkan hanya saldo < 0', () async {
      await dompetOperasi.createDompet(DompetModel(namaDompet: 'A', saldo: -1000));
      await dompetOperasi.createDompet(DompetModel(namaDompet: 'B', saldo: 500));
      await dompetOperasi.createDompet(DompetModel(namaDompet: 'C', saldo: -250));
      
      final total = await dompetOperasi.getTotalSaldoNegatif();
      expect(total, -1250);
    });

    test('11. hapusSemuaDompet harus mengosongkan tabel', () async {
      await dompetOperasi.createDompet(DompetModel(namaDompet: 'Test', saldo: 1000));
      await dompetOperasi.hapusSemuaDompet();

      final hasil = await dompetOperasi.getDompet();
      expect(hasil.isEmpty, true);
    });

    test('12. sisipkanAtauPerbaruiBatch harus menyisipkan dan memperbarui data', () async {
      // Data awal yang akan diperbarui
      final dompetAwal = DompetModel(id: '1', namaDompet: 'Awal', saldo: 100);
      await dompetOperasi.createDompet(dompetAwal);
      
      final batch = [
        // diubah: Skenario update
        dompetAwal.copyWith(namaDompet: 'Diperbarui', saldo: 500), 
        // ditambah: Skenario insert
        DompetModel(id: '2', namaDompet: 'Baru', saldo: 200),
      ];

      await dompetOperasi.sisipkanAtauPerbaruiBatch(batch);
      final hasil = await dompetOperasi.getDompet();

      expect(hasil.length, 2);

      final dompetDiperbarui = hasil.firstWhere((d) => d.id == '1');
      expect(dompetDiperbarui.namaDompet, 'Diperbarui');
      expect(dompetDiperbarui.saldo, 500);

      final dompetBaru = hasil.firstWhere((d) => d.id == '2');
      expect(dompetBaru.namaDompet, 'Baru');
    });
  });
}
