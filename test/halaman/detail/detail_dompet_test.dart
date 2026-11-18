// path: test/halaman/detail/detail_dompet_test.dart

import 'package:admin_wifi/data/operasi/transaksi_operasi.dart';
import 'package:admin_wifi/enum/tipe_transaksi_enum.dart';
import 'package:admin_wifi/fitur/dompet/model/dompet_model.dart';
import 'package:admin_wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:admin_wifi/halaman/detail/detail_dompet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;
  late TransaksiOperasi transaksiOperasi;

  setUpAll(() async {
    // INIT SQLITE FFI (WAJIB untuk test desktop)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // buka DB in-memory
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

    transaksiOperasi = TransaksiOperasi();

    // inject db instance kalau kamu pakai dependency injection
  });

  setUp(() async {
    // reset data tiap test
    await db.execute("DELETE FROM transaksi");
    await db.execute("DELETE FROM dompet");
  });

  Future<DompetModel> buatDompet() async {
    final dompet = DompetModel(
      id: 'dompet1',
      namaDompet: 'Dompet Test',
      saldo: 0,
    );

    await db.insert('dompet', {
      'id': dompet.id,
      'nama_dompet': dompet.namaDompet,
      'saldo': dompet.saldo,
    });

    return dompet;
  }

  Future<void> buatTransaksiBeliKopi() async {
    await transaksiOperasi.tambahTransaksi(
      TransaksiModel(
        id: 'trx1',
        tanggal: DateTime.now(),
        keterangan: 'Beli Kopi',
        jumlah: 10000,
        tipe: TipeTransaksi.pengeluaran,
        idDompet: 'dompet1',
        idKategori: 'kategori1',
      ),
    );
  }

  testWidgets('DetailDompet harus tampil transaksi Beli Kopi', (
    WidgetTester tester,
  ) async {
    final dompet = await buatDompet();
    await buatTransaksiBeliKopi();

    await tester.pumpWidget(MaterialApp(home: DetailDompet(dompet: dompet)));

    // 🔥 INI KUNCI UTAMA FIX
    await tester.pump(); // render awal
    await tester.pump(const Duration(seconds: 1)); // tunggu FutureBuilder
    await tester.pumpAndSettle(); // stabilkan UI

    // DEBUG SAFETY (opsional tapi bagus)
    expect(find.text('Beli Kopi'), findsOneWidget);
  });

  testWidgets('hapus transaksi tidak crash dan UI update', (
    WidgetTester tester,
  ) async {
    final dompet = await buatDompet();
    await buatTransaksiBeliKopi();

    await tester.pumpWidget(MaterialApp(home: DetailDompet(dompet: dompet)));

    await tester.pumpAndSettle();

    // cari item
    final item = find.text('Beli Kopi');
    expect(item, findsOneWidget);

    // long press
    await tester.longPress(item);
    await tester.pumpAndSettle();

    // klik Hapus
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    // harus sudah hilang
    expect(find.text('Beli Kopi'), findsNothing);
  });
}
