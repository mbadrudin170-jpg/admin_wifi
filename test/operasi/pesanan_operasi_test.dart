// path: test/operasi/pesanan_operasi_test.dart
// diubah: Disesuaikan dengan PesananModel terbaru (tanpa namaPelanggan, harga)
// ditambah: Inisialisasi binding untuk pengujian
import 'package:admin_wifi/data/operasi/pesanan_operasi.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/pesanan_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

void main() {
  // ditambah: Inisialisasi binding untuk pengujian
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('PesananOperasi Tests', () {
    late PesananOperasi operasi;
    late Database db;
    final uuid = const Uuid();

    setUp(() async {
      db = await DatabaseHelper.instance.database;
      await db.delete('pesanan');
      operasi = PesananOperasi();
    });

    PesananModel buatModel(String idPelanggan, String status, {String? id, DateTime? tanggal}) {
      return PesananModel(
        id: id ?? uuid.v4(),
        idPelanggan: idPelanggan,
        idPaket: 'paket-test',
        status: status,
        tanggal: tanggal ?? DateTime.now(),
      );
    }

    test('1. simpanPesanan harus berhasil menyimpan data', () async {
      final model = buatModel('pelanggan-A', 'baru');
      await operasi.simpanPesanan(model);

      final hasil = await operasi.ambilSemuaPesanan();
      expect(hasil.length, 1);
      expect(hasil.first.id, model.id);
      expect(hasil.first.idPelanggan, 'pelanggan-A');
    });

    test('2. ambilSemuaPesanan harus mengembalikan data terurut tanggal DESC', () async {
      final modelLama = buatModel('pelanggan-Lama', 'baru', tanggal: DateTime.now().subtract(const Duration(days: 1)));
      final modelBaru = buatModel('pelanggan-Baru', 'baru');

      await operasi.simpanPesanan(modelLama);
      await operasi.simpanPesanan(modelBaru);

      final hasil = await operasi.ambilSemuaPesanan();
      expect(hasil.length, 2);
      expect(hasil.first.idPelanggan, 'pelanggan-Baru'); // Data terbaru harus di atas
      expect(hasil.last.idPelanggan, 'pelanggan-Lama');
    });

    test('3. ambilPesananByStatus harus memfilter data dengan benar', () async {
      await operasi.simpanPesanan(buatModel('A', 'baru'));
      await operasi.simpanPesanan(buatModel('B', 'diproses'));
      await operasi.simpanPesanan(buatModel('C', 'selesai'));
      await operasi.simpanPesanan(buatModel('D', 'diproses'));

      final hasil = await operasi.ambilPesananByStatus('diproses');
      expect(hasil.length, 2);
      expect(hasil.every((p) => p.status == 'diproses'), isTrue);
    });

    test('4. updateStatusPesanan harus mengubah status pesanan', () async {
      final model = buatModel('pelanggan-Update', 'baru');
      await operasi.simpanPesanan(model);

      await operasi.updateStatusPesanan(model.id, 'selesai');

      final hasilDb = await db.query('pesanan', where: 'id = ?', whereArgs: [model.id]);
      final pesananDariDb = PesananModel.fromMap(hasilDb.first);

      expect(pesananDariDb.status, 'selesai');
    });

    test('5. hapusPesanan harus menghapus data dari database', () async {
      final model = buatModel('Akan Dihapus', 'baru');
      await operasi.simpanPesanan(model);

      await operasi.hapusPesanan(model.id);

      final hasil = await operasi.ambilSemuaPesanan();
      expect(hasil.isEmpty, isTrue);
    });

    test('6. sisipkanAtauPerbaruiBatch harus melakukan upsert dengan benar', () async {
      final modelAwal = buatModel('pelanggan-Lama', 'selesai', id: 'id-tetap');
      await operasi.simpanPesanan(modelAwal);

      final batch = [
        modelAwal.copyWith(status: 'diupdate'), // Update
        buatModel('pelanggan-Batch', 'baru', id: 'id-baru'), // Insert
      ];

      await operasi.sisipkanAtauPerbaruiBatch(batch);
      final hasil = await operasi.ambilSemuaPesanan();
      expect(hasil.length, 2);

      final updatedItem = hasil.firstWhere((p) => p.id == 'id-tetap');
      expect(updatedItem.status, 'diupdate');

      final newItem = hasil.firstWhere((p) => p.id == 'id-baru');
      expect(newItem, isNotNull);
    });
  });
}
