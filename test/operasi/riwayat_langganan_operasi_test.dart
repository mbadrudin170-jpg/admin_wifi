// path: test/operasi/riwayat_langganan_operasi_test.dart
// diubah: Disesuaikan dengan RiwayatLanggananModel terbaru
// ditambah: Inisialisasi binding untuk pengujian
import 'package:admin_wifi/data/operasi/riwayat_langganan_operasi.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/enum/status_pembayaran.dart';
import 'package:admin_wifi/model/riwayat_langganan_model.dart';
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

  group('RiwayatLanggananOperasi Tests', () {
    late RiwayatLanggananOperasi operasi;
    late Database db;
    final uuid = const Uuid();

    setUp(() async {
      db = await DatabaseHelper.instance.database;
      await db.delete('riwayat_langganan');
      operasi = RiwayatLanggananOperasi();
    });

    RiwayatLanggananModel buatModel({String? id, DateTime? tanggalBerakhir}) {
      return RiwayatLanggananModel(
        id: id ?? uuid.v4(),
        idPelanggan: 'pelanggan-123',
        idPaket: 'paket-abc',
        namaPaket: 'Paket Super',
        hargaPaket: 150000,
        durasiPaket: 1,
        tipeDurasiPaket: 'bulan',
        tanggalMulai: DateTime(2023, 1, 1),
        tanggalBerakhir: tanggalBerakhir ?? DateTime(2023, 2, 1),
        status: StatusPembayaran.lunas,
        diperbarui: DateTime.now(),
        diarsipkan: null,
      );
    }

    test('1. tambahRiwayatLangganan harus berhasil menyimpan data', () async {
      final model = buatModel();
      await operasi.tambahRiwayatLangganan(model);

      final hasil = await operasi.ambilSemuaRiwayat();
      expect(hasil.length, 1);
      expect(hasil.first.id, model.id);
      expect(hasil.first.namaPaket, 'Paket Super');
    });

    test('2. updateRiwayat harus memperbarui data yang ada', () async {
      final modelAwal = buatModel();
      await operasi.tambahRiwayatLangganan(modelAwal);

      final modelUpdate = modelAwal.copyWith(namaPaket: 'Paket Ganti Nama', hargaPaket: 200000);
      await operasi.updateRiwayat(modelUpdate);

      final hasilDb = await db.query('riwayat_langganan', where: 'id = ?', whereArgs: [modelAwal.id]);
      final dariDb = RiwayatLanggananModel.fromMap(hasilDb.first);

      expect(dariDb.namaPaket, 'Paket Ganti Nama');
      expect(dariDb.hargaPaket, 200000);
    });

    test('3. ambilSemuaRiwayat harus mengembalikan semua data', () async {
      await operasi.tambahRiwayatLangganan(buatModel(id: '1'));
      await operasi.tambahRiwayatLangganan(buatModel(id: '2'));

      final hasil = await operasi.ambilSemuaRiwayat();
      expect(hasil.length, 2);
    });

    test('4. hapusRiwayat harus menghapus data berdasarkan ID', () async {
      final model = buatModel();
      await operasi.tambahRiwayatLangganan(model);

      await operasi.hapusRiwayat(model.id);

      final hasil = await operasi.ambilSemuaRiwayat();
      expect(hasil.isEmpty, isTrue);
    });

    test('5. hapusSemuaRiwayat harus mengosongkan tabel', () async {
      await operasi.tambahRiwayatLangganan(buatModel(id: '1'));
      await operasi.tambahRiwayatLangganan(buatModel(id: '2'));

      await operasi.hapusSemuaRiwayat();

      final hasil = await operasi.ambilSemuaRiwayat();
      expect(hasil.isEmpty, isTrue);
    });

    test('6. getPerubahan harus mengembalikan data setelah timestamp tertentu', () async {
      final waktuAmbil = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 20));

      final modelBaru = buatModel(id: 'baru');
      await operasi.tambahRiwayatLangganan(modelBaru);

      final perubahan = await operasi.getPerubahan(waktuAmbil);

      expect(perubahan.length, 1);
      expect(perubahan.first.id, 'baru');
    });

    test('7. sisipkanAtauPerbaruiBatch harus melakukan upsert data', () async {
      final modelAwal = buatModel(id: 'id-tetap');
      await operasi.tambahRiwayatLangganan(modelAwal);

      final batch = [
        modelAwal.copyWith(namaPaket: 'Paket Updated'), // Update
        buatModel(id: 'id-baru'), // Insert
      ];

      await operasi.sisipkanAtauPerbaruiBatch(batch);
      final hasil = await operasi.ambilSemuaRiwayat();
      expect(hasil.length, 2);

      final updatedItem = hasil.firstWhere((r) => r.id == 'id-tetap');
      expect(updatedItem.namaPaket, 'Paket Updated');

      final newItem = hasil.firstWhere((r) => r.id == 'id-baru');
      expect(newItem, isNotNull);
    });
  });
}
