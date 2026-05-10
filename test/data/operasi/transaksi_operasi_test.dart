// // path: test/data/operasi/transaksi_operasi_test.dart
// // diubah: Menghapus semua parameter 'nama...' dari konstruktor TransaksiModel.

// import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
// import 'package:admin_wifi/data/sqlite.dart';
// import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
// import 'package:admin_wifi/model/dompet_model.dart';
// import 'package:admin_wifi/model/transaksi_model.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:uuid/uuid.dart';

// void main() {
//   late Database db;
//   late TransaksiOperasi operasi;
//   late DompetModel dompetA;
//   late DompetModel dompetB;
//   const double saldoAwal = 1000.0;
//   final uuid = const Uuid();

//   // Setup dijalankan sekali untuk semua test di grup ini
//   setUpAll(() {
//     sqfliteFfiInit();
//     databaseFactory = databaseFactoryFfi;
//   });

//   // Setup dijalankan sebelum setiap test
//   setUp(() async {
//     // Menggunakan database di memori
//     db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    
//     // Membuat skema tabel dari file sqlite.dart
//     await DatabaseHelper.instance.createTables(db);
    
//     // Menggunakan stub untuk instance database agar terisolasi
//     DatabaseHelper.instance.stubDb(db);
//     operasi = TransaksiOperasi();

//     // Membuat data dompet awal
//     dompetA = DompetModel(
//       id: 'dompet-a',
//       namaDompet: 'Dompet A',
//       saldo: saldoAwal, // Saldo awal eksplisit
//     );
//     dompetB = DompetModel(
//       id: 'dompet-b',
//       namaDompet: 'Dompet B',
//       saldo: saldoAwal, // Saldo awal eksplisit
//     );

//     // Menyisipkan dompet ke DB, tapi saldo akan dihitung ulang oleh operasi, jadi kita set manual.
//     await db.insert('dompet', {'id': dompetA.id, 'namaDompet': dompetA.namaDompet, 'saldo': 0});
//     await db.insert('dompet', {'id': dompetB.id, 'namaDompet': dompetB.namaDompet, 'saldo': 0});

//     // Menambahkan transaksi awal untuk menetapkan saldo awal yang benar melalui sistem.
//     final initialTransaksiA = TransaksiModel(
//       id: uuid.v4(),
//       keterangan: 'Saldo Awal A',
//       jumlah: saldoAwal,
//       tanggal: DateTime.now().subtract(const Duration(days: 1)),
//       tipe: TipeTransaksi.pemasukan,
//       idDompet: dompetA.id,
//       idKategori: 'init',
//     );
//     final initialTransaksiB = TransaksiModel(
//       id: uuid.v4(),
//       keterangan: 'Saldo Awal B',
//       jumlah: saldoAwal,
//       tanggal: DateTime.now().subtract(const Duration(days: 1)),
//       tipe: TipeTransaksi.pemasukan,
//       idDompet: dompetB.id,
//       idKategori: 'init',
//     );
//     await operasi.tambahTransaksi(initialTransaksiA);
//     await operasi.tambahTransaksi(initialTransaksiB);
//   });

//   // Membersihkan setelah setiap test
//   tearDown(() async {
//     await db.close();
//   });

//   // Fungsi helper untuk mengambil saldo dompet secara langsung dari DB
//   Future<double> getSaldo(String idDompet) async {
//     final map = await db.query(
//       'dompet',
//       where: 'id = ?',
//       whereArgs: [idDompet],
//     );
//     return (map.first['saldo'] as num).toDouble();
//   }

//   group('TransaksiOperasi Tests', () {
//     test('tambahTransaksi (Pemasukan) harus menambah saldo dompet', () async {
//       final transaksi = TransaksiModel(
//         id: uuid.v4(),
//         keterangan: 'Gaji',
//         jumlah: 500,
//         tanggal: DateTime.now(),
//         tipe: TipeTransaksi.pemasukan,
//         idDompet: dompetA.id,
//         idKategori: '',
//       );

//       await operasi.tambahTransaksi(transaksi);

//       final saldoAkhir = await getSaldo(dompetA.id);
//       expect(saldoAkhir, saldoAwal + 500);
//     });

//     test('tambahTransaksi (Pengeluaran) harus mengurangi saldo dompet', () async {
//       final transaksi = TransaksiModel(
//         id: uuid.v4(),
//         keterangan: 'Beli Kopi',
//         jumlah: 25,
//         tanggal: DateTime.now(),
//         tipe: TipeTransaksi.pengeluaran,
//         idDompet: dompetA.id,
//         idKategori: '',
//       );

//       await operasi.tambahTransaksi(transaksi);

//       final saldoAkhir = await getSaldo(dompetA.id);
//       expect(saldoAkhir, saldoAwal - 25);
//     });

//     test('tambahTransaksi (Transfer) harus memindahkan saldo antar dompet', () async {
//       final transaksi = TransaksiModel(
//         id: uuid.v4(),
//         keterangan: 'Bayar Utang',
//         jumlah: 150,
//         tanggal: DateTime.now(),
//         tipe: TipeTransaksi.transfer,
//         idDompet: dompetA.id,
//         idDompetTujuan: dompetB.id,
//         idKategori: '',
//       );

//       await operasi.tambahTransaksi(transaksi);

//       final saldoAkhirA = await getSaldo(dompetA.id);
//       final saldoAkhirB = await getSaldo(dompetB.id);

//       expect(saldoAkhirA, saldoAwal - 150);
//       expect(saldoAkhirB, saldoAwal + 150);
//     });

//     test('arsipkanTransaksi (Pemasukan) harus mengembalikan saldo', () async {
//       final transaksi = TransaksiModel(
//         id: uuid.v4(),
//         keterangan: 'Bonus',
//         jumlah: 200,
//         tanggal: DateTime.now(),
//         tipe: TipeTransaksi.pemasukan,
//         idDompet: dompetA.id,
//         idKategori: '',
//       );
//       await operasi.tambahTransaksi(transaksi);
//       expect(await getSaldo(dompetA.id), saldoAwal + 200);

//       await operasi.arsipkanTransaksi(transaksi.id);

//       expect(await getSaldo(dompetA.id), saldoAwal);
//     });

//     test('arsipkanTransaksi (Pengeluaran) harus mengembalikan saldo', () async {
//       final transaksi = TransaksiModel(
//         id: uuid.v4(),
//         keterangan: 'Makan Siang',
//         jumlah: 50,
//         tanggal: DateTime.now(),
//         tipe: TipeTransaksi.pengeluaran,
//         idDompet: dompetA.id,
//         idKategori: '',
//       );
//       await operasi.tambahTransaksi(transaksi);
//       expect(await getSaldo(dompetA.id), saldoAwal - 50);

//       await operasi.arsipkanTransaksi(transaksi.id);

//       expect(await getSaldo(dompetA.id), saldoAwal);
//     });

//     test('arsipkanTransaksi (Transfer) harus mengembalikan saldo kedua dompet', () async {
//       final transaksi = TransaksiModel(
//         id: uuid.v4(),
//         keterangan: 'Transfer',
//         jumlah: 100,
//         tanggal: DateTime.now(),
//         tipe: TipeTransaksi.transfer,
//         idDompet: dompetA.id,
//         idDompetTujuan: dompetB.id,
//         idKategori: '',
//       );
//       await operasi.tambahTransaksi(transaksi);
//       expect(await getSaldo(dompetA.id), saldoAwal - 100);
//       expect(await getSaldo(dompetB.id), saldoAwal + 100);

//       await operasi.arsipkanTransaksi(transaksi.id);

//       expect(await getSaldo(dompetA.id), saldoAwal);
//       expect(await getSaldo(dompetB.id), saldoAwal);
//     });

//     test('updateTransaksi (jumlah berubah) harus menyesuaikan saldo', () async {
//       final transaksiAwal = TransaksiModel(
//         id: uuid.v4(),
//         keterangan: 'Pemasukan Awal',
//         jumlah: 100,
//         tanggal: DateTime.now(),
//         tipe: TipeTransaksi.pemasukan,
//         idDompet: dompetA.id,
//         idKategori: '',
//       );
//       await operasi.tambahTransaksi(transaksiAwal);
//       expect(await getSaldo(dompetA.id), saldoAwal + 100);

//       final transaksiUpdate = transaksiAwal.copyWith(jumlah: 250);
//       await operasi.updateTransaksi(transaksiAwal.id, transaksiUpdate);

//       final saldoAkhir = await getSaldo(dompetA.id);
//       expect(saldoAkhir, saldoAwal + 250);
//     });

//     test('updateTransaksi (tipe berubah) harus menyesuaikan saldo', () async {
//       final transaksiAwal = TransaksiModel(
//         id: uuid.v4(),
//         keterangan: 'Awalnya pemasukan',
//         jumlah: 100,
//         tanggal: DateTime.now(),
//         tipe: TipeTransaksi.pemasukan,
//         idDompet: dompetA.id,
//         idKategori: '',
//       );
//       await operasi.tambahTransaksi(transaksiAwal);
//       expect(await getSaldo(dompetA.id), saldoAwal + 100);

//       final transaksiUpdate = transaksiAwal.copyWith(tipe: TipeTransaksi.pengeluaran, jumlah: 50);
//       await operasi.updateTransaksi(transaksiAwal.id, transaksiUpdate);

//       final saldoAkhir = await getSaldo(dompetA.id);
//       expect(saldoAkhir, saldoAwal - 50);
//     });

//     test('updateTransaksi (dompet berubah) harus menyesuaikan semua saldo', () async {
//        final transaksiAwal = TransaksiModel(
//         id: uuid.v4(),
//         keterangan: 'Pemasukan di A',
//         jumlah: 200,
//         tanggal: DateTime.now(),
//         tipe: TipeTransaksi.pemasukan,
//         idDompet: dompetA.id,
//         idKategori: '',
//       );
//       await operasi.tambahTransaksi(transaksiAwal);
//       expect(await getSaldo(dompetA.id), saldoAwal + 200);
//       expect(await getSaldo(dompetB.id), saldoAwal);

//       final transaksiUpdate = transaksiAwal.copyWith(idDompet: dompetB.id);
//       await operasi.updateTransaksi(transaksiAwal.id, transaksiUpdate);
      
//       expect(await getSaldo(dompetA.id), saldoAwal, reason: "Saldo dompet A seharusnya kembali ke awal");
//       expect(await getSaldo(dompetB.id), saldoAwal + 200, reason: "Saldo dompet B seharusnya bertambah");
//     });

//      test('updateTransaksi (transfer berubah) harus menyesuaikan semua saldo', () async {
//       final transaksiAwal = TransaksiModel(
//         id: uuid.v4(),
//         keterangan: 'Transfer A -> B',
//         jumlah: 150,
//         tanggal: DateTime.now(),
//         tipe: TipeTransaksi.transfer,
//         idDompet: dompetA.id,
//         idDompetTujuan: dompetB.id,
//         idKategori: '',
//       );
//       await operasi.tambahTransaksi(transaksiAwal);
//       expect(await getSaldo(dompetA.id), saldoAwal - 150);
//       expect(await getSaldo(dompetB.id), saldoAwal + 150);

//       // Ubah dari transfer menjadi pengeluaran biasa di dompet A
//       final transaksiUpdate = transaksiAwal.copyWith(tipe: TipeTransaksi.pengeluaran, jumlah: 50, idDompetTujuan: null);
//       await operasi.updateTransaksi(transaksiAwal.id, transaksiUpdate);

//       expect(await getSaldo(dompetA.id), saldoAwal - 50, reason: "Saldo dompet A seharusnya hanya berkurang 50");
//       expect(await getSaldo(dompetB.id), saldoAwal, reason: "Saldo dompet B seharusnya kembali ke awal");
//     });
//   });
// }
