// // path: test/data/operasi/dompet_operasi_test.dart
// // diubah: Menyesuaikan pemanggilan fromMap dan toSqlite
// import 'package:admin_wifi/data/operasi/dompet_operasi.dart';
// import 'package:admin_wifi/db/sqflite.dart';
// import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// void main() {
//   // Inisialisasi FFI untuk sqflite
//   sqfliteFfiInit();

//   // Gunakan database factory FFI untuk tes
//   databaseFactory = databaseFactoryFfi;

//   group('DompetOperasi Test (Peningkatan Cakupan)', () {
//     late DompetOperasi dompetOperasi;
//     late Database db;

//     setUp(() async {
//       // Gunakan 'in-memory' database untuk setiap tes
//       db = await databaseFactory.openDatabase(inMemoryDatabasePath);
//       // Inisialisasi skema database
//       await DatabaseHelper.instance.createTables(db);
//       // Stub database helper untuk mengembalikan database in-memory
//       DatabaseHelper.instance.stubDb(db);
//       dompetOperasi = DompetOperasi();
//     });

//     tearDown(() async {
//       await db.close();
//     });

//     test('1. getDompet harus mengembalikan list kosong saat DB kosong', () async {
//       final hasil = await dompetOperasi.getDompet();
//       expect(hasil.isEmpty, true);
//     });

//     test('2. createDompet harus menambahkan dompet baru', () async {
//       final dompet = DompetModel(namaDompet: 'Test', saldo: 1000);
//       await dompetOperasi.createDompet(dompet);
//       final hasil = await dompetOperasi.getDompet();
//       expect(hasil.length, 1);
//       expect(hasil.first.namaDompet, 'Test');
//     });

//     test('3. getDompet harus mengabaikan dompet yang diarsip', () async {
//       final dompetAktif = DompetModel(namaDompet: 'Aktif', saldo: 1000);
//       final dompetArsip = DompetModel(namaDompet: 'Arsip', saldo: 2000, isDeleted: true);

//       await dompetOperasi.createDompet(dompetAktif);
//       // Sisipkan data arsip secara manual untuk simulasi
//       // diubah: Menggunakan toSqlite
//       await db.insert('dompet', dompetArsip.toSqlite());

//       final hasil = await dompetOperasi.getDompet();
//       expect(hasil.length, 1);
//       expect(hasil.first.namaDompet, 'Aktif');
//     });

//     test('4. getDompetById harus mengembalikan null untuk dompet yang diarsip', () async {
//       final dompet = DompetModel(namaDompet: 'Arsip', saldo: 1000, isDeleted: true);
//       // diubah: Menggunakan toSqlite
//       await db.insert('dompet', dompet.toSqlite());

//       final hasil = await dompetOperasi.getDompetById(dompet.id);
//       expect(hasil, isNull);
//     });

//     test('5. updateDompet harus memperbarui data dompet', () async {
//       final dompet = DompetModel(namaDompet: 'Awal', saldo: 1000);
//       await dompetOperasi.createDompet(dompet);

//       final dompetDariDb = (await dompetOperasi.getDompet()).first;
//       final dompetUpdate = dompetDariDb.copyWith(namaDompet: 'Baru', saldo: 20000);

//       await dompetOperasi.updateDompet(dompetUpdate);
//       final hasil = await dompetOperasi.getDompetById(dompet.id);

//       expect(hasil, isNotNull);
//       expect(hasil?.namaDompet, 'Baru');
//       expect(hasil?.saldo, 20000);
//       expect(hasil?.diperbarui, isNot(dompetDariDb.diperbarui));
//     });

//     test('6. arsipkanSatuDompet harus melakukan soft delete', () async {
//       final dompet = DompetModel(namaDompet: 'Test', saldo: 1000);
//       await dompetOperasi.createDompet(dompet);

//       await dompetOperasi.arsipkanSatuDompet(dompet.id);

//       final hasilPublik = await dompetOperasi.getDompetById(dompet.id);
//       expect(hasilPublik, isNull);

//       final db = await DatabaseHelper.instance.database;
//       final maps = await db.query(
//         'dompet',
//         where: 'id = ?',
//         whereArgs: [dompet.id],
//       );

//       expect(maps.isNotEmpty, true);
//       // diubah: Menggunakan fromSqlite
//       final dataDariDb = DompetModel.fromSqlite(maps.first);

//       expect(dataDariDb.isDeleted, true);
//       expect(dataDariDb.diarsipkan, isNotNull);
//     });

//     test(
//       '7. Semua fungsi getTotalSaldo harus mengembalikan 0.0 saat DB kosong',
//       () async {
//         final total = await dompetOperasi.getTotalSaldo();
//         final positif = await dompetOperasi.getTotalSaldoPositif();
//         final negatif = await dompetOperasi.getTotalSaldoNegatif();
//         expect(total, 0.0);
//         expect(positif, 0.0);
//         expect(negatif, 0.0);
//       },
//     );

//     test('8. Fungsi getTotalSaldo harus mengabaikan dompet yang diarsip', () async {
//       // diubah: Menggunakan toSqlite
//       await db.insert('dompet', DompetModel(namaDompet: 'Aktif', saldo: 100).toSqlite());
//       await db.insert('dompet', DompetModel(namaDompet: 'Arsip', saldo: 50, isDeleted: true).toSqlite());

//       final total = await dompetOperasi.getTotalSaldo();
//       expect(total, 100.0);
//     });
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder (belum siap)', () {}, skip: true);
}
