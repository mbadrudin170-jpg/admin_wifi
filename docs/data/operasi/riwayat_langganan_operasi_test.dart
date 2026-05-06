 // path: test/data/operasi/riwayat_langganan_operasi_test.dart
// diperbaiki: Menggunakan DatabaseHelper langsung dan tipe data boolean yang benar.

import 'package:admin_wifi/data/operasi/riwayat_langganan_operasi.dart';
import 'package:admin_wifi/data/sqlite.dart';
import 'package:admin_wifi/model/enum/status_pembayaran.dart';
import 'package:admin_wifi/model/riwayat_langganan_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

void main() {
  late RiwayatLanggananOperasi operasi;
  late Database db;
  final uuid = const Uuid();

  // Inisialisasi FFI untuk sqflite
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Biarkan DatabaseHelper membuat db in-memory
    db = await DatabaseHelper.instance.database;
    operasi = RiwayatLanggananOperasi();
    
    // Bersihkan data sebelum setiap tes
    await db.delete('riwayat_langganan');
  });

  RiwayatLanggananModel buatModel({String? id, bool isDeleted = false}) {
    return RiwayatLanggananModel(
      id: id ?? uuid.v4(),
      idPelanggan: 'pelanggan-123',
      idPaket: 'paket-abc',
      namaPaket: 'Paket Super',
      hargaPaket: 150000,
      durasiPaket: 1,
      tipeDurasiPaket: 'bulan',
      tanggalMulai: DateTime(2023, 1, 1),
      tanggalBerakhir: DateTime(2023, 2, 1),
      status: StatusPembayaran.lunas,
      diperbarui: DateTime.now(),
      diarsipkan: isDeleted ? DateTime.now() : null,
      // diperbaiki: Menggunakan boolean, bukan integer
      isDeleted: isDeleted,
    );
  }

  group('RiwayatLanggananOperasi Tests', () {
    test('1. tambahRiwayatLangganan harus berhasil menyimpan data', () async {
      final model = buatModel();
      await operasi.tambahRiwayatLangganan(model);

      final hasil = await operasi.ambilSemuaRiwayat();
      expect(hasil.length, 1);
      expect(hasil.first.id, model.id);
    });

    test('2. arsipkanRiwayatLangganan (soft delete) harus berhasil', () async {
      final model = buatModel();
      await operasi.tambahRiwayatLangganan(model);

      await operasi.arsipkanRiwayatLangganan(model.id);

      final hasilAktif = await operasi.ambilSemuaRiwayatAktif();
      expect(hasilAktif.isEmpty, isTrue);

      final hasilSemua = await operasi.ambilSemuaRiwayat();
      expect(hasilSemua.length, 1);
      
      final dataArsip = hasilSemua.first;
      expect(dataArsip.isDeleted, isTrue);
      expect(dataArsip.diarsipkan, isNotNull);
    });
    
    test('3. ambilSemuaRiwayatAktif hanya mengembalikan data yang belum diarsipkan', () async {
      await operasi.tambahRiwayatLangganan(buatModel(id: 'aktif-1'));
      final modelUntukArsip = buatModel(id: 'arsip-1');
      await operasi.tambahRiwayatLangganan(modelUntukArsip);
      
      await operasi.arsipkanRiwayatLangganan(modelUntukArsip.id);

      final hasil = await operasi.ambilSemuaRiwayatAktif();
      expect(hasil.length, 1);
      expect(hasil.first.id, 'aktif-1');
    });

    test('4. hapusPermanenRiwayat harus menghapus data dari database', () async {
      final model = buatModel();
      await operasi.tambahRiwayatLangganan(model);

      await operasi.hapusPermanenRiwayat(model.id);

      final hasil = await operasi.ambilSemuaRiwayat();
      expect(hasil.isEmpty, isTrue);
    });

    // ... tes lainnya bisa ditambahkan di sini ...
  });
}
